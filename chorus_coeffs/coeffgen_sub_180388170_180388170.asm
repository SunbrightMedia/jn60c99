; sub_180388170 @ 0x180388170 (RVA 0x388170)  size=0x10A7A

0000000180388170  48 89 5C 24 18              mov     [rsp-8+arg_10], rbx
0000000180388175  48 89 7C 24 20              mov     [rsp-8+arg_18], rdi
000000018038817A  55                          push    rbp
000000018038817B  48 8D 6C 24 A9              lea     rbp, [rsp-57h]
0000000180388180  48 81 EC F0 00 00 00        sub     rsp, 0F0h
0000000180388187  48 8B 51 48                 mov     rdx, [rcx+48h]
000000018038818B  48 B8 67 66 66 66 66 66 66 66  mov     rax, 6666666666666667h
0000000180388195  48 2B 51 38                 sub     rdx, [rcx+38h]
0000000180388199  48 8B F9                    mov     rdi, rcx
000000018038819C  48 F7 EA                    imul    rdx
000000018038819F  48 C1 FA 04                 sar     rdx, 4
00000001803881A3  48 8B C2                    mov     rax, rdx
00000001803881A6  48 C1 E8 3F                 shr     rax, 3Fh
00000001803881AA  48 03 D0                    add     rdx, rax
00000001803881AD  48 81 FA 61 04 00 00        cmp     rdx, 461h
00000001803881B4  73 2A                       jnb     short loc_1803881E0
00000001803881B6  48 B8 66 66 66 66 66 66 66 06  mov     rax, 666666666666666h
00000001803881C0  BA 61 04 00 00              mov     edx, 461h
00000001803881C5  48 89 45 67                 mov     [rbp+57h+arg_0], rax
00000001803881C9  48 83 C1 38                 add     rcx, 38h ; '8'
00000001803881CD  48 B8 FF FF FF FF FF FF FF 7F  mov     rax, 7FFFFFFFFFFFFFFFh
00000001803881D7  48 89 45 6F                 mov     [rbp+57h+arg_8], rax
00000001803881DB  E8 20 35 02 00              call    sub_1803AB700
00000001803881E0  48 8D 05 39 2D 60 00        lea     rax, aUseextjack; "UseExtJack"
00000001803881E7  C7 45 B7 00 00 00 00        mov     dword ptr [rbp+57h+var_A8+8], 0
00000001803881EE  48 89 45 AF                 mov     qword ptr [rbp+57h+var_A8], rax
00000001803881F2  0F 57 C9                    xorps   xmm1, xmm1
00000001803881F5  F3 0F 7F 4D BB              movdqu  [rbp+57h+var_A8+0Ch], xmm1
00000001803881FA  C7 45 CB 01 00 00 00        mov     [rbp+57h+var_8C], 1
0000000180388201  48 8D 87 10 01 00 00        lea     rax, [rdi+110h]
0000000180388208  48 89 45 CF                 mov     [rbp+57h+var_88], rax
000000018038820C  48 8B 57 40                 mov     rdx, [rdi+40h]
0000000180388210  48 39 57 48                 cmp     [rdi+48h], rdx
0000000180388214  74 20                       jz      short loc_180388236
0000000180388216  0F 10 45 AF                 movups  xmm0, [rbp+57h+var_A8]
000000018038821A  0F 11 02                    movups  xmmword ptr [rdx], xmm0
000000018038821D  0F 10 4D BF                 movups  xmm1, xmmword ptr [rbp-41h]
0000000180388221  0F 11 4A 10                 movups  xmmword ptr [rdx+10h], xmm1
0000000180388225  F2 0F 10 45 CF              movsd   xmm0, [rbp+57h+var_88]
000000018038822A  F2 0F 11 42 20              movsd   qword ptr [rdx+20h], xmm0
000000018038822F  48 83 47 40 28              add     qword ptr [rdi+40h], 28h ; '('
0000000180388234  EB 0D                       jmp     short loc_180388243
0000000180388236  4C 8D 45 AF                 lea     r8, [rbp+57h+var_A8]
000000018038823A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038823E  E8 3D FD FF FF              call    sub_180387F80
0000000180388243  48 8D 05 E2 2C 60 00        lea     rax, aMCv; "M.CV"
000000018038824A  C7 45 DF 00 00 00 00        mov     dword ptr [rbp+57h+var_80+8], 0
0000000180388251  48 89 45 D7                 mov     qword ptr [rbp+57h+var_80], rax
0000000180388255  0F 57 C0                    xorps   xmm0, xmm0
0000000180388258  F3 0F 7F 45 E3              movdqu  [rbp+57h+var_80+0Ch], xmm0
000000018038825D  C7 45 F3 01 00 00 00        mov     [rbp+57h+var_64], 1
0000000180388264  48 8D 87 30 01 00 00        lea     rax, [rdi+130h]
000000018038826B  48 89 45 F7                 mov     [rbp+57h+var_60], rax
000000018038826F  48 8B 57 40                 mov     rdx, [rdi+40h]
0000000180388273  48 39 57 48                 cmp     [rdi+48h], rdx
0000000180388277  74 20                       jz      short loc_180388299
0000000180388279  0F 10 45 D7                 movups  xmm0, [rbp+57h+var_80]
000000018038827D  0F 11 02                    movups  xmmword ptr [rdx], xmm0
0000000180388280  0F 10 4D E7                 movups  xmm1, xmmword ptr [rbp-19h]
0000000180388284  0F 11 4A 10                 movups  xmmword ptr [rdx+10h], xmm1
0000000180388288  F2 0F 10 45 F7              movsd   xmm0, [rbp+57h+var_60]
000000018038828D  F2 0F 11 42 20              movsd   qword ptr [rdx+20h], xmm0
0000000180388292  48 83 47 40 28              add     qword ptr [rdi+40h], 28h ; '('
0000000180388297  EB 0D                       jmp     short loc_1803882A6
0000000180388299  4C 8D 45 D7                 lea     r8, [rbp+57h+var_80]
000000018038829D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803882A1  E8 DA FC FF FF              call    sub_180387F80
00000001803882A6  48 8D 05 87 2C 60 00        lea     rax, aMGate; "M.Gate"
00000001803882AD  C7 45 07 00 00 00 00        mov     dword ptr [rbp+57h+var_58+8], 0
00000001803882B4  48 89 45 FF                 mov     qword ptr [rbp+57h+var_58], rax
00000001803882B8  0F 57 C0                    xorps   xmm0, xmm0
00000001803882BB  F3 0F 7F 45 0B              movdqu  [rbp+57h+var_58+0Ch], xmm0
00000001803882C0  C7 45 1B 01 00 00 00        mov     [rbp+57h+var_3C], 1
00000001803882C7  48 8D 87 40 01 00 00        lea     rax, [rdi+140h]
00000001803882CE  48 89 45 1F                 mov     [rbp+57h+var_38], rax
00000001803882D2  48 8B 57 40                 mov     rdx, [rdi+40h]
00000001803882D6  48 39 57 48                 cmp     [rdi+48h], rdx
00000001803882DA  74 20                       jz      short loc_1803882FC
00000001803882DC  0F 10 45 FF                 movups  xmm0, [rbp+57h+var_58]
00000001803882E0  0F 11 02                    movups  xmmword ptr [rdx], xmm0
00000001803882E3  0F 10 4D 0F                 movups  xmm1, xmmword ptr [rbp+0Fh]
00000001803882E7  0F 11 4A 10                 movups  xmmword ptr [rdx+10h], xmm1
00000001803882EB  F2 0F 10 45 1F              movsd   xmm0, [rbp+57h+var_38]
00000001803882F0  F2 0F 11 42 20              movsd   qword ptr [rdx+20h], xmm0
00000001803882F5  48 83 47 40 28              add     qword ptr [rdi+40h], 28h ; '('
00000001803882FA  EB 0D                       jmp     short loc_180388309
00000001803882FC  4C 8D 45 FF                 lea     r8, [rbp+57h+var_58]
0000000180388300  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388304  E8 77 FC FF FF              call    sub_180387F80
0000000180388309  66 0F 6F 05 1F 3D 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388311  48 8D 05 28 2C 60 00        lea     rax, aMasterTune; "Master Tune"
0000000180388318  48 89 45 27                 mov     qword ptr [rbp+57h+var_30], rax
000000018038831C  48 8D 87 70 01 00 00        lea     rax, [rdi+170h]
0000000180388323  48 89 45 47                 mov     [rbp+57h+var_10], rax
0000000180388327  C7 45 2F 00 00 00 00        mov     dword ptr [rbp+57h+var_30+8], 0
000000018038832E  F3 0F 7F 45 33              movdqu  [rbp+57h+var_30+0Ch], xmm0
0000000180388333  C7 45 43 01 00 00 00        mov     [rbp+57h+var_14], 1
000000018038833A  48 8B 57 40                 mov     rdx, [rdi+40h]
000000018038833E  48 39 57 48                 cmp     [rdi+48h], rdx
0000000180388342  74 20                       jz      short loc_180388364
0000000180388344  0F 10 45 27                 movups  xmm0, [rbp+57h+var_30]
0000000180388348  0F 11 02                    movups  xmmword ptr [rdx], xmm0
000000018038834B  0F 10 4D 37                 movups  xmm1, xmmword ptr [rbp+37h]
000000018038834F  0F 11 4A 10                 movups  xmmword ptr [rdx+10h], xmm1
0000000180388353  F2 0F 10 45 47              movsd   xmm0, [rbp+57h+var_10]
0000000180388358  F2 0F 11 42 20              movsd   qword ptr [rdx+20h], xmm0
000000018038835D  48 83 47 40 28              add     qword ptr [rdi+40h], 28h ; '('
0000000180388362  EB 0D                       jmp     short loc_180388371
0000000180388364  4C 8D 45 27                 lea     r8, [rbp+57h+var_30]
0000000180388368  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038836C  E8 0F FC FF FF              call    sub_180387F80
0000000180388371  66 0F 6F 05 B7 3C 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388379  48 8D 05 D0 2B 60 00        lea     rax, aPartTune; "Part Tune"
0000000180388380  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388384  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388388  48 8D 87 80 01 00 00        lea     rax, [rdi+180h]
000000018038838F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388396  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038839A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038839E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803883A3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803883AA  E8 51 36 02 00              call    sub_1803ABA00
00000001803883AF  48 8D 05 AA 2B 60 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
00000001803883B6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803883BD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803883C1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803883C5  48 8D 87 50 02 00 00        lea     rax, [rdi+250h]
00000001803883CC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803883D3  0F 57 C0                    xorps   xmm0, xmm0
00000001803883D6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803883DA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803883DE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803883E3  E8 18 36 02 00              call    sub_1803ABA00
00000001803883E8  48 8D 05 89 2B 60 00        lea     rax, aPortamentoMode; "Portamento Mode"
00000001803883EF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803883F6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803883FA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803883FE  48 8D 87 60 02 00 00        lea     rax, [rdi+260h]
0000000180388405  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038840C  0F 57 C0                    xorps   xmm0, xmm0
000000018038840F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388413  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388417  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038841C  E8 DF 35 02 00              call    sub_1803ABA00
0000000180388421  66 0F 6F 05 07 3C 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388429  48 8D 05 58 2B 60 00        lea     rax, aPortamentoTime; "Portamento Time"
0000000180388430  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388434  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388438  48 8D 87 70 02 00 00        lea     rax, [rdi+270h]
000000018038843F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388446  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038844A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038844E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388453  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038845A  E8 A1 35 02 00              call    sub_1803ABA00
000000018038845F  48 8D 05 32 2B 60 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
0000000180388466  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038846D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388471  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388475  48 8D 87 10 04 00 00        lea     rax, [rdi+410h]
000000018038847C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388483  0F 57 C0                    xorps   xmm0, xmm0
0000000180388486  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038848A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038848E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388493  E8 68 35 02 00              call    sub_1803ABA00
0000000180388498  48 8D 05 11 2B 60 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
000000018038849F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803884A6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803884AA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803884AE  48 8D 87 20 04 00 00        lea     rax, [rdi+420h]
00000001803884B5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803884BC  0F 57 C0                    xorps   xmm0, xmm0
00000001803884BF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803884C3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803884C7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803884CC  E8 2F 35 02 00              call    sub_1803ABA00
00000001803884D1  48 8D 05 F0 2A 60 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
00000001803884D8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803884DF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803884E3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803884E7  48 8D 87 30 04 00 00        lea     rax, [rdi+430h]
00000001803884EE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803884F5  0F 57 C0                    xorps   xmm0, xmm0
00000001803884F8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803884FC  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388500  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388505  E8 F6 34 02 00              call    sub_1803ABA00
000000018038850A  66 0F 6F 05 1E 3B 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388512  48 8D 05 BF 2A 60 00        lea     rax, aLfoRate; "LFO Rate"
0000000180388519  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038851D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388524  48 8D 87 40 04 00 00        lea     rax, [rdi+440h]
000000018038852B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388532  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388536  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038853A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038853E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388543  E8 B8 34 02 00              call    sub_1803ABA00
0000000180388548  48 8D 05 95 2A 60 00        lea     rax, aGate; "Gate"
000000018038854F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388556  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038855A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038855E  48 8D 87 40 07 00 00        lea     rax, [rdi+740h]
0000000180388565  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038856C  0F 57 C0                    xorps   xmm0, xmm0
000000018038856F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388573  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388577  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038857C  E8 7F 34 02 00              call    sub_1803ABA00
0000000180388581  48 8D 05 68 2A 60 00        lea     rax, aLfoTrig; "LFO Trig"
0000000180388588  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038858F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388593  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388597  48 8D 87 50 07 00 00        lea     rax, [rdi+750h]
000000018038859E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803885A5  0F 57 C0                    xorps   xmm0, xmm0
00000001803885A8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803885AC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803885B0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803885B5  E8 46 34 02 00              call    sub_1803ABA00
00000001803885BA  48 8D 05 3F 2A 60 00        lea     rax, aResetSw; "Reset Sw"
00000001803885C1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803885C8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803885CC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803885D0  48 8D 87 60 07 00 00        lea     rax, [rdi+760h]
00000001803885D7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803885DE  0F 57 C0                    xorps   xmm0, xmm0
00000001803885E1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803885E5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803885E9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803885EE  E8 0D 34 02 00              call    sub_1803ABA00
00000001803885F3  66 0F 6F 05 35 3A 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803885FB  48 8D 05 0E 2A 60 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
0000000180388602  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388606  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038860A  48 8D 87 70 07 00 00        lea     rax, [rdi+770h]
0000000180388611  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388618  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038861C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388620  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388625  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038862C  E8 CF 33 02 00              call    sub_1803ABA00
0000000180388631  66 0F 6F 05 F7 39 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388639  48 8D 05 E0 29 60 00        lea     rax, aLfoDelay; "LFO Delay"
0000000180388640  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388644  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388648  48 8D 87 80 07 00 00        lea     rax, [rdi+780h]
000000018038864F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388656  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038865A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038865E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388663  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038866A  E8 91 33 02 00              call    sub_1803ABA00
000000018038866F  66 0F 6F 05 B9 39 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388677  48 8D 05 B2 29 60 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
000000018038867E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388682  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388686  48 8D 87 90 07 00 00        lea     rax, [rdi+790h]
000000018038868D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388694  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388698  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038869C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803886A1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803886A8  E8 53 33 02 00              call    sub_1803ABA00
00000001803886AD  66 0F 6F 05 7B 39 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803886B5  48 8D 05 84 29 60 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
00000001803886BC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803886C0  48 8D 87 A0 07 00 00        lea     rax, [rdi+7A0h]
00000001803886C7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803886CB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803886D2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803886D7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803886DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803886E2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803886E6  E8 15 33 02 00              call    sub_1803ABA00
00000001803886EB  66 0F 6F 05 3D 39 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803886F3  48 8D 05 56 29 60 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
00000001803886FA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803886FE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388702  48 8D 87 B0 07 00 00        lea     rax, [rdi+7B0h]
0000000180388709  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388710  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388714  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388718  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038871D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388724  E8 D7 32 02 00              call    sub_1803ABA00
0000000180388729  66 0F 6F 05 FF 38 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388731  48 8D 05 28 29 60 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
0000000180388738  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038873C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388740  48 8D 87 C0 07 00 00        lea     rax, [rdi+7C0h]
0000000180388747  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038874E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388752  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388756  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038875B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388762  E8 99 32 02 00              call    sub_1803ABA00
0000000180388767  66 0F 6F 05 C1 38 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038876F  48 8D 05 FA 28 60 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
0000000180388776  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038877A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038877E  48 8D 87 D0 07 00 00        lea     rax, [rdi+7D0h]
0000000180388785  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038878C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388790  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388794  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388799  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803887A0  E8 5B 32 02 00              call    sub_1803ABA00
00000001803887A5  66 0F 6F 05 83 38 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803887AD  48 8D 05 CC 28 60 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
00000001803887B4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803887B8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803887BC  48 8D 87 E0 07 00 00        lea     rax, [rdi+7E0h]
00000001803887C3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803887CA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803887CE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803887D2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803887D7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803887DE  E8 1D 32 02 00              call    sub_1803ABA00
00000001803887E3  66 0F 6F 05 45 38 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803887EB  48 8D 05 9E 28 60 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
00000001803887F2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803887F6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803887FA  48 8D 87 F0 07 00 00        lea     rax, [rdi+7F0h]
0000000180388801  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388808  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038880C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388810  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388815  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038881C  E8 DF 31 02 00              call    sub_1803ABA00
0000000180388821  66 0F 6F 05 07 38 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388829  48 8D 05 70 28 60 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
0000000180388830  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388834  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388838  48 8D 87 00 08 00 00        lea     rax, [rdi+800h]
000000018038883F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388846  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038884A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038884E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388853  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038885A  E8 A1 31 02 00              call    sub_1803ABA00
000000018038885F  66 0F 6F 05 C9 37 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388867  48 8D 05 42 28 60 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
000000018038886E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388872  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388876  48 8D 87 10 08 00 00        lea     rax, [rdi+810h]
000000018038887D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388884  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388888  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038888C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388891  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388898  E8 63 31 02 00              call    sub_1803ABA00
000000018038889D  48 8D 05 1C 28 60 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
00000001803888A4  66 0F 6F 05 84 37 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803888AC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803888B0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803888B4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803888B8  48 8D 87 20 08 00 00        lea     rax, [rdi+820h]
00000001803888BF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803888C6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803888CA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803888CF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803888D6  E8 25 31 02 00              call    sub_1803ABA00
00000001803888DB  66 0F 6F 05 4D 37 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803888E3  48 8D 05 E6 27 60 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
00000001803888EA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803888EE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803888F2  48 8D 87 30 08 00 00        lea     rax, [rdi+830h]
00000001803888F9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388900  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388904  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388908  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038890D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388914  E8 E7 30 02 00              call    sub_1803ABA00
0000000180388919  66 0F 6F 05 0F 37 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388921  48 8D 05 C0 27 60 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
0000000180388928  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038892C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388930  48 8D 87 40 08 00 00        lea     rax, [rdi+840h]
0000000180388937  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038893E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388942  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388946  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038894B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388952  E8 A9 30 02 00              call    sub_1803ABA00
0000000180388957  48 8D 05 A2 27 60 00        lea     rax, aReadOnly; "read only"
000000018038895E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388965  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388969  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038896D  48 8D 87 E0 09 00 00        lea     rax, [rdi+9E0h]
0000000180388974  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038897B  0F 57 C0                    xorps   xmm0, xmm0
000000018038897E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388982  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388986  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038898B  E8 70 30 02 00              call    sub_1803ABA00
0000000180388990  48 8D 05 69 27 60 00        lea     rax, aReadOnly; "read only"
0000000180388997  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038899E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803889A2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803889A6  48 8D 87 F0 09 00 00        lea     rax, [rdi+9F0h]
00000001803889AD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803889B4  0F 57 C0                    xorps   xmm0, xmm0
00000001803889B7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803889BB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803889BF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803889C4  E8 37 30 02 00              call    sub_1803ABA00
00000001803889C9  48 8D 05 40 27 60 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00000001803889D0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803889D7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803889DB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803889DF  48 8D 87 00 0A 00 00        lea     rax, [rdi+0A00h]
00000001803889E6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803889ED  0F 57 C0                    xorps   xmm0, xmm0
00000001803889F0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803889F4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803889F8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803889FD  E8 FE 2F 02 00              call    sub_1803ABA00
0000000180388A02  66 0F 6F 05 26 36 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388A0A  48 8D 05 17 27 60 00        lea     rax, aEnvAttack; "ENV Attack"
0000000180388A11  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388A15  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388A19  48 8D 87 E0 0A 00 00        lea     rax, [rdi+0AE0h]
0000000180388A20  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388A27  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388A2B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388A2F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388A34  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388A3B  E8 C0 2F 02 00              call    sub_1803ABA00
0000000180388A40  66 0F 6F 05 E8 35 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388A48  48 8D 05 E9 26 60 00        lea     rax, aEnvSustain; "ENV Sustain"
0000000180388A4F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388A53  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388A58  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388A5F  48 8D 87 F0 0A 00 00        lea     rax, [rdi+0AF0h]
0000000180388A66  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388A6D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388A71  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388A75  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388A79  E8 82 2F 02 00              call    sub_1803ABA00
0000000180388A7E  66 0F 6F 05 AA 35 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388A86  48 8D 05 BB 26 60 00        lea     rax, aEnvDecay; "ENV Decay"
0000000180388A8D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388A91  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388A95  48 8D 87 00 0B 00 00        lea     rax, [rdi+0B00h]
0000000180388A9C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388AA3  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388AA7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388AAB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388AB0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388AB7  E8 44 2F 02 00              call    sub_1803ABA00
0000000180388ABC  66 0F 6F 05 6C 35 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388AC4  48 8D 05 8D 26 60 00        lea     rax, aEnvRelease; "ENV Release"
0000000180388ACB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388ACF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388AD3  48 8D 87 10 0B 00 00        lea     rax, [rdi+0B10h]
0000000180388ADA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388AE1  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388AE5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388AE9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388AEE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388AF5  E8 06 2F 02 00              call    sub_1803ABA00
0000000180388AFA  66 0F 6F 05 2E 35 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388B02  48 8D 05 5F 26 60 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
0000000180388B09  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388B0D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388B11  48 8D 87 20 0B 00 00        lea     rax, [rdi+0B20h]
0000000180388B18  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388B1F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388B23  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388B27  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388B2C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388B33  E8 C8 2E 02 00              call    sub_1803ABA00
0000000180388B38  48 8D 05 D1 25 60 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
0000000180388B3F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388B46  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388B4A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388B4E  48 8D 87 E0 0B 00 00        lea     rax, [rdi+0BE0h]
0000000180388B55  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388B5C  0F 57 C0                    xorps   xmm0, xmm0
0000000180388B5F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388B63  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388B67  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388B6C  E8 8F 2E 02 00              call    sub_1803ABA00
0000000180388B71  66 0F 6F 05 B7 34 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388B79  48 8D 05 A8 25 60 00        lea     rax, aEnvAttack; "ENV Attack"
0000000180388B80  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388B84  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388B88  48 8D 87 C0 0C 00 00        lea     rax, [rdi+0CC0h]
0000000180388B8F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388B96  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388B9A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388B9E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388BA3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388BAA  E8 51 2E 02 00              call    sub_1803ABA00
0000000180388BAF  66 0F 6F 05 79 34 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388BB7  48 8D 05 7A 25 60 00        lea     rax, aEnvSustain; "ENV Sustain"
0000000180388BBE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388BC2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388BC6  48 8D 87 D0 0C 00 00        lea     rax, [rdi+0CD0h]
0000000180388BCD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388BD4  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388BD8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388BDC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388BE1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388BE8  E8 13 2E 02 00              call    sub_1803ABA00
0000000180388BED  66 0F 6F 05 3B 34 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388BF5  48 8D 05 4C 25 60 00        lea     rax, aEnvDecay; "ENV Decay"
0000000180388BFC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388C00  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388C04  48 8D 87 E0 0C 00 00        lea     rax, [rdi+0CE0h]
0000000180388C0B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388C12  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388C16  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388C1B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388C22  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388C26  E8 D5 2D 02 00              call    sub_1803ABA00
0000000180388C2B  66 0F 6F 05 FD 33 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388C33  48 8D 05 1E 25 60 00        lea     rax, aEnvRelease; "ENV Release"
0000000180388C3A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388C3E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388C42  48 8D 87 F0 0C 00 00        lea     rax, [rdi+0CF0h]
0000000180388C49  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388C50  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388C54  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388C58  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388C5D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388C64  E8 97 2D 02 00              call    sub_1803ABA00
0000000180388C69  66 0F 6F 05 BF 33 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388C71  48 8D 05 F0 24 60 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
0000000180388C78  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388C7C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388C80  48 8D 87 00 0D 00 00        lea     rax, [rdi+0D00h]
0000000180388C87  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388C8E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388C92  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388C96  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388C9B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388CA2  E8 59 2D 02 00              call    sub_1803ABA00
0000000180388CA7  48 8D 05 CA 24 60 00        lea     rax, aOsc1Feet; "OSC1 Feet"
0000000180388CAE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388CB5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388CB9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388CBD  48 8D 87 00 0F 00 00        lea     rax, [rdi+0F00h]
0000000180388CC4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388CCB  0F 57 C0                    xorps   xmm0, xmm0
0000000180388CCE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388CD2  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388CD6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388CDB  E8 20 2D 02 00              call    sub_1803ABA00
0000000180388CE0  48 8D 05 A1 24 60 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
0000000180388CE7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388CEE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388CF2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388CF6  48 8D 87 10 0F 00 00        lea     rax, [rdi+0F10h]
0000000180388CFD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388D04  0F 57 C0                    xorps   xmm0, xmm0
0000000180388D07  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388D0B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388D0F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388D14  E8 E7 2C 02 00              call    sub_1803ABA00
0000000180388D19  48 8D 05 78 24 60 00        lea     rax, aBendEnableSw; "Bend Enable SW"
0000000180388D20  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388D27  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388D2B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388D2F  48 8D 87 20 0F 00 00        lea     rax, [rdi+0F20h]
0000000180388D36  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388D3D  0F 57 C0                    xorps   xmm0, xmm0
0000000180388D40  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388D44  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388D48  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388D4D  E8 AE 2C 02 00              call    sub_1803ABA00
0000000180388D52  48 8D 05 4F 24 60 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
0000000180388D59  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388D60  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388D64  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388D68  48 8D 87 30 0F 00 00        lea     rax, [rdi+0F30h]
0000000180388D6F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388D76  0F 57 C0                    xorps   xmm0, xmm0
0000000180388D79  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388D7D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388D81  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388D86  E8 75 2C 02 00              call    sub_1803ABA00
0000000180388D8B  48 8D 05 26 24 60 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
0000000180388D92  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388D99  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388D9D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388DA1  48 8D 87 40 0F 00 00        lea     rax, [rdi+0F40h]
0000000180388DA8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388DAF  0F 57 C0                    xorps   xmm0, xmm0
0000000180388DB2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388DB6  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388DBA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388DBF  E8 3C 2C 02 00              call    sub_1803ABA00
0000000180388DC4  48 8D 05 FD 23 60 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
0000000180388DCB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388DCF  0F 57 C0                    xorps   xmm0, xmm0
0000000180388DD2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388DD9  48 8D 87 50 0F 00 00        lea     rax, [rdi+0F50h]
0000000180388DE0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388DE7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388DEB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388DEF  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388DF3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388DF8  E8 03 2C 02 00              call    sub_1803ABA00
0000000180388DFD  48 8D 05 D4 23 60 00        lea     rax, aPwmSwManual; "PWM SW Manual"
0000000180388E04  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388E0B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388E0F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388E13  48 8D 87 60 0F 00 00        lea     rax, [rdi+0F60h]
0000000180388E1A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388E21  0F 57 C0                    xorps   xmm0, xmm0
0000000180388E24  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388E28  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388E2C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388E31  E8 CA 2B 02 00              call    sub_1803ABA00
0000000180388E36  66 0F 6F 05 F2 31 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388E3E  48 8D 05 A3 23 60 00        lea     rax, aTune; "Tune"
0000000180388E45  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388E49  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388E4D  48 8D 87 70 0F 00 00        lea     rax, [rdi+0F70h]
0000000180388E54  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388E5B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388E5F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388E63  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388E68  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388E6F  E8 8C 2B 02 00              call    sub_1803ABA00
0000000180388E74  66 0F 6F 05 B4 31 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388E7C  48 8D 05 6D 23 60 00        lea     rax, aDetune; "Detune"
0000000180388E83  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388E87  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388E8B  48 8D 87 80 0F 00 00        lea     rax, [rdi+0F80h]
0000000180388E92  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388E99  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388E9D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388EA1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388EA6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388EAD  E8 4E 2B 02 00              call    sub_1803ABA00
0000000180388EB2  66 0F 6F 05 76 31 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388EBA  48 8D 05 37 23 60 00        lea     rax, aModSens; "Mod Sens"
0000000180388EC1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388EC5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388EC9  48 8D 87 90 0F 00 00        lea     rax, [rdi+0F90h]
0000000180388ED0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388ED7  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388EDB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388EDF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388EE4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388EEB  E8 10 2B 02 00              call    sub_1803ABA00
0000000180388EF0  66 0F 6F 05 38 31 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388EF8  48 8D 05 05 23 60 00        lea     rax, aModSw; "Mod Sw"
0000000180388EFF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388F03  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388F07  48 8D 87 A0 0F 00 00        lea     rax, [rdi+0FA0h]
0000000180388F0E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388F15  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388F19  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388F1D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388F22  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388F29  E8 D2 2A 02 00              call    sub_1803ABA00
0000000180388F2E  66 0F 6F 05 FA 30 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388F36  48 8D 05 D3 22 60 00        lea     rax, aLfoGain; "LFO Gain"
0000000180388F3D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388F41  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388F45  48 8D 87 B0 0F 00 00        lea     rax, [rdi+0FB0h]
0000000180388F4C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388F53  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388F57  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388F5B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388F60  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388F67  E8 94 2A 02 00              call    sub_1803ABA00
0000000180388F6C  66 0F 6F 05 BC 30 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388F74  48 8D 05 A5 22 60 00        lea     rax, aLfoLevel; "LFO Level"
0000000180388F7B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388F7F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388F84  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388F8B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388F92  48 8D 87 C0 0F 00 00        lea     rax, [rdi+0FC0h]
0000000180388F99  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388F9D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388FA1  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388FA5  E8 56 2A 02 00              call    sub_1803ABA00
0000000180388FAA  66 0F 6F 05 7E 30 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388FB2  48 8D 05 73 22 60 00        lea     rax, aLfoSw; "LFO Sw"
0000000180388FB9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388FBD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388FC1  48 8D 87 D0 0F 00 00        lea     rax, [rdi+0FD0h]
0000000180388FC8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180388FCF  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180388FD3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180388FD7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180388FDC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180388FE3  E8 18 2A 02 00              call    sub_1803ABA00
0000000180388FE8  66 0F 6F 05 40 30 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180388FF0  48 8D 05 41 22 60 00        lea     rax, aEnv1Level; "ENV1 Level"
0000000180388FF7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180388FFB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180388FFF  48 8D 87 E0 0F 00 00        lea     rax, [rdi+0FE0h]
0000000180389006  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038900D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389011  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389015  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038901A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389021  E8 DA 29 02 00              call    sub_1803ABA00
0000000180389026  66 0F 6F 05 02 30 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038902E  48 8D 05 13 22 60 00        lea     rax, aEnv2Level; "ENV2 Level"
0000000180389035  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389039  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038903D  48 8D 87 F0 0F 00 00        lea     rax, [rdi+0FF0h]
0000000180389044  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038904B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038904F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389053  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389058  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038905F  E8 9C 29 02 00              call    sub_1803ABA00
0000000180389064  66 0F 6F 05 C4 2F 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038906C  48 8D 05 E1 21 60 00        lea     rax, aEnvSw; "ENV Sw"
0000000180389073  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389077  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038907B  48 8D 87 00 10 00 00        lea     rax, [rdi+1000h]
0000000180389082  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389089  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038908D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389091  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389096  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038909D  E8 5E 29 02 00              call    sub_1803ABA00
00000001803890A2  66 0F 6F 05 86 2F 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803890AA  48 8D 05 AF 21 60 00        lea     rax, aBendLevel; "Bend Level"
00000001803890B1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803890B5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803890B9  48 8D 87 10 10 00 00        lea     rax, [rdi+1010h]
00000001803890C0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803890C7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803890CB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803890CF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803890D4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803890DB  E8 20 29 02 00              call    sub_1803ABA00
00000001803890E0  66 0F 6F 05 48 2F 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803890E8  48 8D 05 81 21 60 00        lea     rax, aBendRange; "Bend Range"
00000001803890EF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803890F3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803890F7  48 8D 87 20 10 00 00        lea     rax, [rdi+1020h]
00000001803890FE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389105  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389109  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038910D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389112  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389119  E8 E2 28 02 00              call    sub_1803ABA00
000000018038911E  66 0F 6F 05 0A 2F 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389126  48 8D 05 53 21 60 00        lea     rax, aPwmLevel; "PWM Level"
000000018038912D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389131  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389135  48 8D 87 30 10 00 00        lea     rax, [rdi+1030h]
000000018038913C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389143  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389147  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038914B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389150  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389157  E8 A4 28 02 00              call    sub_1803ABA00
000000018038915C  66 0F 6F 05 CC 2E 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389164  48 8D 05 25 21 60 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
000000018038916B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038916F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389173  48 8D 87 60 10 00 00        lea     rax, [rdi+1060h]
000000018038917A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389181  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389185  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389189  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038918E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389195  E8 66 28 02 00              call    sub_1803ABA00
000000018038919A  66 0F 6F 05 8E 2E 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803891A2  48 8D 05 F7 20 60 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
00000001803891A9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803891AD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803891B1  48 8D 87 70 10 00 00        lea     rax, [rdi+1070h]
00000001803891B8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803891BF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803891C3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803891C7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803891CC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803891D3  E8 28 28 02 00              call    sub_1803ABA00
00000001803891D8  66 0F 6F 05 50 2E 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803891E0  48 8D 05 C9 20 60 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
00000001803891E7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803891EB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803891EF  48 8D 87 80 10 00 00        lea     rax, [rdi+1080h]
00000001803891F6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803891FD  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389201  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389205  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038920A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389211  E8 EA 27 02 00              call    sub_1803ABA00
0000000180389216  66 0F 6F 05 12 2E 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038921E  48 8D 05 9B 20 60 00        lea     rax, aDutyTune; "Duty Tune"
0000000180389225  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389229  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038922D  48 8D 87 90 15 00 00        lea     rax, [rdi+1590h]
0000000180389234  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038923B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038923F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389243  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389248  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038924F  E8 AC 27 02 00              call    sub_1803ABA00
0000000180389254  66 0F 6F 05 D4 2D 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038925C  48 8D 05 6D 20 60 00        lea     rax, aOsc1Mute; "Osc1 Mute"
0000000180389263  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389267  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038926B  48 8D 87 30 19 00 00        lea     rax, [rdi+1930h]
0000000180389272  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389279  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038927D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389281  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389286  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038928D  E8 6E 27 02 00              call    sub_1803ABA00
0000000180389292  66 0F 6F 05 96 2D 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038929A  48 8D 05 3F 20 60 00        lea     rax, aOsc1Level; "Osc1 Level"
00000001803892A1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803892A5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803892A9  48 8D 87 70 19 00 00        lea     rax, [rdi+1970h]
00000001803892B0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803892B7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803892BB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803892BF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803892C4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803892CB  E8 30 27 02 00              call    sub_1803ABA00
00000001803892D0  66 0F 6F 05 58 2D 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803892D8  48 8D 05 11 20 60 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
00000001803892DF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803892E3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803892E7  48 8D 87 80 19 00 00        lea     rax, [rdi+1980h]
00000001803892EE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803892F5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803892F9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803892FD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389302  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389309  E8 F2 26 02 00              call    sub_1803ABA00
000000018038930E  48 8D 05 EB 1F 60 00        lea     rax, aGrifferSw; "Griffer SW"
0000000180389315  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038931C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389320  0F 57 C0                    xorps   xmm0, xmm0
0000000180389323  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038932A  48 8D 87 40 1A 00 00        lea     rax, [rdi+1A40h]
0000000180389331  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389335  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389339  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038933D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389342  E8 B9 26 02 00              call    sub_1803ABA00
0000000180389347  66 0F 6F 05 E1 2C 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038934F  48 8D 05 BA 1F 60 00        lea     rax, aLpfCutoff; "LPF Cutoff"
0000000180389356  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038935A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038935E  48 8D 87 50 1A 00 00        lea     rax, [rdi+1A50h]
0000000180389365  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038936C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389370  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389374  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389379  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389380  E8 7B 26 02 00              call    sub_1803ABA00
0000000180389385  66 0F 6F 05 A3 2C 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038938D  48 8D 05 8C 1F 60 00        lea     rax, aLpfResonance; "LPF Resonance"
0000000180389394  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389398  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038939C  48 8D 87 B0 1A 00 00        lea     rax, [rdi+1AB0h]
00000001803893A3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803893AA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803893AE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803893B2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803893B7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803893BE  E8 3D 26 02 00              call    sub_1803ABA00
00000001803893C3  48 8D 05 66 1F 60 00        lea     rax, aVelocity; "Velocity"
00000001803893CA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803893D1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803893D5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803893D9  48 8D 87 D0 1A 00 00        lea     rax, [rdi+1AD0h]
00000001803893E0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803893E7  0F 57 C0                    xorps   xmm0, xmm0
00000001803893EA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803893EE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803893F2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803893F7  E8 04 26 02 00              call    sub_1803ABA00
00000001803893FC  48 8D 05 39 1F 60 00        lea     rax, aEnv12; "Env1/2"
0000000180389403  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038940A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038940E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389412  48 8D 87 60 1B 00 00        lea     rax, [rdi+1B60h]
0000000180389419  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389420  0F 57 C0                    xorps   xmm0, xmm0
0000000180389423  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389427  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038942B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389430  E8 CB 25 02 00              call    sub_1803ABA00
0000000180389435  48 8D 05 0C 1F 60 00        lea     rax, aIntEnv; "Int/Env"
000000018038943C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389443  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389447  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038944B  48 8D 87 70 1B 00 00        lea     rax, [rdi+1B70h]
0000000180389452  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389459  0F 57 C0                    xorps   xmm0, xmm0
000000018038945C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389460  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389464  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389469  E8 92 25 02 00              call    sub_1803ABA00
000000018038946E  48 8D 05 9B 1D 60 00        lea     rax, aLfoGain; "LFO Gain"
0000000180389475  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038947C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389480  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389484  48 8D 87 80 1C 00 00        lea     rax, [rdi+1C80h]
000000018038948B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389492  0F 57 C0                    xorps   xmm0, xmm0
0000000180389495  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389499  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038949D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803894A2  E8 59 25 02 00              call    sub_1803ABA00
00000001803894A7  48 8D 05 A2 1E 60 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
00000001803894AE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803894B5  0F 57 C0                    xorps   xmm0, xmm0
00000001803894B8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803894BC  48 8D 87 90 1C 00 00        lea     rax, [rdi+1C90h]
00000001803894C3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803894CA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803894CF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803894D3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803894D7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803894DB  E8 20 25 02 00              call    sub_1803ABA00
00000001803894E0  48 8D 05 79 1E 60 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
00000001803894E7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803894EE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803894F2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803894F6  48 8D 87 A0 1C 00 00        lea     rax, [rdi+1CA0h]
00000001803894FD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389504  0F 57 C0                    xorps   xmm0, xmm0
0000000180389507  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038950B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038950F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389514  E8 E7 24 02 00              call    sub_1803ABA00
0000000180389519  66 0F 6F 05 0F 2B 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389521  48 8D 05 F8 1C 60 00        lea     rax, aLfoLevel; "LFO Level"
0000000180389528  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038952C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389530  48 8D 87 B0 1C 00 00        lea     rax, [rdi+1CB0h]
0000000180389537  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038953E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389542  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389546  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038954B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389552  E8 A9 24 02 00              call    sub_1803ABA00
0000000180389557  66 0F 6F 05 D1 2A 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038955F  48 8D 05 0A 1E 60 00        lea     rax, aModSens_0; "MOD Sens"
0000000180389566  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038956A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038956E  48 8D 87 C0 1C 00 00        lea     rax, [rdi+1CC0h]
0000000180389575  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038957C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389580  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389584  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389589  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389590  E8 6B 24 02 00              call    sub_1803ABA00
0000000180389595  66 0F 6F 05 93 2A 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038959D  48 8D 05 D8 1D 60 00        lea     rax, aModSw_0; "MOD SW"
00000001803895A4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803895A8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803895AC  48 8D 87 D0 1C 00 00        lea     rax, [rdi+1CD0h]
00000001803895B3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803895BA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803895BE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803895C2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803895C7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803895CE  E8 2D 24 02 00              call    sub_1803ABA00
00000001803895D3  66 0F 6F 05 55 2A 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803895DB  48 8D 05 A6 1D 60 00        lea     rax, aEnvLevel; "ENV Level"
00000001803895E2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803895E6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803895EA  48 8D 87 E0 1C 00 00        lea     rax, [rdi+1CE0h]
00000001803895F1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803895F8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803895FC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389600  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389605  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038960C  E8 EF 23 02 00              call    sub_1803ABA00
0000000180389611  66 0F 6F 05 17 2A 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389619  48 8D 05 78 1D 60 00        lea     rax, aKcvLevel; "KCV Level"
0000000180389620  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389624  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389628  48 8D 87 F0 1C 00 00        lea     rax, [rdi+1CF0h]
000000018038962F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389636  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038963A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038963E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389643  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038964A  E8 B1 23 02 00              call    sub_1803ABA00
000000018038964F  66 0F 6F 05 D9 29 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389657  48 8D 05 4A 1D 60 00        lea     rax, aVelocitySens; "Velocity Sens"
000000018038965E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389662  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389666  48 8D 87 00 1D 00 00        lea     rax, [rdi+1D00h]
000000018038966D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389674  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389678  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038967C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389681  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389688  E8 73 23 02 00              call    sub_1803ABA00
000000018038968D  66 0F 6F 05 9B 29 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389695  48 8D 05 1C 1D 60 00        lea     rax, aVelocityOffset; "Velocity Offset"
000000018038969C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803896A0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803896A4  48 8D 87 10 1D 00 00        lea     rax, [rdi+1D10h]
00000001803896AB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803896B2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803896B6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803896BA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803896BF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803896C6  E8 35 23 02 00              call    sub_1803ABA00
00000001803896CB  66 0F 6F 05 5D 29 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803896D3  48 8D 05 86 1B 60 00        lea     rax, aBendLevel; "Bend Level"
00000001803896DA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803896DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803896E2  48 8D 87 20 1D 00 00        lea     rax, [rdi+1D20h]
00000001803896E9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803896F0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803896F4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803896F8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803896FD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389704  E8 F7 22 02 00              call    sub_1803ABA00
0000000180389709  66 0F 6F 05 1F 29 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389711  48 8D 05 58 1B 60 00        lea     rax, aBendRange; "Bend Range"
0000000180389718  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038971C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389720  48 8D 87 30 1D 00 00        lea     rax, [rdi+1D30h]
0000000180389727  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038972E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389732  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389736  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038973B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389742  E8 B9 22 02 00              call    sub_1803ABA00
0000000180389747  66 0F 6F 05 E1 28 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038974F  48 8D 05 72 1C 60 00        lea     rax, aCutoffTune; "Cutoff Tune"
0000000180389756  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038975A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038975E  48 8D 87 B0 1D 00 00        lea     rax, [rdi+1DB0h]
0000000180389765  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038976C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389770  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389774  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389779  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389780  E8 7B 22 02 00              call    sub_1803ABA00
0000000180389785  66 0F 6F 05 A3 28 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038978D  48 8D 05 44 1C 60 00        lea     rax, aResonanceTune; "Resonance Tune"
0000000180389794  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389798  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038979C  48 8D 87 C0 1D 00 00        lea     rax, [rdi+1DC0h]
00000001803897A3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803897AA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803897AE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803897B2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803897B7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803897BE  E8 3D 22 02 00              call    sub_1803ABA00
00000001803897C3  48 8D 05 1E 1C 60 00        lea     rax, aPluginSw; "PlugIn Sw"
00000001803897CA  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00000001803897D1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803897D5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803897D9  48 8D 87 D0 1D 00 00        lea     rax, [rdi+1DD0h]
00000001803897E0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803897E7  0F 57 C9                    xorps   xmm1, xmm1
00000001803897EA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803897EE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803897F2  F3 0F 7F 4D 93              movdqu  [rbp+57h+var_C4], xmm1
00000001803897F7  E8 04 22 02 00              call    sub_1803ABA00
00000001803897FC  48 8D 05 E5 1B 60 00        lea     rax, aPluginSw; "PlugIn Sw"
0000000180389803  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
000000018038980A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038980E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389812  48 8D 87 60 23 00 00        lea     rax, [rdi+2360h]
0000000180389819  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389820  0F 57 C0                    xorps   xmm0, xmm0
0000000180389823  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389827  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038982B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389830  E8 CB 21 02 00              call    sub_1803ABA00
0000000180389835  66 0F 6F 05 F3 27 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038983D  48 8D 05 B4 1B 60 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
0000000180389844  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389848  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038984F  48 8D 87 70 23 00 00        lea     rax, [rdi+2370h]
0000000180389856  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038985D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389861  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389865  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389869  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038986E  E8 8D 21 02 00              call    sub_1803ABA00
0000000180389873  66 0F 6F 05 B5 27 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038987B  48 8D 05 86 1B 60 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
0000000180389882  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389886  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038988A  48 8D 87 80 23 00 00        lea     rax, [rdi+2380h]
0000000180389891  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389898  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038989C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803898A0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803898A5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803898AC  E8 4F 21 02 00              call    sub_1803ABA00
00000001803898B1  66 0F 6F 05 77 27 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803898B9  48 8D 05 58 1B 60 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
00000001803898C0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803898C4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803898C8  48 8D 87 90 23 00 00        lea     rax, [rdi+2390h]
00000001803898CF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803898D6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803898DA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803898DE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803898E3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803898EA  E8 11 21 02 00              call    sub_1803ABA00
00000001803898EF  66 0F 6F 05 39 27 60 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803898F7  48 8D 05 2A 1B 60 00        lea     rax, aAmpTone; "AMP TONE"
00000001803898FE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389902  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389906  48 8D 87 70 25 00 00        lea     rax, [rdi+2570h]
000000018038990D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389914  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389918  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038991C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389921  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389928  E8 D3 20 02 00              call    sub_1803ABA00
000000018038992D  66 0F 6F 05 FB 26 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389935  48 8D 05 FC 1A 60 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
000000018038993C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389940  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389944  48 8D 87 80 25 00 00        lea     rax, [rdi+2580h]
000000018038994B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389952  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389956  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038995A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038995F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389966  E8 95 20 02 00              call    sub_1803ABA00
000000018038996B  66 0F 6F 05 BD 26 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389973  48 8D 05 D6 1A 60 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
000000018038997A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038997E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389982  48 8D 87 90 25 00 00        lea     rax, [rdi+2590h]
0000000180389989  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389990  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389994  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389998  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038999D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803899A4  E8 57 20 02 00              call    sub_1803ABA00
00000001803899A9  48 8D 05 80 19 60 00        lea     rax, aVelocity; "Velocity"
00000001803899B0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803899B7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803899BB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803899BF  48 8D 87 D0 25 00 00        lea     rax, [rdi+25D0h]
00000001803899C6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803899CD  0F 57 C0                    xorps   xmm0, xmm0
00000001803899D0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803899D4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803899D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803899DD  E8 1E 20 02 00              call    sub_1803ABA00
00000001803899E2  48 8D 05 7F 1A 60 00        lea     rax, aMute; "Mute"
00000001803899E9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803899F0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803899F4  0F 57 C0                    xorps   xmm0, xmm0
00000001803899F7  48 8D 87 60 26 00 00        lea     rax, [rdi+2660h]
00000001803899FE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389A05  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389A09  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389A0E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389A12  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389A16  E8 E5 1F 02 00              call    sub_1803ABA00
0000000180389A1B  48 8D 05 4E 1A 60 00        lea     rax, aGateSw; "Gate SW"
0000000180389A22  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389A29  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389A2D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389A31  48 8D 87 C0 27 00 00        lea     rax, [rdi+27C0h]
0000000180389A38  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389A3F  0F 57 C0                    xorps   xmm0, xmm0
0000000180389A42  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389A46  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389A4A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389A4F  E8 AC 1F 02 00              call    sub_1803ABA00
0000000180389A54  48 8D 05 1D 1A 60 00        lea     rax, aEnv1Sw; "ENV1 SW"
0000000180389A5B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389A62  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389A66  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389A6A  48 8D 87 D0 27 00 00        lea     rax, [rdi+27D0h]
0000000180389A71  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389A78  0F 57 C0                    xorps   xmm0, xmm0
0000000180389A7B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389A7F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389A83  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389A88  E8 73 1F 02 00              call    sub_1803ABA00
0000000180389A8D  48 8D 05 EC 19 60 00        lea     rax, aEnv2Sw; "ENV2 SW"
0000000180389A94  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389A9B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389A9F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389AA3  48 8D 87 E0 27 00 00        lea     rax, [rdi+27E0h]
0000000180389AAA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389AB1  0F 57 C0                    xorps   xmm0, xmm0
0000000180389AB4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389AB8  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389ABC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389AC1  E8 3A 1F 02 00              call    sub_1803ABA00
0000000180389AC6  48 8D 05 BB 19 60 00        lea     rax, aExtEnvSw; "Ext ENV SW"
0000000180389ACD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389AD4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389AD8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389ADC  48 8D 87 F0 27 00 00        lea     rax, [rdi+27F0h]
0000000180389AE3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389AEA  0F 57 C0                    xorps   xmm0, xmm0
0000000180389AED  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389AF1  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389AF5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389AFA  E8 01 1F 02 00              call    sub_1803ABA00
0000000180389AFF  66 0F 6F 05 29 25 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389B07  48 8D 05 8A 19 60 00        lea     rax, aHpfCutoff; "HPF Cutoff"
0000000180389B0E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389B12  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389B16  48 8D 87 00 28 00 00        lea     rax, [rdi+2800h]
0000000180389B1D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389B24  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389B28  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389B2C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389B31  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389B38  E8 C3 1E 02 00              call    sub_1803ABA00
0000000180389B3D  66 0F 6F 05 EB 24 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389B45  48 8D 05 5C 19 60 00        lea     rax, aHpfSwitch; "HPF Switch"
0000000180389B4C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389B50  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389B54  48 8D 87 10 28 00 00        lea     rax, [rdi+2810h]
0000000180389B5B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389B62  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389B66  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389B6A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389B6F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389B76  E8 85 1E 02 00              call    sub_1803ABA00
0000000180389B7B  66 0F 6F 05 AD 24 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389B83  48 8D 05 2E 19 60 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
0000000180389B8A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389B8E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389B92  48 8D 87 20 28 00 00        lea     rax, [rdi+2820h]
0000000180389B99  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389BA0  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389BA4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389BA8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389BAD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389BB4  E8 47 1E 02 00              call    sub_1803ABA00
0000000180389BB9  48 8D 05 08 19 60 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
0000000180389BC0  66 0F 6F 05 68 24 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389BC8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389BCC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389BD0  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389BD4  48 8D 87 30 28 00 00        lea     rax, [rdi+2830h]
0000000180389BDB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389BE2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389BE6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389BEB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389BF2  E8 09 1E 02 00              call    sub_1803ABA00
0000000180389BF7  66 0F 6F 05 31 24 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389BFF  48 8D 05 DA 18 60 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
0000000180389C06  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389C0A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389C0E  48 8D 87 40 28 00 00        lea     rax, [rdi+2840h]
0000000180389C15  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389C1C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389C20  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389C24  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389C29  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389C30  E8 CB 1D 02 00              call    sub_1803ABA00
0000000180389C35  66 0F 6F 05 F3 23 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389C3D  48 8D 05 AC 18 60 00        lea     rax, aAmpLevel; "AMP LEVEL"
0000000180389C44  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389C48  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389C4C  48 8D 87 50 28 00 00        lea     rax, [rdi+2850h]
0000000180389C53  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389C5A  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389C5E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389C62  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389C67  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389C6E  E8 8D 1D 02 00              call    sub_1803ABA00
0000000180389C73  48 8D 05 A6 12 60 00        lea     rax, aUseextjack; "UseExtJack"
0000000180389C7A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389C81  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389C85  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389C89  48 8D 87 20 2A 00 00        lea     rax, [rdi+2A20h]
0000000180389C90  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389C97  0F 57 C0                    xorps   xmm0, xmm0
0000000180389C9A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389C9E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389CA2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389CA7  E8 54 1D 02 00              call    sub_1803ABA00
0000000180389CAC  48 8D 05 79 12 60 00        lea     rax, aMCv; "M.CV"
0000000180389CB3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389CBA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389CBE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389CC2  48 8D 87 40 2A 00 00        lea     rax, [rdi+2A40h]
0000000180389CC9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389CD0  0F 57 C0                    xorps   xmm0, xmm0
0000000180389CD3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389CD7  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389CDB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389CE0  E8 1B 1D 02 00              call    sub_1803ABA00
0000000180389CE5  48 8D 05 48 12 60 00        lea     rax, aMGate; "M.Gate"
0000000180389CEC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389CF3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389CF7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389CFB  48 8D 87 50 2A 00 00        lea     rax, [rdi+2A50h]
0000000180389D02  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389D09  0F 57 C0                    xorps   xmm0, xmm0
0000000180389D0C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389D10  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389D14  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389D19  E8 E2 1C 02 00              call    sub_1803ABA00
0000000180389D1E  66 0F 6F 05 0A 23 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389D26  48 8D 05 13 12 60 00        lea     rax, aMasterTune; "Master Tune"
0000000180389D2D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389D31  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389D35  48 8D 87 80 2A 00 00        lea     rax, [rdi+2A80h]
0000000180389D3C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389D43  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389D47  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389D4B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389D50  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389D57  E8 A4 1C 02 00              call    sub_1803ABA00
0000000180389D5C  66 0F 6F 05 CC 22 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389D64  48 8D 05 E5 11 60 00        lea     rax, aPartTune; "Part Tune"
0000000180389D6B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389D6F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389D74  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389D7B  48 8D 87 90 2A 00 00        lea     rax, [rdi+2A90h]
0000000180389D82  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389D89  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389D8D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389D91  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389D95  E8 66 1C 02 00              call    sub_1803ABA00
0000000180389D9A  48 8D 05 BF 11 60 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
0000000180389DA1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389DA8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389DAC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389DB0  48 8D 87 60 2B 00 00        lea     rax, [rdi+2B60h]
0000000180389DB7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389DBE  0F 57 C0                    xorps   xmm0, xmm0
0000000180389DC1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389DC5  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389DC9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389DCE  E8 2D 1C 02 00              call    sub_1803ABA00
0000000180389DD3  48 8D 05 9E 11 60 00        lea     rax, aPortamentoMode; "Portamento Mode"
0000000180389DDA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389DE1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389DE5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389DE9  48 8D 87 70 2B 00 00        lea     rax, [rdi+2B70h]
0000000180389DF0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389DF7  0F 57 C0                    xorps   xmm0, xmm0
0000000180389DFA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389DFE  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389E02  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389E07  E8 F4 1B 02 00              call    sub_1803ABA00
0000000180389E0C  66 0F 6F 05 1C 22 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389E14  48 8D 05 6D 11 60 00        lea     rax, aPortamentoTime; "Portamento Time"
0000000180389E1B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389E1F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389E23  48 8D 87 80 2B 00 00        lea     rax, [rdi+2B80h]
0000000180389E2A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389E31  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389E35  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389E39  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389E3E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389E45  E8 B6 1B 02 00              call    sub_1803ABA00
0000000180389E4A  48 8D 05 47 11 60 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
0000000180389E51  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389E58  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389E5C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389E60  48 8D 87 20 2D 00 00        lea     rax, [rdi+2D20h]
0000000180389E67  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389E6E  0F 57 C0                    xorps   xmm0, xmm0
0000000180389E71  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389E75  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389E79  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389E7E  E8 7D 1B 02 00              call    sub_1803ABA00
0000000180389E83  48 8D 05 26 11 60 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
0000000180389E8A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389E91  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389E95  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389E99  48 8D 87 30 2D 00 00        lea     rax, [rdi+2D30h]
0000000180389EA0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389EA7  0F 57 C0                    xorps   xmm0, xmm0
0000000180389EAA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389EAE  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389EB2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389EB7  E8 44 1B 02 00              call    sub_1803ABA00
0000000180389EBC  48 8D 05 05 11 60 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
0000000180389EC3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389ECA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389ECE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389ED2  48 8D 87 40 2D 00 00        lea     rax, [rdi+2D40h]
0000000180389ED9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389EE0  0F 57 C0                    xorps   xmm0, xmm0
0000000180389EE3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389EE7  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389EEB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389EF0  E8 0B 1B 02 00              call    sub_1803ABA00
0000000180389EF5  66 0F 6F 05 33 21 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389EFD  48 8D 05 D4 10 60 00        lea     rax, aLfoRate; "LFO Rate"
0000000180389F04  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389F08  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389F0C  48 8D 87 50 2D 00 00        lea     rax, [rdi+2D50h]
0000000180389F13  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389F1A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389F1E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389F23  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389F2A  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389F2E  E8 CD 1A 02 00              call    sub_1803ABA00
0000000180389F33  48 8D 05 AA 10 60 00        lea     rax, aGate; "Gate"
0000000180389F3A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389F41  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389F45  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389F49  48 8D 87 50 30 00 00        lea     rax, [rdi+3050h]
0000000180389F50  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389F57  0F 57 C0                    xorps   xmm0, xmm0
0000000180389F5A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389F5E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389F62  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389F67  E8 94 1A 02 00              call    sub_1803ABA00
0000000180389F6C  48 8D 05 7D 10 60 00        lea     rax, aLfoTrig; "LFO Trig"
0000000180389F73  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389F7A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389F7E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389F82  48 8D 87 60 30 00 00        lea     rax, [rdi+3060h]
0000000180389F89  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389F90  0F 57 C0                    xorps   xmm0, xmm0
0000000180389F93  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389F97  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389F9B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389FA0  E8 5B 1A 02 00              call    sub_1803ABA00
0000000180389FA5  48 8D 05 54 10 60 00        lea     rax, aResetSw; "Reset Sw"
0000000180389FAC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180389FB3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389FB7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389FBB  48 8D 87 70 30 00 00        lea     rax, [rdi+3070h]
0000000180389FC2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180389FC9  0F 57 C0                    xorps   xmm0, xmm0
0000000180389FCC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180389FD0  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180389FD4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180389FD9  E8 22 1A 02 00              call    sub_1803ABA00
0000000180389FDE  66 0F 6F 05 4A 20 60 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180389FE6  48 8D 05 23 10 60 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
0000000180389FED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180389FF1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180389FF5  48 8D 87 80 30 00 00        lea     rax, [rdi+3080h]
0000000180389FFC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A003  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A007  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A00B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A010  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A017  E8 E4 19 02 00              call    sub_1803ABA00
000000018038A01C  66 0F 6F 05 0C 20 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A024  48 8D 05 F5 0F 60 00        lea     rax, aLfoDelay; "LFO Delay"
000000018038A02B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A02F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A033  48 8D 87 90 30 00 00        lea     rax, [rdi+3090h]
000000018038A03A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A041  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A045  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A049  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A04E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A055  E8 A6 19 02 00              call    sub_1803ABA00
000000018038A05A  66 0F 6F 05 CE 1F 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A062  48 8D 05 C7 0F 60 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
000000018038A069  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A06D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A071  48 8D 87 A0 30 00 00        lea     rax, [rdi+30A0h]
000000018038A078  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A07F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A083  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A087  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A08C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A093  E8 68 19 02 00              call    sub_1803ABA00
000000018038A098  66 0F 6F 05 90 1F 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A0A0  48 8D 05 99 0F 60 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
000000018038A0A7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A0AB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A0AF  48 8D 87 B0 30 00 00        lea     rax, [rdi+30B0h]
000000018038A0B6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A0BD  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A0C1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A0C5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A0CA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A0D1  E8 2A 19 02 00              call    sub_1803ABA00
000000018038A0D6  48 8D 05 73 0F 60 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
000000018038A0DD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A0E1  66 0F 6F 05 47 1F 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A0E9  48 8D 87 C0 30 00 00        lea     rax, [rdi+30C0h]
000000018038A0F0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A0F4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A0F8  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A0FC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A103  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A108  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A10F  E8 EC 18 02 00              call    sub_1803ABA00
000000018038A114  66 0F 6F 05 14 1F 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A11C  48 8D 05 3D 0F 60 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
000000018038A123  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A127  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A12B  48 8D 87 D0 30 00 00        lea     rax, [rdi+30D0h]
000000018038A132  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A139  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A13D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A141  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A146  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A14D  E8 AE 18 02 00              call    sub_1803ABA00
000000018038A152  66 0F 6F 05 D6 1E 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A15A  48 8D 05 0F 0F 60 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
000000018038A161  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A165  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A169  48 8D 87 E0 30 00 00        lea     rax, [rdi+30E0h]
000000018038A170  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A177  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A17B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A17F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A184  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A18B  E8 70 18 02 00              call    sub_1803ABA00
000000018038A190  66 0F 6F 05 98 1E 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A198  48 8D 05 E1 0E 60 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
000000018038A19F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A1A3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A1A7  48 8D 87 F0 30 00 00        lea     rax, [rdi+30F0h]
000000018038A1AE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A1B5  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A1B9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A1BD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A1C2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A1C9  E8 32 18 02 00              call    sub_1803ABA00
000000018038A1CE  66 0F 6F 05 5A 1E 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A1D6  48 8D 05 B3 0E 60 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
000000018038A1DD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A1E1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A1E5  48 8D 87 00 31 00 00        lea     rax, [rdi+3100h]
000000018038A1EC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A1F3  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A1F7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A1FB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A200  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A207  E8 F4 17 02 00              call    sub_1803ABA00
000000018038A20C  66 0F 6F 05 1C 1E 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A214  48 8D 05 85 0E 60 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
000000018038A21B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A21F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A223  48 8D 87 10 31 00 00        lea     rax, [rdi+3110h]
000000018038A22A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A231  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A235  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A239  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A23E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A245  E8 B6 17 02 00              call    sub_1803ABA00
000000018038A24A  66 0F 6F 05 DE 1D 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A252  48 8D 05 57 0E 60 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
000000018038A259  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A25D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A261  48 8D 87 20 31 00 00        lea     rax, [rdi+3120h]
000000018038A268  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A26F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A273  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A277  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A27C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A283  E8 78 17 02 00              call    sub_1803ABA00
000000018038A288  66 0F 6F 05 A0 1D 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A290  48 8D 05 29 0E 60 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
000000018038A297  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A29B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A2A0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A2A7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A2AE  48 8D 87 30 31 00 00        lea     rax, [rdi+3130h]
000000018038A2B5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A2B9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A2BD  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A2C1  E8 3A 17 02 00              call    sub_1803ABA00
000000018038A2C6  66 0F 6F 05 62 1D 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A2CE  48 8D 05 FB 0D 60 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
000000018038A2D5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A2D9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A2DD  48 8D 87 40 31 00 00        lea     rax, [rdi+3140h]
000000018038A2E4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A2EB  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A2EF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A2F3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A2F8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A2FF  E8 FC 16 02 00              call    sub_1803ABA00
000000018038A304  66 0F 6F 05 24 1D 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A30C  48 8D 05 D5 0D 60 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
000000018038A313  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A317  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A31B  48 8D 87 50 31 00 00        lea     rax, [rdi+3150h]
000000018038A322  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A329  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A32D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A331  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A336  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A33D  E8 BE 16 02 00              call    sub_1803ABA00
000000018038A342  48 8D 05 B7 0D 60 00        lea     rax, aReadOnly; "read only"
000000018038A349  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A350  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A354  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A358  48 8D 87 F0 32 00 00        lea     rax, [rdi+32F0h]
000000018038A35F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A366  0F 57 C0                    xorps   xmm0, xmm0
000000018038A369  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A36D  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A371  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A376  E8 85 16 02 00              call    sub_1803ABA00
000000018038A37B  48 8D 05 7E 0D 60 00        lea     rax, aReadOnly; "read only"
000000018038A382  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A389  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A38D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A391  48 8D 87 00 33 00 00        lea     rax, [rdi+3300h]
000000018038A398  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A39F  0F 57 C0                    xorps   xmm0, xmm0
000000018038A3A2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A3A6  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A3AA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A3AF  E8 4C 16 02 00              call    sub_1803ABA00
000000018038A3B4  48 8D 05 55 0D 60 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
000000018038A3BB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A3C2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A3C6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A3CA  48 8D 87 10 33 00 00        lea     rax, [rdi+3310h]
000000018038A3D1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A3D8  0F 57 C0                    xorps   xmm0, xmm0
000000018038A3DB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A3DF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A3E3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A3E8  E8 13 16 02 00              call    sub_1803ABA00
000000018038A3ED  66 0F 6F 05 3B 1C 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A3F5  48 8D 05 2C 0D 60 00        lea     rax, aEnvAttack; "ENV Attack"
000000018038A3FC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A400  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A404  48 8D 87 F0 33 00 00        lea     rax, [rdi+33F0h]
000000018038A40B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A412  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A416  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A41A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A41F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A426  E8 D5 15 02 00              call    sub_1803ABA00
000000018038A42B  66 0F 6F 05 FD 1B 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A433  48 8D 05 FE 0C 60 00        lea     rax, aEnvSustain; "ENV Sustain"
000000018038A43A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A43E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A442  48 8D 87 00 34 00 00        lea     rax, [rdi+3400h]
000000018038A449  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A450  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A454  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A458  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A45D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A464  E8 97 15 02 00              call    sub_1803ABA00
000000018038A469  66 0F 6F 05 BF 1B 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A471  48 8D 05 D0 0C 60 00        lea     rax, aEnvDecay; "ENV Decay"
000000018038A478  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A47C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A480  48 8D 87 10 34 00 00        lea     rax, [rdi+3410h]
000000018038A487  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A48E  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A492  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A496  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A49B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A4A2  E8 59 15 02 00              call    sub_1803ABA00
000000018038A4A7  66 0F 6F 05 81 1B 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A4AF  48 8D 05 A2 0C 60 00        lea     rax, aEnvRelease; "ENV Release"
000000018038A4B6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A4BA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A4BE  48 8D 87 20 34 00 00        lea     rax, [rdi+3420h]
000000018038A4C5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A4CC  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A4D0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A4D4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A4D9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A4E0  E8 1B 15 02 00              call    sub_1803ABA00
000000018038A4E5  66 0F 6F 05 43 1B 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A4ED  48 8D 05 74 0C 60 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
000000018038A4F4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A4F8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A4FC  48 8D 87 30 34 00 00        lea     rax, [rdi+3430h]
000000018038A503  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A50A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A50E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A512  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A517  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A51E  E8 DD 14 02 00              call    sub_1803ABA00
000000018038A523  48 8D 05 E6 0B 60 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
000000018038A52A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A531  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A535  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A539  48 8D 87 F0 34 00 00        lea     rax, [rdi+34F0h]
000000018038A540  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A547  0F 57 C0                    xorps   xmm0, xmm0
000000018038A54A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A54E  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A552  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A557  E8 A4 14 02 00              call    sub_1803ABA00
000000018038A55C  66 0F 6F 05 CC 1A 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A564  48 8D 05 BD 0B 60 00        lea     rax, aEnvAttack; "ENV Attack"
000000018038A56B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A56F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A573  48 8D 87 D0 35 00 00        lea     rax, [rdi+35D0h]
000000018038A57A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A581  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A585  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A589  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A58E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A595  E8 66 14 02 00              call    sub_1803ABA00
000000018038A59A  66 0F 6F 05 8E 1A 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A5A2  48 8D 05 8F 0B 60 00        lea     rax, aEnvSustain; "ENV Sustain"
000000018038A5A9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A5AD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A5B1  48 8D 87 E0 35 00 00        lea     rax, [rdi+35E0h]
000000018038A5B8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A5BF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A5C3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A5C7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A5CC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A5D3  E8 28 14 02 00              call    sub_1803ABA00
000000018038A5D8  66 0F 6F 05 50 1A 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A5E0  48 8D 05 61 0B 60 00        lea     rax, aEnvDecay; "ENV Decay"
000000018038A5E7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A5EB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A5EF  48 8D 87 F0 35 00 00        lea     rax, [rdi+35F0h]
000000018038A5F6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A5FD  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A601  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A605  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A60A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A611  E8 EA 13 02 00              call    sub_1803ABA00
000000018038A616  48 8D 05 3B 0B 60 00        lea     rax, aEnvRelease; "ENV Release"
000000018038A61D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A624  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A628  66 0F 6F 05 00 1A 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A630  48 8D 87 00 36 00 00        lea     rax, [rdi+3600h]
000000018038A637  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A63B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A63F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A643  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A64A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A64F  E8 AC 13 02 00              call    sub_1803ABA00
000000018038A654  66 0F 6F 05 D4 19 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A65C  48 8D 05 05 0B 60 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
000000018038A663  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A667  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A66B  48 8D 87 10 36 00 00        lea     rax, [rdi+3610h]
000000018038A672  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A679  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A67D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A681  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A686  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A68D  E8 6E 13 02 00              call    sub_1803ABA00
000000018038A692  48 8D 05 DF 0A 60 00        lea     rax, aOsc1Feet; "OSC1 Feet"
000000018038A699  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A6A0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A6A4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A6A8  48 8D 87 10 38 00 00        lea     rax, [rdi+3810h]
000000018038A6AF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A6B6  0F 57 C0                    xorps   xmm0, xmm0
000000018038A6B9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A6BD  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A6C1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A6C6  E8 35 13 02 00              call    sub_1803ABA00
000000018038A6CB  48 8D 05 B6 0A 60 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
000000018038A6D2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A6D9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A6DD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A6E1  48 8D 87 20 38 00 00        lea     rax, [rdi+3820h]
000000018038A6E8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A6EF  0F 57 C0                    xorps   xmm0, xmm0
000000018038A6F2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A6F6  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A6FA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A6FF  E8 FC 12 02 00              call    sub_1803ABA00
000000018038A704  48 8D 05 8D 0A 60 00        lea     rax, aBendEnableSw; "Bend Enable SW"
000000018038A70B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A712  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A716  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A71A  48 8D 87 30 38 00 00        lea     rax, [rdi+3830h]
000000018038A721  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A728  0F 57 C0                    xorps   xmm0, xmm0
000000018038A72B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A72F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A733  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A738  E8 C3 12 02 00              call    sub_1803ABA00
000000018038A73D  48 8D 05 64 0A 60 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
000000018038A744  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A74B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A74F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A753  48 8D 87 40 38 00 00        lea     rax, [rdi+3840h]
000000018038A75A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A761  0F 57 C0                    xorps   xmm0, xmm0
000000018038A764  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A768  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A76C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A771  E8 8A 12 02 00              call    sub_1803ABA00
000000018038A776  48 8D 05 3B 0A 60 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
000000018038A77D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A784  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A788  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A78C  48 8D 87 50 38 00 00        lea     rax, [rdi+3850h]
000000018038A793  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A79A  0F 57 C0                    xorps   xmm0, xmm0
000000018038A79D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A7A1  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A7A5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A7AA  E8 51 12 02 00              call    sub_1803ABA00
000000018038A7AF  48 8D 05 12 0A 60 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
000000018038A7B6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A7BD  0F 57 C0                    xorps   xmm0, xmm0
000000018038A7C0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A7C4  48 8D 87 60 38 00 00        lea     rax, [rdi+3860h]
000000018038A7CB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A7D2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A7D7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A7DB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A7DF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A7E3  E8 18 12 02 00              call    sub_1803ABA00
000000018038A7E8  48 8D 05 E9 09 60 00        lea     rax, aPwmSwManual; "PWM SW Manual"
000000018038A7EF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A7F6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A7FA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A7FE  48 8D 87 70 38 00 00        lea     rax, [rdi+3870h]
000000018038A805  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A80C  0F 57 C0                    xorps   xmm0, xmm0
000000018038A80F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A813  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A817  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A81C  E8 DF 11 02 00              call    sub_1803ABA00
000000018038A821  66 0F 6F 05 07 18 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A829  48 8D 05 B8 09 60 00        lea     rax, aTune; "Tune"
000000018038A830  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A834  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A838  48 8D 87 80 38 00 00        lea     rax, [rdi+3880h]
000000018038A83F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A846  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A84A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A84E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A853  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A85A  E8 A1 11 02 00              call    sub_1803ABA00
000000018038A85F  66 0F 6F 05 C9 17 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A867  48 8D 05 82 09 60 00        lea     rax, aDetune; "Detune"
000000018038A86E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A872  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A876  48 8D 87 90 38 00 00        lea     rax, [rdi+3890h]
000000018038A87D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A884  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A888  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A88C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A891  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A898  E8 63 11 02 00              call    sub_1803ABA00
000000018038A89D  66 0F 6F 05 8B 17 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A8A5  48 8D 05 4C 09 60 00        lea     rax, aModSens; "Mod Sens"
000000018038A8AC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A8B0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A8B4  48 8D 87 A0 38 00 00        lea     rax, [rdi+38A0h]
000000018038A8BB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A8C2  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A8C6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A8CA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A8CF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A8D6  E8 25 11 02 00              call    sub_1803ABA00
000000018038A8DB  66 0F 6F 05 4D 17 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A8E3  48 8D 05 1A 09 60 00        lea     rax, aModSw; "Mod Sw"
000000018038A8EA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A8EE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A8F2  48 8D 87 B0 38 00 00        lea     rax, [rdi+38B0h]
000000018038A8F9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A900  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A904  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A908  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A90D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A914  E8 E7 10 02 00              call    sub_1803ABA00
000000018038A919  66 0F 6F 05 0F 17 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A921  48 8D 05 E8 08 60 00        lea     rax, aLfoGain; "LFO Gain"
000000018038A928  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A92C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A930  48 8D 87 C0 38 00 00        lea     rax, [rdi+38C0h]
000000018038A937  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A93E  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A942  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A946  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A94B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A952  E8 A9 10 02 00              call    sub_1803ABA00
000000018038A957  66 0F 6F 05 D1 16 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A95F  48 8D 05 BA 08 60 00        lea     rax, aLfoLevel; "LFO Level"
000000018038A966  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A96A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A96E  48 8D 87 D0 38 00 00        lea     rax, [rdi+38D0h]
000000018038A975  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A97C  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A980  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A984  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A989  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A990  E8 6B 10 02 00              call    sub_1803ABA00
000000018038A995  66 0F 6F 05 93 16 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A99D  48 8D 05 88 08 60 00        lea     rax, aLfoSw; "LFO Sw"
000000018038A9A4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A9A8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A9AC  48 8D 87 E0 38 00 00        lea     rax, [rdi+38E0h]
000000018038A9B3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A9BA  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A9BE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038A9C2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038A9C7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038A9CE  E8 2D 10 02 00              call    sub_1803ABA00
000000018038A9D3  66 0F 6F 05 55 16 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038A9DB  48 8D 05 56 08 60 00        lea     rax, aEnv1Level; "ENV1 Level"
000000018038A9E2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038A9E6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038A9EA  48 8D 87 F0 38 00 00        lea     rax, [rdi+38F0h]
000000018038A9F1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038A9F8  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038A9FC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AA00  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AA05  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AA0C  E8 EF 0F 02 00              call    sub_1803ABA00
000000018038AA11  66 0F 6F 05 17 16 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AA19  48 8D 05 28 08 60 00        lea     rax, aEnv2Level; "ENV2 Level"
000000018038AA20  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AA24  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AA28  48 8D 87 00 39 00 00        lea     rax, [rdi+3900h]
000000018038AA2F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AA36  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AA3A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AA3E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AA43  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AA4A  E8 B1 0F 02 00              call    sub_1803ABA00
000000018038AA4F  66 0F 6F 05 D9 15 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AA57  48 8D 05 F6 07 60 00        lea     rax, aEnvSw; "ENV Sw"
000000018038AA5E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AA62  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AA66  48 8D 87 10 39 00 00        lea     rax, [rdi+3910h]
000000018038AA6D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AA74  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AA78  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AA7C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AA81  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AA88  E8 73 0F 02 00              call    sub_1803ABA00
000000018038AA8D  66 0F 6F 05 9B 15 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AA95  48 8D 05 C4 07 60 00        lea     rax, aBendLevel; "Bend Level"
000000018038AA9C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AAA0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AAA4  48 8D 87 20 39 00 00        lea     rax, [rdi+3920h]
000000018038AAAB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AAB2  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AAB6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AABA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AABF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AAC6  E8 35 0F 02 00              call    sub_1803ABA00
000000018038AACB  66 0F 6F 05 5D 15 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AAD3  48 8D 05 96 07 60 00        lea     rax, aBendRange; "Bend Range"
000000018038AADA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AADE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AAE2  48 8D 87 30 39 00 00        lea     rax, [rdi+3930h]
000000018038AAE9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AAF0  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AAF4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AAF8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AAFD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AB04  E8 F7 0E 02 00              call    sub_1803ABA00
000000018038AB09  66 0F 6F 05 1F 15 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AB11  48 8D 05 68 07 60 00        lea     rax, aPwmLevel; "PWM Level"
000000018038AB18  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AB1C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AB20  48 8D 87 40 39 00 00        lea     rax, [rdi+3940h]
000000018038AB27  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AB2E  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AB32  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AB36  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AB3B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AB42  E8 B9 0E 02 00              call    sub_1803ABA00
000000018038AB47  66 0F 6F 05 E1 14 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AB4F  48 8D 05 3A 07 60 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
000000018038AB56  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AB5A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AB61  48 8D 87 70 39 00 00        lea     rax, [rdi+3970h]
000000018038AB68  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AB6F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AB73  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AB77  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AB7B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AB80  E8 7B 0E 02 00              call    sub_1803ABA00
000000018038AB85  66 0F 6F 05 A3 14 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AB8D  48 8D 05 0C 07 60 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
000000018038AB94  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AB98  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AB9C  48 8D 87 80 39 00 00        lea     rax, [rdi+3980h]
000000018038ABA3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038ABAA  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038ABAE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038ABB2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038ABB7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038ABBE  E8 3D 0E 02 00              call    sub_1803ABA00
000000018038ABC3  66 0F 6F 05 65 14 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038ABCB  48 8D 05 DE 06 60 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
000000018038ABD2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038ABD6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038ABDA  48 8D 87 90 39 00 00        lea     rax, [rdi+3990h]
000000018038ABE1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038ABE8  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038ABEC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038ABF0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038ABF5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038ABFC  E8 FF 0D 02 00              call    sub_1803ABA00
000000018038AC01  66 0F 6F 05 27 14 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AC09  48 8D 05 B0 06 60 00        lea     rax, aDutyTune; "Duty Tune"
000000018038AC10  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AC14  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AC18  48 8D 87 A0 3E 00 00        lea     rax, [rdi+3EA0h]
000000018038AC1F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AC26  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AC2A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AC2E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AC33  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AC3A  E8 C1 0D 02 00              call    sub_1803ABA00
000000018038AC3F  66 0F 6F 05 E9 13 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AC47  48 8D 05 82 06 60 00        lea     rax, aOsc1Mute; "Osc1 Mute"
000000018038AC4E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AC52  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AC56  48 8D 87 40 42 00 00        lea     rax, [rdi+4240h]
000000018038AC5D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AC64  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AC68  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AC6C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AC71  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AC78  E8 83 0D 02 00              call    sub_1803ABA00
000000018038AC7D  66 0F 6F 05 AB 13 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AC85  48 8D 05 54 06 60 00        lea     rax, aOsc1Level; "Osc1 Level"
000000018038AC8C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AC90  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AC94  48 8D 87 80 42 00 00        lea     rax, [rdi+4280h]
000000018038AC9B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038ACA2  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038ACA6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038ACAA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038ACAF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038ACB6  E8 45 0D 02 00              call    sub_1803ABA00
000000018038ACBB  66 0F 6F 05 6D 13 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038ACC3  48 8D 05 26 06 60 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
000000018038ACCA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038ACCE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038ACD2  48 8D 87 90 42 00 00        lea     rax, [rdi+4290h]
000000018038ACD9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038ACE0  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038ACE4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038ACE8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038ACED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038ACF4  E8 07 0D 02 00              call    sub_1803ABA00
000000018038ACF9  48 8D 05 00 06 60 00        lea     rax, aGrifferSw; "Griffer SW"
000000018038AD00  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AD07  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AD0B  0F 57 C0                    xorps   xmm0, xmm0
000000018038AD0E  48 8D 87 50 43 00 00        lea     rax, [rdi+4350h]
000000018038AD15  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AD1C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AD20  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AD25  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AD29  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AD2D  E8 CE 0C 02 00              call    sub_1803ABA00
000000018038AD32  66 0F 6F 05 F6 12 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AD3A  48 8D 05 CF 05 60 00        lea     rax, aLpfCutoff; "LPF Cutoff"
000000018038AD41  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AD45  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AD49  48 8D 87 60 43 00 00        lea     rax, [rdi+4360h]
000000018038AD50  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AD57  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AD5B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AD5F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AD64  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AD6B  E8 90 0C 02 00              call    sub_1803ABA00
000000018038AD70  66 0F 6F 05 B8 12 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AD78  48 8D 05 A1 05 60 00        lea     rax, aLpfResonance; "LPF Resonance"
000000018038AD7F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AD83  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AD87  48 8D 87 C0 43 00 00        lea     rax, [rdi+43C0h]
000000018038AD8E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AD95  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AD99  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AD9D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038ADA2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038ADA9  E8 52 0C 02 00              call    sub_1803ABA00
000000018038ADAE  48 8D 05 7B 05 60 00        lea     rax, aVelocity; "Velocity"
000000018038ADB5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038ADBC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038ADC0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038ADC4  48 8D 87 E0 43 00 00        lea     rax, [rdi+43E0h]
000000018038ADCB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038ADD2  0F 57 C0                    xorps   xmm0, xmm0
000000018038ADD5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038ADD9  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038ADDD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038ADE2  E8 19 0C 02 00              call    sub_1803ABA00
000000018038ADE7  48 8D 05 4E 05 60 00        lea     rax, aEnv12; "Env1/2"
000000018038ADEE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038ADF5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038ADF9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038ADFD  48 8D 87 70 44 00 00        lea     rax, [rdi+4470h]
000000018038AE04  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AE0B  0F 57 C0                    xorps   xmm0, xmm0
000000018038AE0E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AE12  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AE16  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AE1B  E8 E0 0B 02 00              call    sub_1803ABA00
000000018038AE20  48 8D 05 21 05 60 00        lea     rax, aIntEnv; "Int/Env"
000000018038AE27  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AE2E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AE32  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AE36  48 8D 87 80 44 00 00        lea     rax, [rdi+4480h]
000000018038AE3D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AE44  0F 57 C0                    xorps   xmm0, xmm0
000000018038AE47  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AE4B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AE4F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AE54  E8 A7 0B 02 00              call    sub_1803ABA00
000000018038AE59  48 8D 05 B0 03 60 00        lea     rax, aLfoGain; "LFO Gain"
000000018038AE60  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AE67  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AE6B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AE6F  48 8D 87 90 45 00 00        lea     rax, [rdi+4590h]
000000018038AE76  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AE7D  0F 57 C0                    xorps   xmm0, xmm0
000000018038AE80  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AE84  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AE88  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AE8D  E8 6E 0B 02 00              call    sub_1803ABA00
000000018038AE92  48 8D 05 B7 04 60 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
000000018038AE99  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AEA0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AEA4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AEA8  48 8D 87 A0 45 00 00        lea     rax, [rdi+45A0h]
000000018038AEAF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AEB6  0F 57 C0                    xorps   xmm0, xmm0
000000018038AEB9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AEBD  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AEC1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AEC6  E8 35 0B 02 00              call    sub_1803ABA00
000000018038AECB  48 8D 05 8E 04 60 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
000000018038AED2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AED6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AEDA  48 8D 87 B0 45 00 00        lea     rax, [rdi+45B0h]
000000018038AEE1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AEE8  0F 57 C0                    xorps   xmm0, xmm0
000000018038AEEB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AEEF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AEF3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AEFA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AEFF  E8 FC 0A 02 00              call    sub_1803ABA00
000000018038AF04  66 0F 6F 05 24 11 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AF0C  48 8D 05 0D 03 60 00        lea     rax, aLfoLevel; "LFO Level"
000000018038AF13  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AF17  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AF1B  48 8D 87 C0 45 00 00        lea     rax, [rdi+45C0h]
000000018038AF22  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AF29  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AF2D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AF31  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AF36  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AF3D  E8 BE 0A 02 00              call    sub_1803ABA00
000000018038AF42  66 0F 6F 05 E6 10 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AF4A  48 8D 05 1F 04 60 00        lea     rax, aModSens_0; "MOD Sens"
000000018038AF51  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AF55  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AF59  48 8D 87 D0 45 00 00        lea     rax, [rdi+45D0h]
000000018038AF60  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AF67  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AF6B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AF6F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AF74  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AF7B  E8 80 0A 02 00              call    sub_1803ABA00
000000018038AF80  66 0F 6F 05 A8 10 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AF88  48 8D 05 ED 03 60 00        lea     rax, aModSw_0; "MOD SW"
000000018038AF8F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AF93  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AF97  48 8D 87 E0 45 00 00        lea     rax, [rdi+45E0h]
000000018038AF9E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AFA5  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AFA9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AFAD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AFB2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AFB9  E8 42 0A 02 00              call    sub_1803ABA00
000000018038AFBE  66 0F 6F 05 6A 10 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038AFC6  48 8D 05 BB 03 60 00        lea     rax, aEnvLevel; "ENV Level"
000000018038AFCD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038AFD1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038AFD5  48 8D 87 F0 45 00 00        lea     rax, [rdi+45F0h]
000000018038AFDC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038AFE3  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038AFE7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038AFEB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038AFF0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038AFF7  E8 04 0A 02 00              call    sub_1803ABA00
000000018038AFFC  66 0F 6F 05 2C 10 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B004  48 8D 05 8D 03 60 00        lea     rax, aKcvLevel; "KCV Level"
000000018038B00B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B00F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B013  48 8D 87 00 46 00 00        lea     rax, [rdi+4600h]
000000018038B01A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B021  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B025  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B029  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B02E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B035  E8 C6 09 02 00              call    sub_1803ABA00
000000018038B03A  66 0F 6F 05 EE 0F 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B042  48 8D 05 5F 03 60 00        lea     rax, aVelocitySens; "Velocity Sens"
000000018038B049  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B04D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B051  48 8D 87 10 46 00 00        lea     rax, [rdi+4610h]
000000018038B058  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B05F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B063  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B067  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B06C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B073  E8 88 09 02 00              call    sub_1803ABA00
000000018038B078  66 0F 6F 05 B0 0F 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B080  48 8D 05 31 03 60 00        lea     rax, aVelocityOffset; "Velocity Offset"
000000018038B087  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B08B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B090  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B097  48 8D 87 20 46 00 00        lea     rax, [rdi+4620h]
000000018038B09E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B0A5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B0A9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B0AD  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B0B1  E8 4A 09 02 00              call    sub_1803ABA00
000000018038B0B6  66 0F 6F 05 72 0F 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B0BE  48 8D 05 9B 01 60 00        lea     rax, aBendLevel; "Bend Level"
000000018038B0C5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B0C9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B0CD  48 8D 87 30 46 00 00        lea     rax, [rdi+4630h]
000000018038B0D4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B0DB  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B0DF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B0E3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B0E8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B0EF  E8 0C 09 02 00              call    sub_1803ABA00
000000018038B0F4  66 0F 6F 05 34 0F 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B0FC  48 8D 05 6D 01 60 00        lea     rax, aBendRange; "Bend Range"
000000018038B103  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B107  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B10B  48 8D 87 40 46 00 00        lea     rax, [rdi+4640h]
000000018038B112  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B119  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B11D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B121  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B126  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B12D  E8 CE 08 02 00              call    sub_1803ABA00
000000018038B132  66 0F 6F 05 F6 0E 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B13A  48 8D 05 87 02 60 00        lea     rax, aCutoffTune; "Cutoff Tune"
000000018038B141  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B145  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B149  48 8D 87 C0 46 00 00        lea     rax, [rdi+46C0h]
000000018038B150  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B157  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B15B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B15F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B164  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B16B  E8 90 08 02 00              call    sub_1803ABA00
000000018038B170  66 0F 6F 05 B8 0E 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B178  48 8D 05 59 02 60 00        lea     rax, aResonanceTune; "Resonance Tune"
000000018038B17F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B183  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B187  48 8D 87 D0 46 00 00        lea     rax, [rdi+46D0h]
000000018038B18E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B195  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B199  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B19D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B1A2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B1A9  E8 52 08 02 00              call    sub_1803ABA00
000000018038B1AE  48 8D 05 33 02 60 00        lea     rax, aPluginSw; "PlugIn Sw"
000000018038B1B5  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
000000018038B1BC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B1C0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B1C4  48 8D 87 E0 46 00 00        lea     rax, [rdi+46E0h]
000000018038B1CB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B1D2  0F 57 C0                    xorps   xmm0, xmm0
000000018038B1D5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B1D9  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B1DD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B1E2  E8 19 08 02 00              call    sub_1803ABA00
000000018038B1E7  48 8D 05 FA 01 60 00        lea     rax, aPluginSw; "PlugIn Sw"
000000018038B1EE  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
000000018038B1F5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B1F9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B1FD  48 8D 87 70 4C 00 00        lea     rax, [rdi+4C70h]
000000018038B204  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B20B  0F 57 C0                    xorps   xmm0, xmm0
000000018038B20E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B212  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B216  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B21B  E8 E0 07 02 00              call    sub_1803ABA00
000000018038B220  66 0F 6F 05 08 0E 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B228  48 8D 05 C9 01 60 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
000000018038B22F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B233  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B237  48 8D 87 80 4C 00 00        lea     rax, [rdi+4C80h]
000000018038B23E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B245  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B249  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B24E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B255  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B259  E8 A2 07 02 00              call    sub_1803ABA00
000000018038B25E  66 0F 6F 05 CA 0D 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B266  48 8D 05 9B 01 60 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
000000018038B26D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B271  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B275  48 8D 87 90 4C 00 00        lea     rax, [rdi+4C90h]
000000018038B27C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B283  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B287  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B28B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B290  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B297  E8 64 07 02 00              call    sub_1803ABA00
000000018038B29C  66 0F 6F 05 8C 0D 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B2A4  48 8D 05 6D 01 60 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
000000018038B2AB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B2AF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B2B3  48 8D 87 A0 4C 00 00        lea     rax, [rdi+4CA0h]
000000018038B2BA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B2C1  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B2C5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B2C9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B2CE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B2D5  E8 26 07 02 00              call    sub_1803ABA00
000000018038B2DA  66 0F 6F 05 4E 0D 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B2E2  48 8D 05 3F 01 60 00        lea     rax, aAmpTone; "AMP TONE"
000000018038B2E9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B2ED  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B2F1  48 8D 87 80 4E 00 00        lea     rax, [rdi+4E80h]
000000018038B2F8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B2FF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B303  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B307  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B30C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B313  E8 E8 06 02 00              call    sub_1803ABA00
000000018038B318  66 0F 6F 05 10 0D 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B320  48 8D 05 11 01 60 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
000000018038B327  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B32B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B32F  48 8D 87 90 4E 00 00        lea     rax, [rdi+4E90h]
000000018038B336  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B33D  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B341  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B345  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B34A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B351  E8 AA 06 02 00              call    sub_1803ABA00
000000018038B356  66 0F 6F 05 D2 0C 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B35E  48 8D 05 EB 00 60 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
000000018038B365  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B369  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B36D  48 8D 87 A0 4E 00 00        lea     rax, [rdi+4EA0h]
000000018038B374  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B37B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B37F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B383  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B388  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B38F  E8 6C 06 02 00              call    sub_1803ABA00
000000018038B394  48 8D 05 95 FF 5F 00        lea     rax, aVelocity; "Velocity"
000000018038B39B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B3A2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B3A6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B3AA  48 8D 87 E0 4E 00 00        lea     rax, [rdi+4EE0h]
000000018038B3B1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B3B8  0F 57 C0                    xorps   xmm0, xmm0
000000018038B3BB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B3BF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B3C3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B3C8  E8 33 06 02 00              call    sub_1803ABA00
000000018038B3CD  48 8D 05 94 00 60 00        lea     rax, aMute; "Mute"
000000018038B3D4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B3DB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B3DF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B3E3  48 8D 87 70 4F 00 00        lea     rax, [rdi+4F70h]
000000018038B3EA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B3F1  0F 57 C0                    xorps   xmm0, xmm0
000000018038B3F4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B3F8  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B3FC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B401  E8 FA 05 02 00              call    sub_1803ABA00
000000018038B406  48 8D 05 63 00 60 00        lea     rax, aGateSw; "Gate SW"
000000018038B40D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B411  0F 57 C0                    xorps   xmm0, xmm0
000000018038B414  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B41B  48 8D 87 D0 50 00 00        lea     rax, [rdi+50D0h]
000000018038B422  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B429  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B42D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B431  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B435  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B43A  E8 C1 05 02 00              call    sub_1803ABA00
000000018038B43F  48 8D 05 32 00 60 00        lea     rax, aEnv1Sw; "ENV1 SW"
000000018038B446  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B44D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B451  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B455  48 8D 87 E0 50 00 00        lea     rax, [rdi+50E0h]
000000018038B45C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B463  0F 57 C0                    xorps   xmm0, xmm0
000000018038B466  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B46A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B46E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B473  E8 88 05 02 00              call    sub_1803ABA00
000000018038B478  48 8D 05 01 00 60 00        lea     rax, aEnv2Sw; "ENV2 SW"
000000018038B47F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B486  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B48A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B48E  48 8D 87 F0 50 00 00        lea     rax, [rdi+50F0h]
000000018038B495  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B49C  0F 57 C0                    xorps   xmm0, xmm0
000000018038B49F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B4A3  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B4A7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B4AC  E8 4F 05 02 00              call    sub_1803ABA00
000000018038B4B1  48 8D 05 D0 FF 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
000000018038B4B8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B4BF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B4C3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B4C7  48 8D 87 00 51 00 00        lea     rax, [rdi+5100h]
000000018038B4CE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B4D5  0F 57 C0                    xorps   xmm0, xmm0
000000018038B4D8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B4DC  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B4E0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B4E5  E8 16 05 02 00              call    sub_1803ABA00
000000018038B4EA  66 0F 6F 05 3E 0B 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B4F2  48 8D 05 9F FF 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
000000018038B4F9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B4FD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B501  48 8D 87 10 51 00 00        lea     rax, [rdi+5110h]
000000018038B508  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B50F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B513  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B517  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B51C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B523  E8 D8 04 02 00              call    sub_1803ABA00
000000018038B528  66 0F 6F 05 00 0B 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B530  48 8D 05 71 FF 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
000000018038B537  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B53B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B53F  48 8D 87 20 51 00 00        lea     rax, [rdi+5120h]
000000018038B546  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B54D  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B551  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B555  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B55A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B561  E8 9A 04 02 00              call    sub_1803ABA00
000000018038B566  66 0F 6F 05 C2 0A 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B56E  48 8D 05 43 FF 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
000000018038B575  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B579  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B57D  48 8D 87 30 51 00 00        lea     rax, [rdi+5130h]
000000018038B584  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B58B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B58F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B593  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B598  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B59F  E8 5C 04 02 00              call    sub_1803ABA00
000000018038B5A4  66 0F 6F 05 84 0A 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B5AC  48 8D 05 15 FF 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
000000018038B5B3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B5B7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B5BC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B5C3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B5CA  48 8D 87 40 51 00 00        lea     rax, [rdi+5140h]
000000018038B5D1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B5D5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B5D9  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B5DD  E8 1E 04 02 00              call    sub_1803ABA00
000000018038B5E2  66 0F 6F 05 46 0A 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B5EA  48 8D 05 EF FE 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
000000018038B5F1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B5F5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B5F9  48 8D 87 50 51 00 00        lea     rax, [rdi+5150h]
000000018038B600  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B607  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B60B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B60F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B614  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B61B  E8 E0 03 02 00              call    sub_1803ABA00
000000018038B620  66 0F 6F 05 08 0A 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B628  48 8D 05 C1 FE 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
000000018038B62F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B633  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B637  48 8D 87 60 51 00 00        lea     rax, [rdi+5160h]
000000018038B63E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B645  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B649  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B64D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B652  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B659  E8 A2 03 02 00              call    sub_1803ABA00
000000018038B65E  48 8D 05 BB F8 5F 00        lea     rax, aUseextjack; "UseExtJack"
000000018038B665  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B66C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B670  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B674  48 8D 87 30 53 00 00        lea     rax, [rdi+5330h]
000000018038B67B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B682  0F 57 C0                    xorps   xmm0, xmm0
000000018038B685  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B689  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B68D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B692  E8 69 03 02 00              call    sub_1803ABA00
000000018038B697  48 8D 05 8E F8 5F 00        lea     rax, aMCv; "M.CV"
000000018038B69E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B6A5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B6A9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B6AD  48 8D 87 50 53 00 00        lea     rax, [rdi+5350h]
000000018038B6B4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B6BB  0F 57 C0                    xorps   xmm0, xmm0
000000018038B6BE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B6C2  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B6C6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B6CB  E8 30 03 02 00              call    sub_1803ABA00
000000018038B6D0  48 8D 05 5D F8 5F 00        lea     rax, aMGate; "M.Gate"
000000018038B6D7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B6DE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B6E2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B6E6  48 8D 87 60 53 00 00        lea     rax, [rdi+5360h]
000000018038B6ED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B6F4  0F 57 C0                    xorps   xmm0, xmm0
000000018038B6F7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B6FB  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B6FF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B704  E8 F7 02 02 00              call    sub_1803ABA00
000000018038B709  66 0F 6F 05 1F 09 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B711  48 8D 05 28 F8 5F 00        lea     rax, aMasterTune; "Master Tune"
000000018038B718  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B71C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B720  48 8D 87 90 53 00 00        lea     rax, [rdi+5390h]
000000018038B727  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B72E  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B732  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B736  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B73B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B742  E8 B9 02 02 00              call    sub_1803ABA00
000000018038B747  66 0F 6F 05 E1 08 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B74F  48 8D 05 FA F7 5F 00        lea     rax, aPartTune; "Part Tune"
000000018038B756  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B75A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B75E  48 8D 87 A0 53 00 00        lea     rax, [rdi+53A0h]
000000018038B765  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B76C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B770  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B774  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B779  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B780  E8 7B 02 02 00              call    sub_1803ABA00
000000018038B785  48 8D 05 D4 F7 5F 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
000000018038B78C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B793  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B797  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B79B  48 8D 87 70 54 00 00        lea     rax, [rdi+5470h]
000000018038B7A2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B7A9  0F 57 C0                    xorps   xmm0, xmm0
000000018038B7AC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B7B0  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B7B4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B7B9  E8 42 02 02 00              call    sub_1803ABA00
000000018038B7BE  48 8D 05 B3 F7 5F 00        lea     rax, aPortamentoMode; "Portamento Mode"
000000018038B7C5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B7CC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B7D0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B7D4  48 8D 87 80 54 00 00        lea     rax, [rdi+5480h]
000000018038B7DB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B7E2  0F 57 C0                    xorps   xmm0, xmm0
000000018038B7E5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B7E9  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B7ED  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B7F2  E8 09 02 02 00              call    sub_1803ABA00
000000018038B7F7  66 0F 6F 05 31 08 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B7FF  48 8D 05 82 F7 5F 00        lea     rax, aPortamentoTime; "Portamento Time"
000000018038B806  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B80A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B80E  48 8D 87 90 54 00 00        lea     rax, [rdi+5490h]
000000018038B815  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B81C  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B820  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B824  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B829  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B830  E8 CB 01 02 00              call    sub_1803ABA00
000000018038B835  48 8D 05 5C F7 5F 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
000000018038B83C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B843  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B847  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B84B  48 8D 87 30 56 00 00        lea     rax, [rdi+5630h]
000000018038B852  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B859  0F 57 C0                    xorps   xmm0, xmm0
000000018038B85C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B860  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B864  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B869  E8 92 01 02 00              call    sub_1803ABA00
000000018038B86E  48 8D 05 3B F7 5F 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
000000018038B875  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B87C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B880  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B884  48 8D 87 40 56 00 00        lea     rax, [rdi+5640h]
000000018038B88B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B892  0F 57 C0                    xorps   xmm0, xmm0
000000018038B895  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B899  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B89D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B8A2  E8 59 01 02 00              call    sub_1803ABA00
000000018038B8A7  48 8D 05 1A F7 5F 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
000000018038B8AE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B8B5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B8B9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B8BD  48 8D 87 50 56 00 00        lea     rax, [rdi+5650h]
000000018038B8C4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B8CB  0F 57 C0                    xorps   xmm0, xmm0
000000018038B8CE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B8D2  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B8D6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B8DB  E8 20 01 02 00              call    sub_1803ABA00
000000018038B8E0  66 0F 6F 05 48 07 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B8E8  48 8D 05 E9 F6 5F 00        lea     rax, aLfoRate; "LFO Rate"
000000018038B8EF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B8F3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B8F7  48 8D 87 60 56 00 00        lea     rax, [rdi+5660h]
000000018038B8FE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B905  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B909  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B90D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B912  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B919  E8 E2 00 02 00              call    sub_1803ABA00
000000018038B91E  48 8D 05 BF F6 5F 00        lea     rax, aGate; "Gate"
000000018038B925  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B92C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B930  0F 57 C0                    xorps   xmm0, xmm0
000000018038B933  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B93A  48 8D 87 60 59 00 00        lea     rax, [rdi+5960h]
000000018038B941  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B945  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B949  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B94D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B952  E8 A9 00 02 00              call    sub_1803ABA00
000000018038B957  48 8D 05 92 F6 5F 00        lea     rax, aLfoTrig; "LFO Trig"
000000018038B95E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B965  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B969  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B96D  48 8D 87 70 59 00 00        lea     rax, [rdi+5970h]
000000018038B974  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B97B  0F 57 C0                    xorps   xmm0, xmm0
000000018038B97E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B982  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B986  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B98B  E8 70 00 02 00              call    sub_1803ABA00
000000018038B990  48 8D 05 69 F6 5F 00        lea     rax, aResetSw; "Reset Sw"
000000018038B997  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B99E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B9A2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B9A6  48 8D 87 80 59 00 00        lea     rax, [rdi+5980h]
000000018038B9AD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038B9B4  0F 57 C0                    xorps   xmm0, xmm0
000000018038B9B7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B9BB  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B9BF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B9C4  E8 37 00 02 00              call    sub_1803ABA00
000000018038B9C9  66 0F 6F 05 5F 06 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038B9D1  48 8D 05 38 F6 5F 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
000000018038B9D8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038B9DC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038B9E0  48 8D 87 90 59 00 00        lea     rax, [rdi+5990h]
000000018038B9E7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038B9EE  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038B9F2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038B9F6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038B9FB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BA02  E8 F9 FF 01 00              call    sub_1803ABA00
000000018038BA07  66 0F 6F 05 21 06 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BA0F  48 8D 05 0A F6 5F 00        lea     rax, aLfoDelay; "LFO Delay"
000000018038BA16  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BA1A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BA1E  48 8D 87 A0 59 00 00        lea     rax, [rdi+59A0h]
000000018038BA25  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BA2C  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BA30  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BA34  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BA39  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BA40  E8 BB FF 01 00              call    sub_1803ABA00
000000018038BA45  66 0F 6F 05 E3 05 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BA4D  48 8D 05 DC F5 5F 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
000000018038BA54  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BA58  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BA5C  48 8D 87 B0 59 00 00        lea     rax, [rdi+59B0h]
000000018038BA63  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BA6A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BA6E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BA72  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BA77  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BA7E  E8 7D FF 01 00              call    sub_1803ABA00
000000018038BA83  66 0F 6F 05 A5 05 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BA8B  48 8D 05 AE F5 5F 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
000000018038BA92  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BA96  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BA9A  48 8D 87 C0 59 00 00        lea     rax, [rdi+59C0h]
000000018038BAA1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BAA8  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BAAC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BAB0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BAB5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BABC  E8 3F FF 01 00              call    sub_1803ABA00
000000018038BAC1  66 0F 6F 05 67 05 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BAC9  48 8D 05 80 F5 5F 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
000000018038BAD0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BAD4  48 8D 87 D0 59 00 00        lea     rax, [rdi+59D0h]
000000018038BADB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BAE2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BAE7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BAEE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BAF2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BAF6  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BAFA  E8 01 FF 01 00              call    sub_1803ABA00
000000018038BAFF  66 0F 6F 05 29 05 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BB07  48 8D 05 52 F5 5F 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
000000018038BB0E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BB12  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BB16  48 8D 87 E0 59 00 00        lea     rax, [rdi+59E0h]
000000018038BB1D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BB24  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BB28  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BB2C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BB31  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BB38  E8 C3 FE 01 00              call    sub_1803ABA00
000000018038BB3D  66 0F 6F 05 EB 04 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BB45  48 8D 05 24 F5 5F 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
000000018038BB4C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BB50  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BB54  48 8D 87 F0 59 00 00        lea     rax, [rdi+59F0h]
000000018038BB5B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BB62  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BB66  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BB6A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BB6F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BB76  E8 85 FE 01 00              call    sub_1803ABA00
000000018038BB7B  66 0F 6F 05 AD 04 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BB83  48 8D 05 F6 F4 5F 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
000000018038BB8A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BB8E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BB92  48 8D 87 00 5A 00 00        lea     rax, [rdi+5A00h]
000000018038BB99  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BBA0  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BBA4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BBA8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BBAD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BBB4  E8 47 FE 01 00              call    sub_1803ABA00
000000018038BBB9  66 0F 6F 05 6F 04 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BBC1  48 8D 05 C8 F4 5F 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
000000018038BBC8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BBCC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BBD0  48 8D 87 10 5A 00 00        lea     rax, [rdi+5A10h]
000000018038BBD7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BBDE  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BBE2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BBE6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BBEB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BBF2  E8 09 FE 01 00              call    sub_1803ABA00
000000018038BBF7  66 0F 6F 05 31 04 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BBFF  48 8D 05 9A F4 5F 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
000000018038BC06  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BC0A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BC0E  48 8D 87 20 5A 00 00        lea     rax, [rdi+5A20h]
000000018038BC15  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BC1C  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BC20  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BC24  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BC29  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BC30  E8 CB FD 01 00              call    sub_1803ABA00
000000018038BC35  66 0F 6F 05 F3 03 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BC3D  48 8D 05 6C F4 5F 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
000000018038BC44  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BC48  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BC4C  48 8D 87 30 5A 00 00        lea     rax, [rdi+5A30h]
000000018038BC53  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BC5A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BC5E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BC62  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BC67  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BC6E  E8 8D FD 01 00              call    sub_1803ABA00
000000018038BC73  66 0F 6F 05 B5 03 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BC7B  48 8D 05 3E F4 5F 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
000000018038BC82  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BC86  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BC8A  48 8D 87 40 5A 00 00        lea     rax, [rdi+5A40h]
000000018038BC91  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BC98  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BC9C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BCA0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BCA5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BCAC  E8 4F FD 01 00              call    sub_1803ABA00
000000018038BCB1  66 0F 6F 05 77 03 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BCB9  48 8D 05 10 F4 5F 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
000000018038BCC0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BCC4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BCC8  48 8D 87 50 5A 00 00        lea     rax, [rdi+5A50h]
000000018038BCCF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BCD6  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BCDA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BCDE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BCE3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BCEA  E8 11 FD 01 00              call    sub_1803ABA00
000000018038BCEF  66 0F 6F 05 39 03 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BCF7  48 8D 05 EA F3 5F 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
000000018038BCFE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BD02  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BD06  48 8D 87 60 5A 00 00        lea     rax, [rdi+5A60h]
000000018038BD0D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BD14  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BD18  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BD1C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BD21  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BD28  E8 D3 FC 01 00              call    sub_1803ABA00
000000018038BD2D  48 8D 05 CC F3 5F 00        lea     rax, aReadOnly; "read only"
000000018038BD34  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BD3B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BD3F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BD43  48 8D 87 00 5C 00 00        lea     rax, [rdi+5C00h]
000000018038BD4A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BD51  0F 57 C0                    xorps   xmm0, xmm0
000000018038BD54  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BD58  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BD5C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BD61  E8 9A FC 01 00              call    sub_1803ABA00
000000018038BD66  48 8D 05 93 F3 5F 00        lea     rax, aReadOnly; "read only"
000000018038BD6D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BD74  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BD78  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BD7C  48 8D 87 10 5C 00 00        lea     rax, [rdi+5C10h]
000000018038BD83  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BD8A  0F 57 C0                    xorps   xmm0, xmm0
000000018038BD8D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BD91  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BD95  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BD9A  E8 61 FC 01 00              call    sub_1803ABA00
000000018038BD9F  48 8D 05 6A F3 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
000000018038BDA6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BDAD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BDB1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BDB5  48 8D 87 20 5C 00 00        lea     rax, [rdi+5C20h]
000000018038BDBC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BDC3  0F 57 C0                    xorps   xmm0, xmm0
000000018038BDC6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BDCA  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BDCE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BDD3  E8 28 FC 01 00              call    sub_1803ABA00
000000018038BDD8  66 0F 6F 05 50 02 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BDE0  48 8D 05 41 F3 5F 00        lea     rax, aEnvAttack; "ENV Attack"
000000018038BDE7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BDEB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BDEF  48 8D 87 00 5D 00 00        lea     rax, [rdi+5D00h]
000000018038BDF6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BDFD  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BE01  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BE05  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BE0A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BE11  E8 EA FB 01 00              call    sub_1803ABA00
000000018038BE16  66 0F 6F 05 12 02 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BE1E  48 8D 05 13 F3 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
000000018038BE25  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BE29  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BE2D  48 8D 87 10 5D 00 00        lea     rax, [rdi+5D10h]
000000018038BE34  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BE3B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BE3F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BE43  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BE48  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BE4F  E8 AC FB 01 00              call    sub_1803ABA00
000000018038BE54  66 0F 6F 05 D4 01 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BE5C  48 8D 05 E5 F2 5F 00        lea     rax, aEnvDecay; "ENV Decay"
000000018038BE63  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BE67  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BE6E  48 8D 87 20 5D 00 00        lea     rax, [rdi+5D20h]
000000018038BE75  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BE7C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BE80  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BE84  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BE88  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BE8D  E8 6E FB 01 00              call    sub_1803ABA00
000000018038BE92  66 0F 6F 05 96 01 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BE9A  48 8D 05 B7 F2 5F 00        lea     rax, aEnvRelease; "ENV Release"
000000018038BEA1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BEA5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BEA9  48 8D 87 30 5D 00 00        lea     rax, [rdi+5D30h]
000000018038BEB0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BEB7  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BEBB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BEBF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BEC4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BECB  E8 30 FB 01 00              call    sub_1803ABA00
000000018038BED0  66 0F 6F 05 58 01 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BED8  48 8D 05 89 F2 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
000000018038BEDF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BEE3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BEE7  48 8D 87 40 5D 00 00        lea     rax, [rdi+5D40h]
000000018038BEEE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BEF5  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BEF9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BEFD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BF02  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BF09  E8 F2 FA 01 00              call    sub_1803ABA00
000000018038BF0E  48 8D 05 FB F1 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
000000018038BF15  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BF1C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BF20  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BF24  48 8D 87 00 5E 00 00        lea     rax, [rdi+5E00h]
000000018038BF2B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BF32  0F 57 C0                    xorps   xmm0, xmm0
000000018038BF35  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BF39  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BF3D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BF42  E8 B9 FA 01 00              call    sub_1803ABA00
000000018038BF47  66 0F 6F 05 E1 00 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BF4F  48 8D 05 D2 F1 5F 00        lea     rax, aEnvAttack; "ENV Attack"
000000018038BF56  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BF5A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BF5E  48 8D 87 E0 5E 00 00        lea     rax, [rdi+5EE0h]
000000018038BF65  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BF6C  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BF70  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BF74  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BF79  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BF80  E8 7B FA 01 00              call    sub_1803ABA00
000000018038BF85  66 0F 6F 05 A3 00 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BF8D  48 8D 05 A4 F1 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
000000018038BF94  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BF98  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BF9C  48 8D 87 F0 5E 00 00        lea     rax, [rdi+5EF0h]
000000018038BFA3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BFAA  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BFAE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BFB2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BFB7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BFBE  E8 3D FA 01 00              call    sub_1803ABA00
000000018038BFC3  66 0F 6F 05 65 00 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038BFCB  48 8D 05 76 F1 5F 00        lea     rax, aEnvDecay; "ENV Decay"
000000018038BFD2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038BFD6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038BFDA  48 8D 87 00 5F 00 00        lea     rax, [rdi+5F00h]
000000018038BFE1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038BFE8  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038BFEC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038BFF0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038BFF5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038BFFC  E8 FF F9 01 00              call    sub_1803ABA00
000000018038C001  66 0F 6F 05 27 00 60 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C009  48 8D 05 48 F1 5F 00        lea     rax, aEnvRelease; "ENV Release"
000000018038C010  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C014  48 8D 87 10 5F 00 00        lea     rax, [rdi+5F10h]
000000018038C01B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C01F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C026  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C02B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C032  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C036  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C03A  E8 C1 F9 01 00              call    sub_1803ABA00
000000018038C03F  66 0F 6F 05 E9 FF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C047  48 8D 05 1A F1 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
000000018038C04E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C052  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C056  48 8D 87 20 5F 00 00        lea     rax, [rdi+5F20h]
000000018038C05D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C064  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C068  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C06C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C071  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C078  E8 83 F9 01 00              call    sub_1803ABA00
000000018038C07D  48 8D 05 F4 F0 5F 00        lea     rax, aOsc1Feet; "OSC1 Feet"
000000018038C084  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C08B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C08F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C093  48 8D 87 20 61 00 00        lea     rax, [rdi+6120h]
000000018038C09A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C0A1  0F 57 C0                    xorps   xmm0, xmm0
000000018038C0A4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C0A8  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C0AC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C0B1  E8 4A F9 01 00              call    sub_1803ABA00
000000018038C0B6  48 8D 05 CB F0 5F 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
000000018038C0BD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C0C4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C0C8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C0CC  48 8D 87 30 61 00 00        lea     rax, [rdi+6130h]
000000018038C0D3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C0DA  0F 57 C0                    xorps   xmm0, xmm0
000000018038C0DD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C0E1  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C0E5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C0EA  E8 11 F9 01 00              call    sub_1803ABA00
000000018038C0EF  48 8D 05 A2 F0 5F 00        lea     rax, aBendEnableSw; "Bend Enable SW"
000000018038C0F6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C0FD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C101  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C105  48 8D 87 40 61 00 00        lea     rax, [rdi+6140h]
000000018038C10C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C113  0F 57 C0                    xorps   xmm0, xmm0
000000018038C116  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C11A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C11E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C123  E8 D8 F8 01 00              call    sub_1803ABA00
000000018038C128  48 8D 05 79 F0 5F 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
000000018038C12F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C136  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C13A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C13E  48 8D 87 50 61 00 00        lea     rax, [rdi+6150h]
000000018038C145  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C14C  0F 57 C0                    xorps   xmm0, xmm0
000000018038C14F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C153  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C157  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C15C  E8 9F F8 01 00              call    sub_1803ABA00
000000018038C161  48 8D 05 50 F0 5F 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
000000018038C168  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C16F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C173  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C177  48 8D 87 60 61 00 00        lea     rax, [rdi+6160h]
000000018038C17E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C185  0F 57 C0                    xorps   xmm0, xmm0
000000018038C188  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C18C  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C190  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C195  E8 66 F8 01 00              call    sub_1803ABA00
000000018038C19A  48 8D 05 27 F0 5F 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
000000018038C1A1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C1A8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C1AC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C1B0  48 8D 87 70 61 00 00        lea     rax, [rdi+6170h]
000000018038C1B7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C1BE  0F 57 C0                    xorps   xmm0, xmm0
000000018038C1C1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C1C5  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C1C9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C1CE  E8 2D F8 01 00              call    sub_1803ABA00
000000018038C1D3  48 8D 05 FE EF 5F 00        lea     rax, aPwmSwManual; "PWM SW Manual"
000000018038C1DA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C1DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C1E2  48 8D 87 80 61 00 00        lea     rax, [rdi+6180h]
000000018038C1E9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C1F0  0F 57 C0                    xorps   xmm0, xmm0
000000018038C1F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C1F7  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C1FB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C202  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C207  E8 F4 F7 01 00              call    sub_1803ABA00
000000018038C20C  66 0F 6F 05 1C FE 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C214  48 8D 05 CD EF 5F 00        lea     rax, aTune; "Tune"
000000018038C21B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C21F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C223  48 8D 87 90 61 00 00        lea     rax, [rdi+6190h]
000000018038C22A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C231  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C235  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C239  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C23E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C245  E8 B6 F7 01 00              call    sub_1803ABA00
000000018038C24A  66 0F 6F 05 DE FD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C252  48 8D 05 97 EF 5F 00        lea     rax, aDetune; "Detune"
000000018038C259  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C25D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C261  48 8D 87 A0 61 00 00        lea     rax, [rdi+61A0h]
000000018038C268  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C26F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C273  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C277  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C27C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C283  E8 78 F7 01 00              call    sub_1803ABA00
000000018038C288  66 0F 6F 05 A0 FD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C290  48 8D 05 61 EF 5F 00        lea     rax, aModSens; "Mod Sens"
000000018038C297  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C29B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C29F  48 8D 87 B0 61 00 00        lea     rax, [rdi+61B0h]
000000018038C2A6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C2AD  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C2B1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C2B5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C2BA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C2C1  E8 3A F7 01 00              call    sub_1803ABA00
000000018038C2C6  66 0F 6F 05 62 FD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C2CE  48 8D 05 2F EF 5F 00        lea     rax, aModSw; "Mod Sw"
000000018038C2D5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C2D9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C2DD  48 8D 87 C0 61 00 00        lea     rax, [rdi+61C0h]
000000018038C2E4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C2EB  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C2EF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C2F3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C2F8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C2FF  E8 FC F6 01 00              call    sub_1803ABA00
000000018038C304  66 0F 6F 05 24 FD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C30C  48 8D 05 FD EE 5F 00        lea     rax, aLfoGain; "LFO Gain"
000000018038C313  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C317  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C31B  48 8D 87 D0 61 00 00        lea     rax, [rdi+61D0h]
000000018038C322  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C329  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C32D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C331  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C336  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C33D  E8 BE F6 01 00              call    sub_1803ABA00
000000018038C342  66 0F 6F 05 E6 FC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C34A  48 8D 05 CF EE 5F 00        lea     rax, aLfoLevel; "LFO Level"
000000018038C351  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C355  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C359  48 8D 87 E0 61 00 00        lea     rax, [rdi+61E0h]
000000018038C360  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C367  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C36B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C36F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C374  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C37B  E8 80 F6 01 00              call    sub_1803ABA00
000000018038C380  66 0F 6F 05 A8 FC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C388  48 8D 05 9D EE 5F 00        lea     rax, aLfoSw; "LFO Sw"
000000018038C38F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C393  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C398  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C39F  48 8D 87 F0 61 00 00        lea     rax, [rdi+61F0h]
000000018038C3A6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C3AD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C3B1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C3B5  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C3B9  E8 42 F6 01 00              call    sub_1803ABA00
000000018038C3BE  66 0F 6F 05 6A FC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C3C6  48 8D 05 6B EE 5F 00        lea     rax, aEnv1Level; "ENV1 Level"
000000018038C3CD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C3D1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C3D5  48 8D 87 00 62 00 00        lea     rax, [rdi+6200h]
000000018038C3DC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C3E3  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C3E7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C3EB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C3F0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C3F7  E8 04 F6 01 00              call    sub_1803ABA00
000000018038C3FC  66 0F 6F 05 2C FC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C404  48 8D 05 3D EE 5F 00        lea     rax, aEnv2Level; "ENV2 Level"
000000018038C40B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C40F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C413  48 8D 87 10 62 00 00        lea     rax, [rdi+6210h]
000000018038C41A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C421  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C425  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C429  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C42E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C435  E8 C6 F5 01 00              call    sub_1803ABA00
000000018038C43A  66 0F 6F 05 EE FB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C442  48 8D 05 0B EE 5F 00        lea     rax, aEnvSw; "ENV Sw"
000000018038C449  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C44D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C451  48 8D 87 20 62 00 00        lea     rax, [rdi+6220h]
000000018038C458  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C45F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C463  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C467  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C46C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C473  E8 88 F5 01 00              call    sub_1803ABA00
000000018038C478  66 0F 6F 05 B0 FB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C480  48 8D 05 D9 ED 5F 00        lea     rax, aBendLevel; "Bend Level"
000000018038C487  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C48B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C48F  48 8D 87 30 62 00 00        lea     rax, [rdi+6230h]
000000018038C496  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C49D  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C4A1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C4A5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C4AA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C4B1  E8 4A F5 01 00              call    sub_1803ABA00
000000018038C4B6  66 0F 6F 05 72 FB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C4BE  48 8D 05 AB ED 5F 00        lea     rax, aBendRange; "Bend Range"
000000018038C4C5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C4C9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C4CD  48 8D 87 40 62 00 00        lea     rax, [rdi+6240h]
000000018038C4D4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C4DB  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C4DF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C4E3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C4E8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C4EF  E8 0C F5 01 00              call    sub_1803ABA00
000000018038C4F4  66 0F 6F 05 34 FB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C4FC  48 8D 05 7D ED 5F 00        lea     rax, aPwmLevel; "PWM Level"
000000018038C503  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C507  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C50B  48 8D 87 50 62 00 00        lea     rax, [rdi+6250h]
000000018038C512  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C519  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C51D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C521  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C526  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C52D  E8 CE F4 01 00              call    sub_1803ABA00
000000018038C532  66 0F 6F 05 F6 FA 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C53A  48 8D 05 4F ED 5F 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
000000018038C541  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C545  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C549  48 8D 87 80 62 00 00        lea     rax, [rdi+6280h]
000000018038C550  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C557  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C55B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C560  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C567  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C56B  E8 90 F4 01 00              call    sub_1803ABA00
000000018038C570  66 0F 6F 05 B8 FA 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C578  48 8D 05 21 ED 5F 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
000000018038C57F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C583  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C587  48 8D 87 90 62 00 00        lea     rax, [rdi+6290h]
000000018038C58E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C595  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C599  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C59D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C5A2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C5A9  E8 52 F4 01 00              call    sub_1803ABA00
000000018038C5AE  66 0F 6F 05 7A FA 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C5B6  48 8D 05 F3 EC 5F 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
000000018038C5BD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C5C1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C5C5  48 8D 87 A0 62 00 00        lea     rax, [rdi+62A0h]
000000018038C5CC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C5D3  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C5D7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C5DB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C5E0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C5E7  E8 14 F4 01 00              call    sub_1803ABA00
000000018038C5EC  66 0F 6F 05 3C FA 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C5F4  48 8D 05 C5 EC 5F 00        lea     rax, aDutyTune; "Duty Tune"
000000018038C5FB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C5FF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C603  48 8D 87 B0 67 00 00        lea     rax, [rdi+67B0h]
000000018038C60A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C611  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C615  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C619  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C61E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C625  E8 D6 F3 01 00              call    sub_1803ABA00
000000018038C62A  66 0F 6F 05 FE F9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C632  48 8D 05 97 EC 5F 00        lea     rax, aOsc1Mute; "Osc1 Mute"
000000018038C639  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C63D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C641  48 8D 87 50 6B 00 00        lea     rax, [rdi+6B50h]
000000018038C648  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C64F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C653  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C657  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C65C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C663  E8 98 F3 01 00              call    sub_1803ABA00
000000018038C668  66 0F 6F 05 C0 F9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C670  48 8D 05 69 EC 5F 00        lea     rax, aOsc1Level; "Osc1 Level"
000000018038C677  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C67B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C67F  48 8D 87 90 6B 00 00        lea     rax, [rdi+6B90h]
000000018038C686  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C68D  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C691  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C695  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C69A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C6A1  E8 5A F3 01 00              call    sub_1803ABA00
000000018038C6A6  66 0F 6F 05 82 F9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C6AE  48 8D 05 3B EC 5F 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
000000018038C6B5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C6B9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C6BD  48 8D 87 A0 6B 00 00        lea     rax, [rdi+6BA0h]
000000018038C6C4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C6CB  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C6CF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C6D3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C6D8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C6DF  E8 1C F3 01 00              call    sub_1803ABA00
000000018038C6E4  48 8D 05 15 EC 5F 00        lea     rax, aGrifferSw; "Griffer SW"
000000018038C6EB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C6F2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C6F6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C6FA  48 8D 87 60 6C 00 00        lea     rax, [rdi+6C60h]
000000018038C701  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C708  0F 57 C0                    xorps   xmm0, xmm0
000000018038C70B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C70F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C713  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C718  E8 E3 F2 01 00              call    sub_1803ABA00
000000018038C71D  48 8D 05 EC EB 5F 00        lea     rax, aLpfCutoff; "LPF Cutoff"
000000018038C724  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C728  66 0F 6F 05 00 F9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C730  48 8D 87 70 6C 00 00        lea     rax, [rdi+6C70h]
000000018038C737  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C73B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C73F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C743  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C74A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C74F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C756  E8 A5 F2 01 00              call    sub_1803ABA00
000000018038C75B  66 0F 6F 05 CD F8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C763  48 8D 05 B6 EB 5F 00        lea     rax, aLpfResonance; "LPF Resonance"
000000018038C76A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C76E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C772  48 8D 87 D0 6C 00 00        lea     rax, [rdi+6CD0h]
000000018038C779  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C780  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C784  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C788  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C78D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C794  E8 67 F2 01 00              call    sub_1803ABA00
000000018038C799  48 8D 05 90 EB 5F 00        lea     rax, aVelocity; "Velocity"
000000018038C7A0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C7A7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C7AB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C7AF  48 8D 87 F0 6C 00 00        lea     rax, [rdi+6CF0h]
000000018038C7B6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C7BD  0F 57 C0                    xorps   xmm0, xmm0
000000018038C7C0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C7C4  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C7C8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C7CD  E8 2E F2 01 00              call    sub_1803ABA00
000000018038C7D2  48 8D 05 63 EB 5F 00        lea     rax, aEnv12; "Env1/2"
000000018038C7D9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C7E0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C7E4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C7E8  48 8D 87 80 6D 00 00        lea     rax, [rdi+6D80h]
000000018038C7EF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C7F6  0F 57 C0                    xorps   xmm0, xmm0
000000018038C7F9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C7FD  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C801  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C806  E8 F5 F1 01 00              call    sub_1803ABA00
000000018038C80B  48 8D 05 36 EB 5F 00        lea     rax, aIntEnv; "Int/Env"
000000018038C812  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C819  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C81D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C821  48 8D 87 90 6D 00 00        lea     rax, [rdi+6D90h]
000000018038C828  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C82F  0F 57 C0                    xorps   xmm0, xmm0
000000018038C832  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C836  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C83A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C83F  E8 BC F1 01 00              call    sub_1803ABA00
000000018038C844  48 8D 05 C5 E9 5F 00        lea     rax, aLfoGain; "LFO Gain"
000000018038C84B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C852  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C856  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C85A  48 8D 87 A0 6E 00 00        lea     rax, [rdi+6EA0h]
000000018038C861  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C868  0F 57 C0                    xorps   xmm0, xmm0
000000018038C86B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C86F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C873  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C878  E8 83 F1 01 00              call    sub_1803ABA00
000000018038C87D  48 8D 05 CC EA 5F 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
000000018038C884  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C88B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C88F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C893  48 8D 87 B0 6E 00 00        lea     rax, [rdi+6EB0h]
000000018038C89A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C8A1  0F 57 C0                    xorps   xmm0, xmm0
000000018038C8A4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C8A8  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C8AC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C8B1  E8 4A F1 01 00              call    sub_1803ABA00
000000018038C8B6  48 8D 05 A3 EA 5F 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
000000018038C8BD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C8C4  0F 57 C0                    xorps   xmm0, xmm0
000000018038C8C7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C8CB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C8D0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C8D7  48 8D 87 C0 6E 00 00        lea     rax, [rdi+6EC0h]
000000018038C8DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C8E2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C8E6  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C8EA  E8 11 F1 01 00              call    sub_1803ABA00
000000018038C8EF  66 0F 6F 05 39 F7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C8F7  48 8D 05 22 E9 5F 00        lea     rax, aLfoLevel; "LFO Level"
000000018038C8FE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C902  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C906  48 8D 87 D0 6E 00 00        lea     rax, [rdi+6ED0h]
000000018038C90D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C914  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C918  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C91C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C921  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C928  E8 D3 F0 01 00              call    sub_1803ABA00
000000018038C92D  66 0F 6F 05 FB F6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C935  48 8D 05 34 EA 5F 00        lea     rax, aModSens_0; "MOD Sens"
000000018038C93C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C940  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C944  48 8D 87 E0 6E 00 00        lea     rax, [rdi+6EE0h]
000000018038C94B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C952  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C956  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C95A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C95F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C966  E8 95 F0 01 00              call    sub_1803ABA00
000000018038C96B  66 0F 6F 05 BD F6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C973  48 8D 05 02 EA 5F 00        lea     rax, aModSw_0; "MOD SW"
000000018038C97A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C97E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C982  48 8D 87 F0 6E 00 00        lea     rax, [rdi+6EF0h]
000000018038C989  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C990  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C994  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C998  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C99D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C9A4  E8 57 F0 01 00              call    sub_1803ABA00
000000018038C9A9  66 0F 6F 05 7F F6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C9B1  48 8D 05 D0 E9 5F 00        lea     rax, aEnvLevel; "ENV Level"
000000018038C9B8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C9BC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C9C0  48 8D 87 00 6F 00 00        lea     rax, [rdi+6F00h]
000000018038C9C7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038C9CE  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038C9D2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038C9D6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038C9DB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038C9E2  E8 19 F0 01 00              call    sub_1803ABA00
000000018038C9E7  66 0F 6F 05 41 F6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038C9EF  48 8D 05 A2 E9 5F 00        lea     rax, aKcvLevel; "KCV Level"
000000018038C9F6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038C9FA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038C9FE  48 8D 87 10 6F 00 00        lea     rax, [rdi+6F10h]
000000018038CA05  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CA0C  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CA10  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CA14  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CA19  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CA20  E8 DB EF 01 00              call    sub_1803ABA00
000000018038CA25  66 0F 6F 05 03 F6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CA2D  48 8D 05 74 E9 5F 00        lea     rax, aVelocitySens; "Velocity Sens"
000000018038CA34  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CA38  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CA3C  48 8D 87 20 6F 00 00        lea     rax, [rdi+6F20h]
000000018038CA43  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CA4A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CA4E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CA52  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CA57  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CA5E  E8 9D EF 01 00              call    sub_1803ABA00
000000018038CA63  66 0F 6F 05 C5 F5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CA6B  48 8D 05 46 E9 5F 00        lea     rax, aVelocityOffset; "Velocity Offset"
000000018038CA72  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CA76  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CA7A  48 8D 87 30 6F 00 00        lea     rax, [rdi+6F30h]
000000018038CA81  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CA88  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CA8C  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CA90  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CA95  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CA9C  E8 5F EF 01 00              call    sub_1803ABA00
000000018038CAA1  66 0F 6F 05 87 F5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CAA9  48 8D 05 B0 E7 5F 00        lea     rax, aBendLevel; "Bend Level"
000000018038CAB0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CAB4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CAB8  48 8D 87 40 6F 00 00        lea     rax, [rdi+6F40h]
000000018038CABF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CAC6  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CACA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CACE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CAD3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CADA  E8 21 EF 01 00              call    sub_1803ABA00
000000018038CADF  66 0F 6F 05 49 F5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CAE7  48 8D 05 82 E7 5F 00        lea     rax, aBendRange; "Bend Range"
000000018038CAEE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CAF2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CAF6  48 8D 87 50 6F 00 00        lea     rax, [rdi+6F50h]
000000018038CAFD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CB04  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CB08  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CB0C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CB11  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CB18  E8 E3 EE 01 00              call    sub_1803ABA00
000000018038CB1D  66 0F 6F 05 0B F5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CB25  48 8D 05 9C E8 5F 00        lea     rax, aCutoffTune; "Cutoff Tune"
000000018038CB2C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CB30  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CB34  48 8D 87 D0 6F 00 00        lea     rax, [rdi+6FD0h]
000000018038CB3B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CB42  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CB46  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CB4A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CB4F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CB56  E8 A5 EE 01 00              call    sub_1803ABA00
000000018038CB5B  66 0F 6F 05 CD F4 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CB63  48 8D 05 6E E8 5F 00        lea     rax, aResonanceTune; "Resonance Tune"
000000018038CB6A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CB6E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CB72  48 8D 87 E0 6F 00 00        lea     rax, [rdi+6FE0h]
000000018038CB79  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CB80  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CB84  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CB88  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CB8D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CB94  E8 67 EE 01 00              call    sub_1803ABA00
000000018038CB99  48 8D 05 48 E8 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
000000018038CBA0  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
000000018038CBA7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CBAB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CBAF  48 8D 87 F0 6F 00 00        lea     rax, [rdi+6FF0h]
000000018038CBB6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CBBD  0F 57 C0                    xorps   xmm0, xmm0
000000018038CBC0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CBC4  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CBC8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CBCD  E8 2E EE 01 00              call    sub_1803ABA00
000000018038CBD2  48 8D 05 0F E8 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
000000018038CBD9  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
000000018038CBE0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CBE4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CBE8  48 8D 87 80 75 00 00        lea     rax, [rdi+7580h]
000000018038CBEF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CBF6  0F 57 C0                    xorps   xmm0, xmm0
000000018038CBF9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CBFD  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CC01  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CC06  E8 F5 ED 01 00              call    sub_1803ABA00
000000018038CC0B  66 0F 6F 05 1D F4 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CC13  48 8D 05 DE E7 5F 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
000000018038CC1A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CC1E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CC22  48 8D 87 90 75 00 00        lea     rax, [rdi+7590h]
000000018038CC29  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CC30  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CC34  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CC38  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CC3D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CC44  E8 B7 ED 01 00              call    sub_1803ABA00
000000018038CC49  48 8D 05 B8 E7 5F 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
000000018038CC50  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CC57  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CC5B  66 0F 6F 05 CD F3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CC63  48 8D 87 A0 75 00 00        lea     rax, [rdi+75A0h]
000000018038CC6A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CC6E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CC72  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CC76  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CC7D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CC82  E8 79 ED 01 00              call    sub_1803ABA00
000000018038CC87  66 0F 6F 05 A1 F3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CC8F  48 8D 05 82 E7 5F 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
000000018038CC96  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CC9A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CC9E  48 8D 87 B0 75 00 00        lea     rax, [rdi+75B0h]
000000018038CCA5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CCAC  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CCB0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CCB4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CCB9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CCC0  E8 3B ED 01 00              call    sub_1803ABA00
000000018038CCC5  66 0F 6F 05 63 F3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CCCD  48 8D 05 54 E7 5F 00        lea     rax, aAmpTone; "AMP TONE"
000000018038CCD4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CCD8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CCDC  48 8D 87 90 77 00 00        lea     rax, [rdi+7790h]
000000018038CCE3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CCEA  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CCEE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CCF2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CCF7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CCFE  E8 FD EC 01 00              call    sub_1803ABA00
000000018038CD03  66 0F 6F 05 25 F3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CD0B  48 8D 05 26 E7 5F 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
000000018038CD12  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CD16  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CD1A  48 8D 87 A0 77 00 00        lea     rax, [rdi+77A0h]
000000018038CD21  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CD28  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CD2C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CD30  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CD35  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CD3C  E8 BF EC 01 00              call    sub_1803ABA00
000000018038CD41  66 0F 6F 05 E7 F2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CD49  48 8D 05 00 E7 5F 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
000000018038CD50  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CD54  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CD58  48 8D 87 B0 77 00 00        lea     rax, [rdi+77B0h]
000000018038CD5F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CD66  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CD6A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CD6E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CD73  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CD7A  E8 81 EC 01 00              call    sub_1803ABA00
000000018038CD7F  48 8D 05 AA E5 5F 00        lea     rax, aVelocity; "Velocity"
000000018038CD86  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CD8D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CD91  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CD95  48 8D 87 F0 77 00 00        lea     rax, [rdi+77F0h]
000000018038CD9C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CDA3  0F 57 C0                    xorps   xmm0, xmm0
000000018038CDA6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CDAA  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CDAE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CDB3  E8 48 EC 01 00              call    sub_1803ABA00
000000018038CDB8  48 8D 05 A9 E6 5F 00        lea     rax, aMute; "Mute"
000000018038CDBF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CDC6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CDCA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CDCE  48 8D 87 80 78 00 00        lea     rax, [rdi+7880h]
000000018038CDD5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CDDC  0F 57 C0                    xorps   xmm0, xmm0
000000018038CDDF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CDE3  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CDE7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CDEC  E8 0F EC 01 00              call    sub_1803ABA00
000000018038CDF1  48 8D 05 78 E6 5F 00        lea     rax, aGateSw; "Gate SW"
000000018038CDF8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CDFF  0F 57 C0                    xorps   xmm0, xmm0
000000018038CE02  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CE06  48 8D 87 E0 79 00 00        lea     rax, [rdi+79E0h]
000000018038CE0D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CE14  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CE19  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CE1D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CE21  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CE25  E8 D6 EB 01 00              call    sub_1803ABA00
000000018038CE2A  48 8D 05 47 E6 5F 00        lea     rax, aEnv1Sw; "ENV1 SW"
000000018038CE31  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CE38  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CE3C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CE40  48 8D 87 F0 79 00 00        lea     rax, [rdi+79F0h]
000000018038CE47  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CE4E  0F 57 C0                    xorps   xmm0, xmm0
000000018038CE51  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CE55  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CE59  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CE5E  E8 9D EB 01 00              call    sub_1803ABA00
000000018038CE63  48 8D 05 16 E6 5F 00        lea     rax, aEnv2Sw; "ENV2 SW"
000000018038CE6A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CE71  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CE75  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CE79  48 8D 87 00 7A 00 00        lea     rax, [rdi+7A00h]
000000018038CE80  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CE87  0F 57 C0                    xorps   xmm0, xmm0
000000018038CE8A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CE8E  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CE92  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CE97  E8 64 EB 01 00              call    sub_1803ABA00
000000018038CE9C  48 8D 05 E5 E5 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
000000018038CEA3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CEAA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CEAE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CEB2  48 8D 87 10 7A 00 00        lea     rax, [rdi+7A10h]
000000018038CEB9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CEC0  0F 57 C0                    xorps   xmm0, xmm0
000000018038CEC3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CEC7  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CECB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CED0  E8 2B EB 01 00              call    sub_1803ABA00
000000018038CED5  66 0F 6F 05 53 F1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CEDD  48 8D 05 B4 E5 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
000000018038CEE4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CEE8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CEEC  48 8D 87 20 7A 00 00        lea     rax, [rdi+7A20h]
000000018038CEF3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CEFA  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CEFE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CF02  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CF07  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CF0E  E8 ED EA 01 00              call    sub_1803ABA00
000000018038CF13  66 0F 6F 05 15 F1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CF1B  48 8D 05 86 E5 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
000000018038CF22  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CF26  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CF2A  48 8D 87 30 7A 00 00        lea     rax, [rdi+7A30h]
000000018038CF31  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CF38  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CF3C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CF40  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CF45  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CF4C  E8 AF EA 01 00              call    sub_1803ABA00
000000018038CF51  66 0F 6F 05 D7 F0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CF59  48 8D 05 58 E5 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
000000018038CF60  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CF64  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CF68  48 8D 87 40 7A 00 00        lea     rax, [rdi+7A40h]
000000018038CF6F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CF76  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CF7A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CF7E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CF83  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CF8A  E8 71 EA 01 00              call    sub_1803ABA00
000000018038CF8F  66 0F 6F 05 99 F0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CF97  48 8D 05 2A E5 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
000000018038CF9E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CFA2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CFA6  48 8D 87 50 7A 00 00        lea     rax, [rdi+7A50h]
000000018038CFAD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CFB4  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CFB8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CFBC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CFC1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038CFC8  E8 33 EA 01 00              call    sub_1803ABA00
000000018038CFCD  66 0F 6F 05 5B F0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038CFD5  48 8D 05 04 E5 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
000000018038CFDC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038CFE0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038CFE4  48 8D 87 60 7A 00 00        lea     rax, [rdi+7A60h]
000000018038CFEB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038CFF2  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038CFF6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038CFFA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038CFFF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D006  E8 F5 E9 01 00              call    sub_1803ABA00
000000018038D00B  66 0F 6F 05 1D F0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D013  48 8D 05 D6 E4 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
000000018038D01A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D01E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D022  48 8D 87 70 7A 00 00        lea     rax, [rdi+7A70h]
000000018038D029  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D030  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D034  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D038  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D03D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D044  E8 B7 E9 01 00              call    sub_1803ABA00
000000018038D049  48 8D 05 D0 DE 5F 00        lea     rax, aUseextjack; "UseExtJack"
000000018038D050  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D057  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D05B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D05F  48 8D 87 40 7C 00 00        lea     rax, [rdi+7C40h]
000000018038D066  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D06D  0F 57 C0                    xorps   xmm0, xmm0
000000018038D070  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D074  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D078  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D07D  E8 7E E9 01 00              call    sub_1803ABA00
000000018038D082  48 8D 05 A3 DE 5F 00        lea     rax, aMCv; "M.CV"
000000018038D089  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D090  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D094  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D098  48 8D 87 60 7C 00 00        lea     rax, [rdi+7C60h]
000000018038D09F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D0A6  0F 57 C0                    xorps   xmm0, xmm0
000000018038D0A9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D0AD  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D0B1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D0B6  E8 45 E9 01 00              call    sub_1803ABA00
000000018038D0BB  48 8D 05 72 DE 5F 00        lea     rax, aMGate; "M.Gate"
000000018038D0C2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D0C9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D0CD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D0D1  48 8D 87 70 7C 00 00        lea     rax, [rdi+7C70h]
000000018038D0D8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D0DF  0F 57 C0                    xorps   xmm0, xmm0
000000018038D0E2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D0E6  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D0EA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D0EF  E8 0C E9 01 00              call    sub_1803ABA00
000000018038D0F4  66 0F 6F 05 34 EF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D0FC  48 8D 05 3D DE 5F 00        lea     rax, aMasterTune; "Master Tune"
000000018038D103  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D107  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D10B  48 8D 87 A0 7C 00 00        lea     rax, [rdi+7CA0h]
000000018038D112  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D119  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D11D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D121  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D126  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D12D  E8 CE E8 01 00              call    sub_1803ABA00
000000018038D132  66 0F 6F 05 F6 EE 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D13A  48 8D 05 0F DE 5F 00        lea     rax, aPartTune; "Part Tune"
000000018038D141  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D145  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D149  48 8D 87 B0 7C 00 00        lea     rax, [rdi+7CB0h]
000000018038D150  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D157  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D15B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D15F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D164  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D16B  E8 90 E8 01 00              call    sub_1803ABA00
000000018038D170  48 8D 05 E9 DD 5F 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
000000018038D177  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D17E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D182  0F 57 C0                    xorps   xmm0, xmm0
000000018038D185  48 8D 87 80 7D 00 00        lea     rax, [rdi+7D80h]
000000018038D18C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D193  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D197  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D19B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D19F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D1A4  E8 57 E8 01 00              call    sub_1803ABA00
000000018038D1A9  48 8D 05 C8 DD 5F 00        lea     rax, aPortamentoMode; "Portamento Mode"
000000018038D1B0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D1B7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D1BB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D1BF  48 8D 87 90 7D 00 00        lea     rax, [rdi+7D90h]
000000018038D1C6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D1CD  0F 57 C0                    xorps   xmm0, xmm0
000000018038D1D0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D1D4  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D1D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D1DD  E8 1E E8 01 00              call    sub_1803ABA00
000000018038D1E2  66 0F 6F 05 46 EE 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D1EA  48 8D 05 97 DD 5F 00        lea     rax, aPortamentoTime; "Portamento Time"
000000018038D1F1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D1F5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D1F9  48 8D 87 A0 7D 00 00        lea     rax, [rdi+7DA0h]
000000018038D200  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D207  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D20B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D20F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D214  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D21B  E8 E0 E7 01 00              call    sub_1803ABA00
000000018038D220  48 8D 05 71 DD 5F 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
000000018038D227  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D22E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D232  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D236  48 8D 87 40 7F 00 00        lea     rax, [rdi+7F40h]
000000018038D23D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D244  0F 57 C0                    xorps   xmm0, xmm0
000000018038D247  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D24B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D24F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D254  E8 A7 E7 01 00              call    sub_1803ABA00
000000018038D259  48 8D 05 50 DD 5F 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
000000018038D260  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D267  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D26B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D26F  48 8D 87 50 7F 00 00        lea     rax, [rdi+7F50h]
000000018038D276  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D27D  0F 57 C0                    xorps   xmm0, xmm0
000000018038D280  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D284  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D288  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D28D  E8 6E E7 01 00              call    sub_1803ABA00
000000018038D292  48 8D 05 2F DD 5F 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
000000018038D299  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D2A0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D2A4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D2A8  48 8D 87 60 7F 00 00        lea     rax, [rdi+7F60h]
000000018038D2AF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D2B6  0F 57 C0                    xorps   xmm0, xmm0
000000018038D2B9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D2BD  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D2C1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D2C6  E8 35 E7 01 00              call    sub_1803ABA00
000000018038D2CB  66 0F 6F 05 5D ED 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D2D3  48 8D 05 FE DC 5F 00        lea     rax, aLfoRate; "LFO Rate"
000000018038D2DA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D2DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D2E2  48 8D 87 70 7F 00 00        lea     rax, [rdi+7F70h]
000000018038D2E9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D2F0  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D2F4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D2F8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D2FD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D304  E8 F7 E6 01 00              call    sub_1803ABA00
000000018038D309  48 8D 05 D4 DC 5F 00        lea     rax, aGate; "Gate"
000000018038D310  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D317  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D31B  0F 57 C0                    xorps   xmm0, xmm0
000000018038D31E  48 8D 87 70 82 00 00        lea     rax, [rdi+8270h]
000000018038D325  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D32C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D330  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D335  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D339  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D33D  E8 BE E6 01 00              call    sub_1803ABA00
000000018038D342  48 8D 05 A7 DC 5F 00        lea     rax, aLfoTrig; "LFO Trig"
000000018038D349  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D350  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D354  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D358  48 8D 87 80 82 00 00        lea     rax, [rdi+8280h]
000000018038D35F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D366  0F 57 C0                    xorps   xmm0, xmm0
000000018038D369  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D36D  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D371  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D376  E8 85 E6 01 00              call    sub_1803ABA00
000000018038D37B  48 8D 05 7E DC 5F 00        lea     rax, aResetSw; "Reset Sw"
000000018038D382  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D389  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D38D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D391  48 8D 87 90 82 00 00        lea     rax, [rdi+8290h]
000000018038D398  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D39F  0F 57 C0                    xorps   xmm0, xmm0
000000018038D3A2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D3A6  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D3AA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D3AF  E8 4C E6 01 00              call    sub_1803ABA00
000000018038D3B4  66 0F 6F 05 74 EC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D3BC  48 8D 05 4D DC 5F 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
000000018038D3C3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D3C7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D3CB  48 8D 87 A0 82 00 00        lea     rax, [rdi+82A0h]
000000018038D3D2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D3D9  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D3DD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D3E1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D3E6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D3ED  E8 0E E6 01 00              call    sub_1803ABA00
000000018038D3F2  66 0F 6F 05 36 EC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D3FA  48 8D 05 1F DC 5F 00        lea     rax, aLfoDelay; "LFO Delay"
000000018038D401  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D405  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D409  48 8D 87 B0 82 00 00        lea     rax, [rdi+82B0h]
000000018038D410  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D417  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D41B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D41F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D424  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D42B  E8 D0 E5 01 00              call    sub_1803ABA00
000000018038D430  66 0F 6F 05 F8 EB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D438  48 8D 05 F1 DB 5F 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
000000018038D43F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D443  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D447  48 8D 87 C0 82 00 00        lea     rax, [rdi+82C0h]
000000018038D44E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D455  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D459  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D45D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D462  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D469  E8 92 E5 01 00              call    sub_1803ABA00
000000018038D46E  66 0F 6F 05 BA EB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D476  48 8D 05 C3 DB 5F 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
000000018038D47D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D481  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D485  48 8D 87 D0 82 00 00        lea     rax, [rdi+82D0h]
000000018038D48C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D493  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D497  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D49B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D4A0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D4A7  E8 54 E5 01 00              call    sub_1803ABA00
000000018038D4AC  66 0F 6F 05 7C EB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D4B4  48 8D 05 95 DB 5F 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
000000018038D4BB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D4BF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D4C3  48 8D 87 E0 82 00 00        lea     rax, [rdi+82E0h]
000000018038D4CA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D4D1  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D4D5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D4D9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D4DE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D4E5  E8 16 E5 01 00              call    sub_1803ABA00
000000018038D4EA  48 8D 05 6F DB 5F 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
000000018038D4F1  66 0F 6F 05 37 EB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D4F9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D4FD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D501  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D505  48 8D 87 F0 82 00 00        lea     rax, [rdi+82F0h]
000000018038D50C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D513  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D517  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D51C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D523  E8 D8 E4 01 00              call    sub_1803ABA00
000000018038D528  66 0F 6F 05 00 EB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D530  48 8D 05 39 DB 5F 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
000000018038D537  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D53B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D53F  48 8D 87 00 83 00 00        lea     rax, [rdi+8300h]
000000018038D546  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D54D  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D551  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D555  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D55A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D561  E8 9A E4 01 00              call    sub_1803ABA00
000000018038D566  66 0F 6F 05 C2 EA 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D56E  48 8D 05 0B DB 5F 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
000000018038D575  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D579  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D57D  48 8D 87 10 83 00 00        lea     rax, [rdi+8310h]
000000018038D584  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D58B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D58F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D593  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D598  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D59F  E8 5C E4 01 00              call    sub_1803ABA00
000000018038D5A4  66 0F 6F 05 84 EA 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D5AC  48 8D 05 DD DA 5F 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
000000018038D5B3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D5B7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D5BB  48 8D 87 20 83 00 00        lea     rax, [rdi+8320h]
000000018038D5C2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D5C9  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D5CD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D5D1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D5D6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D5DD  E8 1E E4 01 00              call    sub_1803ABA00
000000018038D5E2  66 0F 6F 05 46 EA 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D5EA  48 8D 05 AF DA 5F 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
000000018038D5F1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D5F5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D5F9  48 8D 87 30 83 00 00        lea     rax, [rdi+8330h]
000000018038D600  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D607  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D60B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D60F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D614  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D61B  E8 E0 E3 01 00              call    sub_1803ABA00
000000018038D620  66 0F 6F 05 08 EA 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D628  48 8D 05 81 DA 5F 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
000000018038D62F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D633  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D637  48 8D 87 40 83 00 00        lea     rax, [rdi+8340h]
000000018038D63E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D645  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D649  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D64D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D652  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D659  E8 A2 E3 01 00              call    sub_1803ABA00
000000018038D65E  66 0F 6F 05 CA E9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D666  48 8D 05 53 DA 5F 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
000000018038D66D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D671  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D675  48 8D 87 50 83 00 00        lea     rax, [rdi+8350h]
000000018038D67C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D683  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D687  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D68B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D690  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D697  E8 64 E3 01 00              call    sub_1803ABA00
000000018038D69C  66 0F 6F 05 8C E9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D6A4  48 8D 05 25 DA 5F 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
000000018038D6AB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D6AF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D6B4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D6BB  48 8D 87 60 83 00 00        lea     rax, [rdi+8360h]
000000018038D6C2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D6C9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D6CD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D6D1  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D6D5  E8 26 E3 01 00              call    sub_1803ABA00
000000018038D6DA  66 0F 6F 05 4E E9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D6E2  48 8D 05 FF D9 5F 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
000000018038D6E9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D6ED  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D6F1  48 8D 87 70 83 00 00        lea     rax, [rdi+8370h]
000000018038D6F8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D6FF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D703  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D707  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D70C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D713  E8 E8 E2 01 00              call    sub_1803ABA00
000000018038D718  48 8D 05 E1 D9 5F 00        lea     rax, aReadOnly; "read only"
000000018038D71F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D726  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D72A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D72E  48 8D 87 10 85 00 00        lea     rax, [rdi+8510h]
000000018038D735  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D73C  0F 57 C0                    xorps   xmm0, xmm0
000000018038D73F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D743  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D747  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D74C  E8 AF E2 01 00              call    sub_1803ABA00
000000018038D751  48 8D 05 A8 D9 5F 00        lea     rax, aReadOnly; "read only"
000000018038D758  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D75F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D763  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D767  48 8D 87 20 85 00 00        lea     rax, [rdi+8520h]
000000018038D76E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D775  0F 57 C0                    xorps   xmm0, xmm0
000000018038D778  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D77C  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D780  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D785  E8 76 E2 01 00              call    sub_1803ABA00
000000018038D78A  48 8D 05 7F D9 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
000000018038D791  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D798  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D79C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D7A0  48 8D 87 30 85 00 00        lea     rax, [rdi+8530h]
000000018038D7A7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D7AE  0F 57 C0                    xorps   xmm0, xmm0
000000018038D7B1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D7B5  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D7B9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D7BE  E8 3D E2 01 00              call    sub_1803ABA00
000000018038D7C3  66 0F 6F 05 65 E8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D7CB  48 8D 05 56 D9 5F 00        lea     rax, aEnvAttack; "ENV Attack"
000000018038D7D2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D7D6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D7DA  48 8D 87 10 86 00 00        lea     rax, [rdi+8610h]
000000018038D7E1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D7E8  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D7EC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D7F0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D7F5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D7FC  E8 FF E1 01 00              call    sub_1803ABA00
000000018038D801  66 0F 6F 05 27 E8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D809  48 8D 05 28 D9 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
000000018038D810  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D814  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D818  48 8D 87 20 86 00 00        lea     rax, [rdi+8620h]
000000018038D81F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D826  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D82A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D82E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D833  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D83A  E8 C1 E1 01 00              call    sub_1803ABA00
000000018038D83F  66 0F 6F 05 E9 E7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D847  48 8D 05 FA D8 5F 00        lea     rax, aEnvDecay; "ENV Decay"
000000018038D84E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D852  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D856  48 8D 87 30 86 00 00        lea     rax, [rdi+8630h]
000000018038D85D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D864  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D868  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D86D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D874  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D878  E8 83 E1 01 00              call    sub_1803ABA00
000000018038D87D  66 0F 6F 05 AB E7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D885  48 8D 05 CC D8 5F 00        lea     rax, aEnvRelease; "ENV Release"
000000018038D88C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D890  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D894  48 8D 87 40 86 00 00        lea     rax, [rdi+8640h]
000000018038D89B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D8A2  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D8A6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D8AA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D8AF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D8B6  E8 45 E1 01 00              call    sub_1803ABA00
000000018038D8BB  66 0F 6F 05 6D E7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D8C3  48 8D 05 9E D8 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
000000018038D8CA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D8CE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D8D2  48 8D 87 50 86 00 00        lea     rax, [rdi+8650h]
000000018038D8D9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D8E0  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D8E4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D8E8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D8ED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D8F4  E8 07 E1 01 00              call    sub_1803ABA00
000000018038D8F9  48 8D 05 10 D8 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
000000018038D900  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D907  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D90B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D90F  48 8D 87 10 87 00 00        lea     rax, [rdi+8710h]
000000018038D916  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D91D  0F 57 C0                    xorps   xmm0, xmm0
000000018038D920  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D924  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D928  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D92D  E8 CE E0 01 00              call    sub_1803ABA00
000000018038D932  66 0F 6F 05 F6 E6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D93A  48 8D 05 E7 D7 5F 00        lea     rax, aEnvAttack; "ENV Attack"
000000018038D941  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D945  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D949  48 8D 87 F0 87 00 00        lea     rax, [rdi+87F0h]
000000018038D950  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D957  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D95B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D95F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D964  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D96B  E8 90 E0 01 00              call    sub_1803ABA00
000000018038D970  66 0F 6F 05 B8 E6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D978  48 8D 05 B9 D7 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
000000018038D97F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D983  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D987  48 8D 87 00 88 00 00        lea     rax, [rdi+8800h]
000000018038D98E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D995  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D999  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D99D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D9A2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D9A9  E8 52 E0 01 00              call    sub_1803ABA00
000000018038D9AE  66 0F 6F 05 7A E6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D9B6  48 8D 05 8B D7 5F 00        lea     rax, aEnvDecay; "ENV Decay"
000000018038D9BD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D9C1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038D9C5  48 8D 87 10 88 00 00        lea     rax, [rdi+8810h]
000000018038D9CC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038D9D3  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038D9D7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038D9DB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038D9E0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038D9E7  E8 14 E0 01 00              call    sub_1803ABA00
000000018038D9EC  66 0F 6F 05 3C E6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038D9F4  48 8D 05 5D D7 5F 00        lea     rax, aEnvRelease; "ENV Release"
000000018038D9FB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038D9FF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DA03  48 8D 87 20 88 00 00        lea     rax, [rdi+8820h]
000000018038DA0A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DA11  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DA15  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DA19  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DA1E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DA25  E8 D6 DF 01 00              call    sub_1803ABA00
000000018038DA2A  48 8D 05 37 D7 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
000000018038DA31  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DA35  66 0F 6F 05 F3 E5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DA3D  48 8D 87 30 88 00 00        lea     rax, [rdi+8830h]
000000018038DA44  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DA48  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DA4C  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DA50  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DA57  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DA5C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DA63  E8 98 DF 01 00              call    sub_1803ABA00
000000018038DA68  48 8D 05 09 D7 5F 00        lea     rax, aOsc1Feet; "OSC1 Feet"
000000018038DA6F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DA76  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DA7A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DA7E  48 8D 87 30 8A 00 00        lea     rax, [rdi+8A30h]
000000018038DA85  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DA8C  0F 57 C0                    xorps   xmm0, xmm0
000000018038DA8F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DA93  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DA97  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DA9C  E8 5F DF 01 00              call    sub_1803ABA00
000000018038DAA1  48 8D 05 E0 D6 5F 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
000000018038DAA8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DAAF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DAB3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DAB7  48 8D 87 40 8A 00 00        lea     rax, [rdi+8A40h]
000000018038DABE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DAC5  0F 57 C0                    xorps   xmm0, xmm0
000000018038DAC8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DACC  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DAD0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DAD5  E8 26 DF 01 00              call    sub_1803ABA00
000000018038DADA  48 8D 05 B7 D6 5F 00        lea     rax, aBendEnableSw; "Bend Enable SW"
000000018038DAE1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DAE8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DAEC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DAF0  48 8D 87 50 8A 00 00        lea     rax, [rdi+8A50h]
000000018038DAF7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DAFE  0F 57 C0                    xorps   xmm0, xmm0
000000018038DB01  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DB05  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DB09  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DB0E  E8 ED DE 01 00              call    sub_1803ABA00
000000018038DB13  48 8D 05 8E D6 5F 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
000000018038DB1A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DB21  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DB25  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DB29  48 8D 87 60 8A 00 00        lea     rax, [rdi+8A60h]
000000018038DB30  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DB37  0F 57 C0                    xorps   xmm0, xmm0
000000018038DB3A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DB3E  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DB42  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DB47  E8 B4 DE 01 00              call    sub_1803ABA00
000000018038DB4C  48 8D 05 65 D6 5F 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
000000018038DB53  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DB5A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DB5E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DB62  48 8D 87 70 8A 00 00        lea     rax, [rdi+8A70h]
000000018038DB69  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DB70  0F 57 C0                    xorps   xmm0, xmm0
000000018038DB73  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DB77  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DB7B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DB80  E8 7B DE 01 00              call    sub_1803ABA00
000000018038DB85  48 8D 05 3C D6 5F 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
000000018038DB8C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DB93  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DB97  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DB9B  48 8D 87 80 8A 00 00        lea     rax, [rdi+8A80h]
000000018038DBA2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DBA9  0F 57 C0                    xorps   xmm0, xmm0
000000018038DBAC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DBB0  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DBB4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DBB9  E8 42 DE 01 00              call    sub_1803ABA00
000000018038DBBE  48 8D 05 13 D6 5F 00        lea     rax, aPwmSwManual; "PWM SW Manual"
000000018038DBC5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DBCC  0F 57 C0                    xorps   xmm0, xmm0
000000018038DBCF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DBD3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DBD8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DBDF  48 8D 87 90 8A 00 00        lea     rax, [rdi+8A90h]
000000018038DBE6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DBEA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DBEE  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DBF2  E8 09 DE 01 00              call    sub_1803ABA00
000000018038DBF7  66 0F 6F 05 31 E4 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DBFF  48 8D 05 E2 D5 5F 00        lea     rax, aTune; "Tune"
000000018038DC06  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DC0A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DC0E  48 8D 87 A0 8A 00 00        lea     rax, [rdi+8AA0h]
000000018038DC15  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DC1C  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DC20  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DC24  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DC29  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DC30  E8 CB DD 01 00              call    sub_1803ABA00
000000018038DC35  66 0F 6F 05 F3 E3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DC3D  48 8D 05 AC D5 5F 00        lea     rax, aDetune; "Detune"
000000018038DC44  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DC48  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DC4C  48 8D 87 B0 8A 00 00        lea     rax, [rdi+8AB0h]
000000018038DC53  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DC5A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DC5E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DC62  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DC67  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DC6E  E8 8D DD 01 00              call    sub_1803ABA00
000000018038DC73  66 0F 6F 05 B5 E3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DC7B  48 8D 05 76 D5 5F 00        lea     rax, aModSens; "Mod Sens"
000000018038DC82  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DC86  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DC8A  48 8D 87 C0 8A 00 00        lea     rax, [rdi+8AC0h]
000000018038DC91  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DC98  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DC9C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DCA0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DCA5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DCAC  E8 4F DD 01 00              call    sub_1803ABA00
000000018038DCB1  66 0F 6F 05 77 E3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DCB9  48 8D 05 44 D5 5F 00        lea     rax, aModSw; "Mod Sw"
000000018038DCC0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DCC4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DCC8  48 8D 87 D0 8A 00 00        lea     rax, [rdi+8AD0h]
000000018038DCCF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DCD6  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DCDA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DCDE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DCE3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DCEA  E8 11 DD 01 00              call    sub_1803ABA00
000000018038DCEF  66 0F 6F 05 39 E3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DCF7  48 8D 05 12 D5 5F 00        lea     rax, aLfoGain; "LFO Gain"
000000018038DCFE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DD02  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DD06  48 8D 87 E0 8A 00 00        lea     rax, [rdi+8AE0h]
000000018038DD0D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DD14  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DD18  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DD1C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DD21  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DD28  E8 D3 DC 01 00              call    sub_1803ABA00
000000018038DD2D  66 0F 6F 05 FB E2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DD35  48 8D 05 E4 D4 5F 00        lea     rax, aLfoLevel; "LFO Level"
000000018038DD3C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DD40  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DD44  48 8D 87 F0 8A 00 00        lea     rax, [rdi+8AF0h]
000000018038DD4B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DD52  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DD56  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DD5A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DD5F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DD66  E8 95 DC 01 00              call    sub_1803ABA00
000000018038DD6B  66 0F 6F 05 BD E2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DD73  48 8D 05 B2 D4 5F 00        lea     rax, aLfoSw; "LFO Sw"
000000018038DD7A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DD7E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DD82  48 8D 87 00 8B 00 00        lea     rax, [rdi+8B00h]
000000018038DD89  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DD90  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DD94  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DD98  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DD9D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DDA4  E8 57 DC 01 00              call    sub_1803ABA00
000000018038DDA9  66 0F 6F 05 7F E2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DDB1  48 8D 05 80 D4 5F 00        lea     rax, aEnv1Level; "ENV1 Level"
000000018038DDB8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DDBC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DDC0  48 8D 87 10 8B 00 00        lea     rax, [rdi+8B10h]
000000018038DDC7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DDCE  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DDD2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DDD6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DDDB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DDE2  E8 19 DC 01 00              call    sub_1803ABA00
000000018038DDE7  66 0F 6F 05 41 E2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DDEF  48 8D 05 52 D4 5F 00        lea     rax, aEnv2Level; "ENV2 Level"
000000018038DDF6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DDFA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DDFE  48 8D 87 20 8B 00 00        lea     rax, [rdi+8B20h]
000000018038DE05  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DE0C  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DE10  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DE14  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DE19  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DE20  E8 DB DB 01 00              call    sub_1803ABA00
000000018038DE25  66 0F 6F 05 03 E2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DE2D  48 8D 05 20 D4 5F 00        lea     rax, aEnvSw; "ENV Sw"
000000018038DE34  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DE38  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DE3C  48 8D 87 30 8B 00 00        lea     rax, [rdi+8B30h]
000000018038DE43  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DE4A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DE4E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DE52  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DE57  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DE5E  E8 9D DB 01 00              call    sub_1803ABA00
000000018038DE63  66 0F 6F 05 C5 E1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DE6B  48 8D 05 EE D3 5F 00        lea     rax, aBendLevel; "Bend Level"
000000018038DE72  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DE76  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DE7A  48 8D 87 40 8B 00 00        lea     rax, [rdi+8B40h]
000000018038DE81  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DE88  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DE8C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DE90  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DE95  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DE9C  E8 5F DB 01 00              call    sub_1803ABA00
000000018038DEA1  66 0F 6F 05 87 E1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DEA9  48 8D 05 C0 D3 5F 00        lea     rax, aBendRange; "Bend Range"
000000018038DEB0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DEB4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DEB8  48 8D 87 50 8B 00 00        lea     rax, [rdi+8B50h]
000000018038DEBF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DEC6  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DECA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DECE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DED3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DEDA  E8 21 DB 01 00              call    sub_1803ABA00
000000018038DEDF  66 0F 6F 05 49 E1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DEE7  48 8D 05 92 D3 5F 00        lea     rax, aPwmLevel; "PWM Level"
000000018038DEEE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DEF2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DEF6  48 8D 87 60 8B 00 00        lea     rax, [rdi+8B60h]
000000018038DEFD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DF04  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DF08  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DF0C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DF11  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DF18  E8 E3 DA 01 00              call    sub_1803ABA00
000000018038DF1D  66 0F 6F 05 0B E1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DF25  48 8D 05 64 D3 5F 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
000000018038DF2C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DF30  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DF34  48 8D 87 90 8B 00 00        lea     rax, [rdi+8B90h]
000000018038DF3B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DF42  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DF46  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DF4A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DF4F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DF56  E8 A5 DA 01 00              call    sub_1803ABA00
000000018038DF5B  48 8D 05 3E D3 5F 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
000000018038DF62  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DF69  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DF6D  66 0F 6F 05 BB E0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DF75  48 8D 87 A0 8B 00 00        lea     rax, [rdi+8BA0h]
000000018038DF7C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DF80  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DF84  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DF88  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DF8F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DF94  E8 67 DA 01 00              call    sub_1803ABA00
000000018038DF99  66 0F 6F 05 8F E0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DFA1  48 8D 05 08 D3 5F 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
000000018038DFA8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DFAC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DFB0  48 8D 87 B0 8B 00 00        lea     rax, [rdi+8BB0h]
000000018038DFB7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DFBE  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038DFC2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038DFC6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038DFCB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038DFD2  E8 29 DA 01 00              call    sub_1803ABA00
000000018038DFD7  66 0F 6F 05 51 E0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038DFDF  48 8D 05 DA D2 5F 00        lea     rax, aDutyTune; "Duty Tune"
000000018038DFE6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038DFEA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038DFEE  48 8D 87 C0 90 00 00        lea     rax, [rdi+90C0h]
000000018038DFF5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038DFFC  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E000  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E004  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E009  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E010  E8 EB D9 01 00              call    sub_1803ABA00
000000018038E015  66 0F 6F 05 13 E0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E01D  48 8D 05 AC D2 5F 00        lea     rax, aOsc1Mute; "Osc1 Mute"
000000018038E024  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E028  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E02C  48 8D 87 60 94 00 00        lea     rax, [rdi+9460h]
000000018038E033  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E03A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E03E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E042  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E047  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E04E  E8 AD D9 01 00              call    sub_1803ABA00
000000018038E053  66 0F 6F 05 D5 DF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E05B  48 8D 05 7E D2 5F 00        lea     rax, aOsc1Level; "Osc1 Level"
000000018038E062  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E066  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E06A  48 8D 87 A0 94 00 00        lea     rax, [rdi+94A0h]
000000018038E071  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E078  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E07C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E080  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E085  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E08C  E8 6F D9 01 00              call    sub_1803ABA00
000000018038E091  66 0F 6F 05 97 DF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E099  48 8D 05 50 D2 5F 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
000000018038E0A0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E0A4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E0A8  48 8D 87 B0 94 00 00        lea     rax, [rdi+94B0h]
000000018038E0AF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E0B6  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E0BA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E0BE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E0C3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E0CA  E8 31 D9 01 00              call    sub_1803ABA00
000000018038E0CF  48 8D 05 2A D2 5F 00        lea     rax, aGrifferSw; "Griffer SW"
000000018038E0D6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E0DD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E0E1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E0E5  48 8D 87 70 95 00 00        lea     rax, [rdi+9570h]
000000018038E0EC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E0F3  0F 57 C0                    xorps   xmm0, xmm0
000000018038E0F6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E0FA  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E0FE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E103  E8 F8 D8 01 00              call    sub_1803ABA00
000000018038E108  66 0F 6F 05 20 DF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E110  48 8D 05 F9 D1 5F 00        lea     rax, aLpfCutoff; "LPF Cutoff"
000000018038E117  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E11B  48 8D 87 80 95 00 00        lea     rax, [rdi+9580h]
000000018038E122  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E129  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E12E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E135  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E139  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E13D  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E141  E8 BA D8 01 00              call    sub_1803ABA00
000000018038E146  66 0F 6F 05 E2 DE 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E14E  48 8D 05 CB D1 5F 00        lea     rax, aLpfResonance; "LPF Resonance"
000000018038E155  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E159  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E15D  48 8D 87 E0 95 00 00        lea     rax, [rdi+95E0h]
000000018038E164  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E16B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E16F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E173  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E178  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E17F  E8 7C D8 01 00              call    sub_1803ABA00
000000018038E184  48 8D 05 A5 D1 5F 00        lea     rax, aVelocity; "Velocity"
000000018038E18B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E192  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E196  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E19A  48 8D 87 00 96 00 00        lea     rax, [rdi+9600h]
000000018038E1A1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E1A8  0F 57 C0                    xorps   xmm0, xmm0
000000018038E1AB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E1AF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E1B3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E1B8  E8 43 D8 01 00              call    sub_1803ABA00
000000018038E1BD  48 8D 05 78 D1 5F 00        lea     rax, aEnv12; "Env1/2"
000000018038E1C4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E1CB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E1CF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E1D3  48 8D 87 90 96 00 00        lea     rax, [rdi+9690h]
000000018038E1DA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E1E1  0F 57 C0                    xorps   xmm0, xmm0
000000018038E1E4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E1E8  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E1EC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E1F1  E8 0A D8 01 00              call    sub_1803ABA00
000000018038E1F6  48 8D 05 4B D1 5F 00        lea     rax, aIntEnv; "Int/Env"
000000018038E1FD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E204  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E208  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E20C  48 8D 87 A0 96 00 00        lea     rax, [rdi+96A0h]
000000018038E213  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E21A  0F 57 C0                    xorps   xmm0, xmm0
000000018038E21D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E221  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E225  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E22A  E8 D1 D7 01 00              call    sub_1803ABA00
000000018038E22F  48 8D 05 DA CF 5F 00        lea     rax, aLfoGain; "LFO Gain"
000000018038E236  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E23D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E241  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E245  48 8D 87 B0 97 00 00        lea     rax, [rdi+97B0h]
000000018038E24C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E253  0F 57 C0                    xorps   xmm0, xmm0
000000018038E256  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E25A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E25E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E263  E8 98 D7 01 00              call    sub_1803ABA00
000000018038E268  48 8D 05 E1 D0 5F 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
000000018038E26F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E276  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E27A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E27E  48 8D 87 C0 97 00 00        lea     rax, [rdi+97C0h]
000000018038E285  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E28C  0F 57 C0                    xorps   xmm0, xmm0
000000018038E28F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E293  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E297  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E29C  E8 5F D7 01 00              call    sub_1803ABA00
000000018038E2A1  48 8D 05 B8 D0 5F 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
000000018038E2A8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E2AF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E2B3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E2B7  48 8D 87 D0 97 00 00        lea     rax, [rdi+97D0h]
000000018038E2BE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E2C5  0F 57 C0                    xorps   xmm0, xmm0
000000018038E2C8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E2CC  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E2D0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E2D5  E8 26 D7 01 00              call    sub_1803ABA00
000000018038E2DA  66 0F 6F 05 4E DD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E2E2  48 8D 05 37 CF 5F 00        lea     rax, aLfoLevel; "LFO Level"
000000018038E2E9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E2ED  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E2F1  48 8D 87 E0 97 00 00        lea     rax, [rdi+97E0h]
000000018038E2F8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E2FF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E303  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E307  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E30C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E313  E8 E8 D6 01 00              call    sub_1803ABA00
000000018038E318  66 0F 6F 05 10 DD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E320  48 8D 05 49 D0 5F 00        lea     rax, aModSens_0; "MOD Sens"
000000018038E327  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E32B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E32F  48 8D 87 F0 97 00 00        lea     rax, [rdi+97F0h]
000000018038E336  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E33D  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E341  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E345  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E34A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E351  E8 AA D6 01 00              call    sub_1803ABA00
000000018038E356  66 0F 6F 05 D2 DC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E35E  48 8D 05 17 D0 5F 00        lea     rax, aModSw_0; "MOD SW"
000000018038E365  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E369  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E36D  48 8D 87 00 98 00 00        lea     rax, [rdi+9800h]
000000018038E374  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E37B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E37F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E383  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E388  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E38F  E8 6C D6 01 00              call    sub_1803ABA00
000000018038E394  66 0F 6F 05 94 DC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E39C  48 8D 05 E5 CF 5F 00        lea     rax, aEnvLevel; "ENV Level"
000000018038E3A3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E3A7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E3AB  48 8D 87 10 98 00 00        lea     rax, [rdi+9810h]
000000018038E3B2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E3B9  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E3BD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E3C1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E3C6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E3CD  E8 2E D6 01 00              call    sub_1803ABA00
000000018038E3D2  66 0F 6F 05 56 DC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E3DA  48 8D 05 B7 CF 5F 00        lea     rax, aKcvLevel; "KCV Level"
000000018038E3E1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E3E5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E3E9  48 8D 87 20 98 00 00        lea     rax, [rdi+9820h]
000000018038E3F0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E3F7  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E3FB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E3FF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E404  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E40B  E8 F0 D5 01 00              call    sub_1803ABA00
000000018038E410  66 0F 6F 05 18 DC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E418  48 8D 05 89 CF 5F 00        lea     rax, aVelocitySens; "Velocity Sens"
000000018038E41F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E423  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E427  48 8D 87 30 98 00 00        lea     rax, [rdi+9830h]
000000018038E42E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E435  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E439  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E43D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E442  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E449  E8 B2 D5 01 00              call    sub_1803ABA00
000000018038E44E  66 0F 6F 05 DA DB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E456  48 8D 05 5B CF 5F 00        lea     rax, aVelocityOffset; "Velocity Offset"
000000018038E45D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E461  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E465  48 8D 87 40 98 00 00        lea     rax, [rdi+9840h]
000000018038E46C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E473  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E477  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E47B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E480  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E487  E8 74 D5 01 00              call    sub_1803ABA00
000000018038E48C  66 0F 6F 05 9C DB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E494  48 8D 05 C5 CD 5F 00        lea     rax, aBendLevel; "Bend Level"
000000018038E49B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E49F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E4A6  48 8D 87 50 98 00 00        lea     rax, [rdi+9850h]
000000018038E4AD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E4B4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E4B8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E4BC  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E4C0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E4C5  E8 36 D5 01 00              call    sub_1803ABA00
000000018038E4CA  66 0F 6F 05 5E DB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E4D2  48 8D 05 97 CD 5F 00        lea     rax, aBendRange; "Bend Range"
000000018038E4D9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E4DD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E4E1  48 8D 87 60 98 00 00        lea     rax, [rdi+9860h]
000000018038E4E8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E4EF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E4F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E4F7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E4FC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E503  E8 F8 D4 01 00              call    sub_1803ABA00
000000018038E508  66 0F 6F 05 20 DB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E510  48 8D 05 B1 CE 5F 00        lea     rax, aCutoffTune; "Cutoff Tune"
000000018038E517  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E51B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E51F  48 8D 87 E0 98 00 00        lea     rax, [rdi+98E0h]
000000018038E526  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E52D  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E531  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E535  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E53A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E541  E8 BA D4 01 00              call    sub_1803ABA00
000000018038E546  66 0F 6F 05 E2 DA 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E54E  48 8D 05 83 CE 5F 00        lea     rax, aResonanceTune; "Resonance Tune"
000000018038E555  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E559  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E55D  48 8D 87 F0 98 00 00        lea     rax, [rdi+98F0h]
000000018038E564  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E56B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E56F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E573  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E578  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E57F  E8 7C D4 01 00              call    sub_1803ABA00
000000018038E584  48 8D 05 5D CE 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
000000018038E58B  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
000000018038E592  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E596  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E59A  48 8D 87 00 99 00 00        lea     rax, [rdi+9900h]
000000018038E5A1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E5A8  0F 57 C0                    xorps   xmm0, xmm0
000000018038E5AB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E5AF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E5B3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E5B8  E8 43 D4 01 00              call    sub_1803ABA00
000000018038E5BD  48 8D 05 24 CE 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
000000018038E5C4  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
000000018038E5CB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E5CF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E5D3  48 8D 87 90 9E 00 00        lea     rax, [rdi+9E90h]
000000018038E5DA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E5E1  0F 57 C0                    xorps   xmm0, xmm0
000000018038E5E4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E5E8  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E5EC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E5F1  E8 0A D4 01 00              call    sub_1803ABA00
000000018038E5F6  66 0F 6F 05 32 DA 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E5FE  48 8D 05 F3 CD 5F 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
000000018038E605  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E609  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E60D  48 8D 87 A0 9E 00 00        lea     rax, [rdi+9EA0h]
000000018038E614  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E61B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E61F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E623  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E628  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E62F  E8 CC D3 01 00              call    sub_1803ABA00
000000018038E634  66 0F 6F 05 F4 D9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E63C  48 8D 05 C5 CD 5F 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
000000018038E643  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E647  48 8D 87 B0 9E 00 00        lea     rax, [rdi+9EB0h]
000000018038E64E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E652  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E659  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E65E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E665  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E669  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E66D  E8 8E D3 01 00              call    sub_1803ABA00
000000018038E672  66 0F 6F 05 B6 D9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E67A  48 8D 05 97 CD 5F 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
000000018038E681  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E685  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E689  48 8D 87 C0 9E 00 00        lea     rax, [rdi+9EC0h]
000000018038E690  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E697  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E69B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E69F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E6A4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E6AB  E8 50 D3 01 00              call    sub_1803ABA00
000000018038E6B0  66 0F 6F 05 78 D9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E6B8  48 8D 05 69 CD 5F 00        lea     rax, aAmpTone; "AMP TONE"
000000018038E6BF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E6C3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E6C7  48 8D 87 A0 A0 00 00        lea     rax, [rdi+0A0A0h]
000000018038E6CE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E6D5  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E6D9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E6DD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E6E2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E6E9  E8 12 D3 01 00              call    sub_1803ABA00
000000018038E6EE  66 0F 6F 05 3A D9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E6F6  48 8D 05 3B CD 5F 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
000000018038E6FD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E701  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E705  48 8D 87 B0 A0 00 00        lea     rax, [rdi+0A0B0h]
000000018038E70C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E713  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E717  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E71B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E720  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E727  E8 D4 D2 01 00              call    sub_1803ABA00
000000018038E72C  66 0F 6F 05 FC D8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E734  48 8D 05 15 CD 5F 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
000000018038E73B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E73F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E743  48 8D 87 C0 A0 00 00        lea     rax, [rdi+0A0C0h]
000000018038E74A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E751  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E755  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E759  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E75E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E765  E8 96 D2 01 00              call    sub_1803ABA00
000000018038E76A  48 8D 05 BF CB 5F 00        lea     rax, aVelocity; "Velocity"
000000018038E771  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E778  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E77C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E780  48 8D 87 00 A1 00 00        lea     rax, [rdi+0A100h]
000000018038E787  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E78E  0F 57 C0                    xorps   xmm0, xmm0
000000018038E791  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E795  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E799  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E79E  E8 5D D2 01 00              call    sub_1803ABA00
000000018038E7A3  48 8D 05 BE CC 5F 00        lea     rax, aMute; "Mute"
000000018038E7AA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E7B1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E7B5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E7B9  48 8D 87 90 A1 00 00        lea     rax, [rdi+0A190h]
000000018038E7C0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E7C7  0F 57 C0                    xorps   xmm0, xmm0
000000018038E7CA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E7CE  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E7D2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E7D7  E8 24 D2 01 00              call    sub_1803ABA00
000000018038E7DC  48 8D 05 8D CC 5F 00        lea     rax, aGateSw; "Gate SW"
000000018038E7E3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E7EA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E7EE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E7F2  48 8D 87 F0 A2 00 00        lea     rax, [rdi+0A2F0h]
000000018038E7F9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E800  0F 57 C0                    xorps   xmm0, xmm0
000000018038E803  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E807  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E80B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E810  E8 EB D1 01 00              call    sub_1803ABA00
000000018038E815  48 8D 05 5C CC 5F 00        lea     rax, aEnv1Sw; "ENV1 SW"
000000018038E81C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E820  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E824  48 8D 87 00 A3 00 00        lea     rax, [rdi+0A300h]
000000018038E82B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E832  0F 57 C0                    xorps   xmm0, xmm0
000000018038E835  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E839  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E83D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E844  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E849  E8 B2 D1 01 00              call    sub_1803ABA00
000000018038E84E  48 8D 05 2B CC 5F 00        lea     rax, aEnv2Sw; "ENV2 SW"
000000018038E855  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E85C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E860  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E864  48 8D 87 10 A3 00 00        lea     rax, [rdi+0A310h]
000000018038E86B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E872  0F 57 C0                    xorps   xmm0, xmm0
000000018038E875  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E879  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E87D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E882  E8 79 D1 01 00              call    sub_1803ABA00
000000018038E887  48 8D 05 FA CB 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
000000018038E88E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E895  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E899  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E89D  48 8D 87 20 A3 00 00        lea     rax, [rdi+0A320h]
000000018038E8A4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E8AB  0F 57 C0                    xorps   xmm0, xmm0
000000018038E8AE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E8B2  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E8B6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E8BB  E8 40 D1 01 00              call    sub_1803ABA00
000000018038E8C0  66 0F 6F 05 68 D7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E8C8  48 8D 05 C9 CB 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
000000018038E8CF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E8D3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E8D7  48 8D 87 30 A3 00 00        lea     rax, [rdi+0A330h]
000000018038E8DE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E8E5  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E8E9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E8ED  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E8F2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E8F9  E8 02 D1 01 00              call    sub_1803ABA00
000000018038E8FE  66 0F 6F 05 2A D7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E906  48 8D 05 9B CB 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
000000018038E90D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E911  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E915  48 8D 87 40 A3 00 00        lea     rax, [rdi+0A340h]
000000018038E91C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E923  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E927  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E92B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E930  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E937  E8 C4 D0 01 00              call    sub_1803ABA00
000000018038E93C  66 0F 6F 05 EC D6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E944  48 8D 05 6D CB 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
000000018038E94B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E94F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E953  48 8D 87 50 A3 00 00        lea     rax, [rdi+0A350h]
000000018038E95A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E961  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E965  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E969  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E96E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E975  E8 86 D0 01 00              call    sub_1803ABA00
000000018038E97A  66 0F 6F 05 AE D6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E982  48 8D 05 3F CB 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
000000018038E989  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E98D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E991  48 8D 87 60 A3 00 00        lea     rax, [rdi+0A360h]
000000018038E998  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E99F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E9A3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E9A7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E9AC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E9B3  E8 48 D0 01 00              call    sub_1803ABA00
000000018038E9B8  66 0F 6F 05 70 D6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E9C0  48 8D 05 19 CB 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
000000018038E9C7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038E9CB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038E9D0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038E9D7  48 8D 87 70 A3 00 00        lea     rax, [rdi+0A370h]
000000018038E9DE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038E9E5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038E9E9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038E9ED  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038E9F1  E8 0A D0 01 00              call    sub_1803ABA00
000000018038E9F6  66 0F 6F 05 32 D6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038E9FE  48 8D 05 EB CA 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
000000018038EA05  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EA09  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EA0D  48 8D 87 80 A3 00 00        lea     rax, [rdi+0A380h]
000000018038EA14  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EA1B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EA1F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EA23  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EA28  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EA2F  E8 CC CF 01 00              call    sub_1803ABA00
000000018038EA34  48 8D 05 E5 C4 5F 00        lea     rax, aUseextjack; "UseExtJack"
000000018038EA3B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EA42  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EA46  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EA4A  48 8D 87 50 A5 00 00        lea     rax, [rdi+0A550h]
000000018038EA51  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EA58  0F 57 C0                    xorps   xmm0, xmm0
000000018038EA5B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EA5F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EA63  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EA68  E8 93 CF 01 00              call    sub_1803ABA00
000000018038EA6D  48 8D 05 B8 C4 5F 00        lea     rax, aMCv; "M.CV"
000000018038EA74  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EA7B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EA7F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EA83  48 8D 87 70 A5 00 00        lea     rax, [rdi+0A570h]
000000018038EA8A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EA91  0F 57 C0                    xorps   xmm0, xmm0
000000018038EA94  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EA98  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EA9C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EAA1  E8 5A CF 01 00              call    sub_1803ABA00
000000018038EAA6  48 8D 05 87 C4 5F 00        lea     rax, aMGate; "M.Gate"
000000018038EAAD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EAB4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EAB8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EABC  48 8D 87 80 A5 00 00        lea     rax, [rdi+0A580h]
000000018038EAC3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EACA  0F 57 C0                    xorps   xmm0, xmm0
000000018038EACD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EAD1  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EAD5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EADA  E8 21 CF 01 00              call    sub_1803ABA00
000000018038EADF  66 0F 6F 05 49 D5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038EAE7  48 8D 05 52 C4 5F 00        lea     rax, aMasterTune; "Master Tune"
000000018038EAEE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EAF2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EAF6  48 8D 87 B0 A5 00 00        lea     rax, [rdi+0A5B0h]
000000018038EAFD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EB04  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EB08  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EB0C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EB11  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EB18  E8 E3 CE 01 00              call    sub_1803ABA00
000000018038EB1D  66 0F 6F 05 0B D5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038EB25  48 8D 05 24 C4 5F 00        lea     rax, aPartTune; "Part Tune"
000000018038EB2C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EB30  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EB34  48 8D 87 C0 A5 00 00        lea     rax, [rdi+0A5C0h]
000000018038EB3B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EB42  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EB46  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EB4A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EB4F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EB56  E8 A5 CE 01 00              call    sub_1803ABA00
000000018038EB5B  48 8D 05 FE C3 5F 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
000000018038EB62  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EB69  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EB6D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EB71  48 8D 87 90 A6 00 00        lea     rax, [rdi+0A690h]
000000018038EB78  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EB7F  0F 57 C0                    xorps   xmm0, xmm0
000000018038EB82  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EB86  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EB8B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EB8F  E8 6C CE 01 00              call    sub_1803ABA00
000000018038EB94  48 8D 05 DD C3 5F 00        lea     rax, aPortamentoMode; "Portamento Mode"
000000018038EB9B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EBA2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EBA6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EBAA  48 8D 87 A0 A6 00 00        lea     rax, [rdi+0A6A0h]
000000018038EBB1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EBB8  0F 57 C0                    xorps   xmm0, xmm0
000000018038EBBB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EBBF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EBC3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EBC8  E8 33 CE 01 00              call    sub_1803ABA00
000000018038EBCD  66 0F 6F 05 5B D4 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038EBD5  48 8D 05 AC C3 5F 00        lea     rax, aPortamentoTime; "Portamento Time"
000000018038EBDC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EBE0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EBE4  48 8D 87 B0 A6 00 00        lea     rax, [rdi+0A6B0h]
000000018038EBEB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EBF2  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EBF6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EBFA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EBFF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EC06  E8 F5 CD 01 00              call    sub_1803ABA00
000000018038EC0B  48 8D 05 86 C3 5F 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
000000018038EC12  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EC19  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EC1D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EC21  48 8D 87 50 A8 00 00        lea     rax, [rdi+0A850h]
000000018038EC28  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EC2F  0F 57 C0                    xorps   xmm0, xmm0
000000018038EC32  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EC36  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EC3A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EC3F  E8 BC CD 01 00              call    sub_1803ABA00
000000018038EC44  48 8D 05 65 C3 5F 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
000000018038EC4B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EC52  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EC56  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EC5A  48 8D 87 60 A8 00 00        lea     rax, [rdi+0A860h]
000000018038EC61  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EC68  0F 57 C0                    xorps   xmm0, xmm0
000000018038EC6B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EC6F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EC73  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EC78  E8 83 CD 01 00              call    sub_1803ABA00
000000018038EC7D  48 8D 05 44 C3 5F 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
000000018038EC84  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EC8B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EC8F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EC93  48 8D 87 70 A8 00 00        lea     rax, [rdi+0A870h]
000000018038EC9A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038ECA1  0F 57 C0                    xorps   xmm0, xmm0
000000018038ECA4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038ECA8  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038ECAC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038ECB1  E8 4A CD 01 00              call    sub_1803ABA00
000000018038ECB6  66 0F 6F 05 72 D3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038ECBE  48 8D 05 13 C3 5F 00        lea     rax, aLfoRate; "LFO Rate"
000000018038ECC5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038ECC9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038ECCD  48 8D 87 80 A8 00 00        lea     rax, [rdi+0A880h]
000000018038ECD4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038ECDB  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038ECDF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038ECE3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038ECE8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038ECEF  E8 0C CD 01 00              call    sub_1803ABA00
000000018038ECF4  48 8D 05 E9 C2 5F 00        lea     rax, aGate; "Gate"
000000018038ECFB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038ED02  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038ED06  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038ED0A  48 8D 87 80 AB 00 00        lea     rax, [rdi+0AB80h]
000000018038ED11  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038ED18  0F 57 C0                    xorps   xmm0, xmm0
000000018038ED1B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038ED1F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038ED23  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038ED28  E8 D3 CC 01 00              call    sub_1803ABA00
000000018038ED2D  48 8D 05 BC C2 5F 00        lea     rax, aLfoTrig; "LFO Trig"
000000018038ED34  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038ED38  0F 57 C0                    xorps   xmm0, xmm0
000000018038ED3B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038ED42  48 8D 87 90 AB 00 00        lea     rax, [rdi+0AB90h]
000000018038ED49  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038ED50  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038ED54  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038ED58  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038ED5C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038ED61  E8 9A CC 01 00              call    sub_1803ABA00
000000018038ED66  48 8D 05 93 C2 5F 00        lea     rax, aResetSw; "Reset Sw"
000000018038ED6D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038ED74  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038ED78  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038ED7C  48 8D 87 A0 AB 00 00        lea     rax, [rdi+0ABA0h]
000000018038ED83  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038ED8A  0F 57 C0                    xorps   xmm0, xmm0
000000018038ED8D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038ED91  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038ED95  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038ED9A  E8 61 CC 01 00              call    sub_1803ABA00
000000018038ED9F  66 0F 6F 05 89 D2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038EDA7  48 8D 05 62 C2 5F 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
000000018038EDAE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EDB2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EDB6  48 8D 87 B0 AB 00 00        lea     rax, [rdi+0ABB0h]
000000018038EDBD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EDC4  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EDC8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EDCC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EDD1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EDD8  E8 23 CC 01 00              call    sub_1803ABA00
000000018038EDDD  66 0F 6F 05 4B D2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038EDE5  48 8D 05 34 C2 5F 00        lea     rax, aLfoDelay; "LFO Delay"
000000018038EDEC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EDF0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EDF4  48 8D 87 C0 AB 00 00        lea     rax, [rdi+0ABC0h]
000000018038EDFB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EE02  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EE06  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EE0A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EE0F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EE16  E8 E5 CB 01 00              call    sub_1803ABA00
000000018038EE1B  66 0F 6F 05 0D D2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038EE23  48 8D 05 06 C2 5F 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
000000018038EE2A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EE2E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EE32  48 8D 87 D0 AB 00 00        lea     rax, [rdi+0ABD0h]
000000018038EE39  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EE40  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EE44  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EE48  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EE4D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EE54  E8 A7 CB 01 00              call    sub_1803ABA00
000000018038EE59  66 0F 6F 05 CF D1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038EE61  48 8D 05 D8 C1 5F 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
000000018038EE68  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EE6C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EE70  48 8D 87 E0 AB 00 00        lea     rax, [rdi+0ABE0h]
000000018038EE77  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EE7E  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EE82  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EE86  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EE8B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EE92  E8 69 CB 01 00              call    sub_1803ABA00
000000018038EE97  66 0F 6F 05 91 D1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038EE9F  48 8D 05 AA C1 5F 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
000000018038EEA6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EEAA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EEAE  48 8D 87 F0 AB 00 00        lea     rax, [rdi+0ABF0h]
000000018038EEB5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EEBC  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EEC0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EEC4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EEC9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EED0  E8 2B CB 01 00              call    sub_1803ABA00
000000018038EED5  66 0F 6F 05 53 D1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038EEDD  48 8D 05 7C C1 5F 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
000000018038EEE4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EEE8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EEED  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EEF4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EEFB  48 8D 87 00 AC 00 00        lea     rax, [rdi+0AC00h]
000000018038EF02  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EF06  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EF0A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EF0E  E8 ED CA 01 00              call    sub_1803ABA00
000000018038EF13  66 0F 6F 05 15 D1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038EF1B  48 8D 05 4E C1 5F 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
000000018038EF22  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EF26  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EF2A  48 8D 87 10 AC 00 00        lea     rax, [rdi+0AC10h]
000000018038EF31  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EF38  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EF3C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EF40  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EF45  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EF4C  E8 AF CA 01 00              call    sub_1803ABA00
000000018038EF51  66 0F 6F 05 D7 D0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038EF59  48 8D 05 20 C1 5F 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
000000018038EF60  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EF64  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EF68  48 8D 87 20 AC 00 00        lea     rax, [rdi+0AC20h]
000000018038EF6F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EF76  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EF7A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EF7E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EF83  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EF8A  E8 71 CA 01 00              call    sub_1803ABA00
000000018038EF8F  66 0F 6F 05 99 D0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038EF97  48 8D 05 F2 C0 5F 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
000000018038EF9E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EFA2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EFA6  48 8D 87 30 AC 00 00        lea     rax, [rdi+0AC30h]
000000018038EFAD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EFB4  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EFB8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EFBC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EFC1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038EFC8  E8 33 CA 01 00              call    sub_1803ABA00
000000018038EFCD  66 0F 6F 05 5B D0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038EFD5  48 8D 05 C4 C0 5F 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
000000018038EFDC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038EFE0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038EFE4  48 8D 87 40 AC 00 00        lea     rax, [rdi+0AC40h]
000000018038EFEB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038EFF2  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038EFF6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038EFFA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038EFFF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F006  E8 F5 C9 01 00              call    sub_1803ABA00
000000018038F00B  66 0F 6F 05 1D D0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F013  48 8D 05 96 C0 5F 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
000000018038F01A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F01E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F022  48 8D 87 50 AC 00 00        lea     rax, [rdi+0AC50h]
000000018038F029  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F030  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F034  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F038  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F03D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F044  E8 B7 C9 01 00              call    sub_1803ABA00
000000018038F049  66 0F 6F 05 DF CF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F051  48 8D 05 68 C0 5F 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
000000018038F058  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F05C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F060  48 8D 87 60 AC 00 00        lea     rax, [rdi+0AC60h]
000000018038F067  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F06E  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F072  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F076  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F07B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F082  E8 79 C9 01 00              call    sub_1803ABA00
000000018038F087  66 0F 6F 05 A1 CF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F08F  48 8D 05 3A C0 5F 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
000000018038F096  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F09A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F09E  48 8D 87 70 AC 00 00        lea     rax, [rdi+0AC70h]
000000018038F0A5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F0AC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F0B0  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F0B4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F0B9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F0C0  E8 3B C9 01 00              call    sub_1803ABA00
000000018038F0C5  66 0F 6F 05 63 CF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F0CD  48 8D 05 14 C0 5F 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
000000018038F0D4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F0D8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F0DC  48 8D 87 80 AC 00 00        lea     rax, [rdi+0AC80h]
000000018038F0E3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F0EA  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F0EE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F0F2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F0F7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F0FE  E8 FD C8 01 00              call    sub_1803ABA00
000000018038F103  48 8D 05 F6 BF 5F 00        lea     rax, aReadOnly; "read only"
000000018038F10A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F111  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F115  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F119  48 8D 87 20 AE 00 00        lea     rax, [rdi+0AE20h]
000000018038F120  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F127  0F 57 C0                    xorps   xmm0, xmm0
000000018038F12A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F12E  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F132  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F137  E8 C4 C8 01 00              call    sub_1803ABA00
000000018038F13C  48 8D 05 BD BF 5F 00        lea     rax, aReadOnly; "read only"
000000018038F143  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F14A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F14E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F152  48 8D 87 30 AE 00 00        lea     rax, [rdi+0AE30h]
000000018038F159  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F160  0F 57 C0                    xorps   xmm0, xmm0
000000018038F163  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F167  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F16B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F170  E8 8B C8 01 00              call    sub_1803ABA00
000000018038F175  48 8D 05 94 BF 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
000000018038F17C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F183  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F187  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F18B  48 8D 87 40 AE 00 00        lea     rax, [rdi+0AE40h]
000000018038F192  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F199  0F 57 C0                    xorps   xmm0, xmm0
000000018038F19C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F1A0  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F1A4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F1A9  E8 52 C8 01 00              call    sub_1803ABA00
000000018038F1AE  66 0F 6F 05 7A CE 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F1B6  48 8D 05 6B BF 5F 00        lea     rax, aEnvAttack; "ENV Attack"
000000018038F1BD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F1C1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F1C5  48 8D 87 20 AF 00 00        lea     rax, [rdi+0AF20h]
000000018038F1CC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F1D3  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F1D7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F1DB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F1E0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F1E7  E8 14 C8 01 00              call    sub_1803ABA00
000000018038F1EC  66 0F 6F 05 3C CE 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F1F4  48 8D 05 3D BF 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
000000018038F1FB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F1FF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F203  48 8D 87 30 AF 00 00        lea     rax, [rdi+0AF30h]
000000018038F20A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F211  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F215  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F219  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F21E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F225  E8 D6 C7 01 00              call    sub_1803ABA00
000000018038F22A  66 0F 6F 05 FE CD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F232  48 8D 05 0F BF 5F 00        lea     rax, aEnvDecay; "ENV Decay"
000000018038F239  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F23D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F241  48 8D 87 40 AF 00 00        lea     rax, [rdi+0AF40h]
000000018038F248  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F24F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F253  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F257  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F25C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F263  E8 98 C7 01 00              call    sub_1803ABA00
000000018038F268  48 8D 05 E9 BE 5F 00        lea     rax, aEnvRelease; "ENV Release"
000000018038F26F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F276  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F27A  66 0F 6F 05 AE CD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F282  48 8D 87 50 AF 00 00        lea     rax, [rdi+0AF50h]
000000018038F289  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F28D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F291  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F295  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F29C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F2A1  E8 5A C7 01 00              call    sub_1803ABA00
000000018038F2A6  66 0F 6F 05 82 CD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F2AE  48 8D 05 B3 BE 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
000000018038F2B5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F2B9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F2BD  48 8D 87 60 AF 00 00        lea     rax, [rdi+0AF60h]
000000018038F2C4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F2CB  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F2CF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F2D3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F2D8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F2DF  E8 1C C7 01 00              call    sub_1803ABA00
000000018038F2E4  48 8D 05 25 BE 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
000000018038F2EB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F2F2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F2F6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F2FA  48 8D 87 20 B0 00 00        lea     rax, [rdi+0B020h]
000000018038F301  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F308  0F 57 C0                    xorps   xmm0, xmm0
000000018038F30B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F30F  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F313  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F318  E8 E3 C6 01 00              call    sub_1803ABA00
000000018038F31D  66 0F 6F 05 0B CD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F325  48 8D 05 FC BD 5F 00        lea     rax, aEnvAttack; "ENV Attack"
000000018038F32C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F330  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F334  48 8D 87 00 B1 00 00        lea     rax, [rdi+0B100h]
000000018038F33B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F342  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F346  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F34A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F34F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F356  E8 A5 C6 01 00              call    sub_1803ABA00
000000018038F35B  66 0F 6F 05 CD CC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F363  48 8D 05 CE BD 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
000000018038F36A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F36E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F372  48 8D 87 10 B1 00 00        lea     rax, [rdi+0B110h]
000000018038F379  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F380  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F384  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F388  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F38D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F394  E8 67 C6 01 00              call    sub_1803ABA00
000000018038F399  66 0F 6F 05 8F CC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F3A1  48 8D 05 A0 BD 5F 00        lea     rax, aEnvDecay; "ENV Decay"
000000018038F3A8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F3AC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F3B0  48 8D 87 20 B1 00 00        lea     rax, [rdi+0B120h]
000000018038F3B7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F3BE  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F3C2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F3C6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F3CB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F3D2  E8 29 C6 01 00              call    sub_1803ABA00
000000018038F3D7  66 0F 6F 05 51 CC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F3DF  48 8D 05 72 BD 5F 00        lea     rax, aEnvRelease; "ENV Release"
000000018038F3E6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F3EA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F3EE  48 8D 87 30 B1 00 00        lea     rax, [rdi+0B130h]
000000018038F3F5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F3FC  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F400  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F404  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F409  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F410  E8 EB C5 01 00              call    sub_1803ABA00
000000018038F415  66 0F 6F 05 13 CC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F41D  48 8D 05 44 BD 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
000000018038F424  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F428  48 8D 87 40 B1 00 00        lea     rax, [rdi+0B140h]
000000018038F42F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F436  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F43B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F442  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F446  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F44A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F44E  E8 AD C5 01 00              call    sub_1803ABA00
000000018038F453  48 8D 05 1E BD 5F 00        lea     rax, aOsc1Feet; "OSC1 Feet"
000000018038F45A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F461  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F465  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F469  48 8D 87 40 B3 00 00        lea     rax, [rdi+0B340h]
000000018038F470  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F477  0F 57 C0                    xorps   xmm0, xmm0
000000018038F47A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F47E  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F482  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F487  E8 74 C5 01 00              call    sub_1803ABA00
000000018038F48C  48 8D 05 F5 BC 5F 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
000000018038F493  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F49A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F49E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F4A2  48 8D 87 50 B3 00 00        lea     rax, [rdi+0B350h]
000000018038F4A9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F4B0  0F 57 C0                    xorps   xmm0, xmm0
000000018038F4B3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F4B7  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F4BB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F4C0  E8 3B C5 01 00              call    sub_1803ABA00
000000018038F4C5  48 8D 05 CC BC 5F 00        lea     rax, aBendEnableSw; "Bend Enable SW"
000000018038F4CC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F4D3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F4D7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F4DB  48 8D 87 60 B3 00 00        lea     rax, [rdi+0B360h]
000000018038F4E2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F4E9  0F 57 C0                    xorps   xmm0, xmm0
000000018038F4EC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F4F0  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F4F4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F4F9  E8 02 C5 01 00              call    sub_1803ABA00
000000018038F4FE  48 8D 05 A3 BC 5F 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
000000018038F505  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F50C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F510  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F514  48 8D 87 70 B3 00 00        lea     rax, [rdi+0B370h]
000000018038F51B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F522  0F 57 C0                    xorps   xmm0, xmm0
000000018038F525  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F529  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F52D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F532  E8 C9 C4 01 00              call    sub_1803ABA00
000000018038F537  48 8D 05 7A BC 5F 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
000000018038F53E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F545  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F549  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F54D  48 8D 87 80 B3 00 00        lea     rax, [rdi+0B380h]
000000018038F554  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F55B  0F 57 C0                    xorps   xmm0, xmm0
000000018038F55E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F562  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F566  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F56B  E8 90 C4 01 00              call    sub_1803ABA00
000000018038F570  48 8D 05 51 BC 5F 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
000000018038F577  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F57E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F582  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F586  48 8D 87 90 B3 00 00        lea     rax, [rdi+0B390h]
000000018038F58D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F594  0F 57 C0                    xorps   xmm0, xmm0
000000018038F597  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F59B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F59F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F5A4  E8 57 C4 01 00              call    sub_1803ABA00
000000018038F5A9  48 8D 05 28 BC 5F 00        lea     rax, aPwmSwManual; "PWM SW Manual"
000000018038F5B0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F5B7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F5BB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F5BF  48 8D 87 A0 B3 00 00        lea     rax, [rdi+0B3A0h]
000000018038F5C6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F5CD  0F 57 C0                    xorps   xmm0, xmm0
000000018038F5D0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F5D4  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F5D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F5DD  E8 1E C4 01 00              call    sub_1803ABA00
000000018038F5E2  66 0F 6F 05 46 CA 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F5EA  48 8D 05 F7 BB 5F 00        lea     rax, aTune; "Tune"
000000018038F5F1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F5F5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F5F9  48 8D 87 B0 B3 00 00        lea     rax, [rdi+0B3B0h]
000000018038F600  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F607  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F60B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F60F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F614  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F61B  E8 E0 C3 01 00              call    sub_1803ABA00
000000018038F620  66 0F 6F 05 08 CA 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F628  48 8D 05 C1 BB 5F 00        lea     rax, aDetune; "Detune"
000000018038F62F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F633  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F637  48 8D 87 C0 B3 00 00        lea     rax, [rdi+0B3C0h]
000000018038F63E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F645  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F649  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F64D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F652  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F659  E8 A2 C3 01 00              call    sub_1803ABA00
000000018038F65E  66 0F 6F 05 CA C9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F666  48 8D 05 8B BB 5F 00        lea     rax, aModSens; "Mod Sens"
000000018038F66D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F671  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F675  48 8D 87 D0 B3 00 00        lea     rax, [rdi+0B3D0h]
000000018038F67C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F683  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F687  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F68B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F690  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F697  E8 64 C3 01 00              call    sub_1803ABA00
000000018038F69C  66 0F 6F 05 8C C9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F6A4  48 8D 05 59 BB 5F 00        lea     rax, aModSw; "Mod Sw"
000000018038F6AB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F6AF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F6B3  48 8D 87 E0 B3 00 00        lea     rax, [rdi+0B3E0h]
000000018038F6BA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F6C1  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F6C5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F6C9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F6CE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F6D5  E8 26 C3 01 00              call    sub_1803ABA00
000000018038F6DA  66 0F 6F 05 4E C9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F6E2  48 8D 05 27 BB 5F 00        lea     rax, aLfoGain; "LFO Gain"
000000018038F6E9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F6ED  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F6F1  48 8D 87 F0 B3 00 00        lea     rax, [rdi+0B3F0h]
000000018038F6F8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F6FF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F703  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F707  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F70C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F713  E8 E8 C2 01 00              call    sub_1803ABA00
000000018038F718  66 0F 6F 05 10 C9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F720  48 8D 05 F9 BA 5F 00        lea     rax, aLfoLevel; "LFO Level"
000000018038F727  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F72B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F72F  48 8D 87 00 B4 00 00        lea     rax, [rdi+0B400h]
000000018038F736  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F73D  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F741  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F745  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F74A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F751  E8 AA C2 01 00              call    sub_1803ABA00
000000018038F756  66 0F 6F 05 D2 C8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F75E  48 8D 05 C7 BA 5F 00        lea     rax, aLfoSw; "LFO Sw"
000000018038F765  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F769  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F76D  48 8D 87 10 B4 00 00        lea     rax, [rdi+0B410h]
000000018038F774  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F77B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F77F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F783  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F788  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F78F  E8 6C C2 01 00              call    sub_1803ABA00
000000018038F794  66 0F 6F 05 94 C8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F79C  48 8D 05 95 BA 5F 00        lea     rax, aEnv1Level; "ENV1 Level"
000000018038F7A3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F7A7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F7AE  48 8D 87 20 B4 00 00        lea     rax, [rdi+0B420h]
000000018038F7B5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F7BC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F7C0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F7C4  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F7C8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F7CD  E8 2E C2 01 00              call    sub_1803ABA00
000000018038F7D2  66 0F 6F 05 56 C8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F7DA  48 8D 05 67 BA 5F 00        lea     rax, aEnv2Level; "ENV2 Level"
000000018038F7E1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F7E5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F7E9  48 8D 87 30 B4 00 00        lea     rax, [rdi+0B430h]
000000018038F7F0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F7F7  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F7FB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F7FF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F804  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F80B  E8 F0 C1 01 00              call    sub_1803ABA00
000000018038F810  66 0F 6F 05 18 C8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F818  48 8D 05 35 BA 5F 00        lea     rax, aEnvSw; "ENV Sw"
000000018038F81F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F823  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F827  48 8D 87 40 B4 00 00        lea     rax, [rdi+0B440h]
000000018038F82E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F835  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F839  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F83D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F842  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F849  E8 B2 C1 01 00              call    sub_1803ABA00
000000018038F84E  66 0F 6F 05 DA C7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F856  48 8D 05 03 BA 5F 00        lea     rax, aBendLevel; "Bend Level"
000000018038F85D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F861  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F865  48 8D 87 50 B4 00 00        lea     rax, [rdi+0B450h]
000000018038F86C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F873  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F877  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F87B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F880  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F887  E8 74 C1 01 00              call    sub_1803ABA00
000000018038F88C  66 0F 6F 05 9C C7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F894  48 8D 05 D5 B9 5F 00        lea     rax, aBendRange; "Bend Range"
000000018038F89B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F89F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F8A3  48 8D 87 60 B4 00 00        lea     rax, [rdi+0B460h]
000000018038F8AA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F8B1  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F8B5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F8B9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F8BE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F8C5  E8 36 C1 01 00              call    sub_1803ABA00
000000018038F8CA  66 0F 6F 05 5E C7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F8D2  48 8D 05 A7 B9 5F 00        lea     rax, aPwmLevel; "PWM Level"
000000018038F8D9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F8DD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F8E1  48 8D 87 70 B4 00 00        lea     rax, [rdi+0B470h]
000000018038F8E8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F8EF  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F8F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F8F7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F8FC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F903  E8 F8 C0 01 00              call    sub_1803ABA00
000000018038F908  66 0F 6F 05 20 C7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F910  48 8D 05 79 B9 5F 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
000000018038F917  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F91B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F91F  48 8D 87 A0 B4 00 00        lea     rax, [rdi+0B4A0h]
000000018038F926  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F92D  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F931  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F935  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F93A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F941  E8 BA C0 01 00              call    sub_1803ABA00
000000018038F946  66 0F 6F 05 E2 C6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F94E  48 8D 05 4B B9 5F 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
000000018038F955  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F959  48 8D 87 B0 B4 00 00        lea     rax, [rdi+0B4B0h]
000000018038F960  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F964  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F96B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F970  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F977  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F97B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F97F  E8 7C C0 01 00              call    sub_1803ABA00
000000018038F984  66 0F 6F 05 A4 C6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F98C  48 8D 05 1D B9 5F 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
000000018038F993  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F997  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F99B  48 8D 87 C0 B4 00 00        lea     rax, [rdi+0B4C0h]
000000018038F9A2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F9A9  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F9AD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F9B1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F9B6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F9BD  E8 3E C0 01 00              call    sub_1803ABA00
000000018038F9C2  66 0F 6F 05 66 C6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038F9CA  48 8D 05 EF B8 5F 00        lea     rax, aDutyTune; "Duty Tune"
000000018038F9D1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038F9D5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038F9D9  48 8D 87 D0 B9 00 00        lea     rax, [rdi+0B9D0h]
000000018038F9E0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038F9E7  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038F9EB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038F9EF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038F9F4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038F9FB  E8 00 C0 01 00              call    sub_1803ABA00
000000018038FA00  66 0F 6F 05 28 C6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FA08  48 8D 05 C1 B8 5F 00        lea     rax, aOsc1Mute; "Osc1 Mute"
000000018038FA0F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FA13  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FA17  48 8D 87 70 BD 00 00        lea     rax, [rdi+0BD70h]
000000018038FA1E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FA25  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FA29  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FA2D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FA32  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FA39  E8 C2 BF 01 00              call    sub_1803ABA00
000000018038FA3E  66 0F 6F 05 EA C5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FA46  48 8D 05 93 B8 5F 00        lea     rax, aOsc1Level; "Osc1 Level"
000000018038FA4D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FA51  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FA55  48 8D 87 B0 BD 00 00        lea     rax, [rdi+0BDB0h]
000000018038FA5C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FA63  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FA67  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FA6B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FA70  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FA77  E8 84 BF 01 00              call    sub_1803ABA00
000000018038FA7C  66 0F 6F 05 AC C5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FA84  48 8D 05 65 B8 5F 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
000000018038FA8B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FA8F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FA93  48 8D 87 C0 BD 00 00        lea     rax, [rdi+0BDC0h]
000000018038FA9A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FAA1  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FAA5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FAA9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FAAE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FAB5  E8 46 BF 01 00              call    sub_1803ABA00
000000018038FABA  48 8D 05 3F B8 5F 00        lea     rax, aGrifferSw; "Griffer SW"
000000018038FAC1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FAC8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FACC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FAD0  48 8D 87 80 BE 00 00        lea     rax, [rdi+0BE80h]
000000018038FAD7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FADE  0F 57 C0                    xorps   xmm0, xmm0
000000018038FAE1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FAE5  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FAE9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FAEE  E8 0D BF 01 00              call    sub_1803ABA00
000000018038FAF3  66 0F 6F 05 35 C5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FAFB  48 8D 05 0E B8 5F 00        lea     rax, aLpfCutoff; "LPF Cutoff"
000000018038FB02  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FB06  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FB0A  48 8D 87 90 BE 00 00        lea     rax, [rdi+0BE90h]
000000018038FB11  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FB18  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FB1C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FB20  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FB25  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FB2C  E8 CF BE 01 00              call    sub_1803ABA00
000000018038FB31  48 8D 05 E8 B7 5F 00        lea     rax, aLpfResonance; "LPF Resonance"
000000018038FB38  66 0F 6F 05 F0 C4 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FB40  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FB44  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FB48  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FB4C  48 8D 87 F0 BE 00 00        lea     rax, [rdi+0BEF0h]
000000018038FB53  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FB5A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FB5E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FB63  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FB6A  E8 91 BE 01 00              call    sub_1803ABA00
000000018038FB6F  48 8D 05 BA B7 5F 00        lea     rax, aVelocity; "Velocity"
000000018038FB76  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FB7D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FB81  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FB85  48 8D 87 10 BF 00 00        lea     rax, [rdi+0BF10h]
000000018038FB8C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FB93  0F 57 C0                    xorps   xmm0, xmm0
000000018038FB96  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FB9A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FB9E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FBA3  E8 58 BE 01 00              call    sub_1803ABA00
000000018038FBA8  48 8D 05 8D B7 5F 00        lea     rax, aEnv12; "Env1/2"
000000018038FBAF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FBB6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FBBA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FBBE  48 8D 87 A0 BF 00 00        lea     rax, [rdi+0BFA0h]
000000018038FBC5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FBCC  0F 57 C0                    xorps   xmm0, xmm0
000000018038FBCF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FBD3  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FBD7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FBDC  E8 1F BE 01 00              call    sub_1803ABA00
000000018038FBE1  48 8D 05 60 B7 5F 00        lea     rax, aIntEnv; "Int/Env"
000000018038FBE8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FBEF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FBF3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FBF7  48 8D 87 B0 BF 00 00        lea     rax, [rdi+0BFB0h]
000000018038FBFE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FC05  0F 57 C0                    xorps   xmm0, xmm0
000000018038FC08  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FC0C  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FC10  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FC15  E8 E6 BD 01 00              call    sub_1803ABA00
000000018038FC1A  48 8D 05 EF B5 5F 00        lea     rax, aLfoGain; "LFO Gain"
000000018038FC21  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FC28  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FC2C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FC30  48 8D 87 C0 C0 00 00        lea     rax, [rdi+0C0C0h]
000000018038FC37  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FC3E  0F 57 C0                    xorps   xmm0, xmm0
000000018038FC41  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FC45  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FC49  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FC4E  E8 AD BD 01 00              call    sub_1803ABA00
000000018038FC53  48 8D 05 F6 B6 5F 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
000000018038FC5A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FC61  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FC65  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FC69  48 8D 87 D0 C0 00 00        lea     rax, [rdi+0C0D0h]
000000018038FC70  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FC77  0F 57 C0                    xorps   xmm0, xmm0
000000018038FC7A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FC7E  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FC82  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FC87  E8 74 BD 01 00              call    sub_1803ABA00
000000018038FC8C  48 8D 05 CD B6 5F 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
000000018038FC93  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FC9A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FC9E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FCA2  48 8D 87 E0 C0 00 00        lea     rax, [rdi+0C0E0h]
000000018038FCA9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FCB0  0F 57 C0                    xorps   xmm0, xmm0
000000018038FCB3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FCB7  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FCBB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FCC0  E8 3B BD 01 00              call    sub_1803ABA00
000000018038FCC5  66 0F 6F 05 63 C3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FCCD  48 8D 05 4C B5 5F 00        lea     rax, aLfoLevel; "LFO Level"
000000018038FCD4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FCD8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FCDD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FCE4  48 8D 87 F0 C0 00 00        lea     rax, [rdi+0C0F0h]
000000018038FCEB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FCF2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FCF6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FCFA  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FCFE  E8 FD BC 01 00              call    sub_1803ABA00
000000018038FD03  66 0F 6F 05 25 C3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FD0B  48 8D 05 5E B6 5F 00        lea     rax, aModSens_0; "MOD Sens"
000000018038FD12  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FD16  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FD1A  48 8D 87 00 C1 00 00        lea     rax, [rdi+0C100h]
000000018038FD21  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FD28  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FD2C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FD30  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FD35  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FD3C  E8 BF BC 01 00              call    sub_1803ABA00
000000018038FD41  66 0F 6F 05 E7 C2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FD49  48 8D 05 2C B6 5F 00        lea     rax, aModSw_0; "MOD SW"
000000018038FD50  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FD54  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FD58  48 8D 87 10 C1 00 00        lea     rax, [rdi+0C110h]
000000018038FD5F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FD66  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FD6A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FD6E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FD73  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FD7A  E8 81 BC 01 00              call    sub_1803ABA00
000000018038FD7F  66 0F 6F 05 A9 C2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FD87  48 8D 05 FA B5 5F 00        lea     rax, aEnvLevel; "ENV Level"
000000018038FD8E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FD92  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FD96  48 8D 87 20 C1 00 00        lea     rax, [rdi+0C120h]
000000018038FD9D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FDA4  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FDA8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FDAC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FDB1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FDB8  E8 43 BC 01 00              call    sub_1803ABA00
000000018038FDBD  66 0F 6F 05 6B C2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FDC5  48 8D 05 CC B5 5F 00        lea     rax, aKcvLevel; "KCV Level"
000000018038FDCC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FDD0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FDD4  48 8D 87 30 C1 00 00        lea     rax, [rdi+0C130h]
000000018038FDDB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FDE2  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FDE6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FDEA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FDEF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FDF6  E8 05 BC 01 00              call    sub_1803ABA00
000000018038FDFB  66 0F 6F 05 2D C2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FE03  48 8D 05 9E B5 5F 00        lea     rax, aVelocitySens; "Velocity Sens"
000000018038FE0A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FE0E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FE12  48 8D 87 40 C1 00 00        lea     rax, [rdi+0C140h]
000000018038FE19  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FE20  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FE24  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FE28  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FE2D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FE34  E8 C7 BB 01 00              call    sub_1803ABA00
000000018038FE39  66 0F 6F 05 EF C1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FE41  48 8D 05 70 B5 5F 00        lea     rax, aVelocityOffset; "Velocity Offset"
000000018038FE48  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FE4C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FE50  48 8D 87 50 C1 00 00        lea     rax, [rdi+0C150h]
000000018038FE57  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FE5E  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FE62  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FE66  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FE6B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FE72  E8 89 BB 01 00              call    sub_1803ABA00
000000018038FE77  66 0F 6F 05 B1 C1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FE7F  48 8D 05 DA B3 5F 00        lea     rax, aBendLevel; "Bend Level"
000000018038FE86  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FE8A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FE8E  48 8D 87 60 C1 00 00        lea     rax, [rdi+0C160h]
000000018038FE95  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FE9C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FEA0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FEA5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FEAC  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FEB0  E8 4B BB 01 00              call    sub_1803ABA00
000000018038FEB5  66 0F 6F 05 73 C1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FEBD  48 8D 05 AC B3 5F 00        lea     rax, aBendRange; "Bend Range"
000000018038FEC4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FEC8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FECC  48 8D 87 70 C1 00 00        lea     rax, [rdi+0C170h]
000000018038FED3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FEDA  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FEDE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FEE2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FEE7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FEEE  E8 0D BB 01 00              call    sub_1803ABA00
000000018038FEF3  66 0F 6F 05 35 C1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FEFB  48 8D 05 C6 B4 5F 00        lea     rax, aCutoffTune; "Cutoff Tune"
000000018038FF02  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FF06  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FF0A  48 8D 87 F0 C1 00 00        lea     rax, [rdi+0C1F0h]
000000018038FF11  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FF18  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FF1C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FF20  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FF25  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FF2C  E8 CF BA 01 00              call    sub_1803ABA00
000000018038FF31  66 0F 6F 05 F7 C0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FF39  48 8D 05 98 B4 5F 00        lea     rax, aResonanceTune; "Resonance Tune"
000000018038FF40  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FF44  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FF48  48 8D 87 00 C2 00 00        lea     rax, [rdi+0C200h]
000000018038FF4F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018038FF56  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FF5A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FF5E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FF63  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FF6A  E8 91 BA 01 00              call    sub_1803ABA00
000000018038FF6F  48 8D 05 72 B4 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
000000018038FF76  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
000000018038FF7D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FF81  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FF85  48 8D 87 10 C2 00 00        lea     rax, [rdi+0C210h]
000000018038FF8C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FF93  0F 57 C0                    xorps   xmm0, xmm0
000000018038FF96  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FF9A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FF9E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FFA3  E8 58 BA 01 00              call    sub_1803ABA00
000000018038FFA8  48 8D 05 39 B4 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
000000018038FFAF  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
000000018038FFB6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FFBA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FFBE  48 8D 87 A0 C7 00 00        lea     rax, [rdi+0C7A0h]
000000018038FFC5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018038FFCC  0F 57 C0                    xorps   xmm0, xmm0
000000018038FFCF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018038FFD3  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018038FFD7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018038FFDC  E8 1F BA 01 00              call    sub_1803ABA00
000000018038FFE1  66 0F 6F 05 47 C0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018038FFE9  48 8D 05 08 B4 5F 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
000000018038FFF0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018038FFF4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018038FFF8  48 8D 87 B0 C7 00 00        lea     rax, [rdi+0C7B0h]
000000018038FFFF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390006  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039000A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039000E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390013  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039001A  E8 E1 B9 01 00              call    sub_1803ABA00
000000018039001F  66 0F 6F 05 09 C0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390027  48 8D 05 DA B3 5F 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
000000018039002E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390032  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390036  48 8D 87 C0 C7 00 00        lea     rax, [rdi+0C7C0h]
000000018039003D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390044  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390048  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039004C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390051  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390058  E8 A3 B9 01 00              call    sub_1803ABA00
000000018039005D  48 8D 05 B4 B3 5F 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
0000000180390064  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390068  66 0F 6F 05 C0 BF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390070  48 8D 87 D0 C7 00 00        lea     rax, [rdi+0C7D0h]
0000000180390077  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039007B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039007F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390083  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039008A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039008F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390096  E8 65 B9 01 00              call    sub_1803ABA00
000000018039009B  66 0F 6F 05 8D BF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803900A3  48 8D 05 7E B3 5F 00        lea     rax, aAmpTone; "AMP TONE"
00000001803900AA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803900AE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803900B2  48 8D 87 B0 C9 00 00        lea     rax, [rdi+0C9B0h]
00000001803900B9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803900C0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803900C4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803900C8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803900CD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803900D4  E8 27 B9 01 00              call    sub_1803ABA00
00000001803900D9  66 0F 6F 05 4F BF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803900E1  48 8D 05 50 B3 5F 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
00000001803900E8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803900EC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803900F0  48 8D 87 C0 C9 00 00        lea     rax, [rdi+0C9C0h]
00000001803900F7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803900FE  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390102  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390106  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039010B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390112  E8 E9 B8 01 00              call    sub_1803ABA00
0000000180390117  66 0F 6F 05 11 BF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039011F  48 8D 05 2A B3 5F 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
0000000180390126  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039012A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039012E  48 8D 87 D0 C9 00 00        lea     rax, [rdi+0C9D0h]
0000000180390135  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039013C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390140  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390144  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390149  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390150  E8 AB B8 01 00              call    sub_1803ABA00
0000000180390155  48 8D 05 D4 B1 5F 00        lea     rax, aVelocity; "Velocity"
000000018039015C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390163  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390167  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039016B  48 8D 87 10 CA 00 00        lea     rax, [rdi+0CA10h]
0000000180390172  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390179  0F 57 C0                    xorps   xmm0, xmm0
000000018039017C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390180  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390184  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390189  E8 72 B8 01 00              call    sub_1803ABA00
000000018039018E  48 8D 05 D3 B2 5F 00        lea     rax, aMute; "Mute"
0000000180390195  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039019C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803901A0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803901A4  48 8D 87 A0 CA 00 00        lea     rax, [rdi+0CAA0h]
00000001803901AB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803901B2  0F 57 C0                    xorps   xmm0, xmm0
00000001803901B5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803901B9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803901BD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803901C2  E8 39 B8 01 00              call    sub_1803ABA00
00000001803901C7  48 8D 05 A2 B2 5F 00        lea     rax, aGateSw; "Gate SW"
00000001803901CE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803901D5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803901D9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803901DD  48 8D 87 00 CC 00 00        lea     rax, [rdi+0CC00h]
00000001803901E4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803901EB  0F 57 C0                    xorps   xmm0, xmm0
00000001803901EE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803901F2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803901F6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803901FB  E8 00 B8 01 00              call    sub_1803ABA00
0000000180390200  48 8D 05 71 B2 5F 00        lea     rax, aEnv1Sw; "ENV1 SW"
0000000180390207  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039020E  0F 57 C0                    xorps   xmm0, xmm0
0000000180390211  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390215  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039021A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390221  48 8D 87 10 CC 00 00        lea     rax, [rdi+0CC10h]
0000000180390228  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039022C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390230  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390234  E8 C7 B7 01 00              call    sub_1803ABA00
0000000180390239  48 8D 05 40 B2 5F 00        lea     rax, aEnv2Sw; "ENV2 SW"
0000000180390240  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390247  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039024B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039024F  48 8D 87 20 CC 00 00        lea     rax, [rdi+0CC20h]
0000000180390256  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039025D  0F 57 C0                    xorps   xmm0, xmm0
0000000180390260  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390264  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390268  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039026D  E8 8E B7 01 00              call    sub_1803ABA00
0000000180390272  48 8D 05 0F B2 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
0000000180390279  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390280  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390284  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390288  48 8D 87 30 CC 00 00        lea     rax, [rdi+0CC30h]
000000018039028F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390296  0F 57 C0                    xorps   xmm0, xmm0
0000000180390299  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039029D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803902A1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803902A6  E8 55 B7 01 00              call    sub_1803ABA00
00000001803902AB  66 0F 6F 05 7D BD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803902B3  48 8D 05 DE B1 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
00000001803902BA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803902BE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803902C2  48 8D 87 40 CC 00 00        lea     rax, [rdi+0CC40h]
00000001803902C9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803902D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803902D4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803902D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803902DD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803902E4  E8 17 B7 01 00              call    sub_1803ABA00
00000001803902E9  66 0F 6F 05 3F BD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803902F1  48 8D 05 B0 B1 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
00000001803902F8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803902FC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390300  48 8D 87 50 CC 00 00        lea     rax, [rdi+0CC50h]
0000000180390307  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039030E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390312  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390316  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039031B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390322  E8 D9 B6 01 00              call    sub_1803ABA00
0000000180390327  66 0F 6F 05 01 BD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039032F  48 8D 05 82 B1 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
0000000180390336  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039033A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039033E  48 8D 87 60 CC 00 00        lea     rax, [rdi+0CC60h]
0000000180390345  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039034C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390350  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390354  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390359  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390360  E8 9B B6 01 00              call    sub_1803ABA00
0000000180390365  66 0F 6F 05 C3 BC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039036D  48 8D 05 54 B1 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
0000000180390374  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390378  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039037C  48 8D 87 70 CC 00 00        lea     rax, [rdi+0CC70h]
0000000180390383  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039038A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039038E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390392  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390397  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039039E  E8 5D B6 01 00              call    sub_1803ABA00
00000001803903A3  66 0F 6F 05 85 BC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803903AB  48 8D 05 2E B1 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
00000001803903B2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803903B6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803903BA  48 8D 87 80 CC 00 00        lea     rax, [rdi+0CC80h]
00000001803903C1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803903C8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803903CC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803903D0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803903D5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803903DC  E8 1F B6 01 00              call    sub_1803ABA00
00000001803903E1  66 0F 6F 05 47 BC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803903E9  48 8D 05 00 B1 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
00000001803903F0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803903F4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803903F8  48 8D 87 90 CC 00 00        lea     rax, [rdi+0CC90h]
00000001803903FF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390406  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039040A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039040E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390413  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039041A  E8 E1 B5 01 00              call    sub_1803ABA00
000000018039041F  48 8D 05 FA AA 5F 00        lea     rax, aUseextjack; "UseExtJack"
0000000180390426  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039042D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390431  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390435  48 8D 87 60 CE 00 00        lea     rax, [rdi+0CE60h]
000000018039043C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390443  0F 57 C0                    xorps   xmm0, xmm0
0000000180390446  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039044A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039044E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390453  E8 A8 B5 01 00              call    sub_1803ABA00
0000000180390458  48 8D 05 CD AA 5F 00        lea     rax, aMCv; "M.CV"
000000018039045F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390466  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039046A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039046E  48 8D 87 80 CE 00 00        lea     rax, [rdi+0CE80h]
0000000180390475  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039047C  0F 57 C0                    xorps   xmm0, xmm0
000000018039047F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390483  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390487  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039048C  E8 6F B5 01 00              call    sub_1803ABA00
0000000180390491  48 8D 05 9C AA 5F 00        lea     rax, aMGate; "M.Gate"
0000000180390498  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039049F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803904A3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803904A7  48 8D 87 90 CE 00 00        lea     rax, [rdi+0CE90h]
00000001803904AE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803904B5  0F 57 C0                    xorps   xmm0, xmm0
00000001803904B8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803904BC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803904C0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803904C5  E8 36 B5 01 00              call    sub_1803ABA00
00000001803904CA  66 0F 6F 05 5E BB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803904D2  48 8D 05 67 AA 5F 00        lea     rax, aMasterTune; "Master Tune"
00000001803904D9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803904DD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803904E1  48 8D 87 C0 CE 00 00        lea     rax, [rdi+0CEC0h]
00000001803904E8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803904EF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803904F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803904F7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803904FC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390503  E8 F8 B4 01 00              call    sub_1803ABA00
0000000180390508  66 0F 6F 05 20 BB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390510  48 8D 05 39 AA 5F 00        lea     rax, aPartTune; "Part Tune"
0000000180390517  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039051B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039051F  48 8D 87 D0 CE 00 00        lea     rax, [rdi+0CED0h]
0000000180390526  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039052D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390531  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390535  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039053A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390541  E8 BA B4 01 00              call    sub_1803ABA00
0000000180390546  48 8D 05 13 AA 5F 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
000000018039054D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390554  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390558  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039055C  48 8D 87 A0 CF 00 00        lea     rax, [rdi+0CFA0h]
0000000180390563  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039056A  0F 57 C0                    xorps   xmm0, xmm0
000000018039056D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390571  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390575  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039057A  E8 81 B4 01 00              call    sub_1803ABA00
000000018039057F  48 8D 05 F2 A9 5F 00        lea     rax, aPortamentoMode; "Portamento Mode"
0000000180390586  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039058D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390591  0F 57 C0                    xorps   xmm0, xmm0
0000000180390594  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039059B  48 8D 87 B0 CF 00 00        lea     rax, [rdi+0CFB0h]
00000001803905A2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803905A6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803905AA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803905AE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803905B3  E8 48 B4 01 00              call    sub_1803ABA00
00000001803905B8  66 0F 6F 05 70 BA 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803905C0  48 8D 05 C1 A9 5F 00        lea     rax, aPortamentoTime; "Portamento Time"
00000001803905C7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803905CB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803905CF  48 8D 87 C0 CF 00 00        lea     rax, [rdi+0CFC0h]
00000001803905D6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803905DD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803905E1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803905E5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803905EA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803905F1  E8 0A B4 01 00              call    sub_1803ABA00
00000001803905F6  48 8D 05 9B A9 5F 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
00000001803905FD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390604  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390608  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039060C  48 8D 87 60 D1 00 00        lea     rax, [rdi+0D160h]
0000000180390613  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039061A  0F 57 C0                    xorps   xmm0, xmm0
000000018039061D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390621  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390625  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039062A  E8 D1 B3 01 00              call    sub_1803ABA00
000000018039062F  48 8D 05 7A A9 5F 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
0000000180390636  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039063D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390641  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390645  48 8D 87 70 D1 00 00        lea     rax, [rdi+0D170h]
000000018039064C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390653  0F 57 C0                    xorps   xmm0, xmm0
0000000180390656  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039065A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039065E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390663  E8 98 B3 01 00              call    sub_1803ABA00
0000000180390668  48 8D 05 59 A9 5F 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
000000018039066F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390676  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039067A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039067E  48 8D 87 80 D1 00 00        lea     rax, [rdi+0D180h]
0000000180390685  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039068C  0F 57 C0                    xorps   xmm0, xmm0
000000018039068F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390693  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390697  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039069C  E8 5F B3 01 00              call    sub_1803ABA00
00000001803906A1  66 0F 6F 05 87 B9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803906A9  48 8D 05 28 A9 5F 00        lea     rax, aLfoRate; "LFO Rate"
00000001803906B0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803906B4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803906B8  48 8D 87 90 D1 00 00        lea     rax, [rdi+0D190h]
00000001803906BF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803906C6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803906CA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803906CE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803906D3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803906DA  E8 21 B3 01 00              call    sub_1803ABA00
00000001803906DF  48 8D 05 FE A8 5F 00        lea     rax, aGate; "Gate"
00000001803906E6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803906ED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803906F1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803906F5  48 8D 87 90 D4 00 00        lea     rax, [rdi+0D490h]
00000001803906FC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390703  0F 57 C0                    xorps   xmm0, xmm0
0000000180390706  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039070A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039070E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390713  E8 E8 B2 01 00              call    sub_1803ABA00
0000000180390718  48 8D 05 D1 A8 5F 00        lea     rax, aLfoTrig; "LFO Trig"
000000018039071F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390726  0F 57 C0                    xorps   xmm0, xmm0
0000000180390729  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039072D  48 8D 87 A0 D4 00 00        lea     rax, [rdi+0D4A0h]
0000000180390734  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039073B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390740  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390744  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390748  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039074C  E8 AF B2 01 00              call    sub_1803ABA00
0000000180390751  48 8D 05 A8 A8 5F 00        lea     rax, aResetSw; "Reset Sw"
0000000180390758  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039075F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390763  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390767  48 8D 87 B0 D4 00 00        lea     rax, [rdi+0D4B0h]
000000018039076E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390775  0F 57 C0                    xorps   xmm0, xmm0
0000000180390778  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039077C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390780  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390785  E8 76 B2 01 00              call    sub_1803ABA00
000000018039078A  66 0F 6F 05 9E B8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390792  48 8D 05 77 A8 5F 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
0000000180390799  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039079D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803907A1  48 8D 87 C0 D4 00 00        lea     rax, [rdi+0D4C0h]
00000001803907A8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803907AF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803907B3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803907B7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803907BC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803907C3  E8 38 B2 01 00              call    sub_1803ABA00
00000001803907C8  66 0F 6F 05 60 B8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803907D0  48 8D 05 49 A8 5F 00        lea     rax, aLfoDelay; "LFO Delay"
00000001803907D7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803907DB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803907DF  48 8D 87 D0 D4 00 00        lea     rax, [rdi+0D4D0h]
00000001803907E6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803907ED  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803907F1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803907F5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803907FA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390801  E8 FA B1 01 00              call    sub_1803ABA00
0000000180390806  66 0F 6F 05 22 B8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039080E  48 8D 05 1B A8 5F 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
0000000180390815  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390819  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039081D  48 8D 87 E0 D4 00 00        lea     rax, [rdi+0D4E0h]
0000000180390824  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039082B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039082F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390833  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390838  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039083F  E8 BC B1 01 00              call    sub_1803ABA00
0000000180390844  66 0F 6F 05 E4 B7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039084C  48 8D 05 ED A7 5F 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
0000000180390853  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390857  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039085B  48 8D 87 F0 D4 00 00        lea     rax, [rdi+0D4F0h]
0000000180390862  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390869  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039086D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390871  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390876  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039087D  E8 7E B1 01 00              call    sub_1803ABA00
0000000180390882  66 0F 6F 05 A6 B7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039088A  48 8D 05 BF A7 5F 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
0000000180390891  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390895  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390899  48 8D 87 00 D5 00 00        lea     rax, [rdi+0D500h]
00000001803908A0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803908A7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803908AB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803908AF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803908B4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803908BB  E8 40 B1 01 00              call    sub_1803ABA00
00000001803908C0  66 0F 6F 05 68 B7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803908C8  48 8D 05 91 A7 5F 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
00000001803908CF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803908D3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803908D7  48 8D 87 10 D5 00 00        lea     rax, [rdi+0D510h]
00000001803908DE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803908E5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803908E9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803908ED  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803908F2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803908F9  E8 02 B1 01 00              call    sub_1803ABA00
00000001803908FE  66 0F 6F 05 2A B7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390906  48 8D 05 63 A7 5F 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
000000018039090D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390911  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390915  48 8D 87 20 D5 00 00        lea     rax, [rdi+0D520h]
000000018039091C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390923  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390927  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039092B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390930  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390937  E8 C4 B0 01 00              call    sub_1803ABA00
000000018039093C  66 0F 6F 05 EC B6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390944  48 8D 05 35 A7 5F 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
000000018039094B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039094F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390953  48 8D 87 30 D5 00 00        lea     rax, [rdi+0D530h]
000000018039095A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390961  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390965  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390969  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039096E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390975  E8 86 B0 01 00              call    sub_1803ABA00
000000018039097A  66 0F 6F 05 AE B6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390982  48 8D 05 07 A7 5F 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
0000000180390989  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039098D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390991  48 8D 87 40 D5 00 00        lea     rax, [rdi+0D540h]
0000000180390998  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039099F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803909A3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803909A7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803909AC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803909B3  E8 48 B0 01 00              call    sub_1803ABA00
00000001803909B8  66 0F 6F 05 70 B6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803909C0  48 8D 05 D9 A6 5F 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
00000001803909C7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803909CB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803909CF  48 8D 87 50 D5 00 00        lea     rax, [rdi+0D550h]
00000001803909D6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803909DD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803909E1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803909E5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803909EA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803909F1  E8 0A B0 01 00              call    sub_1803ABA00
00000001803909F6  66 0F 6F 05 32 B6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803909FE  48 8D 05 AB A6 5F 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
0000000180390A05  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390A09  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390A0D  48 8D 87 60 D5 00 00        lea     rax, [rdi+0D560h]
0000000180390A14  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390A1B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390A1F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390A23  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390A28  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390A2F  E8 CC AF 01 00              call    sub_1803ABA00
0000000180390A34  66 0F 6F 05 F4 B5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390A3C  48 8D 05 7D A6 5F 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
0000000180390A43  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390A47  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390A4B  48 8D 87 70 D5 00 00        lea     rax, [rdi+0D570h]
0000000180390A52  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390A59  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390A5D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390A61  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390A66  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390A6D  E8 8E AF 01 00              call    sub_1803ABA00
0000000180390A72  66 0F 6F 05 B6 B5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390A7A  48 8D 05 4F A6 5F 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
0000000180390A81  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390A85  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390A89  48 8D 87 80 D5 00 00        lea     rax, [rdi+0D580h]
0000000180390A90  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390A97  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390A9B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390A9F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390AA4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390AAB  E8 50 AF 01 00              call    sub_1803ABA00
0000000180390AB0  66 0F 6F 05 78 B5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390AB8  48 8D 05 29 A6 5F 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
0000000180390ABF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390AC3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390ACA  48 8D 87 90 D5 00 00        lea     rax, [rdi+0D590h]
0000000180390AD1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390AD8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390ADC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390AE0  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390AE4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390AE9  E8 12 AF 01 00              call    sub_1803ABA00
0000000180390AEE  48 8D 05 0B A6 5F 00        lea     rax, aReadOnly; "read only"
0000000180390AF5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390AFC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390B00  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390B04  48 8D 87 30 D7 00 00        lea     rax, [rdi+0D730h]
0000000180390B0B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390B12  0F 57 C0                    xorps   xmm0, xmm0
0000000180390B15  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390B19  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390B1D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390B22  E8 D9 AE 01 00              call    sub_1803ABA00
0000000180390B27  48 8D 05 D2 A5 5F 00        lea     rax, aReadOnly; "read only"
0000000180390B2E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390B35  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390B39  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390B3D  48 8D 87 40 D7 00 00        lea     rax, [rdi+0D740h]
0000000180390B44  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390B4B  0F 57 C0                    xorps   xmm0, xmm0
0000000180390B4E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390B52  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390B56  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390B5B  E8 A0 AE 01 00              call    sub_1803ABA00
0000000180390B60  48 8D 05 A9 A5 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
0000000180390B67  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390B6E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390B72  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390B76  48 8D 87 50 D7 00 00        lea     rax, [rdi+0D750h]
0000000180390B7D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390B84  0F 57 C0                    xorps   xmm0, xmm0
0000000180390B87  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390B8B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390B8F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390B94  E8 67 AE 01 00              call    sub_1803ABA00
0000000180390B99  66 0F 6F 05 8F B4 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390BA1  48 8D 05 80 A5 5F 00        lea     rax, aEnvAttack; "ENV Attack"
0000000180390BA8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390BAC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390BB0  48 8D 87 30 D8 00 00        lea     rax, [rdi+0D830h]
0000000180390BB7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390BBE  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390BC2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390BC6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390BCB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390BD2  E8 29 AE 01 00              call    sub_1803ABA00
0000000180390BD7  66 0F 6F 05 51 B4 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390BDF  48 8D 05 52 A5 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
0000000180390BE6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390BEA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390BEE  48 8D 87 40 D8 00 00        lea     rax, [rdi+0D840h]
0000000180390BF5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390BFC  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390C00  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390C04  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390C09  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390C10  E8 EB AD 01 00              call    sub_1803ABA00
0000000180390C15  66 0F 6F 05 13 B4 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390C1D  48 8D 05 24 A5 5F 00        lea     rax, aEnvDecay; "ENV Decay"
0000000180390C24  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390C28  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390C2C  48 8D 87 50 D8 00 00        lea     rax, [rdi+0D850h]
0000000180390C33  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390C3A  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390C3E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390C42  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390C47  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390C4E  E8 AD AD 01 00              call    sub_1803ABA00
0000000180390C53  66 0F 6F 05 D5 B3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390C5B  48 8D 05 F6 A4 5F 00        lea     rax, aEnvRelease; "ENV Release"
0000000180390C62  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390C66  48 8D 87 60 D8 00 00        lea     rax, [rdi+0D860h]
0000000180390C6D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390C71  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390C78  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390C7D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390C84  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390C88  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390C8C  E8 6F AD 01 00              call    sub_1803ABA00
0000000180390C91  66 0F 6F 05 97 B3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390C99  48 8D 05 C8 A4 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
0000000180390CA0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390CA4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390CA8  48 8D 87 70 D8 00 00        lea     rax, [rdi+0D870h]
0000000180390CAF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390CB6  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390CBA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390CBE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390CC3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390CCA  E8 31 AD 01 00              call    sub_1803ABA00
0000000180390CCF  48 8D 05 3A A4 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
0000000180390CD6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390CDD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390CE1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390CE5  48 8D 87 30 D9 00 00        lea     rax, [rdi+0D930h]
0000000180390CEC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390CF3  0F 57 C0                    xorps   xmm0, xmm0
0000000180390CF6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390CFA  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390CFE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390D03  E8 F8 AC 01 00              call    sub_1803ABA00
0000000180390D08  66 0F 6F 05 20 B3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390D10  48 8D 05 11 A4 5F 00        lea     rax, aEnvAttack; "ENV Attack"
0000000180390D17  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390D1B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390D1F  48 8D 87 10 DA 00 00        lea     rax, [rdi+0DA10h]
0000000180390D26  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390D2D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390D31  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390D35  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390D3A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390D41  E8 BA AC 01 00              call    sub_1803ABA00
0000000180390D46  66 0F 6F 05 E2 B2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390D4E  48 8D 05 E3 A3 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
0000000180390D55  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390D59  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390D5D  48 8D 87 20 DA 00 00        lea     rax, [rdi+0DA20h]
0000000180390D64  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390D6B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390D6F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390D73  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390D78  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390D7F  E8 7C AC 01 00              call    sub_1803ABA00
0000000180390D84  66 0F 6F 05 A4 B2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390D8C  48 8D 05 B5 A3 5F 00        lea     rax, aEnvDecay; "ENV Decay"
0000000180390D93  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390D97  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390D9B  48 8D 87 30 DA 00 00        lea     rax, [rdi+0DA30h]
0000000180390DA2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390DA9  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390DAD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390DB1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390DB6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390DBD  E8 3E AC 01 00              call    sub_1803ABA00
0000000180390DC2  66 0F 6F 05 66 B2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390DCA  48 8D 05 87 A3 5F 00        lea     rax, aEnvRelease; "ENV Release"
0000000180390DD1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390DD5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390DD9  48 8D 87 40 DA 00 00        lea     rax, [rdi+0DA40h]
0000000180390DE0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390DE7  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390DEB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390DEF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390DF4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390DFB  E8 00 AC 01 00              call    sub_1803ABA00
0000000180390E00  66 0F 6F 05 28 B2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390E08  48 8D 05 59 A3 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
0000000180390E0F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390E13  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390E17  48 8D 87 50 DA 00 00        lea     rax, [rdi+0DA50h]
0000000180390E1E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390E25  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390E29  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390E2D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390E32  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390E39  E8 C2 AB 01 00              call    sub_1803ABA00
0000000180390E3E  48 8D 05 33 A3 5F 00        lea     rax, aOsc1Feet; "OSC1 Feet"
0000000180390E45  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390E49  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390E4D  48 8D 87 50 DC 00 00        lea     rax, [rdi+0DC50h]
0000000180390E54  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390E5B  0F 57 C0                    xorps   xmm0, xmm0
0000000180390E5E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390E62  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390E66  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390E6D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390E72  E8 89 AB 01 00              call    sub_1803ABA00
0000000180390E77  48 8D 05 0A A3 5F 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
0000000180390E7E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390E85  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390E89  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390E8D  48 8D 87 60 DC 00 00        lea     rax, [rdi+0DC60h]
0000000180390E94  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390E9B  0F 57 C0                    xorps   xmm0, xmm0
0000000180390E9E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390EA2  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390EA6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390EAB  E8 50 AB 01 00              call    sub_1803ABA00
0000000180390EB0  48 8D 05 E1 A2 5F 00        lea     rax, aBendEnableSw; "Bend Enable SW"
0000000180390EB7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390EBE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390EC2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390EC6  48 8D 87 70 DC 00 00        lea     rax, [rdi+0DC70h]
0000000180390ECD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390ED4  0F 57 C0                    xorps   xmm0, xmm0
0000000180390ED7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390EDB  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390EDF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390EE4  E8 17 AB 01 00              call    sub_1803ABA00
0000000180390EE9  48 8D 05 B8 A2 5F 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
0000000180390EF0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390EF7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390EFB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390EFF  48 8D 87 80 DC 00 00        lea     rax, [rdi+0DC80h]
0000000180390F06  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390F0D  0F 57 C0                    xorps   xmm0, xmm0
0000000180390F10  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390F14  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390F18  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390F1D  E8 DE AA 01 00              call    sub_1803ABA00
0000000180390F22  48 8D 05 8F A2 5F 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
0000000180390F29  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390F30  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390F34  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390F38  48 8D 87 90 DC 00 00        lea     rax, [rdi+0DC90h]
0000000180390F3F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390F46  0F 57 C0                    xorps   xmm0, xmm0
0000000180390F49  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390F4D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390F51  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390F56  E8 A5 AA 01 00              call    sub_1803ABA00
0000000180390F5B  48 8D 05 66 A2 5F 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
0000000180390F62  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390F69  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390F6D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390F71  48 8D 87 A0 DC 00 00        lea     rax, [rdi+0DCA0h]
0000000180390F78  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390F7F  0F 57 C0                    xorps   xmm0, xmm0
0000000180390F82  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390F86  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390F8A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390F8F  E8 6C AA 01 00              call    sub_1803ABA00
0000000180390F94  48 8D 05 3D A2 5F 00        lea     rax, aPwmSwManual; "PWM SW Manual"
0000000180390F9B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390FA2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390FA6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390FAA  48 8D 87 B0 DC 00 00        lea     rax, [rdi+0DCB0h]
0000000180390FB1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390FB8  0F 57 C0                    xorps   xmm0, xmm0
0000000180390FBB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180390FBF  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180390FC3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390FC8  E8 33 AA 01 00              call    sub_1803ABA00
0000000180390FCD  66 0F 6F 05 5B B0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180390FD5  48 8D 05 0C A2 5F 00        lea     rax, aTune; "Tune"
0000000180390FDC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180390FE0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180390FE5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180390FEC  48 8D 87 C0 DC 00 00        lea     rax, [rdi+0DCC0h]
0000000180390FF3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180390FFA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180390FFE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391002  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391006  E8 F5 A9 01 00              call    sub_1803ABA00
000000018039100B  66 0F 6F 05 1D B0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391013  48 8D 05 D6 A1 5F 00        lea     rax, aDetune; "Detune"
000000018039101A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039101E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391022  48 8D 87 D0 DC 00 00        lea     rax, [rdi+0DCD0h]
0000000180391029  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391030  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391034  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391038  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039103D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391044  E8 B7 A9 01 00              call    sub_1803ABA00
0000000180391049  66 0F 6F 05 DF AF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391051  48 8D 05 A0 A1 5F 00        lea     rax, aModSens; "Mod Sens"
0000000180391058  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039105C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391060  48 8D 87 E0 DC 00 00        lea     rax, [rdi+0DCE0h]
0000000180391067  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039106E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391072  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391076  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039107B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391082  E8 79 A9 01 00              call    sub_1803ABA00
0000000180391087  66 0F 6F 05 A1 AF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039108F  48 8D 05 6E A1 5F 00        lea     rax, aModSw; "Mod Sw"
0000000180391096  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039109A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039109E  48 8D 87 F0 DC 00 00        lea     rax, [rdi+0DCF0h]
00000001803910A5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803910AC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803910B0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803910B4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803910B9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803910C0  E8 3B A9 01 00              call    sub_1803ABA00
00000001803910C5  66 0F 6F 05 63 AF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803910CD  48 8D 05 3C A1 5F 00        lea     rax, aLfoGain; "LFO Gain"
00000001803910D4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803910D8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803910DC  48 8D 87 00 DD 00 00        lea     rax, [rdi+0DD00h]
00000001803910E3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803910EA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803910EE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803910F2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803910F7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803910FE  E8 FD A8 01 00              call    sub_1803ABA00
0000000180391103  66 0F 6F 05 25 AF 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039110B  48 8D 05 0E A1 5F 00        lea     rax, aLfoLevel; "LFO Level"
0000000180391112  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391116  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039111A  48 8D 87 10 DD 00 00        lea     rax, [rdi+0DD10h]
0000000180391121  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391128  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039112C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391130  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391135  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039113C  E8 BF A8 01 00              call    sub_1803ABA00
0000000180391141  66 0F 6F 05 E7 AE 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391149  48 8D 05 DC A0 5F 00        lea     rax, aLfoSw; "LFO Sw"
0000000180391150  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391154  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391158  48 8D 87 20 DD 00 00        lea     rax, [rdi+0DD20h]
000000018039115F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391166  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039116A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039116E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391173  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039117A  E8 81 A8 01 00              call    sub_1803ABA00
000000018039117F  66 0F 6F 05 A9 AE 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391187  48 8D 05 AA A0 5F 00        lea     rax, aEnv1Level; "ENV1 Level"
000000018039118E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391192  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391196  48 8D 87 30 DD 00 00        lea     rax, [rdi+0DD30h]
000000018039119D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803911A4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803911A8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803911AD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803911B4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803911B8  E8 43 A8 01 00              call    sub_1803ABA00
00000001803911BD  66 0F 6F 05 6B AE 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803911C5  48 8D 05 7C A0 5F 00        lea     rax, aEnv2Level; "ENV2 Level"
00000001803911CC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803911D0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803911D4  48 8D 87 40 DD 00 00        lea     rax, [rdi+0DD40h]
00000001803911DB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803911E2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803911E6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803911EA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803911EF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803911F6  E8 05 A8 01 00              call    sub_1803ABA00
00000001803911FB  66 0F 6F 05 2D AE 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391203  48 8D 05 4A A0 5F 00        lea     rax, aEnvSw; "ENV Sw"
000000018039120A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039120E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391212  48 8D 87 50 DD 00 00        lea     rax, [rdi+0DD50h]
0000000180391219  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391220  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391224  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391228  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039122D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391234  E8 C7 A7 01 00              call    sub_1803ABA00
0000000180391239  66 0F 6F 05 EF AD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391241  48 8D 05 18 A0 5F 00        lea     rax, aBendLevel; "Bend Level"
0000000180391248  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039124C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391250  48 8D 87 60 DD 00 00        lea     rax, [rdi+0DD60h]
0000000180391257  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039125E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391262  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391266  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039126B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391272  E8 89 A7 01 00              call    sub_1803ABA00
0000000180391277  66 0F 6F 05 B1 AD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039127F  48 8D 05 EA 9F 5F 00        lea     rax, aBendRange; "Bend Range"
0000000180391286  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039128A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039128E  48 8D 87 70 DD 00 00        lea     rax, [rdi+0DD70h]
0000000180391295  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039129C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803912A0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803912A4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803912A9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803912B0  E8 4B A7 01 00              call    sub_1803ABA00
00000001803912B5  66 0F 6F 05 73 AD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803912BD  48 8D 05 BC 9F 5F 00        lea     rax, aPwmLevel; "PWM Level"
00000001803912C4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803912C8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803912CC  48 8D 87 80 DD 00 00        lea     rax, [rdi+0DD80h]
00000001803912D3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803912DA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803912DE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803912E2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803912E7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803912EE  E8 0D A7 01 00              call    sub_1803ABA00
00000001803912F3  66 0F 6F 05 35 AD 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803912FB  48 8D 05 8E 9F 5F 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
0000000180391302  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391306  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039130A  48 8D 87 B0 DD 00 00        lea     rax, [rdi+0DDB0h]
0000000180391311  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391318  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039131C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391320  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391325  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039132C  E8 CF A6 01 00              call    sub_1803ABA00
0000000180391331  66 0F 6F 05 F7 AC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391339  48 8D 05 60 9F 5F 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
0000000180391340  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391344  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391348  48 8D 87 C0 DD 00 00        lea     rax, [rdi+0DDC0h]
000000018039134F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391356  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039135A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039135E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391363  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039136A  E8 91 A6 01 00              call    sub_1803ABA00
000000018039136F  48 8D 05 3A 9F 5F 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
0000000180391376  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039137A  66 0F 6F 05 AE AC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391382  48 8D 87 D0 DD 00 00        lea     rax, [rdi+0DDD0h]
0000000180391389  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039138D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391391  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391395  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039139C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803913A1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803913A8  E8 53 A6 01 00              call    sub_1803ABA00
00000001803913AD  66 0F 6F 05 7B AC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803913B5  48 8D 05 04 9F 5F 00        lea     rax, aDutyTune; "Duty Tune"
00000001803913BC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803913C0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803913C4  48 8D 87 E0 E2 00 00        lea     rax, [rdi+0E2E0h]
00000001803913CB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803913D2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803913D6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803913DA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803913DF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803913E6  E8 15 A6 01 00              call    sub_1803ABA00
00000001803913EB  66 0F 6F 05 3D AC 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803913F3  48 8D 05 D6 9E 5F 00        lea     rax, aOsc1Mute; "Osc1 Mute"
00000001803913FA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803913FE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391402  48 8D 87 80 E6 00 00        lea     rax, [rdi+0E680h]
0000000180391409  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391410  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391414  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391418  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039141D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391424  E8 D7 A5 01 00              call    sub_1803ABA00
0000000180391429  66 0F 6F 05 FF AB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391431  48 8D 05 A8 9E 5F 00        lea     rax, aOsc1Level; "Osc1 Level"
0000000180391438  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039143C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391440  48 8D 87 C0 E6 00 00        lea     rax, [rdi+0E6C0h]
0000000180391447  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039144E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391452  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391456  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039145B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391462  E8 99 A5 01 00              call    sub_1803ABA00
0000000180391467  66 0F 6F 05 C1 AB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039146F  48 8D 05 7A 9E 5F 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
0000000180391476  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039147A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039147E  48 8D 87 D0 E6 00 00        lea     rax, [rdi+0E6D0h]
0000000180391485  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039148C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391490  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391494  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391499  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803914A0  E8 5B A5 01 00              call    sub_1803ABA00
00000001803914A5  48 8D 05 54 9E 5F 00        lea     rax, aGrifferSw; "Griffer SW"
00000001803914AC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803914B3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803914B7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803914BB  48 8D 87 90 E7 00 00        lea     rax, [rdi+0E790h]
00000001803914C2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803914C9  0F 57 C0                    xorps   xmm0, xmm0
00000001803914CC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803914D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803914D4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803914D9  E8 22 A5 01 00              call    sub_1803ABA00
00000001803914DE  66 0F 6F 05 4A AB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803914E6  48 8D 05 23 9E 5F 00        lea     rax, aLpfCutoff; "LPF Cutoff"
00000001803914ED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803914F1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803914F5  48 8D 87 A0 E7 00 00        lea     rax, [rdi+0E7A0h]
00000001803914FC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391503  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391507  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039150B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391510  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391517  E8 E4 A4 01 00              call    sub_1803ABA00
000000018039151C  66 0F 6F 05 0C AB 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391524  48 8D 05 F5 9D 5F 00        lea     rax, aLpfResonance; "LPF Resonance"
000000018039152B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039152F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391534  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039153B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391542  48 8D 87 00 E8 00 00        lea     rax, [rdi+0E800h]
0000000180391549  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039154D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391551  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391555  E8 A6 A4 01 00              call    sub_1803ABA00
000000018039155A  48 8D 05 CF 9D 5F 00        lea     rax, aVelocity; "Velocity"
0000000180391561  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391568  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039156C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391570  48 8D 87 20 E8 00 00        lea     rax, [rdi+0E820h]
0000000180391577  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039157E  0F 57 C0                    xorps   xmm0, xmm0
0000000180391581  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391585  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391589  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039158E  E8 6D A4 01 00              call    sub_1803ABA00
0000000180391593  48 8D 05 A2 9D 5F 00        lea     rax, aEnv12; "Env1/2"
000000018039159A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803915A1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803915A5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803915A9  48 8D 87 B0 E8 00 00        lea     rax, [rdi+0E8B0h]
00000001803915B0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803915B7  0F 57 C0                    xorps   xmm0, xmm0
00000001803915BA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803915BE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803915C2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803915C7  E8 34 A4 01 00              call    sub_1803ABA00
00000001803915CC  48 8D 05 75 9D 5F 00        lea     rax, aIntEnv; "Int/Env"
00000001803915D3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803915DA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803915DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803915E2  48 8D 87 C0 E8 00 00        lea     rax, [rdi+0E8C0h]
00000001803915E9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803915F0  0F 57 C0                    xorps   xmm0, xmm0
00000001803915F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803915F7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803915FB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391600  E8 FB A3 01 00              call    sub_1803ABA00
0000000180391605  48 8D 05 04 9C 5F 00        lea     rax, aLfoGain; "LFO Gain"
000000018039160C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391613  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391617  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039161B  48 8D 87 D0 E9 00 00        lea     rax, [rdi+0E9D0h]
0000000180391622  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391629  0F 57 C0                    xorps   xmm0, xmm0
000000018039162C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391630  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391634  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391639  E8 C2 A3 01 00              call    sub_1803ABA00
000000018039163E  48 8D 05 0B 9D 5F 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
0000000180391645  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039164C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391650  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391654  48 8D 87 E0 E9 00 00        lea     rax, [rdi+0E9E0h]
000000018039165B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391662  0F 57 C0                    xorps   xmm0, xmm0
0000000180391665  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391669  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039166D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391672  E8 89 A3 01 00              call    sub_1803ABA00
0000000180391677  48 8D 05 E2 9C 5F 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
000000018039167E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391685  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391689  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039168D  48 8D 87 F0 E9 00 00        lea     rax, [rdi+0E9F0h]
0000000180391694  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039169B  0F 57 C0                    xorps   xmm0, xmm0
000000018039169E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803916A2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803916A6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803916AB  E8 50 A3 01 00              call    sub_1803ABA00
00000001803916B0  66 0F 6F 05 78 A9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803916B8  48 8D 05 61 9B 5F 00        lea     rax, aLfoLevel; "LFO Level"
00000001803916BF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803916C3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803916C7  48 8D 87 00 EA 00 00        lea     rax, [rdi+0EA00h]
00000001803916CE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803916D5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803916D9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803916DD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803916E2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803916E9  E8 12 A3 01 00              call    sub_1803ABA00
00000001803916EE  66 0F 6F 05 3A A9 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803916F6  48 8D 05 73 9C 5F 00        lea     rax, aModSens_0; "MOD Sens"
00000001803916FD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391701  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391705  48 8D 87 10 EA 00 00        lea     rax, [rdi+0EA10h]
000000018039170C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391713  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391717  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039171B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391720  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391727  E8 D4 A2 01 00              call    sub_1803ABA00
000000018039172C  66 0F 6F 05 FC A8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391734  48 8D 05 41 9C 5F 00        lea     rax, aModSw_0; "MOD SW"
000000018039173B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039173F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391743  48 8D 87 20 EA 00 00        lea     rax, [rdi+0EA20h]
000000018039174A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391751  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391755  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391759  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039175E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391765  E8 96 A2 01 00              call    sub_1803ABA00
000000018039176A  66 0F 6F 05 BE A8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391772  48 8D 05 0F 9C 5F 00        lea     rax, aEnvLevel; "ENV Level"
0000000180391779  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039177D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391781  48 8D 87 30 EA 00 00        lea     rax, [rdi+0EA30h]
0000000180391788  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039178F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391793  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391797  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039179C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803917A3  E8 58 A2 01 00              call    sub_1803ABA00
00000001803917A8  66 0F 6F 05 80 A8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803917B0  48 8D 05 E1 9B 5F 00        lea     rax, aKcvLevel; "KCV Level"
00000001803917B7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803917BB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803917BF  48 8D 87 40 EA 00 00        lea     rax, [rdi+0EA40h]
00000001803917C6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803917CD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803917D1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803917D5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803917DA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803917E1  E8 1A A2 01 00              call    sub_1803ABA00
00000001803917E6  66 0F 6F 05 42 A8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803917EE  48 8D 05 B3 9B 5F 00        lea     rax, aVelocitySens; "Velocity Sens"
00000001803917F5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803917F9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803917FD  48 8D 87 50 EA 00 00        lea     rax, [rdi+0EA50h]
0000000180391804  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039180B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039180F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391813  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391818  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039181F  E8 DC A1 01 00              call    sub_1803ABA00
0000000180391824  66 0F 6F 05 04 A8 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039182C  48 8D 05 85 9B 5F 00        lea     rax, aVelocityOffset; "Velocity Offset"
0000000180391833  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391837  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039183B  48 8D 87 60 EA 00 00        lea     rax, [rdi+0EA60h]
0000000180391842  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391849  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039184D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391851  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391856  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039185D  E8 9E A1 01 00              call    sub_1803ABA00
0000000180391862  66 0F 6F 05 C6 A7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039186A  48 8D 05 EF 99 5F 00        lea     rax, aBendLevel; "Bend Level"
0000000180391871  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391875  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391879  48 8D 87 70 EA 00 00        lea     rax, [rdi+0EA70h]
0000000180391880  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391887  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039188B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039188F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391894  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039189B  E8 60 A1 01 00              call    sub_1803ABA00
00000001803918A0  48 8D 05 C9 99 5F 00        lea     rax, aBendRange; "Bend Range"
00000001803918A7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803918AE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803918B2  66 0F 6F 05 76 A7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803918BA  48 8D 87 80 EA 00 00        lea     rax, [rdi+0EA80h]
00000001803918C1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803918C5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803918C9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803918CD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803918D4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803918D9  E8 22 A1 01 00              call    sub_1803ABA00
00000001803918DE  66 0F 6F 05 4A A7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803918E6  48 8D 05 DB 9A 5F 00        lea     rax, aCutoffTune; "Cutoff Tune"
00000001803918ED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803918F1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803918F5  48 8D 87 00 EB 00 00        lea     rax, [rdi+0EB00h]
00000001803918FC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391903  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391907  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039190B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391910  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391917  E8 E4 A0 01 00              call    sub_1803ABA00
000000018039191C  66 0F 6F 05 0C A7 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391924  48 8D 05 AD 9A 5F 00        lea     rax, aResonanceTune; "Resonance Tune"
000000018039192B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039192F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391933  48 8D 87 10 EB 00 00        lea     rax, [rdi+0EB10h]
000000018039193A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391941  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391945  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391949  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039194E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391955  E8 A6 A0 01 00              call    sub_1803ABA00
000000018039195A  48 8D 05 87 9A 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
0000000180391961  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
0000000180391968  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039196C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391970  48 8D 87 20 EB 00 00        lea     rax, [rdi+0EB20h]
0000000180391977  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039197E  0F 57 C0                    xorps   xmm0, xmm0
0000000180391981  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391985  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391989  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039198E  E8 6D A0 01 00              call    sub_1803ABA00
0000000180391993  48 8D 05 4E 9A 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
000000018039199A  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00000001803919A1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803919A5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803919A9  48 8D 87 B0 F0 00 00        lea     rax, [rdi+0F0B0h]
00000001803919B0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803919B7  0F 57 C0                    xorps   xmm0, xmm0
00000001803919BA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803919BE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803919C2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803919C7  E8 34 A0 01 00              call    sub_1803ABA00
00000001803919CC  66 0F 6F 05 5C A6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803919D4  48 8D 05 1D 9A 5F 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
00000001803919DB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803919DF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803919E3  48 8D 87 C0 F0 00 00        lea     rax, [rdi+0F0C0h]
00000001803919EA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803919F1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803919F5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803919F9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803919FE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391A05  E8 F6 9F 01 00              call    sub_1803ABA00
0000000180391A0A  66 0F 6F 05 1E A6 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391A12  48 8D 05 EF 99 5F 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
0000000180391A19  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391A1D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391A21  48 8D 87 D0 F0 00 00        lea     rax, [rdi+0F0D0h]
0000000180391A28  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391A2F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391A33  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391A37  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391A3C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391A43  E8 B8 9F 01 00              call    sub_1803ABA00
0000000180391A48  66 0F 6F 05 E0 A5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391A50  48 8D 05 C1 99 5F 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
0000000180391A57  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391A5B  48 8D 87 E0 F0 00 00        lea     rax, [rdi+0F0E0h]
0000000180391A62  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391A69  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391A6E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391A75  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391A79  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391A7D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391A81  E8 7A 9F 01 00              call    sub_1803ABA00
0000000180391A86  66 0F 6F 05 A2 A5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391A8E  48 8D 05 93 99 5F 00        lea     rax, aAmpTone; "AMP TONE"
0000000180391A95  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391A99  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391A9D  48 8D 87 C0 F2 00 00        lea     rax, [rdi+0F2C0h]
0000000180391AA4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391AAB  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391AAF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391AB3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391AB8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391ABF  E8 3C 9F 01 00              call    sub_1803ABA00
0000000180391AC4  66 0F 6F 05 64 A5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391ACC  48 8D 05 65 99 5F 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
0000000180391AD3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391AD7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391ADB  48 8D 87 D0 F2 00 00        lea     rax, [rdi+0F2D0h]
0000000180391AE2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391AE9  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391AED  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391AF1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391AF6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391AFD  E8 FE 9E 01 00              call    sub_1803ABA00
0000000180391B02  66 0F 6F 05 26 A5 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391B0A  48 8D 05 3F 99 5F 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
0000000180391B11  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391B15  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391B19  48 8D 87 E0 F2 00 00        lea     rax, [rdi+0F2E0h]
0000000180391B20  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391B27  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391B2B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391B2F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391B34  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391B3B  E8 C0 9E 01 00              call    sub_1803ABA00
0000000180391B40  48 8D 05 E9 97 5F 00        lea     rax, aVelocity; "Velocity"
0000000180391B47  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391B4E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391B52  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391B56  48 8D 87 20 F3 00 00        lea     rax, [rdi+0F320h]
0000000180391B5D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391B64  0F 57 C0                    xorps   xmm0, xmm0
0000000180391B67  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391B6B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391B6F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391B74  E8 87 9E 01 00              call    sub_1803ABA00
0000000180391B79  48 8D 05 E8 98 5F 00        lea     rax, aMute; "Mute"
0000000180391B80  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391B87  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391B8B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391B8F  48 8D 87 B0 F3 00 00        lea     rax, [rdi+0F3B0h]
0000000180391B96  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391B9D  0F 57 C0                    xorps   xmm0, xmm0
0000000180391BA0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391BA4  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391BA8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391BAD  E8 4E 9E 01 00              call    sub_1803ABA00
0000000180391BB2  48 8D 05 B7 98 5F 00        lea     rax, aGateSw; "Gate SW"
0000000180391BB9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391BC0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391BC4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391BC8  48 8D 87 10 F5 00 00        lea     rax, [rdi+0F510h]
0000000180391BCF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391BD6  0F 57 C0                    xorps   xmm0, xmm0
0000000180391BD9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391BDD  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391BE1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391BE6  E8 15 9E 01 00              call    sub_1803ABA00
0000000180391BEB  48 8D 05 86 98 5F 00        lea     rax, aEnv1Sw; "ENV1 SW"
0000000180391BF2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391BF9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391BFD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391C01  48 8D 87 20 F5 00 00        lea     rax, [rdi+0F520h]
0000000180391C08  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391C0F  0F 57 C0                    xorps   xmm0, xmm0
0000000180391C12  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391C16  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391C1A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391C1F  E8 DC 9D 01 00              call    sub_1803ABA00
0000000180391C24  48 8D 05 55 98 5F 00        lea     rax, aEnv2Sw; "ENV2 SW"
0000000180391C2B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391C32  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391C36  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391C3A  48 8D 87 30 F5 00 00        lea     rax, [rdi+0F530h]
0000000180391C41  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391C48  0F 57 C0                    xorps   xmm0, xmm0
0000000180391C4B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391C4F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391C53  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391C58  E8 A3 9D 01 00              call    sub_1803ABA00
0000000180391C5D  48 8D 05 24 98 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
0000000180391C64  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391C6B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391C6F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391C73  48 8D 87 40 F5 00 00        lea     rax, [rdi+0F540h]
0000000180391C7A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391C81  0F 57 C0                    xorps   xmm0, xmm0
0000000180391C84  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391C88  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391C8C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391C91  E8 6A 9D 01 00              call    sub_1803ABA00
0000000180391C96  66 0F 6F 05 92 A3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391C9E  48 8D 05 F3 97 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
0000000180391CA5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391CA9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391CAD  48 8D 87 50 F5 00 00        lea     rax, [rdi+0F550h]
0000000180391CB4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391CBB  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391CBF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391CC3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391CC8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391CCF  E8 2C 9D 01 00              call    sub_1803ABA00
0000000180391CD4  66 0F 6F 05 54 A3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391CDC  48 8D 05 C5 97 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
0000000180391CE3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391CE7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391CEB  48 8D 87 60 F5 00 00        lea     rax, [rdi+0F560h]
0000000180391CF2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391CF9  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391CFD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391D01  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391D06  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391D0D  E8 EE 9C 01 00              call    sub_1803ABA00
0000000180391D12  66 0F 6F 05 16 A3 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391D1A  48 8D 05 97 97 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
0000000180391D21  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391D25  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391D29  48 8D 87 70 F5 00 00        lea     rax, [rdi+0F570h]
0000000180391D30  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391D37  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391D3B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391D3F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391D44  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391D4B  E8 B0 9C 01 00              call    sub_1803ABA00
0000000180391D50  66 0F 6F 05 D8 A2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391D58  48 8D 05 69 97 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
0000000180391D5F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391D63  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391D67  48 8D 87 80 F5 00 00        lea     rax, [rdi+0F580h]
0000000180391D6E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391D75  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391D79  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391D7D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391D82  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391D89  E8 72 9C 01 00              call    sub_1803ABA00
0000000180391D8E  66 0F 6F 05 9A A2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391D96  48 8D 05 43 97 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
0000000180391D9D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391DA1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391DA5  48 8D 87 90 F5 00 00        lea     rax, [rdi+0F590h]
0000000180391DAC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391DB3  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391DB7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391DBB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391DC0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391DC7  E8 34 9C 01 00              call    sub_1803ABA00
0000000180391DCC  66 0F 6F 05 5C A2 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391DD4  48 8D 05 15 97 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
0000000180391DDB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391DDF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391DE6  48 8D 87 A0 F5 00 00        lea     rax, [rdi+0F5A0h]
0000000180391DED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391DF4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391DF8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391DFC  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391E00  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391E05  E8 F6 9B 01 00              call    sub_1803ABA00
0000000180391E0A  48 8D 05 0F 91 5F 00        lea     rax, aUseextjack; "UseExtJack"
0000000180391E11  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391E18  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391E1C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391E20  48 8D 87 70 F7 00 00        lea     rax, [rdi+0F770h]
0000000180391E27  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391E2E  0F 57 C0                    xorps   xmm0, xmm0
0000000180391E31  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391E35  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391E39  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391E3E  E8 BD 9B 01 00              call    sub_1803ABA00
0000000180391E43  48 8D 05 E2 90 5F 00        lea     rax, aMCv; "M.CV"
0000000180391E4A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391E51  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391E55  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391E59  48 8D 87 90 F7 00 00        lea     rax, [rdi+0F790h]
0000000180391E60  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391E67  0F 57 C0                    xorps   xmm0, xmm0
0000000180391E6A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391E6E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391E72  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391E77  E8 84 9B 01 00              call    sub_1803ABA00
0000000180391E7C  48 8D 05 B1 90 5F 00        lea     rax, aMGate; "M.Gate"
0000000180391E83  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391E8A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391E8E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391E92  48 8D 87 A0 F7 00 00        lea     rax, [rdi+0F7A0h]
0000000180391E99  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391EA0  0F 57 C0                    xorps   xmm0, xmm0
0000000180391EA3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391EA7  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391EAB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391EB0  E8 4B 9B 01 00              call    sub_1803ABA00
0000000180391EB5  66 0F 6F 05 73 A1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391EBD  48 8D 05 7C 90 5F 00        lea     rax, aMasterTune; "Master Tune"
0000000180391EC4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391EC8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391ECC  48 8D 87 D0 F7 00 00        lea     rax, [rdi+0F7D0h]
0000000180391ED3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391EDA  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391EDE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391EE2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391EE7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391EEE  E8 0D 9B 01 00              call    sub_1803ABA00
0000000180391EF3  66 0F 6F 05 35 A1 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391EFB  48 8D 05 4E 90 5F 00        lea     rax, aPartTune; "Part Tune"
0000000180391F02  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391F06  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391F0A  48 8D 87 E0 F7 00 00        lea     rax, [rdi+0F7E0h]
0000000180391F11  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391F18  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391F1C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391F20  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391F25  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391F2C  E8 CF 9A 01 00              call    sub_1803ABA00
0000000180391F31  48 8D 05 28 90 5F 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
0000000180391F38  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391F3F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391F43  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391F47  48 8D 87 B0 F8 00 00        lea     rax, [rdi+0F8B0h]
0000000180391F4E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391F55  0F 57 C0                    xorps   xmm0, xmm0
0000000180391F58  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391F5C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391F60  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391F65  E8 96 9A 01 00              call    sub_1803ABA00
0000000180391F6A  48 8D 05 07 90 5F 00        lea     rax, aPortamentoMode; "Portamento Mode"
0000000180391F71  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391F78  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391F7C  0F 57 C0                    xorps   xmm0, xmm0
0000000180391F7F  48 8D 87 C0 F8 00 00        lea     rax, [rdi+0F8C0h]
0000000180391F86  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391F8D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391F91  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391F96  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391F9A  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391F9E  E8 5D 9A 01 00              call    sub_1803ABA00
0000000180391FA3  66 0F 6F 05 85 A0 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180391FAB  48 8D 05 D6 8F 5F 00        lea     rax, aPortamentoTime; "Portamento Time"
0000000180391FB2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391FB6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391FBA  48 8D 87 D0 F8 00 00        lea     rax, [rdi+0F8D0h]
0000000180391FC1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391FC8  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180391FCC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180391FD0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180391FD5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180391FDC  E8 1F 9A 01 00              call    sub_1803ABA00
0000000180391FE1  48 8D 05 B0 8F 5F 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
0000000180391FE8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180391FEF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180391FF3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180391FF7  48 8D 87 70 FA 00 00        lea     rax, [rdi+0FA70h]
0000000180391FFE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392005  0F 57 C0                    xorps   xmm0, xmm0
0000000180392008  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039200C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392010  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392015  E8 E6 99 01 00              call    sub_1803ABA00
000000018039201A  48 8D 05 8F 8F 5F 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
0000000180392021  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392028  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039202C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392030  48 8D 87 80 FA 00 00        lea     rax, [rdi+0FA80h]
0000000180392037  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039203E  0F 57 C0                    xorps   xmm0, xmm0
0000000180392041  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392045  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392049  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039204E  E8 AD 99 01 00              call    sub_1803ABA00
0000000180392053  48 8D 05 6E 8F 5F 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
000000018039205A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392061  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392065  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392069  48 8D 87 90 FA 00 00        lea     rax, [rdi+0FA90h]
0000000180392070  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392077  0F 57 C0                    xorps   xmm0, xmm0
000000018039207A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039207E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392082  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392087  E8 74 99 01 00              call    sub_1803ABA00
000000018039208C  66 0F 6F 05 9C 9F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392094  48 8D 05 3D 8F 5F 00        lea     rax, aLfoRate; "LFO Rate"
000000018039209B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039209F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803920A3  48 8D 87 A0 FA 00 00        lea     rax, [rdi+0FAA0h]
00000001803920AA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803920B1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803920B5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803920B9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803920BE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803920C5  E8 36 99 01 00              call    sub_1803ABA00
00000001803920CA  48 8D 05 13 8F 5F 00        lea     rax, aGate; "Gate"
00000001803920D1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803920D8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803920DC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803920E0  48 8D 87 A0 FD 00 00        lea     rax, [rdi+0FDA0h]
00000001803920E7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803920EE  0F 57 C0                    xorps   xmm0, xmm0
00000001803920F1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803920F5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803920F9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803920FE  E8 FD 98 01 00              call    sub_1803ABA00
0000000180392103  48 8D 05 E6 8E 5F 00        lea     rax, aLfoTrig; "LFO Trig"
000000018039210A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392111  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392115  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392119  48 8D 87 B0 FD 00 00        lea     rax, [rdi+0FDB0h]
0000000180392120  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392127  0F 57 C0                    xorps   xmm0, xmm0
000000018039212A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039212E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392132  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392137  E8 C4 98 01 00              call    sub_1803ABA00
000000018039213C  48 8D 05 BD 8E 5F 00        lea     rax, aResetSw; "Reset Sw"
0000000180392143  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392147  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039214B  48 8D 87 C0 FD 00 00        lea     rax, [rdi+0FDC0h]
0000000180392152  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392159  0F 57 C0                    xorps   xmm0, xmm0
000000018039215C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392160  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392164  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039216B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392170  E8 8B 98 01 00              call    sub_1803ABA00
0000000180392175  66 0F 6F 05 B3 9E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039217D  48 8D 05 8C 8E 5F 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
0000000180392184  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392188  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039218C  48 8D 87 D0 FD 00 00        lea     rax, [rdi+0FDD0h]
0000000180392193  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039219A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039219E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803921A2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803921A7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803921AE  E8 4D 98 01 00              call    sub_1803ABA00
00000001803921B3  66 0F 6F 05 75 9E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803921BB  48 8D 05 5E 8E 5F 00        lea     rax, aLfoDelay; "LFO Delay"
00000001803921C2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803921C6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803921CA  48 8D 87 E0 FD 00 00        lea     rax, [rdi+0FDE0h]
00000001803921D1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803921D8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803921DC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803921E0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803921E5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803921EC  E8 0F 98 01 00              call    sub_1803ABA00
00000001803921F1  66 0F 6F 05 37 9E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803921F9  48 8D 05 30 8E 5F 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
0000000180392200  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392204  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392208  48 8D 87 F0 FD 00 00        lea     rax, [rdi+0FDF0h]
000000018039220F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392216  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039221A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039221E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392223  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039222A  E8 D1 97 01 00              call    sub_1803ABA00
000000018039222F  66 0F 6F 05 F9 9D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392237  48 8D 05 02 8E 5F 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
000000018039223E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392242  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392246  48 8D 87 00 FE 00 00        lea     rax, [rdi+0FE00h]
000000018039224D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392254  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392258  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039225C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392261  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392268  E8 93 97 01 00              call    sub_1803ABA00
000000018039226D  66 0F 6F 05 BB 9D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392275  48 8D 05 D4 8D 5F 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
000000018039227C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392280  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392284  48 8D 87 10 FE 00 00        lea     rax, [rdi+0FE10h]
000000018039228B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392292  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392296  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039229A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039229F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803922A6  E8 55 97 01 00              call    sub_1803ABA00
00000001803922AB  66 0F 6F 05 7D 9D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803922B3  48 8D 05 A6 8D 5F 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
00000001803922BA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803922BE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803922C2  48 8D 87 20 FE 00 00        lea     rax, [rdi+0FE20h]
00000001803922C9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803922D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803922D4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803922D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803922DD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803922E4  E8 17 97 01 00              call    sub_1803ABA00
00000001803922E9  66 0F 6F 05 3F 9D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803922F1  48 8D 05 78 8D 5F 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
00000001803922F8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803922FC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392301  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392308  48 8D 87 30 FE 00 00        lea     rax, [rdi+0FE30h]
000000018039230F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392316  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039231A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039231E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392322  E8 D9 96 01 00              call    sub_1803ABA00
0000000180392327  66 0F 6F 05 01 9D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039232F  48 8D 05 4A 8D 5F 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
0000000180392336  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039233A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039233E  48 8D 87 40 FE 00 00        lea     rax, [rdi+0FE40h]
0000000180392345  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039234C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392350  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392354  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392359  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392360  E8 9B 96 01 00              call    sub_1803ABA00
0000000180392365  66 0F 6F 05 C3 9C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039236D  48 8D 05 1C 8D 5F 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
0000000180392374  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392378  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039237C  48 8D 87 50 FE 00 00        lea     rax, [rdi+0FE50h]
0000000180392383  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039238A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039238E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392392  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392397  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039239E  E8 5D 96 01 00              call    sub_1803ABA00
00000001803923A3  66 0F 6F 05 85 9C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803923AB  48 8D 05 EE 8C 5F 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
00000001803923B2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803923B6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803923BA  48 8D 87 60 FE 00 00        lea     rax, [rdi+0FE60h]
00000001803923C1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803923C8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803923CC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803923D0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803923D5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803923DC  E8 1F 96 01 00              call    sub_1803ABA00
00000001803923E1  66 0F 6F 05 47 9C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803923E9  48 8D 05 C0 8C 5F 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
00000001803923F0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803923F4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803923F8  48 8D 87 70 FE 00 00        lea     rax, [rdi+0FE70h]
00000001803923FF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392406  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039240A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039240E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392413  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039241A  E8 E1 95 01 00              call    sub_1803ABA00
000000018039241F  66 0F 6F 05 09 9C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392427  48 8D 05 92 8C 5F 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
000000018039242E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392432  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392436  48 8D 87 80 FE 00 00        lea     rax, [rdi+0FE80h]
000000018039243D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392444  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392448  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039244C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392451  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392458  E8 A3 95 01 00              call    sub_1803ABA00
000000018039245D  66 0F 6F 05 CB 9B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392465  48 8D 05 64 8C 5F 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
000000018039246C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392470  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392474  48 8D 87 90 FE 00 00        lea     rax, [rdi+0FE90h]
000000018039247B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392482  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392486  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039248A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039248F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392496  E8 65 95 01 00              call    sub_1803ABA00
000000018039249B  66 0F 6F 05 8D 9B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803924A3  48 8D 05 3E 8C 5F 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
00000001803924AA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803924AE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803924B2  48 8D 87 A0 FE 00 00        lea     rax, [rdi+0FEA0h]
00000001803924B9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803924C0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803924C4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803924C9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803924D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803924D4  E8 27 95 01 00              call    sub_1803ABA00
00000001803924D9  48 8D 05 20 8C 5F 00        lea     rax, aReadOnly; "read only"
00000001803924E0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803924E7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803924EB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803924EF  48 8D 87 40 00 01 00        lea     rax, [rdi+10040h]
00000001803924F6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803924FD  0F 57 C0                    xorps   xmm0, xmm0
0000000180392500  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392504  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392508  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039250D  E8 EE 94 01 00              call    sub_1803ABA00
0000000180392512  48 8D 05 E7 8B 5F 00        lea     rax, aReadOnly; "read only"
0000000180392519  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392520  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392524  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392528  48 8D 87 50 00 01 00        lea     rax, [rdi+10050h]
000000018039252F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392536  0F 57 C0                    xorps   xmm0, xmm0
0000000180392539  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039253D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392541  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392546  E8 B5 94 01 00              call    sub_1803ABA00
000000018039254B  48 8D 05 BE 8B 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
0000000180392552  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392559  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039255D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392561  48 8D 87 60 00 01 00        lea     rax, [rdi+10060h]
0000000180392568  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039256F  0F 57 C0                    xorps   xmm0, xmm0
0000000180392572  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392576  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039257A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039257F  E8 7C 94 01 00              call    sub_1803ABA00
0000000180392584  66 0F 6F 05 A4 9A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039258C  48 8D 05 95 8B 5F 00        lea     rax, aEnvAttack; "ENV Attack"
0000000180392593  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392597  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039259B  48 8D 87 40 01 01 00        lea     rax, [rdi+10140h]
00000001803925A2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803925A9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803925AD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803925B1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803925B6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803925BD  E8 3E 94 01 00              call    sub_1803ABA00
00000001803925C2  66 0F 6F 05 66 9A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803925CA  48 8D 05 67 8B 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
00000001803925D1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803925D5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803925D9  48 8D 87 50 01 01 00        lea     rax, [rdi+10150h]
00000001803925E0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803925E7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803925EB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803925EF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803925F4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803925FB  E8 00 94 01 00              call    sub_1803ABA00
0000000180392600  66 0F 6F 05 28 9A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392608  48 8D 05 39 8B 5F 00        lea     rax, aEnvDecay; "ENV Decay"
000000018039260F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392613  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392617  48 8D 87 60 01 01 00        lea     rax, [rdi+10160h]
000000018039261E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392625  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392629  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039262D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392632  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392639  E8 C2 93 01 00              call    sub_1803ABA00
000000018039263E  66 0F 6F 05 EA 99 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392646  48 8D 05 0B 8B 5F 00        lea     rax, aEnvRelease; "ENV Release"
000000018039264D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392651  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392655  48 8D 87 70 01 01 00        lea     rax, [rdi+10170h]
000000018039265C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392663  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392667  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039266B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392670  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392677  E8 84 93 01 00              call    sub_1803ABA00
000000018039267C  48 8D 05 E5 8A 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
0000000180392683  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392687  66 0F 6F 05 A1 99 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039268F  48 8D 87 80 01 01 00        lea     rax, [rdi+10180h]
0000000180392696  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039269A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039269E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803926A2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803926A9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803926AE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803926B5  E8 46 93 01 00              call    sub_1803ABA00
00000001803926BA  48 8D 05 4F 8A 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00000001803926C1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803926C8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803926CC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803926D0  48 8D 87 40 02 01 00        lea     rax, [rdi+10240h]
00000001803926D7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803926DE  0F 57 C0                    xorps   xmm0, xmm0
00000001803926E1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803926E5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803926E9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803926EE  E8 0D 93 01 00              call    sub_1803ABA00
00000001803926F3  66 0F 6F 05 35 99 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803926FB  48 8D 05 26 8A 5F 00        lea     rax, aEnvAttack; "ENV Attack"
0000000180392702  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392706  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039270A  48 8D 87 20 03 01 00        lea     rax, [rdi+10320h]
0000000180392711  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392718  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039271C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392720  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392725  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039272C  E8 CF 92 01 00              call    sub_1803ABA00
0000000180392731  66 0F 6F 05 F7 98 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392739  48 8D 05 F8 89 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
0000000180392740  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392744  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392748  48 8D 87 30 03 01 00        lea     rax, [rdi+10330h]
000000018039274F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392756  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039275A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039275E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392763  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039276A  E8 91 92 01 00              call    sub_1803ABA00
000000018039276F  66 0F 6F 05 B9 98 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392777  48 8D 05 CA 89 5F 00        lea     rax, aEnvDecay; "ENV Decay"
000000018039277E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392782  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392786  48 8D 87 40 03 01 00        lea     rax, [rdi+10340h]
000000018039278D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392794  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392798  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039279C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803927A1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803927A8  E8 53 92 01 00              call    sub_1803ABA00
00000001803927AD  66 0F 6F 05 7B 98 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803927B5  48 8D 05 9C 89 5F 00        lea     rax, aEnvRelease; "ENV Release"
00000001803927BC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803927C0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803927C4  48 8D 87 50 03 01 00        lea     rax, [rdi+10350h]
00000001803927CB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803927D2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803927D6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803927DA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803927DF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803927E6  E8 15 92 01 00              call    sub_1803ABA00
00000001803927EB  66 0F 6F 05 3D 98 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803927F3  48 8D 05 6E 89 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00000001803927FA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803927FE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392802  48 8D 87 60 03 01 00        lea     rax, [rdi+10360h]
0000000180392809  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392810  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392814  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392818  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039281D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392824  E8 D7 91 01 00              call    sub_1803ABA00
0000000180392829  48 8D 05 48 89 5F 00        lea     rax, aOsc1Feet; "OSC1 Feet"
0000000180392830  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392837  0F 57 C0                    xorps   xmm0, xmm0
000000018039283A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039283E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392843  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039284A  48 8D 87 60 05 01 00        lea     rax, [rdi+10560h]
0000000180392851  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392855  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392859  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039285D  E8 9E 91 01 00              call    sub_1803ABA00
0000000180392862  48 8D 05 1F 89 5F 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
0000000180392869  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392870  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392874  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392878  48 8D 87 70 05 01 00        lea     rax, [rdi+10570h]
000000018039287F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392886  0F 57 C0                    xorps   xmm0, xmm0
0000000180392889  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039288D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392891  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392896  E8 65 91 01 00              call    sub_1803ABA00
000000018039289B  48 8D 05 F6 88 5F 00        lea     rax, aBendEnableSw; "Bend Enable SW"
00000001803928A2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803928A9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803928AD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803928B1  48 8D 87 80 05 01 00        lea     rax, [rdi+10580h]
00000001803928B8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803928BF  0F 57 C0                    xorps   xmm0, xmm0
00000001803928C2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803928C6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803928CA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803928CF  E8 2C 91 01 00              call    sub_1803ABA00
00000001803928D4  48 8D 05 CD 88 5F 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
00000001803928DB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803928E2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803928E6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803928EA  48 8D 87 90 05 01 00        lea     rax, [rdi+10590h]
00000001803928F1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803928F8  0F 57 C0                    xorps   xmm0, xmm0
00000001803928FB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803928FF  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392903  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392908  E8 F3 90 01 00              call    sub_1803ABA00
000000018039290D  48 8D 05 A4 88 5F 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
0000000180392914  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039291B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039291F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392923  48 8D 87 A0 05 01 00        lea     rax, [rdi+105A0h]
000000018039292A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392931  0F 57 C0                    xorps   xmm0, xmm0
0000000180392934  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392938  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039293C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392941  E8 BA 90 01 00              call    sub_1803ABA00
0000000180392946  48 8D 05 7B 88 5F 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
000000018039294D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392954  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392958  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039295C  48 8D 87 B0 05 01 00        lea     rax, [rdi+105B0h]
0000000180392963  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039296A  0F 57 C0                    xorps   xmm0, xmm0
000000018039296D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392971  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392975  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039297A  E8 81 90 01 00              call    sub_1803ABA00
000000018039297F  48 8D 05 52 88 5F 00        lea     rax, aPwmSwManual; "PWM SW Manual"
0000000180392986  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039298D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392991  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392995  48 8D 87 C0 05 01 00        lea     rax, [rdi+105C0h]
000000018039299C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803929A3  0F 57 C0                    xorps   xmm0, xmm0
00000001803929A6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803929AA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803929AE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803929B3  E8 48 90 01 00              call    sub_1803ABA00
00000001803929B8  66 0F 6F 05 70 96 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803929C0  48 8D 05 21 88 5F 00        lea     rax, aTune; "Tune"
00000001803929C7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803929CB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803929CF  48 8D 87 D0 05 01 00        lea     rax, [rdi+105D0h]
00000001803929D6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803929DD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803929E1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803929E5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803929EA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803929F1  E8 0A 90 01 00              call    sub_1803ABA00
00000001803929F6  66 0F 6F 05 32 96 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803929FE  48 8D 05 EB 87 5F 00        lea     rax, aDetune; "Detune"
0000000180392A05  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392A09  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392A0D  48 8D 87 E0 05 01 00        lea     rax, [rdi+105E0h]
0000000180392A14  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392A1B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392A1F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392A23  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392A28  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392A2F  E8 CC 8F 01 00              call    sub_1803ABA00
0000000180392A34  66 0F 6F 05 F4 95 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392A3C  48 8D 05 B5 87 5F 00        lea     rax, aModSens; "Mod Sens"
0000000180392A43  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392A47  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392A4B  48 8D 87 F0 05 01 00        lea     rax, [rdi+105F0h]
0000000180392A52  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392A59  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392A5D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392A61  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392A66  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392A6D  E8 8E 8F 01 00              call    sub_1803ABA00
0000000180392A72  66 0F 6F 05 B6 95 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392A7A  48 8D 05 83 87 5F 00        lea     rax, aModSw; "Mod Sw"
0000000180392A81  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392A85  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392A89  48 8D 87 00 06 01 00        lea     rax, [rdi+10600h]
0000000180392A90  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392A97  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392A9B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392A9F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392AA4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392AAB  E8 50 8F 01 00              call    sub_1803ABA00
0000000180392AB0  66 0F 6F 05 78 95 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392AB8  48 8D 05 51 87 5F 00        lea     rax, aLfoGain; "LFO Gain"
0000000180392ABF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392AC3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392AC7  48 8D 87 10 06 01 00        lea     rax, [rdi+10610h]
0000000180392ACE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392AD5  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392AD9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392ADD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392AE2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392AE9  E8 12 8F 01 00              call    sub_1803ABA00
0000000180392AEE  66 0F 6F 05 3A 95 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392AF6  48 8D 05 23 87 5F 00        lea     rax, aLfoLevel; "LFO Level"
0000000180392AFD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392B01  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392B05  48 8D 87 20 06 01 00        lea     rax, [rdi+10620h]
0000000180392B0C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392B13  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392B17  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392B1B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392B20  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392B27  E8 D4 8E 01 00              call    sub_1803ABA00
0000000180392B2C  66 0F 6F 05 FC 94 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392B34  48 8D 05 F1 86 5F 00        lea     rax, aLfoSw; "LFO Sw"
0000000180392B3B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392B3F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392B43  48 8D 87 30 06 01 00        lea     rax, [rdi+10630h]
0000000180392B4A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392B51  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392B55  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392B59  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392B5E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392B65  E8 96 8E 01 00              call    sub_1803ABA00
0000000180392B6A  66 0F 6F 05 BE 94 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392B72  48 8D 05 BF 86 5F 00        lea     rax, aEnv1Level; "ENV1 Level"
0000000180392B79  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392B7D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392B81  48 8D 87 40 06 01 00        lea     rax, [rdi+10640h]
0000000180392B88  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392B8F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392B93  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392B97  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392B9C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392BA3  E8 58 8E 01 00              call    sub_1803ABA00
0000000180392BA8  48 8D 05 99 86 5F 00        lea     rax, aEnv2Level; "ENV2 Level"
0000000180392BAF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392BB6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392BBA  66 0F 6F 05 6E 94 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392BC2  48 8D 87 50 06 01 00        lea     rax, [rdi+10650h]
0000000180392BC9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392BCD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392BD1  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392BD5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392BDC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392BE1  E8 1A 8E 01 00              call    sub_1803ABA00
0000000180392BE6  66 0F 6F 05 42 94 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392BEE  48 8D 05 5F 86 5F 00        lea     rax, aEnvSw; "ENV Sw"
0000000180392BF5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392BF9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392BFD  48 8D 87 60 06 01 00        lea     rax, [rdi+10660h]
0000000180392C04  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392C0B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392C0F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392C13  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392C18  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392C1F  E8 DC 8D 01 00              call    sub_1803ABA00
0000000180392C24  66 0F 6F 05 04 94 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392C2C  48 8D 05 2D 86 5F 00        lea     rax, aBendLevel; "Bend Level"
0000000180392C33  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392C37  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392C3B  48 8D 87 70 06 01 00        lea     rax, [rdi+10670h]
0000000180392C42  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392C49  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392C4D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392C51  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392C56  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392C5D  E8 9E 8D 01 00              call    sub_1803ABA00
0000000180392C62  66 0F 6F 05 C6 93 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392C6A  48 8D 05 FF 85 5F 00        lea     rax, aBendRange; "Bend Range"
0000000180392C71  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392C75  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392C79  48 8D 87 80 06 01 00        lea     rax, [rdi+10680h]
0000000180392C80  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392C87  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392C8B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392C8F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392C94  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392C9B  E8 60 8D 01 00              call    sub_1803ABA00
0000000180392CA0  66 0F 6F 05 88 93 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392CA8  48 8D 05 D1 85 5F 00        lea     rax, aPwmLevel; "PWM Level"
0000000180392CAF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392CB3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392CB7  48 8D 87 90 06 01 00        lea     rax, [rdi+10690h]
0000000180392CBE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392CC5  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392CC9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392CCD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392CD2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392CD9  E8 22 8D 01 00              call    sub_1803ABA00
0000000180392CDE  66 0F 6F 05 4A 93 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392CE6  48 8D 05 A3 85 5F 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
0000000180392CED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392CF1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392CF5  48 8D 87 C0 06 01 00        lea     rax, [rdi+106C0h]
0000000180392CFC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392D03  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392D07  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392D0B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392D10  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392D17  E8 E4 8C 01 00              call    sub_1803ABA00
0000000180392D1C  66 0F 6F 05 0C 93 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392D24  48 8D 05 75 85 5F 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
0000000180392D2B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392D2F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392D33  48 8D 87 D0 06 01 00        lea     rax, [rdi+106D0h]
0000000180392D3A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392D41  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392D45  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392D49  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392D4E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392D55  E8 A6 8C 01 00              call    sub_1803ABA00
0000000180392D5A  66 0F 6F 05 CE 92 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392D62  48 8D 05 47 85 5F 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
0000000180392D69  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392D6D  48 8D 87 E0 06 01 00        lea     rax, [rdi+106E0h]
0000000180392D74  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392D7B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392D80  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392D87  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392D8B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392D8F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392D93  E8 68 8C 01 00              call    sub_1803ABA00
0000000180392D98  66 0F 6F 05 90 92 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392DA0  48 8D 05 19 85 5F 00        lea     rax, aDutyTune; "Duty Tune"
0000000180392DA7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392DAB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392DAF  48 8D 87 F0 0B 01 00        lea     rax, [rdi+10BF0h]
0000000180392DB6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392DBD  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392DC1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392DC5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392DCA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392DD1  E8 2A 8C 01 00              call    sub_1803ABA00
0000000180392DD6  66 0F 6F 05 52 92 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392DDE  48 8D 05 EB 84 5F 00        lea     rax, aOsc1Mute; "Osc1 Mute"
0000000180392DE5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392DE9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392DED  48 8D 87 90 0F 01 00        lea     rax, [rdi+10F90h]
0000000180392DF4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392DFB  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392DFF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392E03  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392E08  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392E0F  E8 EC 8B 01 00              call    sub_1803ABA00
0000000180392E14  66 0F 6F 05 14 92 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392E1C  48 8D 05 BD 84 5F 00        lea     rax, aOsc1Level; "Osc1 Level"
0000000180392E23  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392E27  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392E2B  48 8D 87 D0 0F 01 00        lea     rax, [rdi+10FD0h]
0000000180392E32  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392E39  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392E3D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392E41  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392E46  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392E4D  E8 AE 8B 01 00              call    sub_1803ABA00
0000000180392E52  66 0F 6F 05 D6 91 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392E5A  48 8D 05 8F 84 5F 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
0000000180392E61  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392E65  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392E69  48 8D 87 E0 0F 01 00        lea     rax, [rdi+10FE0h]
0000000180392E70  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392E77  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392E7B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392E7F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392E84  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392E8B  E8 70 8B 01 00              call    sub_1803ABA00
0000000180392E90  48 8D 05 69 84 5F 00        lea     rax, aGrifferSw; "Griffer SW"
0000000180392E97  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392E9E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392EA2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392EA6  48 8D 87 A0 10 01 00        lea     rax, [rdi+110A0h]
0000000180392EAD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392EB4  0F 57 C0                    xorps   xmm0, xmm0
0000000180392EB7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392EBB  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392EBF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392EC4  E8 37 8B 01 00              call    sub_1803ABA00
0000000180392EC9  66 0F 6F 05 5F 91 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392ED1  48 8D 05 38 84 5F 00        lea     rax, aLpfCutoff; "LPF Cutoff"
0000000180392ED8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392EDC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392EE0  48 8D 87 B0 10 01 00        lea     rax, [rdi+110B0h]
0000000180392EE7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392EEE  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392EF2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392EF6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392EFB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392F02  E8 F9 8A 01 00              call    sub_1803ABA00
0000000180392F07  66 0F 6F 05 21 91 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180392F0F  48 8D 05 0A 84 5F 00        lea     rax, aLpfResonance; "LPF Resonance"
0000000180392F16  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392F1A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392F1E  48 8D 87 10 11 01 00        lea     rax, [rdi+11110h]
0000000180392F25  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392F2C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392F30  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392F34  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392F39  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392F40  E8 BB 8A 01 00              call    sub_1803ABA00
0000000180392F45  48 8D 05 E4 83 5F 00        lea     rax, aVelocity; "Velocity"
0000000180392F4C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392F53  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392F57  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392F5B  48 8D 87 30 11 01 00        lea     rax, [rdi+11130h]
0000000180392F62  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392F69  0F 57 C0                    xorps   xmm0, xmm0
0000000180392F6C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392F70  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392F74  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392F79  E8 82 8A 01 00              call    sub_1803ABA00
0000000180392F7E  48 8D 05 B7 83 5F 00        lea     rax, aEnv12; "Env1/2"
0000000180392F85  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392F8C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392F90  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392F94  48 8D 87 C0 11 01 00        lea     rax, [rdi+111C0h]
0000000180392F9B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392FA2  0F 57 C0                    xorps   xmm0, xmm0
0000000180392FA5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392FA9  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392FAD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392FB2  E8 49 8A 01 00              call    sub_1803ABA00
0000000180392FB7  48 8D 05 8A 83 5F 00        lea     rax, aIntEnv; "Int/Env"
0000000180392FBE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392FC5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180392FC9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180392FCD  48 8D 87 D0 11 01 00        lea     rax, [rdi+111D0h]
0000000180392FD4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180392FDB  0F 57 C0                    xorps   xmm0, xmm0
0000000180392FDE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180392FE2  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180392FE6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180392FEB  E8 10 8A 01 00              call    sub_1803ABA00
0000000180392FF0  48 8D 05 19 82 5F 00        lea     rax, aLfoGain; "LFO Gain"
0000000180392FF7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180392FFE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393002  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393006  48 8D 87 E0 12 01 00        lea     rax, [rdi+112E0h]
000000018039300D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393014  0F 57 C0                    xorps   xmm0, xmm0
0000000180393017  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039301B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039301F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393024  E8 D7 89 01 00              call    sub_1803ABA00
0000000180393029  48 8D 05 20 83 5F 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
0000000180393030  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393037  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039303B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039303F  48 8D 87 F0 12 01 00        lea     rax, [rdi+112F0h]
0000000180393046  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039304D  0F 57 C0                    xorps   xmm0, xmm0
0000000180393050  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393054  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393058  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039305D  E8 9E 89 01 00              call    sub_1803ABA00
0000000180393062  48 8D 05 F7 82 5F 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
0000000180393069  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393070  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393074  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393078  48 8D 87 00 13 01 00        lea     rax, [rdi+11300h]
000000018039307F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393086  0F 57 C0                    xorps   xmm0, xmm0
0000000180393089  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039308D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393091  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393096  E8 65 89 01 00              call    sub_1803ABA00
000000018039309B  66 0F 6F 05 8D 8F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803930A3  48 8D 05 76 81 5F 00        lea     rax, aLfoLevel; "LFO Level"
00000001803930AA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803930AE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803930B2  48 8D 87 10 13 01 00        lea     rax, [rdi+11310h]
00000001803930B9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803930C0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803930C4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803930C8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803930CD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803930D4  E8 27 89 01 00              call    sub_1803ABA00
00000001803930D9  66 0F 6F 05 4F 8F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803930E1  48 8D 05 88 82 5F 00        lea     rax, aModSens_0; "MOD Sens"
00000001803930E8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803930EC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803930F3  48 8D 87 20 13 01 00        lea     rax, [rdi+11320h]
00000001803930FA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393101  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393105  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393109  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039310D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393112  E8 E9 88 01 00              call    sub_1803ABA00
0000000180393117  66 0F 6F 05 11 8F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039311F  48 8D 05 56 82 5F 00        lea     rax, aModSw_0; "MOD SW"
0000000180393126  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039312A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039312E  48 8D 87 30 13 01 00        lea     rax, [rdi+11330h]
0000000180393135  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039313C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393140  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393144  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393149  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393150  E8 AB 88 01 00              call    sub_1803ABA00
0000000180393155  66 0F 6F 05 D3 8E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039315D  48 8D 05 24 82 5F 00        lea     rax, aEnvLevel; "ENV Level"
0000000180393164  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393168  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039316C  48 8D 87 40 13 01 00        lea     rax, [rdi+11340h]
0000000180393173  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039317A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039317E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393182  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393187  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039318E  E8 6D 88 01 00              call    sub_1803ABA00
0000000180393193  66 0F 6F 05 95 8E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039319B  48 8D 05 F6 81 5F 00        lea     rax, aKcvLevel; "KCV Level"
00000001803931A2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803931A6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803931AA  48 8D 87 50 13 01 00        lea     rax, [rdi+11350h]
00000001803931B1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803931B8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803931BC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803931C0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803931C5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803931CC  E8 2F 88 01 00              call    sub_1803ABA00
00000001803931D1  66 0F 6F 05 57 8E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803931D9  48 8D 05 C8 81 5F 00        lea     rax, aVelocitySens; "Velocity Sens"
00000001803931E0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803931E4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803931E8  48 8D 87 60 13 01 00        lea     rax, [rdi+11360h]
00000001803931EF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803931F6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803931FA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803931FE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393203  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039320A  E8 F1 87 01 00              call    sub_1803ABA00
000000018039320F  66 0F 6F 05 19 8E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393217  48 8D 05 9A 81 5F 00        lea     rax, aVelocityOffset; "Velocity Offset"
000000018039321E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393222  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393226  48 8D 87 70 13 01 00        lea     rax, [rdi+11370h]
000000018039322D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393234  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393238  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039323C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393241  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393248  E8 B3 87 01 00              call    sub_1803ABA00
000000018039324D  66 0F 6F 05 DB 8D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393255  48 8D 05 04 80 5F 00        lea     rax, aBendLevel; "Bend Level"
000000018039325C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393260  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393264  48 8D 87 80 13 01 00        lea     rax, [rdi+11380h]
000000018039326B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393272  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393276  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039327A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039327F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393286  E8 75 87 01 00              call    sub_1803ABA00
000000018039328B  66 0F 6F 05 9D 8D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393293  48 8D 05 D6 7F 5F 00        lea     rax, aBendRange; "Bend Range"
000000018039329A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039329E  48 8D 87 90 13 01 00        lea     rax, [rdi+11390h]
00000001803932A5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803932A9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803932B0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803932B5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803932BC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803932C0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803932C4  E8 37 87 01 00              call    sub_1803ABA00
00000001803932C9  66 0F 6F 05 5F 8D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803932D1  48 8D 05 F0 80 5F 00        lea     rax, aCutoffTune; "Cutoff Tune"
00000001803932D8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803932DC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803932E0  48 8D 87 10 14 01 00        lea     rax, [rdi+11410h]
00000001803932E7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803932EE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803932F2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803932F6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803932FB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393302  E8 F9 86 01 00              call    sub_1803ABA00
0000000180393307  66 0F 6F 05 21 8D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039330F  48 8D 05 C2 80 5F 00        lea     rax, aResonanceTune; "Resonance Tune"
0000000180393316  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039331A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039331E  48 8D 87 20 14 01 00        lea     rax, [rdi+11420h]
0000000180393325  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039332C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393330  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393334  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393339  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393340  E8 BB 86 01 00              call    sub_1803ABA00
0000000180393345  48 8D 05 9C 80 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
000000018039334C  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
0000000180393353  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393357  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039335B  48 8D 87 30 14 01 00        lea     rax, [rdi+11430h]
0000000180393362  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393369  0F 57 C0                    xorps   xmm0, xmm0
000000018039336C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393370  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393374  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393379  E8 82 86 01 00              call    sub_1803ABA00
000000018039337E  48 8D 05 63 80 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
0000000180393385  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
000000018039338C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393390  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393394  48 8D 87 C0 19 01 00        lea     rax, [rdi+119C0h]
000000018039339B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803933A2  0F 57 C0                    xorps   xmm0, xmm0
00000001803933A5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803933A9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803933AD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803933B2  E8 49 86 01 00              call    sub_1803ABA00
00000001803933B7  66 0F 6F 05 71 8C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803933BF  48 8D 05 32 80 5F 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
00000001803933C6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803933CA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803933CE  48 8D 87 D0 19 01 00        lea     rax, [rdi+119D0h]
00000001803933D5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803933DC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803933E0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803933E4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803933E9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803933F0  E8 0B 86 01 00              call    sub_1803ABA00
00000001803933F5  66 0F 6F 05 33 8C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803933FD  48 8D 05 04 80 5F 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
0000000180393404  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393408  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039340C  48 8D 87 E0 19 01 00        lea     rax, [rdi+119E0h]
0000000180393413  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039341A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039341E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393422  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393427  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039342E  E8 CD 85 01 00              call    sub_1803ABA00
0000000180393433  66 0F 6F 05 F5 8B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039343B  48 8D 05 D6 7F 5F 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
0000000180393442  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393446  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039344A  48 8D 87 F0 19 01 00        lea     rax, [rdi+119F0h]
0000000180393451  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393458  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039345C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393460  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393465  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039346C  E8 8F 85 01 00              call    sub_1803ABA00
0000000180393471  48 8D 05 B0 7F 5F 00        lea     rax, aAmpTone; "AMP TONE"
0000000180393478  66 0F 6F 05 B0 8B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393480  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393484  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393488  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039348C  48 8D 87 D0 1B 01 00        lea     rax, [rdi+11BD0h]
0000000180393493  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039349A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039349E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803934A3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803934AA  E8 51 85 01 00              call    sub_1803ABA00
00000001803934AF  66 0F 6F 05 79 8B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803934B7  48 8D 05 7A 7F 5F 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
00000001803934BE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803934C2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803934C6  48 8D 87 E0 1B 01 00        lea     rax, [rdi+11BE0h]
00000001803934CD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803934D4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803934D8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803934DC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803934E1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803934E8  E8 13 85 01 00              call    sub_1803ABA00
00000001803934ED  66 0F 6F 05 3B 8B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803934F5  48 8D 05 54 7F 5F 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
00000001803934FC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393500  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393504  48 8D 87 F0 1B 01 00        lea     rax, [rdi+11BF0h]
000000018039350B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393512  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393516  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039351A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039351F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393526  E8 D5 84 01 00              call    sub_1803ABA00
000000018039352B  48 8D 05 FE 7D 5F 00        lea     rax, aVelocity; "Velocity"
0000000180393532  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393539  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039353D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393541  48 8D 87 30 1C 01 00        lea     rax, [rdi+11C30h]
0000000180393548  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039354F  0F 57 C0                    xorps   xmm0, xmm0
0000000180393552  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393556  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039355A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039355F  E8 9C 84 01 00              call    sub_1803ABA00
0000000180393564  48 8D 05 FD 7E 5F 00        lea     rax, aMute; "Mute"
000000018039356B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393572  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393576  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039357A  48 8D 87 C0 1C 01 00        lea     rax, [rdi+11CC0h]
0000000180393581  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393588  0F 57 C0                    xorps   xmm0, xmm0
000000018039358B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039358F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393593  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393598  E8 63 84 01 00              call    sub_1803ABA00
000000018039359D  48 8D 05 CC 7E 5F 00        lea     rax, aGateSw; "Gate SW"
00000001803935A4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803935AB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803935AF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803935B3  48 8D 87 20 1E 01 00        lea     rax, [rdi+11E20h]
00000001803935BA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803935C1  0F 57 C0                    xorps   xmm0, xmm0
00000001803935C4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803935C8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803935CC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803935D1  E8 2A 84 01 00              call    sub_1803ABA00
00000001803935D6  48 8D 05 9B 7E 5F 00        lea     rax, aEnv1Sw; "ENV1 SW"
00000001803935DD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803935E4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803935E8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803935EC  48 8D 87 30 1E 01 00        lea     rax, [rdi+11E30h]
00000001803935F3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803935FA  0F 57 C0                    xorps   xmm0, xmm0
00000001803935FD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393601  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393605  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039360A  E8 F1 83 01 00              call    sub_1803ABA00
000000018039360F  48 8D 05 6A 7E 5F 00        lea     rax, aEnv2Sw; "ENV2 SW"
0000000180393616  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039361D  0F 57 C0                    xorps   xmm0, xmm0
0000000180393620  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393624  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393629  48 8D 87 40 1E 01 00        lea     rax, [rdi+11E40h]
0000000180393630  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393637  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039363B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039363F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393643  E8 B8 83 01 00              call    sub_1803ABA00
0000000180393648  48 8D 05 39 7E 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
000000018039364F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393656  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039365A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039365E  48 8D 87 50 1E 01 00        lea     rax, [rdi+11E50h]
0000000180393665  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039366C  0F 57 C0                    xorps   xmm0, xmm0
000000018039366F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393673  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393677  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039367C  E8 7F 83 01 00              call    sub_1803ABA00
0000000180393681  66 0F 6F 05 A7 89 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393689  48 8D 05 08 7E 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
0000000180393690  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393694  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393698  48 8D 87 60 1E 01 00        lea     rax, [rdi+11E60h]
000000018039369F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803936A6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803936AA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803936AE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803936B3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803936BA  E8 41 83 01 00              call    sub_1803ABA00
00000001803936BF  66 0F 6F 05 69 89 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803936C7  48 8D 05 DA 7D 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
00000001803936CE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803936D2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803936D6  48 8D 87 70 1E 01 00        lea     rax, [rdi+11E70h]
00000001803936DD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803936E4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803936E8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803936EC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803936F1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803936F8  E8 03 83 01 00              call    sub_1803ABA00
00000001803936FD  66 0F 6F 05 2B 89 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393705  48 8D 05 AC 7D 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
000000018039370C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393710  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393714  48 8D 87 80 1E 01 00        lea     rax, [rdi+11E80h]
000000018039371B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393722  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393726  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039372A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039372F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393736  E8 C5 82 01 00              call    sub_1803ABA00
000000018039373B  66 0F 6F 05 ED 88 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393743  48 8D 05 7E 7D 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
000000018039374A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039374E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393752  48 8D 87 90 1E 01 00        lea     rax, [rdi+11E90h]
0000000180393759  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393760  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393764  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393768  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039376D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393774  E8 87 82 01 00              call    sub_1803ABA00
0000000180393779  66 0F 6F 05 AF 88 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393781  48 8D 05 58 7D 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
0000000180393788  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039378C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393790  48 8D 87 A0 1E 01 00        lea     rax, [rdi+11EA0h]
0000000180393797  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039379E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803937A2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803937A6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803937AB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803937B2  E8 49 82 01 00              call    sub_1803ABA00
00000001803937B7  66 0F 6F 05 71 88 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803937BF  48 8D 05 2A 7D 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
00000001803937C6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803937CA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803937CE  48 8D 87 B0 1E 01 00        lea     rax, [rdi+11EB0h]
00000001803937D5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803937DC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803937E0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803937E5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803937EC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803937F0  E8 0B 82 01 00              call    sub_1803ABA00
00000001803937F5  48 8D 05 24 77 5F 00        lea     rax, aUseextjack; "UseExtJack"
00000001803937FC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393803  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393807  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039380B  48 8D 87 80 20 01 00        lea     rax, [rdi+12080h]
0000000180393812  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393819  0F 57 C0                    xorps   xmm0, xmm0
000000018039381C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393820  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393824  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393829  E8 D2 81 01 00              call    sub_1803ABA00
000000018039382E  48 8D 05 F7 76 5F 00        lea     rax, aMCv; "M.CV"
0000000180393835  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039383C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393840  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393844  48 8D 87 A0 20 01 00        lea     rax, [rdi+120A0h]
000000018039384B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393852  0F 57 C0                    xorps   xmm0, xmm0
0000000180393855  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393859  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039385D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393862  E8 99 81 01 00              call    sub_1803ABA00
0000000180393867  48 8D 05 C6 76 5F 00        lea     rax, aMGate; "M.Gate"
000000018039386E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393875  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393879  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039387D  48 8D 87 B0 20 01 00        lea     rax, [rdi+120B0h]
0000000180393884  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039388B  0F 57 C0                    xorps   xmm0, xmm0
000000018039388E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393892  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393896  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039389B  E8 60 81 01 00              call    sub_1803ABA00
00000001803938A0  66 0F 6F 05 88 87 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803938A8  48 8D 05 91 76 5F 00        lea     rax, aMasterTune; "Master Tune"
00000001803938AF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803938B3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803938B7  48 8D 87 E0 20 01 00        lea     rax, [rdi+120E0h]
00000001803938BE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803938C5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803938C9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803938CD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803938D2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803938D9  E8 22 81 01 00              call    sub_1803ABA00
00000001803938DE  66 0F 6F 05 4A 87 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803938E6  48 8D 05 63 76 5F 00        lea     rax, aPartTune; "Part Tune"
00000001803938ED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803938F1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803938F5  48 8D 87 F0 20 01 00        lea     rax, [rdi+120F0h]
00000001803938FC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393903  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393907  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039390B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393910  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393917  E8 E4 80 01 00              call    sub_1803ABA00
000000018039391C  48 8D 05 3D 76 5F 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
0000000180393923  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039392A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039392E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393932  48 8D 87 C0 21 01 00        lea     rax, [rdi+121C0h]
0000000180393939  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393940  0F 57 C0                    xorps   xmm0, xmm0
0000000180393943  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393947  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039394B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393950  E8 AB 80 01 00              call    sub_1803ABA00
0000000180393955  48 8D 05 1C 76 5F 00        lea     rax, aPortamentoMode; "Portamento Mode"
000000018039395C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393963  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393967  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039396B  48 8D 87 D0 21 01 00        lea     rax, [rdi+121D0h]
0000000180393972  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393979  0F 57 C0                    xorps   xmm0, xmm0
000000018039397C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393980  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393984  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393989  E8 72 80 01 00              call    sub_1803ABA00
000000018039398E  48 8D 05 F3 75 5F 00        lea     rax, aPortamentoTime; "Portamento Time"
0000000180393995  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393999  66 0F 6F 05 8F 86 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803939A1  48 8D 87 E0 21 01 00        lea     rax, [rdi+121E0h]
00000001803939A8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803939AC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803939B0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803939B4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803939BB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803939C0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803939C7  E8 34 80 01 00              call    sub_1803ABA00
00000001803939CC  48 8D 05 C5 75 5F 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
00000001803939D3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803939DA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803939DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803939E2  48 8D 87 80 23 01 00        lea     rax, [rdi+12380h]
00000001803939E9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803939F0  0F 57 C0                    xorps   xmm0, xmm0
00000001803939F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803939F7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803939FB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393A00  E8 FB 7F 01 00              call    sub_1803ABA00
0000000180393A05  48 8D 05 A4 75 5F 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
0000000180393A0C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393A13  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393A17  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393A1B  48 8D 87 90 23 01 00        lea     rax, [rdi+12390h]
0000000180393A22  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393A29  0F 57 C0                    xorps   xmm0, xmm0
0000000180393A2C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393A30  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393A34  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393A39  E8 C2 7F 01 00              call    sub_1803ABA00
0000000180393A3E  48 8D 05 83 75 5F 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
0000000180393A45  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393A4C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393A50  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393A54  48 8D 87 A0 23 01 00        lea     rax, [rdi+123A0h]
0000000180393A5B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393A62  0F 57 C0                    xorps   xmm0, xmm0
0000000180393A65  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393A69  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393A6D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393A72  E8 89 7F 01 00              call    sub_1803ABA00
0000000180393A77  66 0F 6F 05 B1 85 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393A7F  48 8D 05 52 75 5F 00        lea     rax, aLfoRate; "LFO Rate"
0000000180393A86  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393A8A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393A8E  48 8D 87 B0 23 01 00        lea     rax, [rdi+123B0h]
0000000180393A95  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393A9C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393AA0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393AA4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393AA9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393AB0  E8 4B 7F 01 00              call    sub_1803ABA00
0000000180393AB5  48 8D 05 28 75 5F 00        lea     rax, aGate; "Gate"
0000000180393ABC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393AC3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393AC7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393ACB  48 8D 87 B0 26 01 00        lea     rax, [rdi+126B0h]
0000000180393AD2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393AD9  0F 57 C0                    xorps   xmm0, xmm0
0000000180393ADC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393AE0  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393AE4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393AE9  E8 12 7F 01 00              call    sub_1803ABA00
0000000180393AEE  48 8D 05 FB 74 5F 00        lea     rax, aLfoTrig; "LFO Trig"
0000000180393AF5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393AFC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393B00  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393B04  48 8D 87 C0 26 01 00        lea     rax, [rdi+126C0h]
0000000180393B0B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393B12  0F 57 C0                    xorps   xmm0, xmm0
0000000180393B15  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393B19  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393B1D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393B22  E8 D9 7E 01 00              call    sub_1803ABA00
0000000180393B27  48 8D 05 D2 74 5F 00        lea     rax, aResetSw; "Reset Sw"
0000000180393B2E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393B35  0F 57 C0                    xorps   xmm0, xmm0
0000000180393B38  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393B3C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393B41  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393B48  48 8D 87 D0 26 01 00        lea     rax, [rdi+126D0h]
0000000180393B4F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393B53  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393B57  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393B5B  E8 A0 7E 01 00              call    sub_1803ABA00
0000000180393B60  66 0F 6F 05 C8 84 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393B68  48 8D 05 A1 74 5F 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
0000000180393B6F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393B73  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393B77  48 8D 87 E0 26 01 00        lea     rax, [rdi+126E0h]
0000000180393B7E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393B85  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393B89  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393B8D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393B92  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393B99  E8 62 7E 01 00              call    sub_1803ABA00
0000000180393B9E  66 0F 6F 05 8A 84 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393BA6  48 8D 05 73 74 5F 00        lea     rax, aLfoDelay; "LFO Delay"
0000000180393BAD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393BB1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393BB5  48 8D 87 F0 26 01 00        lea     rax, [rdi+126F0h]
0000000180393BBC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393BC3  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393BC7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393BCB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393BD0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393BD7  E8 24 7E 01 00              call    sub_1803ABA00
0000000180393BDC  66 0F 6F 05 4C 84 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393BE4  48 8D 05 45 74 5F 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
0000000180393BEB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393BEF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393BF3  48 8D 87 00 27 01 00        lea     rax, [rdi+12700h]
0000000180393BFA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393C01  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393C05  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393C09  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393C0E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393C15  E8 E6 7D 01 00              call    sub_1803ABA00
0000000180393C1A  66 0F 6F 05 0E 84 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393C22  48 8D 05 17 74 5F 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
0000000180393C29  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393C2D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393C31  48 8D 87 10 27 01 00        lea     rax, [rdi+12710h]
0000000180393C38  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393C3F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393C43  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393C47  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393C4C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393C53  E8 A8 7D 01 00              call    sub_1803ABA00
0000000180393C58  66 0F 6F 05 D0 83 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393C60  48 8D 05 E9 73 5F 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
0000000180393C67  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393C6B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393C6F  48 8D 87 20 27 01 00        lea     rax, [rdi+12720h]
0000000180393C76  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393C7D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393C81  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393C85  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393C8A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393C91  E8 6A 7D 01 00              call    sub_1803ABA00
0000000180393C96  66 0F 6F 05 92 83 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393C9E  48 8D 05 BB 73 5F 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
0000000180393CA5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393CA9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393CAD  48 8D 87 30 27 01 00        lea     rax, [rdi+12730h]
0000000180393CB4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393CBB  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393CBF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393CC3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393CC8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393CCF  E8 2C 7D 01 00              call    sub_1803ABA00
0000000180393CD4  66 0F 6F 05 54 83 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393CDC  48 8D 05 8D 73 5F 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
0000000180393CE3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393CE7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393CEB  48 8D 87 40 27 01 00        lea     rax, [rdi+12740h]
0000000180393CF2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393CF9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393CFD  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393D01  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393D06  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393D0D  E8 EE 7C 01 00              call    sub_1803ABA00
0000000180393D12  66 0F 6F 05 16 83 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393D1A  48 8D 05 5F 73 5F 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
0000000180393D21  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393D25  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393D29  48 8D 87 50 27 01 00        lea     rax, [rdi+12750h]
0000000180393D30  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393D37  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393D3B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393D3F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393D44  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393D4B  E8 B0 7C 01 00              call    sub_1803ABA00
0000000180393D50  66 0F 6F 05 D8 82 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393D58  48 8D 05 31 73 5F 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
0000000180393D5F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393D63  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393D67  48 8D 87 60 27 01 00        lea     rax, [rdi+12760h]
0000000180393D6E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393D75  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393D79  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393D7D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393D82  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393D89  E8 72 7C 01 00              call    sub_1803ABA00
0000000180393D8E  66 0F 6F 05 9A 82 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393D96  48 8D 05 03 73 5F 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
0000000180393D9D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393DA1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393DA5  48 8D 87 70 27 01 00        lea     rax, [rdi+12770h]
0000000180393DAC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393DB3  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393DB7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393DBB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393DC0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393DC7  E8 34 7C 01 00              call    sub_1803ABA00
0000000180393DCC  66 0F 6F 05 5C 82 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393DD4  48 8D 05 D5 72 5F 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
0000000180393DDB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393DDF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393DE3  48 8D 87 80 27 01 00        lea     rax, [rdi+12780h]
0000000180393DEA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393DF1  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393DF5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393DF9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393DFE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393E05  E8 F6 7B 01 00              call    sub_1803ABA00
0000000180393E0A  66 0F 6F 05 1E 82 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393E12  48 8D 05 A7 72 5F 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
0000000180393E19  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393E1D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393E21  48 8D 87 90 27 01 00        lea     rax, [rdi+12790h]
0000000180393E28  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393E2F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393E33  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393E37  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393E3C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393E43  E8 B8 7B 01 00              call    sub_1803ABA00
0000000180393E48  66 0F 6F 05 E0 81 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393E50  48 8D 05 79 72 5F 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
0000000180393E57  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393E5B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393E5F  48 8D 87 A0 27 01 00        lea     rax, [rdi+127A0h]
0000000180393E66  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393E6D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393E71  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393E75  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393E7A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393E81  E8 7A 7B 01 00              call    sub_1803ABA00
0000000180393E86  66 0F 6F 05 A2 81 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393E8E  48 8D 05 53 72 5F 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
0000000180393E95  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393E99  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393E9D  48 8D 87 B0 27 01 00        lea     rax, [rdi+127B0h]
0000000180393EA4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393EAB  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393EAF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393EB3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393EB8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393EBF  E8 3C 7B 01 00              call    sub_1803ABA00
0000000180393EC4  48 8D 05 35 72 5F 00        lea     rax, aReadOnly; "read only"
0000000180393ECB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393ED2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393ED6  0F 57 C0                    xorps   xmm0, xmm0
0000000180393ED9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393EE0  48 8D 87 50 29 01 00        lea     rax, [rdi+12950h]
0000000180393EE7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393EEB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393EEF  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393EF3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393EF8  E8 03 7B 01 00              call    sub_1803ABA00
0000000180393EFD  48 8D 05 FC 71 5F 00        lea     rax, aReadOnly; "read only"
0000000180393F04  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393F0B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393F0F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393F13  48 8D 87 60 29 01 00        lea     rax, [rdi+12960h]
0000000180393F1A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393F21  0F 57 C0                    xorps   xmm0, xmm0
0000000180393F24  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393F28  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393F2C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393F31  E8 CA 7A 01 00              call    sub_1803ABA00
0000000180393F36  48 8D 05 D3 71 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
0000000180393F3D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393F44  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393F48  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393F4C  48 8D 87 70 29 01 00        lea     rax, [rdi+12970h]
0000000180393F53  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393F5A  0F 57 C0                    xorps   xmm0, xmm0
0000000180393F5D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393F61  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393F65  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393F6A  E8 91 7A 01 00              call    sub_1803ABA00
0000000180393F6F  66 0F 6F 05 B9 80 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393F77  48 8D 05 AA 71 5F 00        lea     rax, aEnvAttack; "ENV Attack"
0000000180393F7E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393F82  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393F86  48 8D 87 50 2A 01 00        lea     rax, [rdi+12A50h]
0000000180393F8D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393F94  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393F98  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393F9C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393FA1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393FA8  E8 53 7A 01 00              call    sub_1803ABA00
0000000180393FAD  66 0F 6F 05 7B 80 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393FB5  48 8D 05 7C 71 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
0000000180393FBC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393FC0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180393FC4  48 8D 87 60 2A 01 00        lea     rax, [rdi+12A60h]
0000000180393FCB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180393FD2  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180393FD6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180393FDA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180393FDF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180393FE6  E8 15 7A 01 00              call    sub_1803ABA00
0000000180393FEB  66 0F 6F 05 3D 80 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180393FF3  48 8D 05 4E 71 5F 00        lea     rax, aEnvDecay; "ENV Decay"
0000000180393FFA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180393FFE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394002  48 8D 87 70 2A 01 00        lea     rax, [rdi+12A70h]
0000000180394009  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394010  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394014  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394018  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039401D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394024  E8 D7 79 01 00              call    sub_1803ABA00
0000000180394029  66 0F 6F 05 FF 7F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394031  48 8D 05 20 71 5F 00        lea     rax, aEnvRelease; "ENV Release"
0000000180394038  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039403C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394040  48 8D 87 80 2A 01 00        lea     rax, [rdi+12A80h]
0000000180394047  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039404E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394052  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394056  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039405B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394062  E8 99 79 01 00              call    sub_1803ABA00
0000000180394067  66 0F 6F 05 C1 7F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039406F  48 8D 05 F2 70 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
0000000180394076  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039407A  48 8D 87 90 2A 01 00        lea     rax, [rdi+12A90h]
0000000180394081  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394088  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039408D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394094  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394098  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039409C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803940A0  E8 5B 79 01 00              call    sub_1803ABA00
00000001803940A5  48 8D 05 64 70 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00000001803940AC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803940B3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803940B7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803940BB  48 8D 87 50 2B 01 00        lea     rax, [rdi+12B50h]
00000001803940C2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803940C9  0F 57 C0                    xorps   xmm0, xmm0
00000001803940CC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803940D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803940D4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803940D9  E8 22 79 01 00              call    sub_1803ABA00
00000001803940DE  66 0F 6F 05 4A 7F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803940E6  48 8D 05 3B 70 5F 00        lea     rax, aEnvAttack; "ENV Attack"
00000001803940ED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803940F1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803940F5  48 8D 87 30 2C 01 00        lea     rax, [rdi+12C30h]
00000001803940FC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394103  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394107  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039410B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394110  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394117  E8 E4 78 01 00              call    sub_1803ABA00
000000018039411C  66 0F 6F 05 0C 7F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394124  48 8D 05 0D 70 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
000000018039412B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039412F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394133  48 8D 87 40 2C 01 00        lea     rax, [rdi+12C40h]
000000018039413A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394141  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394145  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394149  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039414E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394155  E8 A6 78 01 00              call    sub_1803ABA00
000000018039415A  66 0F 6F 05 CE 7E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394162  48 8D 05 DF 6F 5F 00        lea     rax, aEnvDecay; "ENV Decay"
0000000180394169  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039416D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394171  48 8D 87 50 2C 01 00        lea     rax, [rdi+12C50h]
0000000180394178  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039417F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394183  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394187  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039418C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394193  E8 68 78 01 00              call    sub_1803ABA00
0000000180394198  66 0F 6F 05 90 7E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803941A0  48 8D 05 B1 6F 5F 00        lea     rax, aEnvRelease; "ENV Release"
00000001803941A7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803941AB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803941AF  48 8D 87 60 2C 01 00        lea     rax, [rdi+12C60h]
00000001803941B6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803941BD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803941C1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803941C5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803941CA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803941D1  E8 2A 78 01 00              call    sub_1803ABA00
00000001803941D6  66 0F 6F 05 52 7E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803941DE  48 8D 05 83 6F 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00000001803941E5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803941E9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803941ED  48 8D 87 70 2C 01 00        lea     rax, [rdi+12C70h]
00000001803941F4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803941FB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803941FF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394203  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394208  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039420F  E8 EC 77 01 00              call    sub_1803ABA00
0000000180394214  48 8D 05 5D 6F 5F 00        lea     rax, aOsc1Feet; "OSC1 Feet"
000000018039421B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394222  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394226  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039422A  48 8D 87 70 2E 01 00        lea     rax, [rdi+12E70h]
0000000180394231  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394238  0F 57 C0                    xorps   xmm0, xmm0
000000018039423B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039423F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394243  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394248  E8 B3 77 01 00              call    sub_1803ABA00
000000018039424D  48 8D 05 34 6F 5F 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
0000000180394254  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039425B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039425F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394263  48 8D 87 80 2E 01 00        lea     rax, [rdi+12E80h]
000000018039426A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394271  0F 57 C0                    xorps   xmm0, xmm0
0000000180394274  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394278  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039427C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394281  E8 7A 77 01 00              call    sub_1803ABA00
0000000180394286  48 8D 05 0B 6F 5F 00        lea     rax, aBendEnableSw; "Bend Enable SW"
000000018039428D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394294  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394298  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039429C  48 8D 87 90 2E 01 00        lea     rax, [rdi+12E90h]
00000001803942A3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803942AA  0F 57 C0                    xorps   xmm0, xmm0
00000001803942AD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803942B1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803942B5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803942BA  E8 41 77 01 00              call    sub_1803ABA00
00000001803942BF  48 8D 05 E2 6E 5F 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
00000001803942C6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803942CD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803942D1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803942D5  48 8D 87 A0 2E 01 00        lea     rax, [rdi+12EA0h]
00000001803942DC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803942E3  0F 57 C0                    xorps   xmm0, xmm0
00000001803942E6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803942EA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803942EE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803942F3  E8 08 77 01 00              call    sub_1803ABA00
00000001803942F8  48 8D 05 B9 6E 5F 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
00000001803942FF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394306  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039430A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039430E  48 8D 87 B0 2E 01 00        lea     rax, [rdi+12EB0h]
0000000180394315  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039431C  0F 57 C0                    xorps   xmm0, xmm0
000000018039431F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394323  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394327  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039432C  E8 CF 76 01 00              call    sub_1803ABA00
0000000180394331  48 8D 05 90 6E 5F 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
0000000180394338  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039433F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394343  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394347  48 8D 87 C0 2E 01 00        lea     rax, [rdi+12EC0h]
000000018039434E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394355  0F 57 C0                    xorps   xmm0, xmm0
0000000180394358  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039435C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394360  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394365  E8 96 76 01 00              call    sub_1803ABA00
000000018039436A  48 8D 05 67 6E 5F 00        lea     rax, aPwmSwManual; "PWM SW Manual"
0000000180394371  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394378  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039437C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394380  48 8D 87 D0 2E 01 00        lea     rax, [rdi+12ED0h]
0000000180394387  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039438E  0F 57 C0                    xorps   xmm0, xmm0
0000000180394391  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394395  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394399  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039439E  E8 5D 76 01 00              call    sub_1803ABA00
00000001803943A3  66 0F 6F 05 85 7C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803943AB  48 8D 05 36 6E 5F 00        lea     rax, aTune; "Tune"
00000001803943B2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803943B6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803943BA  48 8D 87 E0 2E 01 00        lea     rax, [rdi+12EE0h]
00000001803943C1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803943C8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803943CC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803943D0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803943D5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803943DC  E8 1F 76 01 00              call    sub_1803ABA00
00000001803943E1  66 0F 6F 05 47 7C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803943E9  48 8D 05 00 6E 5F 00        lea     rax, aDetune; "Detune"
00000001803943F0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803943F4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803943FB  48 8D 87 F0 2E 01 00        lea     rax, [rdi+12EF0h]
0000000180394402  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394409  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039440D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394411  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394415  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039441A  E8 E1 75 01 00              call    sub_1803ABA00
000000018039441F  66 0F 6F 05 09 7C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394427  48 8D 05 CA 6D 5F 00        lea     rax, aModSens; "Mod Sens"
000000018039442E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394432  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394436  48 8D 87 00 2F 01 00        lea     rax, [rdi+12F00h]
000000018039443D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394444  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394448  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039444C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394451  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394458  E8 A3 75 01 00              call    sub_1803ABA00
000000018039445D  66 0F 6F 05 CB 7B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394465  48 8D 05 98 6D 5F 00        lea     rax, aModSw; "Mod Sw"
000000018039446C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394470  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394474  48 8D 87 10 2F 01 00        lea     rax, [rdi+12F10h]
000000018039447B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394482  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394486  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039448A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039448F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394496  E8 65 75 01 00              call    sub_1803ABA00
000000018039449B  66 0F 6F 05 8D 7B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803944A3  48 8D 05 66 6D 5F 00        lea     rax, aLfoGain; "LFO Gain"
00000001803944AA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803944AE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803944B2  48 8D 87 20 2F 01 00        lea     rax, [rdi+12F20h]
00000001803944B9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803944C0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803944C4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803944C8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803944CD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803944D4  E8 27 75 01 00              call    sub_1803ABA00
00000001803944D9  66 0F 6F 05 4F 7B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803944E1  48 8D 05 38 6D 5F 00        lea     rax, aLfoLevel; "LFO Level"
00000001803944E8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803944EC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803944F0  48 8D 87 30 2F 01 00        lea     rax, [rdi+12F30h]
00000001803944F7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803944FE  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394502  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394506  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039450B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394512  E8 E9 74 01 00              call    sub_1803ABA00
0000000180394517  66 0F 6F 05 11 7B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039451F  48 8D 05 06 6D 5F 00        lea     rax, aLfoSw; "LFO Sw"
0000000180394526  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039452A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039452E  48 8D 87 40 2F 01 00        lea     rax, [rdi+12F40h]
0000000180394535  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039453C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394540  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394544  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394549  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394550  E8 AB 74 01 00              call    sub_1803ABA00
0000000180394555  66 0F 6F 05 D3 7A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039455D  48 8D 05 D4 6C 5F 00        lea     rax, aEnv1Level; "ENV1 Level"
0000000180394564  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394568  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039456C  48 8D 87 50 2F 01 00        lea     rax, [rdi+12F50h]
0000000180394573  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039457A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039457E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394582  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394587  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039458E  E8 6D 74 01 00              call    sub_1803ABA00
0000000180394593  66 0F 6F 05 95 7A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039459B  48 8D 05 A6 6C 5F 00        lea     rax, aEnv2Level; "ENV2 Level"
00000001803945A2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803945A6  48 8D 87 60 2F 01 00        lea     rax, [rdi+12F60h]
00000001803945AD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803945B1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803945B8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803945BD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803945C4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803945C8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803945CC  E8 2F 74 01 00              call    sub_1803ABA00
00000001803945D1  66 0F 6F 05 57 7A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803945D9  48 8D 05 74 6C 5F 00        lea     rax, aEnvSw; "ENV Sw"
00000001803945E0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803945E4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803945E8  48 8D 87 70 2F 01 00        lea     rax, [rdi+12F70h]
00000001803945EF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803945F6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803945FA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803945FE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394603  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039460A  E8 F1 73 01 00              call    sub_1803ABA00
000000018039460F  66 0F 6F 05 19 7A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394617  48 8D 05 42 6C 5F 00        lea     rax, aBendLevel; "Bend Level"
000000018039461E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394622  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394626  48 8D 87 80 2F 01 00        lea     rax, [rdi+12F80h]
000000018039462D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394634  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394638  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039463C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394641  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394648  E8 B3 73 01 00              call    sub_1803ABA00
000000018039464D  66 0F 6F 05 DB 79 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394655  48 8D 05 14 6C 5F 00        lea     rax, aBendRange; "Bend Range"
000000018039465C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394660  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394664  48 8D 87 90 2F 01 00        lea     rax, [rdi+12F90h]
000000018039466B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394672  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394676  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039467A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039467F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394686  E8 75 73 01 00              call    sub_1803ABA00
000000018039468B  66 0F 6F 05 9D 79 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394693  48 8D 05 E6 6B 5F 00        lea     rax, aPwmLevel; "PWM Level"
000000018039469A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039469E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803946A2  48 8D 87 A0 2F 01 00        lea     rax, [rdi+12FA0h]
00000001803946A9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803946B0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803946B4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803946B8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803946BD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803946C4  E8 37 73 01 00              call    sub_1803ABA00
00000001803946C9  66 0F 6F 05 5F 79 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803946D1  48 8D 05 B8 6B 5F 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
00000001803946D8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803946DC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803946E0  48 8D 87 D0 2F 01 00        lea     rax, [rdi+12FD0h]
00000001803946E7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803946EE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803946F2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803946F6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803946FB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394702  E8 F9 72 01 00              call    sub_1803ABA00
0000000180394707  66 0F 6F 05 21 79 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039470F  48 8D 05 8A 6B 5F 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
0000000180394716  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039471A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039471E  48 8D 87 E0 2F 01 00        lea     rax, [rdi+12FE0h]
0000000180394725  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039472C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394730  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394734  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394739  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394740  E8 BB 72 01 00              call    sub_1803ABA00
0000000180394745  66 0F 6F 05 E3 78 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039474D  48 8D 05 5C 6B 5F 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
0000000180394754  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394758  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039475C  48 8D 87 F0 2F 01 00        lea     rax, [rdi+12FF0h]
0000000180394763  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039476A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039476E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394772  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394777  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039477E  E8 7D 72 01 00              call    sub_1803ABA00
0000000180394783  48 8D 05 36 6B 5F 00        lea     rax, aDutyTune; "Duty Tune"
000000018039478A  66 0F 6F 05 9E 78 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394792  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394796  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039479A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039479E  48 8D 87 00 35 01 00        lea     rax, [rdi+13500h]
00000001803947A5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803947AC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803947B0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803947B5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803947BC  E8 3F 72 01 00              call    sub_1803ABA00
00000001803947C1  66 0F 6F 05 67 78 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803947C9  48 8D 05 00 6B 5F 00        lea     rax, aOsc1Mute; "Osc1 Mute"
00000001803947D0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803947D4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803947D8  48 8D 87 A0 38 01 00        lea     rax, [rdi+138A0h]
00000001803947DF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803947E6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803947EA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803947EE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803947F3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803947FA  E8 01 72 01 00              call    sub_1803ABA00
00000001803947FF  66 0F 6F 05 29 78 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394807  48 8D 05 D2 6A 5F 00        lea     rax, aOsc1Level; "Osc1 Level"
000000018039480E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394812  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394816  48 8D 87 E0 38 01 00        lea     rax, [rdi+138E0h]
000000018039481D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394824  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394828  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039482C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394831  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394838  E8 C3 71 01 00              call    sub_1803ABA00
000000018039483D  66 0F 6F 05 EB 77 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394845  48 8D 05 A4 6A 5F 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
000000018039484C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394850  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394854  48 8D 87 F0 38 01 00        lea     rax, [rdi+138F0h]
000000018039485B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394862  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394866  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039486A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039486F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394876  E8 85 71 01 00              call    sub_1803ABA00
000000018039487B  48 8D 05 7E 6A 5F 00        lea     rax, aGrifferSw; "Griffer SW"
0000000180394882  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394889  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039488D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394891  48 8D 87 B0 39 01 00        lea     rax, [rdi+139B0h]
0000000180394898  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039489F  0F 57 C0                    xorps   xmm0, xmm0
00000001803948A2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803948A6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803948AA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803948AF  E8 4C 71 01 00              call    sub_1803ABA00
00000001803948B4  66 0F 6F 05 74 77 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803948BC  48 8D 05 4D 6A 5F 00        lea     rax, aLpfCutoff; "LPF Cutoff"
00000001803948C3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803948C7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803948CB  48 8D 87 C0 39 01 00        lea     rax, [rdi+139C0h]
00000001803948D2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803948D9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803948DD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803948E1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803948E6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803948ED  E8 0E 71 01 00              call    sub_1803ABA00
00000001803948F2  66 0F 6F 05 36 77 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803948FA  48 8D 05 1F 6A 5F 00        lea     rax, aLpfResonance; "LPF Resonance"
0000000180394901  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394905  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394909  48 8D 87 20 3A 01 00        lea     rax, [rdi+13A20h]
0000000180394910  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394917  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039491B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039491F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394924  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039492B  E8 D0 70 01 00              call    sub_1803ABA00
0000000180394930  48 8D 05 F9 69 5F 00        lea     rax, aVelocity; "Velocity"
0000000180394937  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039493E  0F 57 C0                    xorps   xmm0, xmm0
0000000180394941  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394945  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039494A  48 8D 87 40 3A 01 00        lea     rax, [rdi+13A40h]
0000000180394951  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394958  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039495C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394960  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394964  E8 97 70 01 00              call    sub_1803ABA00
0000000180394969  48 8D 05 CC 69 5F 00        lea     rax, aEnv12; "Env1/2"
0000000180394970  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394977  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039497B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039497F  48 8D 87 D0 3A 01 00        lea     rax, [rdi+13AD0h]
0000000180394986  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039498D  0F 57 C0                    xorps   xmm0, xmm0
0000000180394990  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394994  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394998  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039499D  E8 5E 70 01 00              call    sub_1803ABA00
00000001803949A2  48 8D 05 9F 69 5F 00        lea     rax, aIntEnv; "Int/Env"
00000001803949A9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803949B0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803949B4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803949B8  48 8D 87 E0 3A 01 00        lea     rax, [rdi+13AE0h]
00000001803949BF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803949C6  0F 57 C0                    xorps   xmm0, xmm0
00000001803949C9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803949CD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803949D1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803949D6  E8 25 70 01 00              call    sub_1803ABA00
00000001803949DB  48 8D 05 2E 68 5F 00        lea     rax, aLfoGain; "LFO Gain"
00000001803949E2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803949E9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803949ED  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803949F1  48 8D 87 F0 3B 01 00        lea     rax, [rdi+13BF0h]
00000001803949F8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803949FF  0F 57 C0                    xorps   xmm0, xmm0
0000000180394A02  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394A06  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394A0A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394A0F  E8 EC 6F 01 00              call    sub_1803ABA00
0000000180394A14  48 8D 05 35 69 5F 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
0000000180394A1B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394A22  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394A26  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394A2A  48 8D 87 00 3C 01 00        lea     rax, [rdi+13C00h]
0000000180394A31  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394A38  0F 57 C0                    xorps   xmm0, xmm0
0000000180394A3B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394A3F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394A43  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394A48  E8 B3 6F 01 00              call    sub_1803ABA00
0000000180394A4D  48 8D 05 0C 69 5F 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
0000000180394A54  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394A5B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394A5F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394A63  48 8D 87 10 3C 01 00        lea     rax, [rdi+13C10h]
0000000180394A6A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394A71  0F 57 C0                    xorps   xmm0, xmm0
0000000180394A74  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394A78  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394A7C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394A81  E8 7A 6F 01 00              call    sub_1803ABA00
0000000180394A86  66 0F 6F 05 A2 75 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394A8E  48 8D 05 8B 67 5F 00        lea     rax, aLfoLevel; "LFO Level"
0000000180394A95  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394A99  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394A9D  48 8D 87 20 3C 01 00        lea     rax, [rdi+13C20h]
0000000180394AA4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394AAB  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394AAF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394AB3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394AB8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394ABF  E8 3C 6F 01 00              call    sub_1803ABA00
0000000180394AC4  66 0F 6F 05 64 75 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394ACC  48 8D 05 9D 68 5F 00        lea     rax, aModSens_0; "MOD Sens"
0000000180394AD3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394AD7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394ADB  48 8D 87 30 3C 01 00        lea     rax, [rdi+13C30h]
0000000180394AE2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394AE9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394AED  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394AF2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394AF9  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394AFD  E8 FE 6E 01 00              call    sub_1803ABA00
0000000180394B02  66 0F 6F 05 26 75 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394B0A  48 8D 05 6B 68 5F 00        lea     rax, aModSw_0; "MOD SW"
0000000180394B11  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394B15  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394B19  48 8D 87 40 3C 01 00        lea     rax, [rdi+13C40h]
0000000180394B20  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394B27  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394B2B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394B2F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394B34  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394B3B  E8 C0 6E 01 00              call    sub_1803ABA00
0000000180394B40  66 0F 6F 05 E8 74 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394B48  48 8D 05 39 68 5F 00        lea     rax, aEnvLevel; "ENV Level"
0000000180394B4F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394B53  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394B57  48 8D 87 50 3C 01 00        lea     rax, [rdi+13C50h]
0000000180394B5E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394B65  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394B69  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394B6D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394B72  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394B79  E8 82 6E 01 00              call    sub_1803ABA00
0000000180394B7E  66 0F 6F 05 AA 74 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394B86  48 8D 05 0B 68 5F 00        lea     rax, aKcvLevel; "KCV Level"
0000000180394B8D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394B91  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394B95  48 8D 87 60 3C 01 00        lea     rax, [rdi+13C60h]
0000000180394B9C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394BA3  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394BA7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394BAB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394BB0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394BB7  E8 44 6E 01 00              call    sub_1803ABA00
0000000180394BBC  66 0F 6F 05 6C 74 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394BC4  48 8D 05 DD 67 5F 00        lea     rax, aVelocitySens; "Velocity Sens"
0000000180394BCB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394BCF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394BD3  48 8D 87 70 3C 01 00        lea     rax, [rdi+13C70h]
0000000180394BDA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394BE1  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394BE5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394BE9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394BEE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394BF5  E8 06 6E 01 00              call    sub_1803ABA00
0000000180394BFA  66 0F 6F 05 2E 74 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394C02  48 8D 05 AF 67 5F 00        lea     rax, aVelocityOffset; "Velocity Offset"
0000000180394C09  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394C0D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394C11  48 8D 87 80 3C 01 00        lea     rax, [rdi+13C80h]
0000000180394C18  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394C1F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394C23  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394C27  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394C2C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394C33  E8 C8 6D 01 00              call    sub_1803ABA00
0000000180394C38  66 0F 6F 05 F0 73 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394C40  48 8D 05 19 66 5F 00        lea     rax, aBendLevel; "Bend Level"
0000000180394C47  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394C4B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394C4F  48 8D 87 90 3C 01 00        lea     rax, [rdi+13C90h]
0000000180394C56  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394C5D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394C61  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394C65  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394C6A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394C71  E8 8A 6D 01 00              call    sub_1803ABA00
0000000180394C76  66 0F 6F 05 B2 73 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394C7E  48 8D 05 EB 65 5F 00        lea     rax, aBendRange; "Bend Range"
0000000180394C85  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394C89  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394C8D  48 8D 87 A0 3C 01 00        lea     rax, [rdi+13CA0h]
0000000180394C94  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394C9B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394C9F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394CA3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394CA8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394CAF  E8 4C 6D 01 00              call    sub_1803ABA00
0000000180394CB4  48 8D 05 0D 67 5F 00        lea     rax, aCutoffTune; "Cutoff Tune"
0000000180394CBB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394CBF  66 0F 6F 05 69 73 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394CC7  48 8D 87 20 3D 01 00        lea     rax, [rdi+13D20h]
0000000180394CCE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394CD2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394CD6  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394CDA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394CE1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394CE6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394CED  E8 0E 6D 01 00              call    sub_1803ABA00
0000000180394CF2  66 0F 6F 05 36 73 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394CFA  48 8D 05 D7 66 5F 00        lea     rax, aResonanceTune; "Resonance Tune"
0000000180394D01  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394D05  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394D09  48 8D 87 30 3D 01 00        lea     rax, [rdi+13D30h]
0000000180394D10  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394D17  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394D1B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394D1F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394D24  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394D2B  E8 D0 6C 01 00              call    sub_1803ABA00
0000000180394D30  48 8D 05 B1 66 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
0000000180394D37  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
0000000180394D3E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394D42  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394D46  48 8D 87 40 3D 01 00        lea     rax, [rdi+13D40h]
0000000180394D4D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394D54  0F 57 C0                    xorps   xmm0, xmm0
0000000180394D57  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394D5B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394D5F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394D64  E8 97 6C 01 00              call    sub_1803ABA00
0000000180394D69  48 8D 05 78 66 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
0000000180394D70  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
0000000180394D77  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394D7B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394D7F  48 8D 87 D0 42 01 00        lea     rax, [rdi+142D0h]
0000000180394D86  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394D8D  0F 57 C0                    xorps   xmm0, xmm0
0000000180394D90  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394D94  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394D98  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394D9D  E8 5E 6C 01 00              call    sub_1803ABA00
0000000180394DA2  66 0F 6F 05 86 72 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394DAA  48 8D 05 47 66 5F 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
0000000180394DB1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394DB5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394DB9  48 8D 87 E0 42 01 00        lea     rax, [rdi+142E0h]
0000000180394DC0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394DC7  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394DCB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394DCF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394DD4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394DDB  E8 20 6C 01 00              call    sub_1803ABA00
0000000180394DE0  66 0F 6F 05 48 72 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394DE8  48 8D 05 19 66 5F 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
0000000180394DEF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394DF3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394DF7  48 8D 87 F0 42 01 00        lea     rax, [rdi+142F0h]
0000000180394DFE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394E05  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394E09  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394E0D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394E12  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394E19  E8 E2 6B 01 00              call    sub_1803ABA00
0000000180394E1E  66 0F 6F 05 0A 72 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394E26  48 8D 05 EB 65 5F 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
0000000180394E2D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394E31  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394E35  48 8D 87 00 43 01 00        lea     rax, [rdi+14300h]
0000000180394E3C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394E43  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394E47  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394E4B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394E50  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394E57  E8 A4 6B 01 00              call    sub_1803ABA00
0000000180394E5C  66 0F 6F 05 CC 71 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394E64  48 8D 05 BD 65 5F 00        lea     rax, aAmpTone; "AMP TONE"
0000000180394E6B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394E6F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394E74  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394E7B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394E82  48 8D 87 E0 44 01 00        lea     rax, [rdi+144E0h]
0000000180394E89  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394E8D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394E91  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394E95  E8 66 6B 01 00              call    sub_1803ABA00
0000000180394E9A  66 0F 6F 05 8E 71 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394EA2  48 8D 05 8F 65 5F 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
0000000180394EA9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394EAD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394EB1  48 8D 87 F0 44 01 00        lea     rax, [rdi+144F0h]
0000000180394EB8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394EBF  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394EC3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394EC7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394ECC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394ED3  E8 28 6B 01 00              call    sub_1803ABA00
0000000180394ED8  66 0F 6F 05 50 71 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180394EE0  48 8D 05 69 65 5F 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
0000000180394EE7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394EEB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394EEF  48 8D 87 00 45 01 00        lea     rax, [rdi+14500h]
0000000180394EF6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394EFD  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394F01  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394F05  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394F0A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394F11  E8 EA 6A 01 00              call    sub_1803ABA00
0000000180394F16  48 8D 05 13 64 5F 00        lea     rax, aVelocity; "Velocity"
0000000180394F1D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394F24  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394F28  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394F2C  48 8D 87 40 45 01 00        lea     rax, [rdi+14540h]
0000000180394F33  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394F3A  0F 57 C0                    xorps   xmm0, xmm0
0000000180394F3D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394F41  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394F45  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394F4A  E8 B1 6A 01 00              call    sub_1803ABA00
0000000180394F4F  48 8D 05 12 65 5F 00        lea     rax, aMute; "Mute"
0000000180394F56  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394F5D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394F61  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394F65  48 8D 87 D0 45 01 00        lea     rax, [rdi+145D0h]
0000000180394F6C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394F73  0F 57 C0                    xorps   xmm0, xmm0
0000000180394F76  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394F7A  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394F7E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394F83  E8 78 6A 01 00              call    sub_1803ABA00
0000000180394F88  48 8D 05 E1 64 5F 00        lea     rax, aGateSw; "Gate SW"
0000000180394F8F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394F96  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394F9A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394F9E  48 8D 87 30 47 01 00        lea     rax, [rdi+14730h]
0000000180394FA5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394FAC  0F 57 C0                    xorps   xmm0, xmm0
0000000180394FAF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394FB3  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394FB7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394FBC  E8 3F 6A 01 00              call    sub_1803ABA00
0000000180394FC1  48 8D 05 B0 64 5F 00        lea     rax, aEnv1Sw; "ENV1 SW"
0000000180394FC8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180394FCF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180394FD3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180394FD7  48 8D 87 40 47 01 00        lea     rax, [rdi+14740h]
0000000180394FDE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180394FE5  0F 57 C0                    xorps   xmm0, xmm0
0000000180394FE8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180394FEC  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180394FF0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180394FF5  E8 06 6A 01 00              call    sub_1803ABA00
0000000180394FFA  48 8D 05 7F 64 5F 00        lea     rax, aEnv2Sw; "ENV2 SW"
0000000180395001  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395008  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039500C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395010  48 8D 87 50 47 01 00        lea     rax, [rdi+14750h]
0000000180395017  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039501E  0F 57 C0                    xorps   xmm0, xmm0
0000000180395021  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395025  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039502A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039502E  E8 CD 69 01 00              call    sub_1803ABA00
0000000180395033  48 8D 05 4E 64 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
000000018039503A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395041  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395045  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395049  48 8D 87 60 47 01 00        lea     rax, [rdi+14760h]
0000000180395050  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395057  0F 57 C0                    xorps   xmm0, xmm0
000000018039505A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039505E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395062  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395067  E8 94 69 01 00              call    sub_1803ABA00
000000018039506C  66 0F 6F 05 BC 6F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395074  48 8D 05 1D 64 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
000000018039507B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039507F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395083  48 8D 87 70 47 01 00        lea     rax, [rdi+14770h]
000000018039508A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395091  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395095  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395099  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039509E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803950A5  E8 56 69 01 00              call    sub_1803ABA00
00000001803950AA  66 0F 6F 05 7E 6F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803950B2  48 8D 05 EF 63 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
00000001803950B9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803950BD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803950C1  48 8D 87 80 47 01 00        lea     rax, [rdi+14780h]
00000001803950C8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803950CF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803950D3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803950D7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803950DC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803950E3  E8 18 69 01 00              call    sub_1803ABA00
00000001803950E8  66 0F 6F 05 40 6F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803950F0  48 8D 05 C1 63 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
00000001803950F7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803950FB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803950FF  48 8D 87 90 47 01 00        lea     rax, [rdi+14790h]
0000000180395106  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039510D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395111  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395115  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039511A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395121  E8 DA 68 01 00              call    sub_1803ABA00
0000000180395126  66 0F 6F 05 02 6F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039512E  48 8D 05 93 63 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
0000000180395135  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395139  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039513D  48 8D 87 A0 47 01 00        lea     rax, [rdi+147A0h]
0000000180395144  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039514B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039514F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395153  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395158  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039515F  E8 9C 68 01 00              call    sub_1803ABA00
0000000180395164  66 0F 6F 05 C4 6E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039516C  48 8D 05 6D 63 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
0000000180395173  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395177  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039517B  48 8D 87 B0 47 01 00        lea     rax, [rdi+147B0h]
0000000180395182  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395189  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039518D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395191  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395196  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039519D  E8 5E 68 01 00              call    sub_1803ABA00
00000001803951A2  66 0F 6F 05 86 6E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803951AA  48 8D 05 3F 63 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
00000001803951B1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803951B5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803951B9  48 8D 87 C0 47 01 00        lea     rax, [rdi+147C0h]
00000001803951C0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803951C7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803951CB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803951CF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803951D4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803951DB  E8 20 68 01 00              call    sub_1803ABA00
00000001803951E0  48 8D 05 19 63 5F 00        lea     rax, aExtNoiseSw; "Ext Noise Sw"
00000001803951E7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803951EE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803951F2  0F 57 C0                    xorps   xmm0, xmm0
00000001803951F5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803951FC  48 8D 87 50 49 01 00        lea     rax, [rdi+14950h]
0000000180395203  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395207  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039520B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039520F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395214  E8 E7 67 01 00              call    sub_1803ABA00
0000000180395219  66 0F 6F 05 0F 6E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395221  48 8D 05 E8 62 5F 00        lea     rax, aVoice01OutputO; "Voice01 Output On/Off"
0000000180395228  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039522C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395230  48 8D 87 E0 49 01 00        lea     rax, [rdi+149E0h]
0000000180395237  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039523E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395242  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395246  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039524B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395252  E8 A9 67 01 00              call    sub_1803ABA00
0000000180395257  66 0F 6F 05 D1 6D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039525F  48 8D 05 C2 62 5F 00        lea     rax, aVoice23OutputO; "Voice23 Output On/Off"
0000000180395266  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039526A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039526E  48 8D 87 F0 49 01 00        lea     rax, [rdi+149F0h]
0000000180395275  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039527C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395280  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395284  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395289  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395290  E8 6B 67 01 00              call    sub_1803ABA00
0000000180395295  66 0F 6F 05 93 6D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039529D  48 8D 05 9C 62 5F 00        lea     rax, aVoice45OutputO; "Voice45 Output On/Off"
00000001803952A4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803952A8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803952AC  48 8D 87 00 4A 01 00        lea     rax, [rdi+14A00h]
00000001803952B3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803952BA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803952BE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803952C2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803952C7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803952CE  E8 2D 67 01 00              call    sub_1803ABA00
00000001803952D3  66 0F 6F 05 55 6D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803952DB  48 8D 05 76 62 5F 00        lea     rax, aVoice67OutputO; "Voice67 Output On/Off"
00000001803952E2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803952E6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803952EA  48 8D 87 10 4A 01 00        lea     rax, [rdi+14A10h]
00000001803952F1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803952F8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803952FC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395300  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395305  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039530C  E8 EF 66 01 00              call    sub_1803ABA00
0000000180395311  66 0F 6F 05 17 6D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395319  48 8D 05 50 62 5F 00        lea     rax, aEffectSw; "Effect SW"
0000000180395320  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395324  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395328  48 8D 87 40 4A 01 00        lea     rax, [rdi+14A40h]
000000018039532F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395336  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039533A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039533E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395343  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039534A  E8 B1 66 01 00              call    sub_1803ABA00
000000018039534F  66 0F 6F 05 D9 6C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395357  48 8D 05 22 62 5F 00        lea     rax, aMuteSw; "Mute SW"
000000018039535E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395362  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395366  48 8D 87 50 4A 01 00        lea     rax, [rdi+14A50h]
000000018039536D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395374  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395378  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039537C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395381  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395388  E8 73 66 01 00              call    sub_1803ABA00
000000018039538D  66 0F 6F 05 9B 6C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395395  48 8D 05 EC 61 5F 00        lea     rax, aDsDrive; "DS Drive"
000000018039539C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803953A0  48 8D 87 90 4C 01 00        lea     rax, [rdi+14C90h]
00000001803953A7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803953AE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803953B3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803953BA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803953BE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803953C2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803953C6  E8 35 66 01 00              call    sub_1803ABA00
00000001803953CB  66 0F 6F 05 5D 6C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803953D3  48 8D 05 BE 61 5F 00        lea     rax, aDsLevel; "DS Level"
00000001803953DA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803953DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803953E2  48 8D 87 A0 4C 01 00        lea     rax, [rdi+14CA0h]
00000001803953E9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803953F0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803953F4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803953F8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803953FD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395404  E8 F7 65 01 00              call    sub_1803ABA00
0000000180395409  66 0F 6F 05 1F 6C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395411  48 8D 05 90 61 5F 00        lea     rax, aDsMute; "DS Mute"
0000000180395418  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039541C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395420  48 8D 87 B0 4C 01 00        lea     rax, [rdi+14CB0h]
0000000180395427  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039542E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395432  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395436  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039543B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395442  E8 B9 65 01 00              call    sub_1803ABA00
0000000180395447  66 0F 6F 05 E1 6B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039544F  48 8D 05 5A 61 5F 00        lea     rax, aDsBiasmute; "DS BiasMute"
0000000180395456  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039545A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039545E  48 8D 87 C0 4C 01 00        lea     rax, [rdi+14CC0h]
0000000180395465  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039546C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395470  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395474  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395479  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395480  E8 7B 65 01 00              call    sub_1803ABA00
0000000180395485  66 0F 6F 05 A3 6B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039548D  48 8D 05 2C 61 5F 00        lea     rax, aOdTone; "OD TONE"
0000000180395494  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395498  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039549C  48 8D 87 E0 4F 01 00        lea     rax, [rdi+14FE0h]
00000001803954A3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803954AA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803954AE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803954B2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803954B7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803954BE  E8 3D 65 01 00              call    sub_1803ABA00
00000001803954C3  66 0F 6F 05 65 6B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803954CB  48 8D 05 B6 60 5F 00        lea     rax, aDsDrive; "DS Drive"
00000001803954D2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803954D6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803954DA  48 8D 87 10 51 01 00        lea     rax, [rdi+15110h]
00000001803954E1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803954E8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803954EC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803954F0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803954F5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803954FC  E8 FF 64 01 00              call    sub_1803ABA00
0000000180395501  66 0F 6F 05 27 6B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395509  48 8D 05 88 60 5F 00        lea     rax, aDsLevel; "DS Level"
0000000180395510  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395514  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395518  48 8D 87 20 51 01 00        lea     rax, [rdi+15120h]
000000018039551F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395526  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039552A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039552E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395533  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039553A  E8 C1 64 01 00              call    sub_1803ABA00
000000018039553F  66 0F 6F 05 E9 6A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395547  48 8D 05 5A 60 5F 00        lea     rax, aDsMute; "DS Mute"
000000018039554E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395552  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395556  48 8D 87 30 51 01 00        lea     rax, [rdi+15130h]
000000018039555D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395564  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395568  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039556C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395571  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395578  E8 83 64 01 00              call    sub_1803ABA00
000000018039557D  66 0F 6F 05 AB 6A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395585  48 8D 05 24 60 5F 00        lea     rax, aDsBiasmute; "DS BiasMute"
000000018039558C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395590  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395594  48 8D 87 40 51 01 00        lea     rax, [rdi+15140h]
000000018039559B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803955A2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803955A6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803955AA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803955AF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803955B6  E8 45 64 01 00              call    sub_1803ABA00
00000001803955BB  66 0F 6F 05 6D 6A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803955C3  48 8D 05 FE 5F 5F 00        lea     rax, aDsTone; "DS TONE"
00000001803955CA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803955CE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803955D2  48 8D 87 10 54 01 00        lea     rax, [rdi+15410h]
00000001803955D9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803955E0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803955E4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803955E8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803955ED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803955F4  E8 07 64 01 00              call    sub_1803ABA00
00000001803955F9  66 0F 6F 05 2F 6A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395601  48 8D 05 80 5F 5F 00        lea     rax, aDsDrive; "DS Drive"
0000000180395608  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039560C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395610  48 8D 87 40 56 01 00        lea     rax, [rdi+15640h]
0000000180395617  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039561E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395622  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395626  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039562B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395632  E8 C9 63 01 00              call    sub_1803ABA00
0000000180395637  66 0F 6F 05 F1 69 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039563F  48 8D 05 52 5F 5F 00        lea     rax, aDsLevel; "DS Level"
0000000180395646  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039564A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039564E  48 8D 87 50 56 01 00        lea     rax, [rdi+15650h]
0000000180395655  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039565C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395660  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395664  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395669  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395670  E8 8B 63 01 00              call    sub_1803ABA00
0000000180395675  66 0F 6F 05 B3 69 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039567D  48 8D 05 24 5F 5F 00        lea     rax, aDsMute; "DS Mute"
0000000180395684  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395688  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039568C  48 8D 87 60 56 01 00        lea     rax, [rdi+15660h]
0000000180395693  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039569A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039569E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803956A2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803956A7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803956AE  E8 4D 63 01 00              call    sub_1803ABA00
00000001803956B3  66 0F 6F 05 75 69 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803956BB  48 8D 05 0E 5F 5F 00        lea     rax, aMtTone; "MT TONE"
00000001803956C2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803956C6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803956CA  48 8D 87 90 5B 01 00        lea     rax, [rdi+15B90h]
00000001803956D1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803956D8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803956DC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803956E0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803956E5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803956EC  E8 0F 63 01 00              call    sub_1803ABA00
00000001803956F1  66 0F 6F 05 37 69 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803956F9  48 8D 05 88 5E 5F 00        lea     rax, aDsDrive; "DS Drive"
0000000180395700  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395704  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395708  48 8D 87 E0 5C 01 00        lea     rax, [rdi+15CE0h]
000000018039570F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395716  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039571A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039571E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395723  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039572A  E8 D1 62 01 00              call    sub_1803ABA00
000000018039572F  66 0F 6F 05 F9 68 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395737  48 8D 05 5A 5E 5F 00        lea     rax, aDsLevel; "DS Level"
000000018039573E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395742  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395749  48 8D 87 F0 5C 01 00        lea     rax, [rdi+15CF0h]
0000000180395750  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395757  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039575B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039575F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395763  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395768  E8 93 62 01 00              call    sub_1803ABA00
000000018039576D  66 0F 6F 05 BB 68 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395775  48 8D 05 2C 5E 5F 00        lea     rax, aDsMute; "DS Mute"
000000018039577C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395780  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395784  48 8D 87 00 5D 01 00        lea     rax, [rdi+15D00h]
000000018039578B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395792  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395796  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039579A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039579F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803957A6  E8 55 62 01 00              call    sub_1803ABA00
00000001803957AB  66 0F 6F 05 7D 68 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803957B3  48 8D 05 F6 5D 5F 00        lea     rax, aDsBiasmute; "DS BiasMute"
00000001803957BA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803957BE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803957C2  48 8D 87 10 5D 01 00        lea     rax, [rdi+15D10h]
00000001803957C9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803957D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803957D4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803957D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803957DD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803957E4  E8 17 62 01 00              call    sub_1803ABA00
00000001803957E9  66 0F 6F 05 3F 68 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803957F1  48 8D 05 E0 5D 5F 00        lea     rax, aFzTone; "FZ TONE"
00000001803957F8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803957FC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395800  48 8D 87 90 60 01 00        lea     rax, [rdi+16090h]
0000000180395807  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039580E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395812  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395816  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039581B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395822  E8 D9 61 01 00              call    sub_1803ABA00
0000000180395827  48 8D 05 B2 5D 5F 00        lea     rax, aDelayTime; "Delay Time"
000000018039582E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395835  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395839  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039583D  48 8D 87 F0 63 01 00        lea     rax, [rdi+163F0h]
0000000180395844  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039584B  0F 57 C0                    xorps   xmm0, xmm0
000000018039584E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395852  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395856  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039585B  E8 A0 61 01 00              call    sub_1803ABA00
0000000180395860  48 8D 05 89 5D 5F 00        lea     rax, aErrorDepth; "Error Depth"
0000000180395867  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039586E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395872  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395876  48 8D 87 00 64 01 00        lea     rax, [rdi+16400h]
000000018039587D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395884  0F 57 C0                    xorps   xmm0, xmm0
0000000180395887  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039588B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039588F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395894  E8 67 61 01 00              call    sub_1803ABA00
0000000180395899  66 0F 6F 05 8F 67 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803958A1  48 8D 05 30 57 5F 00        lea     rax, aLfoRate; "LFO Rate"
00000001803958A8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803958AC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803958B0  48 8D 87 10 64 01 00        lea     rax, [rdi+16410h]
00000001803958B7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803958BE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803958C2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803958C6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803958CB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803958D2  E8 29 61 01 00              call    sub_1803ABA00
00000001803958D7  66 0F 6F 05 51 67 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803958DF  48 8D 05 1A 5D 5F 00        lea     rax, aLfoPhase; "LFO Phase"
00000001803958E6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803958EA  48 8D 87 20 64 01 00        lea     rax, [rdi+16420h]
00000001803958F1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803958F5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803958FC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395901  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395908  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039590C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395910  E8 EB 60 01 00              call    sub_1803ABA00
0000000180395915  66 0F 6F 05 13 67 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039591D  48 8D 05 EC 5C 5F 00        lea     rax, aLfoDepth; "LFO Depth"
0000000180395924  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395928  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039592C  48 8D 87 30 64 01 00        lea     rax, [rdi+16430h]
0000000180395933  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039593A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039593E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395942  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395947  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039594E  E8 AD 60 01 00              call    sub_1803ABA00
0000000180395953  66 0F 6F 05 D5 66 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039595B  48 8D 05 BE 5C 5F 00        lea     rax, aNoiseLevel; "Noise Level"
0000000180395962  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395966  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039596A  48 8D 87 40 64 01 00        lea     rax, [rdi+16440h]
0000000180395971  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395978  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039597C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395980  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395985  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039598C  E8 6F 60 01 00              call    sub_1803ABA00
0000000180395991  66 0F 6F 05 97 66 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395999  48 8D 05 90 5C 5F 00        lea     rax, aDryLevel; "Dry Level"
00000001803959A0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803959A4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803959A8  48 8D 87 50 64 01 00        lea     rax, [rdi+16450h]
00000001803959AF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803959B6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803959BA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803959BE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803959C3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803959CA  E8 31 60 01 00              call    sub_1803ABA00
00000001803959CF  66 0F 6F 05 59 66 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803959D7  48 8D 05 62 5C 5F 00        lea     rax, aWetLevel; "Wet Level"
00000001803959DE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803959E2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803959E6  48 8D 87 60 64 01 00        lea     rax, [rdi+16460h]
00000001803959ED  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803959F4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803959F8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803959FC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395A01  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395A08  E8 F3 5F 01 00              call    sub_1803ABA00
0000000180395A0D  66 0F 6F 05 1B 66 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395A15  48 8D 05 30 5C 5F 00        lea     rax, aIpFc; "Ip Fc"
0000000180395A1C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395A20  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395A24  48 8D 87 70 64 01 00        lea     rax, [rdi+16470h]
0000000180395A2B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395A32  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395A36  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395A3A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395A3F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395A46  E8 B5 5F 01 00              call    sub_1803ABA00
0000000180395A4B  66 0F 6F 05 DD 65 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395A53  48 8D 05 FA 5B 5F 00        lea     rax, aOnOff; "On/Off"
0000000180395A5A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395A5E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395A62  48 8D 87 80 64 01 00        lea     rax, [rdi+16480h]
0000000180395A69  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395A70  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395A74  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395A78  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395A7D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395A84  E8 77 5F 01 00              call    sub_1803ABA00
0000000180395A89  66 0F 6F 05 9F 65 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395A91  48 8D 05 D0 59 5F 00        lea     rax, aMute; "Mute"
0000000180395A98  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395A9C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395AA0  48 8D 87 90 64 01 00        lea     rax, [rdi+16490h]
0000000180395AA7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395AAE  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395AB2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395AB6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395ABB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395AC2  E8 39 5F 01 00              call    sub_1803ABA00
0000000180395AC7  48 8D 05 12 5B 5F 00        lea     rax, aDelayTime; "Delay Time"
0000000180395ACE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395AD2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395AD6  48 8D 87 50 78 01 00        lea     rax, [rdi+17850h]
0000000180395ADD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395AE4  0F 57 C0                    xorps   xmm0, xmm0
0000000180395AE7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395AEB  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395AEF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395AF6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395AFB  E8 00 5F 01 00              call    sub_1803ABA00
0000000180395B00  66 0F 6F 05 28 65 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395B08  48 8D 05 C9 54 5F 00        lea     rax, aLfoRate; "LFO Rate"
0000000180395B0F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395B13  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395B17  48 8D 87 60 78 01 00        lea     rax, [rdi+17860h]
0000000180395B1E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395B25  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395B29  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395B2D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395B32  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395B39  E8 C2 5E 01 00              call    sub_1803ABA00
0000000180395B3E  66 0F 6F 05 EA 64 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395B46  48 8D 05 C3 5A 5F 00        lea     rax, aLfoDepth; "LFO Depth"
0000000180395B4D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395B51  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395B55  48 8D 87 70 78 01 00        lea     rax, [rdi+17870h]
0000000180395B5C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395B63  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395B67  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395B6B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395B70  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395B77  E8 84 5E 01 00              call    sub_1803ABA00
0000000180395B7C  66 0F 6F 05 AC 64 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395B84  48 8D 05 C1 5A 5F 00        lea     rax, aIpFc; "Ip Fc"
0000000180395B8B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395B8F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395B93  48 8D 87 80 78 01 00        lea     rax, [rdi+17880h]
0000000180395B9A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395BA1  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395BA5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395BA9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395BAE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395BB5  E8 46 5E 01 00              call    sub_1803ABA00
0000000180395BBA  66 0F 6F 05 6E 64 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395BC2  48 8D 05 8B 5A 5F 00        lea     rax, aOnOff; "On/Off"
0000000180395BC9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395BCD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395BD1  48 8D 87 90 78 01 00        lea     rax, [rdi+17890h]
0000000180395BD8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395BDF  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395BE3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395BE7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395BEC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395BF3  E8 08 5E 01 00              call    sub_1803ABA00
0000000180395BF8  66 0F 6F 05 30 64 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395C00  48 8D 05 61 58 5F 00        lea     rax, aMute; "Mute"
0000000180395C07  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395C0B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395C0F  48 8D 87 A0 78 01 00        lea     rax, [rdi+178A0h]
0000000180395C16  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395C1D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395C21  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395C25  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395C2A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395C31  E8 CA 5D 01 00              call    sub_1803ABA00
0000000180395C36  66 0F 6F 05 F2 63 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395C3E  48 8D 05 1B 5A 5F 00        lea     rax, aPatchLevel; "Patch Level"
0000000180395C45  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395C49  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395C4D  48 8D 87 D0 8A 01 00        lea     rax, [rdi+18AD0h]
0000000180395C54  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395C5B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395C5F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395C63  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395C68  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395C6F  E8 8C 5D 01 00              call    sub_1803ABA00
0000000180395C74  66 0F 6F 05 B4 63 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395C7C  48 8D 05 ED 59 5F 00        lea     rax, aExpression; "Expression"
0000000180395C83  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395C87  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395C8C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395C93  48 8D 87 10 8B 01 00        lea     rax, [rdi+18B10h]
0000000180395C9A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395CA1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395CA5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395CA9  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395CAD  E8 4E 5D 01 00              call    sub_1803ABA00
0000000180395CB2  66 0F 6F 05 76 63 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180395CBA  48 8D 05 BB 59 5F 00        lea     rax, aVolume; "Volume"
0000000180395CC1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395CC5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395CC9  48 8D 87 20 8B 01 00        lea     rax, [rdi+18B20h]
0000000180395CD0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395CD7  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395CDB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395CDF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395CE4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395CEB  E8 10 5D 01 00              call    sub_1803ABA00
0000000180395CF0  48 8D 05 91 59 5F 00        lea     rax, aVoice0GateNoti; "Voice0 Gate Notify"
0000000180395CF7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395CFE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395D02  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395D06  48 8D 87 70 8C 01 00        lea     rax, [rdi+18C70h]
0000000180395D0D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395D14  0F 57 C0                    xorps   xmm0, xmm0
0000000180395D17  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395D1B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395D1F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395D24  E8 D7 5C 01 00              call    sub_1803ABA00
0000000180395D29  48 8D 05 70 59 5F 00        lea     rax, aVoice0NoteOffN; "Voice0 Note Off Notify"
0000000180395D30  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395D37  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395D3B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395D3F  48 8D 87 80 8C 01 00        lea     rax, [rdi+18C80h]
0000000180395D46  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395D4D  0F 57 C0                    xorps   xmm0, xmm0
0000000180395D50  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395D54  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395D58  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395D5D  E8 9E 5C 01 00              call    sub_1803ABA00
0000000180395D62  48 8D 05 4F 59 5F 00        lea     rax, aVoice1GateNoti; "Voice1 Gate Notify"
0000000180395D69  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395D70  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395D74  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395D78  48 8D 87 90 8C 01 00        lea     rax, [rdi+18C90h]
0000000180395D7F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395D86  0F 57 C0                    xorps   xmm0, xmm0
0000000180395D89  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395D8D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395D91  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395D96  E8 65 5C 01 00              call    sub_1803ABA00
0000000180395D9B  48 8D 05 2E 59 5F 00        lea     rax, aVoice1NoteOffN; "Voice1 Note Off Notify"
0000000180395DA2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395DA9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395DAD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395DB1  48 8D 87 A0 8C 01 00        lea     rax, [rdi+18CA0h]
0000000180395DB8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395DBF  0F 57 C0                    xorps   xmm0, xmm0
0000000180395DC2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395DC6  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395DCA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395DCF  E8 2C 5C 01 00              call    sub_1803ABA00
0000000180395DD4  48 8D 05 0D 59 5F 00        lea     rax, aVoice2GateNoti; "Voice2 Gate Notify"
0000000180395DDB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395DE2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395DE6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395DEA  48 8D 87 B0 8C 01 00        lea     rax, [rdi+18CB0h]
0000000180395DF1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395DF8  0F 57 C0                    xorps   xmm0, xmm0
0000000180395DFB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395DFF  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395E03  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395E08  E8 F3 5B 01 00              call    sub_1803ABA00
0000000180395E0D  48 8D 05 EC 58 5F 00        lea     rax, aVoice2NoteOffN; "Voice2 Note Off Notify"
0000000180395E14  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395E1B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395E1F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395E23  48 8D 87 C0 8C 01 00        lea     rax, [rdi+18CC0h]
0000000180395E2A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395E31  0F 57 C0                    xorps   xmm0, xmm0
0000000180395E34  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395E38  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395E3D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395E41  E8 BA 5B 01 00              call    sub_1803ABA00
0000000180395E46  48 8D 05 CB 58 5F 00        lea     rax, aVoice3GateNoti; "Voice3 Gate Notify"
0000000180395E4D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395E54  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395E58  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395E5C  48 8D 87 D0 8C 01 00        lea     rax, [rdi+18CD0h]
0000000180395E63  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395E6A  0F 57 C0                    xorps   xmm0, xmm0
0000000180395E6D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395E71  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395E75  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395E7A  E8 81 5B 01 00              call    sub_1803ABA00
0000000180395E7F  48 8D 05 AA 58 5F 00        lea     rax, aVoice3NoteOffN; "Voice3 Note Off Notify"
0000000180395E86  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395E8D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395E91  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395E95  48 8D 87 E0 8C 01 00        lea     rax, [rdi+18CE0h]
0000000180395E9C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395EA3  0F 57 C0                    xorps   xmm0, xmm0
0000000180395EA6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395EAA  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395EAE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395EB3  E8 48 5B 01 00              call    sub_1803ABA00
0000000180395EB8  48 8D 05 89 58 5F 00        lea     rax, aVoice4GateNoti; "Voice4 Gate Notify"
0000000180395EBF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395EC6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395ECA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395ECE  48 8D 87 F0 8C 01 00        lea     rax, [rdi+18CF0h]
0000000180395ED5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395EDC  0F 57 C0                    xorps   xmm0, xmm0
0000000180395EDF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395EE3  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395EE7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395EEC  E8 0F 5B 01 00              call    sub_1803ABA00
0000000180395EF1  48 8D 05 68 58 5F 00        lea     rax, aVoice4NoteOffN; "Voice4 Note Off Notify"
0000000180395EF8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395EFF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395F03  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395F07  48 8D 87 00 8D 01 00        lea     rax, [rdi+18D00h]
0000000180395F0E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395F15  0F 57 C0                    xorps   xmm0, xmm0
0000000180395F18  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395F1C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395F20  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395F25  E8 D6 5A 01 00              call    sub_1803ABA00
0000000180395F2A  48 8D 05 47 58 5F 00        lea     rax, aVoice5GateNoti; "Voice5 Gate Notify"
0000000180395F31  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395F38  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395F3C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395F40  48 8D 87 10 8D 01 00        lea     rax, [rdi+18D10h]
0000000180395F47  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395F4E  0F 57 C0                    xorps   xmm0, xmm0
0000000180395F51  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395F55  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395F59  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395F5E  E8 9D 5A 01 00              call    sub_1803ABA00
0000000180395F63  48 8D 05 26 58 5F 00        lea     rax, aVoice5NoteOffN; "Voice5 Note Off Notify"
0000000180395F6A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395F71  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395F75  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395F79  48 8D 87 20 8D 01 00        lea     rax, [rdi+18D20h]
0000000180395F80  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395F87  0F 57 C0                    xorps   xmm0, xmm0
0000000180395F8A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395F8E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395F92  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395F97  E8 64 5A 01 00              call    sub_1803ABA00
0000000180395F9C  48 8D 05 05 58 5F 00        lea     rax, aVoice6GateNoti; "Voice6 Gate Notify"
0000000180395FA3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395FAA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395FAE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395FB2  48 8D 87 30 8D 01 00        lea     rax, [rdi+18D30h]
0000000180395FB9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395FC0  0F 57 C0                    xorps   xmm0, xmm0
0000000180395FC3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180395FC7  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180395FCB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180395FD0  E8 2B 5A 01 00              call    sub_1803ABA00
0000000180395FD5  48 8D 05 E4 57 5F 00        lea     rax, aVoice6NoteOffN; "Voice6 Note Off Notify"
0000000180395FDC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180395FE0  0F 57 C0                    xorps   xmm0, xmm0
0000000180395FE3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180395FEA  48 8D 87 40 8D 01 00        lea     rax, [rdi+18D40h]
0000000180395FF1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180395FF8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180395FFC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396000  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396004  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396009  E8 F2 59 01 00              call    sub_1803ABA00
000000018039600E  48 8D 05 C3 57 5F 00        lea     rax, aVoice7GateNoti; "Voice7 Gate Notify"
0000000180396015  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039601C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396020  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396024  48 8D 87 50 8D 01 00        lea     rax, [rdi+18D50h]
000000018039602B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396032  0F 57 C0                    xorps   xmm0, xmm0
0000000180396035  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396039  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039603D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396042  E8 B9 59 01 00              call    sub_1803ABA00
0000000180396047  48 8D 05 A2 57 5F 00        lea     rax, aVoice7NoteOffN; "Voice7 Note Off Notify"
000000018039604E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396055  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396059  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039605D  48 8D 87 60 8D 01 00        lea     rax, [rdi+18D60h]
0000000180396064  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039606B  0F 57 C0                    xorps   xmm0, xmm0
000000018039606E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396072  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396076  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039607B  E8 80 59 01 00              call    sub_1803ABA00
0000000180396080  66 0F 6F 05 A8 5F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396088  48 8D 05 79 57 5F 00        lea     rax, aDlyMute; "DLY Mute"
000000018039608F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396093  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396097  48 8D 87 70 8D 01 00        lea     rax, [rdi+18D70h]
000000018039609E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803960A5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803960A9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803960AD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803960B2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803960B9  E8 42 59 01 00              call    sub_1803ABA00
00000001803960BE  48 8D 05 1B 55 5F 00        lea     rax, aDelayTime; "Delay Time"
00000001803960C5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803960CC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803960D0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803960D4  48 8D 87 D0 8F 01 00        lea     rax, [rdi+18FD0h]
00000001803960DB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803960E2  0F 57 C0                    xorps   xmm0, xmm0
00000001803960E5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803960E9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803960ED  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803960F2  E8 09 59 01 00              call    sub_1803ABA00
00000001803960F7  66 0F 6F 05 31 5F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803960FF  48 8D 05 12 57 5F 00        lea     rax, aHighCutC0; "High Cut C0"
0000000180396106  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039610A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039610E  48 8D 87 E0 8F 01 00        lea     rax, [rdi+18FE0h]
0000000180396115  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039611C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396120  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396124  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396129  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396130  E8 CB 58 01 00              call    sub_1803ABA00
0000000180396135  66 0F 6F 05 F3 5E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039613D  48 8D 05 E4 56 5F 00        lea     rax, aHighCutA0; "High Cut A0"
0000000180396144  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396148  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039614C  48 8D 87 F0 8F 01 00        lea     rax, [rdi+18FF0h]
0000000180396153  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039615A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039615E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396162  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396167  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039616E  E8 8D 58 01 00              call    sub_1803ABA00
0000000180396173  66 0F 6F 05 B5 5E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039617B  48 8D 05 B6 56 5F 00        lea     rax, aHighCutA1; "High Cut A1"
0000000180396182  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396186  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039618B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396192  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396199  48 8D 87 00 90 01 00        lea     rax, [rdi+19000h]
00000001803961A0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803961A4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803961A8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803961AC  E8 4F 58 01 00              call    sub_1803ABA00
00000001803961B1  66 0F 6F 05 77 5E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803961B9  48 8D 05 88 56 5F 00        lea     rax, aHighCutB0; "High Cut B0"
00000001803961C0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803961C4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803961C8  48 8D 87 10 90 01 00        lea     rax, [rdi+19010h]
00000001803961CF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803961D6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803961DA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803961DE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803961E3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803961EA  E8 11 58 01 00              call    sub_1803ABA00
00000001803961EF  66 0F 6F 05 39 5E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803961F7  48 8D 05 5A 56 5F 00        lea     rax, aHighCutB2; "High Cut B2"
00000001803961FE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396202  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396206  48 8D 87 20 90 01 00        lea     rax, [rdi+19020h]
000000018039620D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396214  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396218  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039621C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396221  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396228  E8 D3 57 01 00              call    sub_1803ABA00
000000018039622D  66 0F 6F 05 FB 5D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396235  48 8D 05 2C 56 5F 00        lea     rax, aUseIirHighCutF; "Use IIR High Cut Filter"
000000018039623C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396240  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396244  48 8D 87 30 90 01 00        lea     rax, [rdi+19030h]
000000018039624B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396252  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396256  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039625A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039625F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396266  E8 95 57 01 00              call    sub_1803ABA00
000000018039626B  66 0F 6F 05 BD 5D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396273  48 8D 05 06 56 5F 00        lea     rax, aHighCutFc; "High Cut Fc"
000000018039627A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039627E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396282  48 8D 87 40 90 01 00        lea     rax, [rdi+19040h]
0000000180396289  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396290  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396294  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396298  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039629D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803962A4  E8 57 57 01 00              call    sub_1803ABA00
00000001803962A9  66 0F 6F 05 7F 5D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803962B1  48 8D 05 D8 55 5F 00        lea     rax, aHighCutQc; "High Cut Qc"
00000001803962B8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803962BC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803962C0  48 8D 87 50 90 01 00        lea     rax, [rdi+19050h]
00000001803962C7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803962CE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803962D2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803962D6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803962DB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803962E2  E8 19 57 01 00              call    sub_1803ABA00
00000001803962E7  66 0F 6F 05 41 5D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803962EF  48 8D 05 AA 55 5F 00        lea     rax, aHighCutSw; "High Cut Sw"
00000001803962F6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803962FA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803962FE  48 8D 87 60 90 01 00        lea     rax, [rdi+19060h]
0000000180396305  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039630C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396310  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396314  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396319  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396320  E8 DB 56 01 00              call    sub_1803ABA00
0000000180396325  66 0F 6F 05 03 5D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039632D  48 8D 05 FC 52 5F 00        lea     rax, aDryLevel; "Dry Level"
0000000180396334  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396338  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039633C  48 8D 87 70 90 01 00        lea     rax, [rdi+19070h]
0000000180396343  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039634A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039634E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396352  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396357  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039635E  E8 9D 56 01 00              call    sub_1803ABA00
0000000180396363  66 0F 6F 05 C5 5C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039636B  48 8D 05 CE 52 5F 00        lea     rax, aWetLevel; "Wet Level"
0000000180396372  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396376  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039637A  48 8D 87 80 90 01 00        lea     rax, [rdi+19080h]
0000000180396381  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396388  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039638C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396390  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396395  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039639C  E8 5F 56 01 00              call    sub_1803ABA00
00000001803963A1  66 0F 6F 05 87 5C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803963A9  48 8D 05 9C 52 5F 00        lea     rax, aIpFc; "Ip Fc"
00000001803963B0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803963B4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803963B8  48 8D 87 90 90 01 00        lea     rax, [rdi+19090h]
00000001803963BF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803963C6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803963CA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803963CE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803963D3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803963DA  E8 21 56 01 00              call    sub_1803ABA00
00000001803963DF  66 0F 6F 05 49 5C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803963E7  48 8D 05 C2 54 5F 00        lea     rax, aFeedback_0; "Feedback"
00000001803963EE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803963F2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803963F6  48 8D 87 A0 90 01 00        lea     rax, [rdi+190A0h]
00000001803963FD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396404  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396408  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039640C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396411  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396418  E8 E3 55 01 00              call    sub_1803ABA00
000000018039641D  66 0F 6F 05 0B 5C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396425  48 8D 05 28 52 5F 00        lea     rax, aOnOff; "On/Off"
000000018039642C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396430  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396434  48 8D 87 B0 90 01 00        lea     rax, [rdi+190B0h]
000000018039643B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396442  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396446  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039644A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039644F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396456  E8 A5 55 01 00              call    sub_1803ABA00
000000018039645B  66 0F 6F 05 CD 5B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396463  48 8D 05 FE 4F 5F 00        lea     rax, aMute; "Mute"
000000018039646A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039646E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396472  48 8D 87 C0 90 01 00        lea     rax, [rdi+190C0h]
0000000180396479  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396480  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396484  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396488  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039648D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396494  E8 67 55 01 00              call    sub_1803ABA00
0000000180396499  66 0F 6F 05 8F 5B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803964A1  48 8D 05 18 54 5F 00        lea     rax, aLfDampFc; "LF Damp Fc"
00000001803964A8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803964AC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803964B0  48 8D 87 D0 90 01 00        lea     rax, [rdi+190D0h]
00000001803964B7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803964BE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803964C2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803964C6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803964CB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803964D2  E8 29 55 01 00              call    sub_1803ABA00
00000001803964D7  66 0F 6F 05 51 5B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803964DF  48 8D 05 EA 53 5F 00        lea     rax, aLfDampHp; "LF Damp Hp"
00000001803964E6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803964EA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803964EE  48 8D 87 E0 90 01 00        lea     rax, [rdi+190E0h]
00000001803964F5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803964FC  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396500  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396504  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396509  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396510  E8 EB 54 01 00              call    sub_1803ABA00
0000000180396515  48 8D 05 C4 53 5F 00        lea     rax, aLfDampLp; "LF Damp Lp"
000000018039651C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396523  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396527  66 0F 6F 05 01 5B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039652F  48 8D 87 F0 90 01 00        lea     rax, [rdi+190F0h]
0000000180396536  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039653A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039653E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396542  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396549  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039654E  E8 AD 54 01 00              call    sub_1803ABA00
0000000180396553  66 0F 6F 05 D5 5A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039655B  48 8D 05 8E 53 5F 00        lea     rax, aHfDampFc; "HF Damp Fc"
0000000180396562  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396566  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039656A  48 8D 87 00 91 01 00        lea     rax, [rdi+19100h]
0000000180396571  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396578  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039657C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396580  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396585  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039658C  E8 6F 54 01 00              call    sub_1803ABA00
0000000180396591  66 0F 6F 05 97 5A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396599  48 8D 05 60 53 5F 00        lea     rax, aHfDampHp; "HF Damp Hp"
00000001803965A0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803965A4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803965A8  48 8D 87 10 91 01 00        lea     rax, [rdi+19110h]
00000001803965AF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803965B6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803965BA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803965BE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803965C3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803965CA  E8 31 54 01 00              call    sub_1803ABA00
00000001803965CF  66 0F 6F 05 59 5A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803965D7  48 8D 05 32 53 5F 00        lea     rax, aHfDampLp; "HF Damp Lp"
00000001803965DE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803965E2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803965E6  48 8D 87 20 91 01 00        lea     rax, [rdi+19120h]
00000001803965ED  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803965F4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803965F8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803965FC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396601  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396608  E8 F3 53 01 00              call    sub_1803ABA00
000000018039660D  48 8D 05 CC 4F 5F 00        lea     rax, aDelayTime; "Delay Time"
0000000180396614  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039661B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039661F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396623  48 8D 87 70 93 41 00        lea     rax, [rdi+419370h]
000000018039662A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396631  0F 57 C0                    xorps   xmm0, xmm0
0000000180396634  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396638  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039663C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396641  E8 BA 53 01 00              call    sub_1803ABA00
0000000180396646  66 0F 6F 05 E2 59 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039664E  48 8D 05 C3 51 5F 00        lea     rax, aHighCutC0; "High Cut C0"
0000000180396655  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396659  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039665D  48 8D 87 80 93 41 00        lea     rax, [rdi+419380h]
0000000180396664  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039666B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039666F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396673  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396678  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039667F  E8 7C 53 01 00              call    sub_1803ABA00
0000000180396684  66 0F 6F 05 A4 59 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039668C  48 8D 05 95 51 5F 00        lea     rax, aHighCutA0; "High Cut A0"
0000000180396693  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396697  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039669B  48 8D 87 90 93 41 00        lea     rax, [rdi+419390h]
00000001803966A2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803966A9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803966AD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803966B1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803966B6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803966BD  E8 3E 53 01 00              call    sub_1803ABA00
00000001803966C2  66 0F 6F 05 66 59 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803966CA  48 8D 05 67 51 5F 00        lea     rax, aHighCutA1; "High Cut A1"
00000001803966D1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803966D5  48 8D 87 A0 93 41 00        lea     rax, [rdi+4193A0h]
00000001803966DC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803966E3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803966E8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803966EF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803966F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803966F7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803966FB  E8 00 53 01 00              call    sub_1803ABA00
0000000180396700  66 0F 6F 05 28 59 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396708  48 8D 05 39 51 5F 00        lea     rax, aHighCutB0; "High Cut B0"
000000018039670F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396713  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396717  48 8D 87 B0 93 41 00        lea     rax, [rdi+4193B0h]
000000018039671E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396725  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396729  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039672D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396732  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396739  E8 C2 52 01 00              call    sub_1803ABA00
000000018039673E  66 0F 6F 05 EA 58 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396746  48 8D 05 0B 51 5F 00        lea     rax, aHighCutB2; "High Cut B2"
000000018039674D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396751  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396755  48 8D 87 C0 93 41 00        lea     rax, [rdi+4193C0h]
000000018039675C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396763  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396767  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039676B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396770  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396777  E8 84 52 01 00              call    sub_1803ABA00
000000018039677C  66 0F 6F 05 AC 58 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396784  48 8D 05 DD 50 5F 00        lea     rax, aUseIirHighCutF; "Use IIR High Cut Filter"
000000018039678B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039678F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396793  48 8D 87 D0 93 41 00        lea     rax, [rdi+4193D0h]
000000018039679A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803967A1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803967A5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803967A9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803967AE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803967B5  E8 46 52 01 00              call    sub_1803ABA00
00000001803967BA  66 0F 6F 05 6E 58 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803967C2  48 8D 05 B7 50 5F 00        lea     rax, aHighCutFc; "High Cut Fc"
00000001803967C9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803967CD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803967D1  48 8D 87 E0 93 41 00        lea     rax, [rdi+4193E0h]
00000001803967D8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803967DF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803967E3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803967E7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803967EC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803967F3  E8 08 52 01 00              call    sub_1803ABA00
00000001803967F8  66 0F 6F 05 30 58 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396800  48 8D 05 89 50 5F 00        lea     rax, aHighCutQc; "High Cut Qc"
0000000180396807  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039680B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039680F  48 8D 87 F0 93 41 00        lea     rax, [rdi+4193F0h]
0000000180396816  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039681D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396821  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396825  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039682A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396831  E8 CA 51 01 00              call    sub_1803ABA00
0000000180396836  66 0F 6F 05 F2 57 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039683E  48 8D 05 5B 50 5F 00        lea     rax, aHighCutSw; "High Cut Sw"
0000000180396845  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396849  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039684D  48 8D 87 00 94 41 00        lea     rax, [rdi+419400h]
0000000180396854  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039685B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039685F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396863  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396868  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039686F  E8 8C 51 01 00              call    sub_1803ABA00
0000000180396874  66 0F 6F 05 B4 57 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039687C  48 8D 05 AD 4D 5F 00        lea     rax, aDryLevel; "Dry Level"
0000000180396883  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396887  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039688B  48 8D 87 10 94 41 00        lea     rax, [rdi+419410h]
0000000180396892  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396899  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039689D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803968A1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803968A6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803968AD  E8 4E 51 01 00              call    sub_1803ABA00
00000001803968B2  66 0F 6F 05 76 57 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803968BA  48 8D 05 7F 4D 5F 00        lea     rax, aWetLevel; "Wet Level"
00000001803968C1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803968C5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803968C9  48 8D 87 20 94 41 00        lea     rax, [rdi+419420h]
00000001803968D0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803968D7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803968DB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803968DF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803968E4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803968EB  E8 10 51 01 00              call    sub_1803ABA00
00000001803968F0  66 0F 6F 05 38 57 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803968F8  48 8D 05 4D 4D 5F 00        lea     rax, aIpFc; "Ip Fc"
00000001803968FF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396903  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396907  48 8D 87 30 94 41 00        lea     rax, [rdi+419430h]
000000018039690E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396915  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396919  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039691D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396922  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396929  E8 D2 50 01 00              call    sub_1803ABA00
000000018039692E  66 0F 6F 05 FA 56 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396936  48 8D 05 E3 4F 5F 00        lea     rax, aTapTime; "Tap Time"
000000018039693D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396941  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396945  48 8D 87 40 94 41 00        lea     rax, [rdi+419440h]
000000018039694C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396953  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396957  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039695B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396960  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396967  E8 94 50 01 00              call    sub_1803ABA00
000000018039696C  66 0F 6F 05 BC 56 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396974  48 8D 05 35 4F 5F 00        lea     rax, aFeedback_0; "Feedback"
000000018039697B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039697F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396983  48 8D 87 50 94 41 00        lea     rax, [rdi+419450h]
000000018039698A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396991  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396995  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396999  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039699E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803969A5  E8 56 50 01 00              call    sub_1803ABA00
00000001803969AA  66 0F 6F 05 7E 56 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803969B2  48 8D 05 9B 4C 5F 00        lea     rax, aOnOff; "On/Off"
00000001803969B9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803969BD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803969C1  48 8D 87 60 94 41 00        lea     rax, [rdi+419460h]
00000001803969C8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803969CF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803969D3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803969D7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803969DC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803969E3  E8 18 50 01 00              call    sub_1803ABA00
00000001803969E8  66 0F 6F 05 40 56 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803969F0  48 8D 05 71 4A 5F 00        lea     rax, aMute; "Mute"
00000001803969F7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803969FB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803969FF  48 8D 87 70 94 41 00        lea     rax, [rdi+419470h]
0000000180396A06  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396A0D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396A11  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396A15  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396A1A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396A21  E8 DA 4F 01 00              call    sub_1803ABA00
0000000180396A26  66 0F 6F 05 02 56 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396A2E  48 8D 05 F7 4E 5F 00        lea     rax, aTapSw; "Tap Sw"
0000000180396A35  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396A39  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396A3D  48 8D 87 80 94 41 00        lea     rax, [rdi+419480h]
0000000180396A44  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396A4B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396A4F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396A53  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396A58  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396A5F  E8 9C 4F 01 00              call    sub_1803ABA00
0000000180396A64  66 0F 6F 05 C4 55 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396A6C  48 8D 05 C5 4E 5F 00        lea     rax, aStereoSw; "Stereo Sw"
0000000180396A73  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396A77  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396A7E  48 8D 87 90 94 41 00        lea     rax, [rdi+419490h]
0000000180396A85  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396A8C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396A90  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396A94  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396A98  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396A9D  E8 5E 4F 01 00              call    sub_1803ABA00
0000000180396AA2  66 0F 6F 05 86 55 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396AAA  48 8D 05 97 4E 5F 00        lea     rax, aWetGain; "Wet Gain"
0000000180396AB1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396AB5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396AB9  48 8D 87 A0 94 41 00        lea     rax, [rdi+4194A0h]
0000000180396AC0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396AC7  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396ACB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396ACF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396AD4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396ADB  E8 20 4F 01 00              call    sub_1803ABA00
0000000180396AE0  66 0F 6F 05 48 55 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396AE8  48 8D 05 D1 4D 5F 00        lea     rax, aLfDampFc; "LF Damp Fc"
0000000180396AEF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396AF3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396AF7  48 8D 87 B0 94 41 00        lea     rax, [rdi+4194B0h]
0000000180396AFE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396B05  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396B09  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396B0D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396B12  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396B19  E8 E2 4E 01 00              call    sub_1803ABA00
0000000180396B1E  66 0F 6F 05 0A 55 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396B26  48 8D 05 A3 4D 5F 00        lea     rax, aLfDampHp; "LF Damp Hp"
0000000180396B2D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396B31  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396B35  48 8D 87 C0 94 41 00        lea     rax, [rdi+4194C0h]
0000000180396B3C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396B43  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396B47  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396B4B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396B50  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396B57  E8 A4 4E 01 00              call    sub_1803ABA00
0000000180396B5C  66 0F 6F 05 CC 54 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396B64  48 8D 05 75 4D 5F 00        lea     rax, aLfDampLp; "LF Damp Lp"
0000000180396B6B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396B6F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396B73  48 8D 87 D0 94 41 00        lea     rax, [rdi+4194D0h]
0000000180396B7A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396B81  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396B85  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396B89  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396B8E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396B95  E8 66 4E 01 00              call    sub_1803ABA00
0000000180396B9A  66 0F 6F 05 8E 54 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396BA2  48 8D 05 47 4D 5F 00        lea     rax, aHfDampFc; "HF Damp Fc"
0000000180396BA9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396BAD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396BB1  48 8D 87 E0 94 41 00        lea     rax, [rdi+4194E0h]
0000000180396BB8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396BBF  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396BC3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396BC7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396BCC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396BD3  E8 28 4E 01 00              call    sub_1803ABA00
0000000180396BD8  66 0F 6F 05 50 54 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396BE0  48 8D 05 19 4D 5F 00        lea     rax, aHfDampHp; "HF Damp Hp"
0000000180396BE7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396BEB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396BEF  48 8D 87 F0 94 41 00        lea     rax, [rdi+4194F0h]
0000000180396BF6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396BFD  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396C01  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396C05  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396C0A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396C11  E8 EA 4D 01 00              call    sub_1803ABA00
0000000180396C16  66 0F 6F 05 12 54 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396C1E  48 8D 05 EB 4C 5F 00        lea     rax, aHfDampLp; "HF Damp Lp"
0000000180396C25  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396C29  48 8D 87 00 95 41 00        lea     rax, [rdi+419500h]
0000000180396C30  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396C34  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396C3B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396C40  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396C47  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396C4B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396C4F  E8 AC 4D 01 00              call    sub_1803ABA00
0000000180396C54  66 0F 6F 05 D4 53 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396C5C  48 8D 05 F5 4C 5F 00        lea     rax, aChorusCv; "Chorus CV"
0000000180396C63  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396C67  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396C6B  48 8D 87 B0 95 61 00        lea     rax, [rdi+6195B0h]
0000000180396C72  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396C79  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396C7D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396C81  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396C86  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396C8D  E8 6E 4D 01 00              call    sub_1803ABA00
0000000180396C92  66 0F 6F 05 96 53 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396C9A  48 8D 05 C7 4C 5F 00        lea     rax, aChrusLfoSync; "Chrus LFO Sync"
0000000180396CA1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396CA5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396CA9  48 8D 87 C0 95 61 00        lea     rax, [rdi+6195C0h]
0000000180396CB0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396CB7  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396CBB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396CBF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396CC4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396CCB  E8 30 4D 01 00              call    sub_1803ABA00
0000000180396CD0  48 8D 05 09 49 5F 00        lea     rax, aDelayTime; "Delay Time"
0000000180396CD7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396CDE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396CE2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396CE6  48 8D 87 E0 98 61 00        lea     rax, [rdi+6198E0h]
0000000180396CED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396CF4  0F 57 C0                    xorps   xmm0, xmm0
0000000180396CF7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396CFB  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396CFF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396D04  E8 F7 4C 01 00              call    sub_1803ABA00
0000000180396D09  66 0F 6F 05 1F 53 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396D11  48 8D 05 60 4C 5F 00        lea     rax, aLfoCurve; "LFO Curve"
0000000180396D18  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396D1C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396D20  48 8D 87 F0 98 61 00        lea     rax, [rdi+6198F0h]
0000000180396D27  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396D2E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396D32  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396D36  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396D3B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396D42  E8 B9 4C 01 00              call    sub_1803ABA00
0000000180396D47  66 0F 6F 05 E1 52 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396D4F  48 8D 05 32 4C 5F 00        lea     rax, aLfoManual; "LFO Manual"
0000000180396D56  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396D5A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396D5E  48 8D 87 00 99 61 00        lea     rax, [rdi+619900h]
0000000180396D65  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396D6C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396D70  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396D74  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396D79  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396D80  E8 7B 4C 01 00              call    sub_1803ABA00
0000000180396D85  66 0F 6F 05 A3 52 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396D8D  48 8D 05 7C 48 5F 00        lea     rax, aLfoDepth; "LFO Depth"
0000000180396D94  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396D98  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396D9C  48 8D 87 10 99 61 00        lea     rax, [rdi+619910h]
0000000180396DA3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396DAA  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396DAE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396DB2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396DB7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396DBE  E8 3D 4C 01 00              call    sub_1803ABA00
0000000180396DC3  66 0F 6F 05 65 52 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396DCB  48 8D 05 46 4A 5F 00        lea     rax, aHighCutC0; "High Cut C0"
0000000180396DD2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396DD6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396DDA  48 8D 87 20 99 61 00        lea     rax, [rdi+619920h]
0000000180396DE1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396DE8  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396DEC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396DF0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396DF5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396DFC  E8 FF 4B 01 00              call    sub_1803ABA00
0000000180396E01  48 8D 05 20 4A 5F 00        lea     rax, aHighCutA0; "High Cut A0"
0000000180396E08  66 0F 6F 05 20 52 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396E10  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396E14  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396E18  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396E1C  48 8D 87 30 99 61 00        lea     rax, [rdi+619930h]
0000000180396E23  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396E2A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396E2E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396E33  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396E3A  E8 C1 4B 01 00              call    sub_1803ABA00
0000000180396E3F  66 0F 6F 05 E9 51 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396E47  48 8D 05 EA 49 5F 00        lea     rax, aHighCutA1; "High Cut A1"
0000000180396E4E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396E52  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396E56  48 8D 87 40 99 61 00        lea     rax, [rdi+619940h]
0000000180396E5D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396E64  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396E68  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396E6C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396E71  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396E78  E8 83 4B 01 00              call    sub_1803ABA00
0000000180396E7D  66 0F 6F 05 AB 51 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396E85  48 8D 05 BC 49 5F 00        lea     rax, aHighCutB0; "High Cut B0"
0000000180396E8C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396E90  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396E94  48 8D 87 50 99 61 00        lea     rax, [rdi+619950h]
0000000180396E9B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396EA2  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396EA6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396EAA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396EAF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396EB6  E8 45 4B 01 00              call    sub_1803ABA00
0000000180396EBB  66 0F 6F 05 6D 51 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396EC3  48 8D 05 8E 49 5F 00        lea     rax, aHighCutB2; "High Cut B2"
0000000180396ECA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396ECE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396ED2  48 8D 87 60 99 61 00        lea     rax, [rdi+619960h]
0000000180396ED9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396EE0  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396EE4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396EE8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396EED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396EF4  E8 07 4B 01 00              call    sub_1803ABA00
0000000180396EF9  66 0F 6F 05 2F 51 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396F01  48 8D 05 60 49 5F 00        lea     rax, aUseIirHighCutF; "Use IIR High Cut Filter"
0000000180396F08  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396F0C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396F10  48 8D 87 70 99 61 00        lea     rax, [rdi+619970h]
0000000180396F17  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396F1E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396F22  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396F26  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396F2B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396F32  E8 C9 4A 01 00              call    sub_1803ABA00
0000000180396F37  66 0F 6F 05 F1 50 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396F3F  48 8D 05 3A 49 5F 00        lea     rax, aHighCutFc; "High Cut Fc"
0000000180396F46  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396F4A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396F4E  48 8D 87 80 99 61 00        lea     rax, [rdi+619980h]
0000000180396F55  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396F5C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396F60  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396F64  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396F69  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396F70  E8 8B 4A 01 00              call    sub_1803ABA00
0000000180396F75  66 0F 6F 05 B3 50 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396F7D  48 8D 05 0C 49 5F 00        lea     rax, aHighCutQc; "High Cut Qc"
0000000180396F84  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396F88  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396F8C  48 8D 87 90 99 61 00        lea     rax, [rdi+619990h]
0000000180396F93  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396F9A  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396F9E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396FA2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396FA7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396FAE  E8 4D 4A 01 00              call    sub_1803ABA00
0000000180396FB3  66 0F 6F 05 75 50 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396FBB  48 8D 05 DE 48 5F 00        lea     rax, aHighCutSw; "High Cut Sw"
0000000180396FC2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180396FC6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180396FCB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180396FD2  48 8D 87 A0 99 61 00        lea     rax, [rdi+6199A0h]
0000000180396FD9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180396FE0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180396FE4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180396FE8  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180396FEC  E8 0F 4A 01 00              call    sub_1803ABA00
0000000180396FF1  66 0F 6F 05 37 50 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180396FF9  48 8D 05 98 49 5F 00        lea     rax, aLowCutFc; "Low Cut Fc"
0000000180397000  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397004  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397008  48 8D 87 B0 99 61 00        lea     rax, [rdi+6199B0h]
000000018039700F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397016  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039701A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039701E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397023  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039702A  E8 D1 49 01 00              call    sub_1803ABA00
000000018039702F  66 0F 6F 05 F9 4F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397037  48 8D 05 6A 49 5F 00        lea     rax, aLowCutSw; "Low Cut Sw"
000000018039703E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397042  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397046  48 8D 87 C0 99 61 00        lea     rax, [rdi+6199C0h]
000000018039704D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397054  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397058  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039705C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397061  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397068  E8 93 49 01 00              call    sub_1803ABA00
000000018039706D  66 0F 6F 05 BB 4F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397075  48 8D 05 B4 45 5F 00        lea     rax, aDryLevel; "Dry Level"
000000018039707C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397080  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397084  48 8D 87 D0 99 61 00        lea     rax, [rdi+6199D0h]
000000018039708B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397092  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397096  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039709A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039709F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803970A6  E8 55 49 01 00              call    sub_1803ABA00
00000001803970AB  66 0F 6F 05 7D 4F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803970B3  48 8D 05 86 45 5F 00        lea     rax, aWetLevel; "Wet Level"
00000001803970BA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803970BE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803970C2  48 8D 87 E0 99 61 00        lea     rax, [rdi+6199E0h]
00000001803970C9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803970D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803970D4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803970D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803970DD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803970E4  E8 17 49 01 00              call    sub_1803ABA00
00000001803970E9  66 0F 6F 05 3F 4F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803970F1  48 8D 05 54 45 5F 00        lea     rax, aIpFc; "Ip Fc"
00000001803970F8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803970FC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397100  48 8D 87 F0 99 61 00        lea     rax, [rdi+6199F0h]
0000000180397107  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039710E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397112  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397116  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039711B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397122  E8 D9 48 01 00              call    sub_1803ABA00
0000000180397127  66 0F 6F 05 01 4F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039712F  48 8D 05 7A 47 5F 00        lea     rax, aFeedback_0; "Feedback"
0000000180397136  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039713A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039713E  48 8D 87 00 9A 61 00        lea     rax, [rdi+619A00h]
0000000180397145  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039714C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397150  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397154  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397159  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397160  E8 9B 48 01 00              call    sub_1803ABA00
0000000180397165  66 0F 6F 05 C3 4E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039716D  48 8D 05 E0 44 5F 00        lea     rax, aOnOff; "On/Off"
0000000180397174  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397178  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039717C  48 8D 87 10 9A 61 00        lea     rax, [rdi+619A10h]
0000000180397183  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039718A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039718E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397193  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039719A  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039719E  E8 5D 48 01 00              call    sub_1803ABA00
00000001803971A3  66 0F 6F 05 85 4E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803971AB  48 8D 05 B6 42 5F 00        lea     rax, aMute; "Mute"
00000001803971B2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803971B6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803971BA  48 8D 87 20 9A 61 00        lea     rax, [rdi+619A20h]
00000001803971C1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803971C8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803971CC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803971D0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803971D5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803971DC  E8 1F 48 01 00              call    sub_1803ABA00
00000001803971E1  66 0F 6F 05 47 4E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803971E9  48 8D 05 3C 47 5F 00        lea     rax, aTapSw; "Tap Sw"
00000001803971F0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803971F4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803971F8  48 8D 87 30 9A 61 00        lea     rax, [rdi+619A30h]
00000001803971FF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397206  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039720A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039720E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397213  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039721A  E8 E1 47 01 00              call    sub_1803ABA00
000000018039721F  66 0F 6F 05 09 4E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397227  48 8D 05 0A 47 5F 00        lea     rax, aStereoSw; "Stereo Sw"
000000018039722E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397232  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397236  48 8D 87 40 9A 61 00        lea     rax, [rdi+619A40h]
000000018039723D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397244  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397248  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039724C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397251  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397258  E8 A3 47 01 00              call    sub_1803ABA00
000000018039725D  66 0F 6F 05 CB 4D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397265  48 8D 05 4C 47 5F 00        lea     rax, aDryGain; "Dry Gain"
000000018039726C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397270  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397274  48 8D 87 50 9A 61 00        lea     rax, [rdi+619A50h]
000000018039727B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397282  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397286  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039728A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039728F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397296  E8 65 47 01 00              call    sub_1803ABA00
000000018039729B  66 0F 6F 05 8D 4D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803972A3  48 8D 05 9E 46 5F 00        lea     rax, aWetGain; "Wet Gain"
00000001803972AA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803972AE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803972B2  48 8D 87 60 9A 61 00        lea     rax, [rdi+619A60h]
00000001803972B9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803972C0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803972C4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803972C8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803972CD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803972D4  E8 27 47 01 00              call    sub_1803ABA00
00000001803972D9  66 0F 6F 05 4F 4D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803972E1  48 8D 05 E0 46 5F 00        lea     rax, aFlangerCv; "Flanger CV"
00000001803972E8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803972EC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803972F0  48 8D 87 20 1B 62 00        lea     rax, [rdi+621B20h]
00000001803972F7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803972FE  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397302  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397306  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039730B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397312  E8 E9 46 01 00              call    sub_1803ABA00
0000000180397317  66 0F 6F 05 11 4D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039731F  48 8D 05 B2 46 5F 00        lea     rax, aFlangerLfoSync; "Flanger LFO Sync"
0000000180397326  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039732A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039732E  48 8D 87 30 1B 62 00        lea     rax, [rdi+621B30h]
0000000180397335  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039733C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397340  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397344  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397349  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397350  E8 AB 46 01 00              call    sub_1803ABA00
0000000180397355  48 8D 05 84 42 5F 00        lea     rax, aDelayTime; "Delay Time"
000000018039735C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397360  0F 57 C0                    xorps   xmm0, xmm0
0000000180397363  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039736A  48 8D 87 00 1F 62 00        lea     rax, [rdi+621F00h]
0000000180397371  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397378  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039737C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397380  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397384  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397389  E8 72 46 01 00              call    sub_1803ABA00
000000018039738E  66 0F 6F 05 9A 4C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397396  48 8D 05 DB 45 5F 00        lea     rax, aLfoCurve; "LFO Curve"
000000018039739D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803973A1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803973A5  48 8D 87 10 1F 62 00        lea     rax, [rdi+621F10h]
00000001803973AC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803973B3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803973B7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803973BB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803973C0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803973C7  E8 34 46 01 00              call    sub_1803ABA00
00000001803973CC  66 0F 6F 05 5C 4C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803973D4  48 8D 05 AD 45 5F 00        lea     rax, aLfoManual; "LFO Manual"
00000001803973DB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803973DF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803973E3  48 8D 87 20 1F 62 00        lea     rax, [rdi+621F20h]
00000001803973EA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803973F1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803973F5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803973F9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803973FE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397405  E8 F6 45 01 00              call    sub_1803ABA00
000000018039740A  66 0F 6F 05 1E 4C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397412  48 8D 05 F7 41 5F 00        lea     rax, aLfoDepth; "LFO Depth"
0000000180397419  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039741D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397421  48 8D 87 30 1F 62 00        lea     rax, [rdi+621F30h]
0000000180397428  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039742F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397433  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397437  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039743C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397443  E8 B8 45 01 00              call    sub_1803ABA00
0000000180397448  66 0F 6F 05 E0 4B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397450  48 8D 05 C1 43 5F 00        lea     rax, aHighCutC0; "High Cut C0"
0000000180397457  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039745B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039745F  48 8D 87 40 1F 62 00        lea     rax, [rdi+621F40h]
0000000180397466  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039746D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397471  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397475  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039747A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397481  E8 7A 45 01 00              call    sub_1803ABA00
0000000180397486  66 0F 6F 05 A2 4B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039748E  48 8D 05 93 43 5F 00        lea     rax, aHighCutA0; "High Cut A0"
0000000180397495  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397499  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039749D  48 8D 87 50 1F 62 00        lea     rax, [rdi+621F50h]
00000001803974A4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803974AB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803974AF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803974B3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803974B8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803974BF  E8 3C 45 01 00              call    sub_1803ABA00
00000001803974C4  66 0F 6F 05 64 4B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803974CC  48 8D 05 65 43 5F 00        lea     rax, aHighCutA1; "High Cut A1"
00000001803974D3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803974D7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803974DB  48 8D 87 60 1F 62 00        lea     rax, [rdi+621F60h]
00000001803974E2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803974E9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803974ED  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803974F1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803974F6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803974FD  E8 FE 44 01 00              call    sub_1803ABA00
0000000180397502  66 0F 6F 05 26 4B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039750A  48 8D 05 37 43 5F 00        lea     rax, aHighCutB0; "High Cut B0"
0000000180397511  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397515  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039751A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397521  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397528  48 8D 87 70 1F 62 00        lea     rax, [rdi+621F70h]
000000018039752F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397533  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397537  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039753B  E8 C0 44 01 00              call    sub_1803ABA00
0000000180397540  66 0F 6F 05 E8 4A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397548  48 8D 05 09 43 5F 00        lea     rax, aHighCutB2; "High Cut B2"
000000018039754F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397553  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397557  48 8D 87 80 1F 62 00        lea     rax, [rdi+621F80h]
000000018039755E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397565  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397569  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039756D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397572  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397579  E8 82 44 01 00              call    sub_1803ABA00
000000018039757E  66 0F 6F 05 AA 4A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397586  48 8D 05 DB 42 5F 00        lea     rax, aUseIirHighCutF; "Use IIR High Cut Filter"
000000018039758D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397591  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397595  48 8D 87 90 1F 62 00        lea     rax, [rdi+621F90h]
000000018039759C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803975A3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803975A7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803975AB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803975B0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803975B7  E8 44 44 01 00              call    sub_1803ABA00
00000001803975BC  66 0F 6F 05 6C 4A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803975C4  48 8D 05 B5 42 5F 00        lea     rax, aHighCutFc; "High Cut Fc"
00000001803975CB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803975CF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803975D3  48 8D 87 A0 1F 62 00        lea     rax, [rdi+621FA0h]
00000001803975DA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803975E1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803975E5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803975E9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803975EE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803975F5  E8 06 44 01 00              call    sub_1803ABA00
00000001803975FA  66 0F 6F 05 2E 4A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397602  48 8D 05 87 42 5F 00        lea     rax, aHighCutQc; "High Cut Qc"
0000000180397609  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039760D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397611  48 8D 87 B0 1F 62 00        lea     rax, [rdi+621FB0h]
0000000180397618  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039761F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397623  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397627  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039762C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397633  E8 C8 43 01 00              call    sub_1803ABA00
0000000180397638  66 0F 6F 05 F0 49 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397640  48 8D 05 59 42 5F 00        lea     rax, aHighCutSw; "High Cut Sw"
0000000180397647  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039764B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039764F  48 8D 87 C0 1F 62 00        lea     rax, [rdi+621FC0h]
0000000180397656  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039765D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397661  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397665  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039766A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397671  E8 8A 43 01 00              call    sub_1803ABA00
0000000180397676  66 0F 6F 05 B2 49 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039767E  48 8D 05 13 43 5F 00        lea     rax, aLowCutFc; "Low Cut Fc"
0000000180397685  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397689  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039768D  48 8D 87 D0 1F 62 00        lea     rax, [rdi+621FD0h]
0000000180397694  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039769B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039769F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803976A3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803976A8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803976AF  E8 4C 43 01 00              call    sub_1803ABA00
00000001803976B4  66 0F 6F 05 74 49 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803976BC  48 8D 05 E5 42 5F 00        lea     rax, aLowCutSw; "Low Cut Sw"
00000001803976C3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803976C7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803976CB  48 8D 87 E0 1F 62 00        lea     rax, [rdi+621FE0h]
00000001803976D2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803976D9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803976DD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803976E1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803976E6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803976ED  E8 0E 43 01 00              call    sub_1803ABA00
00000001803976F2  66 0F 6F 05 36 49 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803976FA  48 8D 05 2F 3F 5F 00        lea     rax, aDryLevel; "Dry Level"
0000000180397701  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397705  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397709  48 8D 87 F0 1F 62 00        lea     rax, [rdi+621FF0h]
0000000180397710  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397717  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039771B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039771F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397724  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039772B  E8 D0 42 01 00              call    sub_1803ABA00
0000000180397730  66 0F 6F 05 F8 48 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397738  48 8D 05 01 3F 5F 00        lea     rax, aWetLevel; "Wet Level"
000000018039773F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397743  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397747  48 8D 87 00 20 62 00        lea     rax, [rdi+622000h]
000000018039774E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397755  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397759  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039775D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397762  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397769  E8 92 42 01 00              call    sub_1803ABA00
000000018039776E  66 0F 6F 05 BA 48 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397776  48 8D 05 CF 3E 5F 00        lea     rax, aIpFc; "Ip Fc"
000000018039777D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397781  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397785  48 8D 87 10 20 62 00        lea     rax, [rdi+622010h]
000000018039778C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397793  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397797  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039779B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803977A0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803977A7  E8 54 42 01 00              call    sub_1803ABA00
00000001803977AC  66 0F 6F 05 7C 48 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803977B4  48 8D 05 F5 40 5F 00        lea     rax, aFeedback_0; "Feedback"
00000001803977BB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803977BF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803977C3  48 8D 87 20 20 62 00        lea     rax, [rdi+622020h]
00000001803977CA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803977D1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803977D5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803977D9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803977DE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803977E5  E8 16 42 01 00              call    sub_1803ABA00
00000001803977EA  66 0F 6F 05 3E 48 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803977F2  48 8D 05 5B 3E 5F 00        lea     rax, aOnOff; "On/Off"
00000001803977F9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803977FD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397801  48 8D 87 30 20 62 00        lea     rax, [rdi+622030h]
0000000180397808  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039780F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397813  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397817  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039781C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397823  E8 D8 41 01 00              call    sub_1803ABA00
0000000180397828  66 0F 6F 05 00 48 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397830  48 8D 05 31 3C 5F 00        lea     rax, aMute; "Mute"
0000000180397837  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039783B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039783F  48 8D 87 40 20 62 00        lea     rax, [rdi+622040h]
0000000180397846  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039784D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397851  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397855  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039785A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397861  E8 9A 41 01 00              call    sub_1803ABA00
0000000180397866  66 0F 6F 05 C2 47 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039786E  48 8D 05 7B 41 5F 00        lea     rax, aLfoStPhase; "LFO St.Phase"
0000000180397875  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397879  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039787D  48 8D 87 50 20 62 00        lea     rax, [rdi+622050h]
0000000180397884  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039788B  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039788F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397893  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397898  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039789F  E8 5C 41 01 00              call    sub_1803ABA00
00000001803978A4  48 8D 05 55 41 5F 00        lea     rax, aLfoStOfst; "LFO St.Ofst"
00000001803978AB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803978B2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803978B6  66 0F 6F 05 72 47 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803978BE  48 8D 87 60 20 62 00        lea     rax, [rdi+622060h]
00000001803978C5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803978C9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803978CD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803978D1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803978D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803978DD  E8 1E 41 01 00              call    sub_1803ABA00
00000001803978E2  48 8D 05 F7 3C 5F 00        lea     rax, aDelayTime; "Delay Time"
00000001803978E9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803978F0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803978F4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803978F8  48 8D 87 90 23 63 00        lea     rax, [rdi+632390h]
00000001803978FF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397906  0F 57 C0                    xorps   xmm0, xmm0
0000000180397909  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039790D  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397911  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397916  E8 E5 40 01 00              call    sub_1803ABA00
000000018039791B  66 0F 6F 05 0D 47 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397923  48 8D 05 EE 3E 5F 00        lea     rax, aHighCutC0; "High Cut C0"
000000018039792A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039792E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397932  48 8D 87 A0 23 63 00        lea     rax, [rdi+6323A0h]
0000000180397939  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397940  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397944  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397948  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039794D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397954  E8 A7 40 01 00              call    sub_1803ABA00
0000000180397959  66 0F 6F 05 CF 46 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397961  48 8D 05 C0 3E 5F 00        lea     rax, aHighCutA0; "High Cut A0"
0000000180397968  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039796C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397970  48 8D 87 B0 23 63 00        lea     rax, [rdi+6323B0h]
0000000180397977  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039797E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397982  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397986  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039798B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397992  E8 69 40 01 00              call    sub_1803ABA00
0000000180397997  66 0F 6F 05 91 46 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039799F  48 8D 05 92 3E 5F 00        lea     rax, aHighCutA1; "High Cut A1"
00000001803979A6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803979AA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803979AE  48 8D 87 C0 23 63 00        lea     rax, [rdi+6323C0h]
00000001803979B5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803979BC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803979C0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803979C4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803979C9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803979D0  E8 2B 40 01 00              call    sub_1803ABA00
00000001803979D5  66 0F 6F 05 53 46 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803979DD  48 8D 05 64 3E 5F 00        lea     rax, aHighCutB0; "High Cut B0"
00000001803979E4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803979E8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803979EC  48 8D 87 D0 23 63 00        lea     rax, [rdi+6323D0h]
00000001803979F3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803979FA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803979FE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397A02  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397A07  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397A0E  E8 ED 3F 01 00              call    sub_1803ABA00
0000000180397A13  66 0F 6F 05 15 46 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397A1B  48 8D 05 36 3E 5F 00        lea     rax, aHighCutB2; "High Cut B2"
0000000180397A22  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397A26  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397A2A  48 8D 87 E0 23 63 00        lea     rax, [rdi+6323E0h]
0000000180397A31  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397A38  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397A3C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397A40  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397A45  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397A4C  E8 AF 3F 01 00              call    sub_1803ABA00
0000000180397A51  66 0F 6F 05 D7 45 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397A59  48 8D 05 08 3E 5F 00        lea     rax, aUseIirHighCutF; "Use IIR High Cut Filter"
0000000180397A60  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397A64  48 8D 87 F0 23 63 00        lea     rax, [rdi+6323F0h]
0000000180397A6B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397A72  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397A77  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397A7E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397A82  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397A86  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397A8A  E8 71 3F 01 00              call    sub_1803ABA00
0000000180397A8F  66 0F 6F 05 99 45 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397A97  48 8D 05 E2 3D 5F 00        lea     rax, aHighCutFc; "High Cut Fc"
0000000180397A9E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397AA2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397AA6  48 8D 87 00 24 63 00        lea     rax, [rdi+632400h]
0000000180397AAD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397AB4  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397AB8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397ABC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397AC1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397AC8  E8 33 3F 01 00              call    sub_1803ABA00
0000000180397ACD  66 0F 6F 05 5B 45 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397AD5  48 8D 05 B4 3D 5F 00        lea     rax, aHighCutQc; "High Cut Qc"
0000000180397ADC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397AE0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397AE4  48 8D 87 10 24 63 00        lea     rax, [rdi+632410h]
0000000180397AEB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397AF2  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397AF6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397AFA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397AFF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397B06  E8 F5 3E 01 00              call    sub_1803ABA00
0000000180397B0B  66 0F 6F 05 1D 45 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397B13  48 8D 05 86 3D 5F 00        lea     rax, aHighCutSw; "High Cut Sw"
0000000180397B1A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397B1E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397B22  48 8D 87 20 24 63 00        lea     rax, [rdi+632420h]
0000000180397B29  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397B30  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397B34  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397B38  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397B3D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397B44  E8 B7 3E 01 00              call    sub_1803ABA00
0000000180397B49  66 0F 6F 05 DF 44 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397B51  48 8D 05 D8 3A 5F 00        lea     rax, aDryLevel; "Dry Level"
0000000180397B58  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397B5C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397B60  48 8D 87 30 24 63 00        lea     rax, [rdi+632430h]
0000000180397B67  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397B6E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397B72  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397B76  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397B7B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397B82  E8 79 3E 01 00              call    sub_1803ABA00
0000000180397B87  66 0F 6F 05 A1 44 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397B8F  48 8D 05 AA 3A 5F 00        lea     rax, aWetLevel; "Wet Level"
0000000180397B96  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397B9A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397B9E  48 8D 87 40 24 63 00        lea     rax, [rdi+632440h]
0000000180397BA5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397BAC  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397BB0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397BB4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397BB9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397BC0  E8 3B 3E 01 00              call    sub_1803ABA00
0000000180397BC5  66 0F 6F 05 63 44 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397BCD  48 8D 05 78 3A 5F 00        lea     rax, aIpFc; "Ip Fc"
0000000180397BD4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397BD8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397BDC  48 8D 87 50 24 63 00        lea     rax, [rdi+632450h]
0000000180397BE3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397BEA  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397BEE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397BF2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397BF7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397BFE  E8 FD 3D 01 00              call    sub_1803ABA00
0000000180397C03  66 0F 6F 05 25 44 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397C0B  48 8D 05 9E 3C 5F 00        lea     rax, aFeedback_0; "Feedback"
0000000180397C12  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397C16  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397C1A  48 8D 87 60 24 63 00        lea     rax, [rdi+632460h]
0000000180397C21  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397C28  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397C2C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397C30  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397C35  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397C3C  E8 BF 3D 01 00              call    sub_1803ABA00
0000000180397C41  66 0F 6F 05 E7 43 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397C49  48 8D 05 04 3A 5F 00        lea     rax, aOnOff; "On/Off"
0000000180397C50  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397C54  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397C58  48 8D 87 70 24 63 00        lea     rax, [rdi+632470h]
0000000180397C5F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397C66  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397C6A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397C6E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397C73  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397C7A  E8 81 3D 01 00              call    sub_1803ABA00
0000000180397C7F  66 0F 6F 05 A9 43 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397C87  48 8D 05 DA 37 5F 00        lea     rax, aMute; "Mute"
0000000180397C8E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397C92  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397C96  48 8D 87 80 24 63 00        lea     rax, [rdi+632480h]
0000000180397C9D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397CA4  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397CA8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397CAC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397CB1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397CB8  E8 43 3D 01 00              call    sub_1803ABA00
0000000180397CBD  66 0F 6F 05 6B 43 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397CC5  48 8D 05 F4 3B 5F 00        lea     rax, aLfDampFc; "LF Damp Fc"
0000000180397CCC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397CD0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397CD4  48 8D 87 90 24 63 00        lea     rax, [rdi+632490h]
0000000180397CDB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397CE2  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397CE6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397CEA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397CEF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397CF6  E8 05 3D 01 00              call    sub_1803ABA00
0000000180397CFB  66 0F 6F 05 2D 43 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397D03  48 8D 05 C6 3B 5F 00        lea     rax, aLfDampHp; "LF Damp Hp"
0000000180397D0A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397D0E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397D12  48 8D 87 A0 24 63 00        lea     rax, [rdi+6324A0h]
0000000180397D19  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397D20  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397D24  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397D28  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397D2D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397D34  E8 C7 3C 01 00              call    sub_1803ABA00
0000000180397D39  66 0F 6F 05 EF 42 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397D41  48 8D 05 98 3B 5F 00        lea     rax, aLfDampLp; "LF Damp Lp"
0000000180397D48  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397D4C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397D50  48 8D 87 B0 24 63 00        lea     rax, [rdi+6324B0h]
0000000180397D57  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397D5E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397D62  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397D66  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397D6B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397D72  E8 89 3C 01 00              call    sub_1803ABA00
0000000180397D77  66 0F 6F 05 B1 42 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397D7F  48 8D 05 6A 3B 5F 00        lea     rax, aHfDampFc; "HF Damp Fc"
0000000180397D86  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397D8A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397D8E  48 8D 87 C0 24 63 00        lea     rax, [rdi+6324C0h]
0000000180397D95  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397D9C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397DA0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397DA4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397DA9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397DB0  E8 4B 3C 01 00              call    sub_1803ABA00
0000000180397DB5  66 0F 6F 05 73 42 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397DBD  48 8D 05 3C 3B 5F 00        lea     rax, aHfDampHp; "HF Damp Hp"
0000000180397DC4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397DC8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397DCC  48 8D 87 D0 24 63 00        lea     rax, [rdi+6324D0h]
0000000180397DD3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397DDA  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397DDE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397DE2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397DE7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397DEE  E8 0D 3C 01 00              call    sub_1803ABA00
0000000180397DF3  66 0F 6F 05 35 42 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397DFB  48 8D 05 0E 3B 5F 00        lea     rax, aHfDampLp; "HF Damp Lp"
0000000180397E02  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397E06  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397E0D  48 8D 87 E0 24 63 00        lea     rax, [rdi+6324E0h]
0000000180397E14  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397E1B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397E1F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397E23  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397E27  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397E2C  E8 CF 3B 01 00              call    sub_1803ABA00
0000000180397E31  66 0F 6F 05 F7 41 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397E39  48 8D 05 18 3B 5F 00        lea     rax, aChorusCv; "Chorus CV"
0000000180397E40  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397E44  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397E48  48 8D 87 B0 25 A3 00        lea     rax, [rdi+0A325B0h]
0000000180397E4F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397E56  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397E5A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397E5E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397E63  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397E6A  E8 91 3B 01 00              call    sub_1803ABA00
0000000180397E6F  66 0F 6F 05 B9 41 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397E77  48 8D 05 EA 3A 5F 00        lea     rax, aChrusLfoSync; "Chrus LFO Sync"
0000000180397E7E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397E82  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397E86  48 8D 87 C0 25 A3 00        lea     rax, [rdi+0A325C0h]
0000000180397E8D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397E94  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397E98  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397E9C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397EA1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397EA8  E8 53 3B 01 00              call    sub_1803ABA00
0000000180397EAD  48 8D 05 2C 37 5F 00        lea     rax, aDelayTime; "Delay Time"
0000000180397EB4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397EBB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397EBF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397EC3  48 8D 87 90 29 A3 00        lea     rax, [rdi+0A32990h]
0000000180397ECA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397ED1  0F 57 C0                    xorps   xmm0, xmm0
0000000180397ED4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397ED8  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397EDC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397EE1  E8 1A 3B 01 00              call    sub_1803ABA00
0000000180397EE6  66 0F 6F 05 42 41 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397EEE  48 8D 05 83 3A 5F 00        lea     rax, aLfoCurve; "LFO Curve"
0000000180397EF5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397EF9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397EFD  48 8D 87 A0 29 A3 00        lea     rax, [rdi+0A329A0h]
0000000180397F04  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397F0B  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397F0F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397F13  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397F18  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397F1F  E8 DC 3A 01 00              call    sub_1803ABA00
0000000180397F24  66 0F 6F 05 04 41 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397F2C  48 8D 05 55 3A 5F 00        lea     rax, aLfoManual; "LFO Manual"
0000000180397F33  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397F37  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397F3B  48 8D 87 B0 29 A3 00        lea     rax, [rdi+0A329B0h]
0000000180397F42  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397F49  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397F4D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397F51  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397F56  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397F5D  E8 9E 3A 01 00              call    sub_1803ABA00
0000000180397F62  66 0F 6F 05 C6 40 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397F6A  48 8D 05 9F 36 5F 00        lea     rax, aLfoDepth; "LFO Depth"
0000000180397F71  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397F75  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397F79  48 8D 87 C0 29 A3 00        lea     rax, [rdi+0A329C0h]
0000000180397F80  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397F87  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397F8B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397F8F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397F94  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397F9B  E8 60 3A 01 00              call    sub_1803ABA00
0000000180397FA0  66 0F 6F 05 88 40 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397FA8  48 8D 05 69 38 5F 00        lea     rax, aHighCutC0; "High Cut C0"
0000000180397FAF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397FB3  48 8D 87 D0 29 A3 00        lea     rax, [rdi+0A329D0h]
0000000180397FBA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180397FBE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180397FC5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180397FCA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180397FD1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397FD5  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180397FD9  E8 22 3A 01 00              call    sub_1803ABA00
0000000180397FDE  66 0F 6F 05 4A 40 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180397FE6  48 8D 05 3B 38 5F 00        lea     rax, aHighCutA0; "High Cut A0"
0000000180397FED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180397FF1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180397FF5  48 8D 87 E0 29 A3 00        lea     rax, [rdi+0A329E0h]
0000000180397FFC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398003  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398007  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039800B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398010  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398017  E8 E4 39 01 00              call    sub_1803ABA00
000000018039801C  66 0F 6F 05 0C 40 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398024  48 8D 05 0D 38 5F 00        lea     rax, aHighCutA1; "High Cut A1"
000000018039802B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039802F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398033  48 8D 87 F0 29 A3 00        lea     rax, [rdi+0A329F0h]
000000018039803A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398041  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398045  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398049  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039804E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398055  E8 A6 39 01 00              call    sub_1803ABA00
000000018039805A  66 0F 6F 05 CE 3F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398062  48 8D 05 DF 37 5F 00        lea     rax, aHighCutB0; "High Cut B0"
0000000180398069  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039806D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398071  48 8D 87 00 2A A3 00        lea     rax, [rdi+0A32A00h]
0000000180398078  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039807F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398083  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398087  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039808C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398093  E8 68 39 01 00              call    sub_1803ABA00
0000000180398098  66 0F 6F 05 90 3F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803980A0  48 8D 05 B1 37 5F 00        lea     rax, aHighCutB2; "High Cut B2"
00000001803980A7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803980AB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803980AF  48 8D 87 10 2A A3 00        lea     rax, [rdi+0A32A10h]
00000001803980B6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803980BD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803980C1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803980C5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803980CA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803980D1  E8 2A 39 01 00              call    sub_1803ABA00
00000001803980D6  66 0F 6F 05 52 3F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803980DE  48 8D 05 83 37 5F 00        lea     rax, aUseIirHighCutF; "Use IIR High Cut Filter"
00000001803980E5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803980E9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803980ED  48 8D 87 20 2A A3 00        lea     rax, [rdi+0A32A20h]
00000001803980F4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803980FB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803980FF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398103  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398108  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039810F  E8 EC 38 01 00              call    sub_1803ABA00
0000000180398114  66 0F 6F 05 14 3F 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039811C  48 8D 05 5D 37 5F 00        lea     rax, aHighCutFc; "High Cut Fc"
0000000180398123  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398127  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039812B  48 8D 87 30 2A A3 00        lea     rax, [rdi+0A32A30h]
0000000180398132  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398139  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039813D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398141  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398146  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039814D  E8 AE 38 01 00              call    sub_1803ABA00
0000000180398152  66 0F 6F 05 D6 3E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039815A  48 8D 05 2F 37 5F 00        lea     rax, aHighCutQc; "High Cut Qc"
0000000180398161  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398165  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398169  48 8D 87 40 2A A3 00        lea     rax, [rdi+0A32A40h]
0000000180398170  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398177  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039817B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039817F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398184  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039818B  E8 70 38 01 00              call    sub_1803ABA00
0000000180398190  48 8D 05 09 37 5F 00        lea     rax, aHighCutSw; "High Cut Sw"
0000000180398197  66 0F 6F 05 91 3E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039819F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803981A3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803981A7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803981AB  48 8D 87 50 2A A3 00        lea     rax, [rdi+0A32A50h]
00000001803981B2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803981B9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803981BD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803981C2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803981C9  E8 32 38 01 00              call    sub_1803ABA00
00000001803981CE  66 0F 6F 05 5A 3E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803981D6  48 8D 05 BB 37 5F 00        lea     rax, aLowCutFc; "Low Cut Fc"
00000001803981DD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803981E1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803981E5  48 8D 87 60 2A A3 00        lea     rax, [rdi+0A32A60h]
00000001803981EC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803981F3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803981F7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803981FB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398200  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398207  E8 F4 37 01 00              call    sub_1803ABA00
000000018039820C  66 0F 6F 05 1C 3E 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398214  48 8D 05 8D 37 5F 00        lea     rax, aLowCutSw; "Low Cut Sw"
000000018039821B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039821F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398223  48 8D 87 70 2A A3 00        lea     rax, [rdi+0A32A70h]
000000018039822A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398231  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398235  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398239  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039823E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398245  E8 B6 37 01 00              call    sub_1803ABA00
000000018039824A  66 0F 6F 05 DE 3D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398252  48 8D 05 D7 33 5F 00        lea     rax, aDryLevel; "Dry Level"
0000000180398259  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039825D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398261  48 8D 87 80 2A A3 00        lea     rax, [rdi+0A32A80h]
0000000180398268  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039826F  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398273  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398277  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039827C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398283  E8 78 37 01 00              call    sub_1803ABA00
0000000180398288  66 0F 6F 05 A0 3D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398290  48 8D 05 A9 33 5F 00        lea     rax, aWetLevel; "Wet Level"
0000000180398297  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039829B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039829F  48 8D 87 90 2A A3 00        lea     rax, [rdi+0A32A90h]
00000001803982A6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803982AD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803982B1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803982B5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803982BA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803982C1  E8 3A 37 01 00              call    sub_1803ABA00
00000001803982C6  66 0F 6F 05 62 3D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803982CE  48 8D 05 77 33 5F 00        lea     rax, aIpFc; "Ip Fc"
00000001803982D5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803982D9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803982DD  48 8D 87 A0 2A A3 00        lea     rax, [rdi+0A32AA0h]
00000001803982E4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803982EB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803982EF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803982F3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803982F8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803982FF  E8 FC 36 01 00              call    sub_1803ABA00
0000000180398304  66 0F 6F 05 24 3D 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039830C  48 8D 05 9D 35 5F 00        lea     rax, aFeedback_0; "Feedback"
0000000180398313  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398317  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039831B  48 8D 87 B0 2A A3 00        lea     rax, [rdi+0A32AB0h]
0000000180398322  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398329  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039832D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398331  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398336  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039833D  E8 BE 36 01 00              call    sub_1803ABA00
0000000180398342  66 0F 6F 05 E6 3C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039834A  48 8D 05 03 33 5F 00        lea     rax, aOnOff; "On/Off"
0000000180398351  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398355  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039835A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398361  48 8D 87 C0 2A A3 00        lea     rax, [rdi+0A32AC0h]
0000000180398368  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039836F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398373  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398377  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039837B  E8 80 36 01 00              call    sub_1803ABA00
0000000180398380  66 0F 6F 05 A8 3C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398388  48 8D 05 D9 30 5F 00        lea     rax, aMute; "Mute"
000000018039838F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398393  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398397  48 8D 87 D0 2A A3 00        lea     rax, [rdi+0A32AD0h]
000000018039839E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803983A5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803983A9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803983AD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803983B2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803983B9  E8 42 36 01 00              call    sub_1803ABA00
00000001803983BE  66 0F 6F 05 6A 3C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803983C6  48 8D 05 23 36 5F 00        lea     rax, aLfoStPhase; "LFO St.Phase"
00000001803983CD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803983D1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803983D5  48 8D 87 E0 2A A3 00        lea     rax, [rdi+0A32AE0h]
00000001803983DC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803983E3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803983E7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803983EB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803983F0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803983F7  E8 04 36 01 00              call    sub_1803ABA00
00000001803983FC  66 0F 6F 05 2C 3C 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398404  48 8D 05 F5 35 5F 00        lea     rax, aLfoStOfst; "LFO St.Ofst"
000000018039840B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039840F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398413  48 8D 87 F0 2A A3 00        lea     rax, [rdi+0A32AF0h]
000000018039841A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398421  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398425  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398429  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039842E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398435  E8 C6 35 01 00              call    sub_1803ABA00
000000018039843A  48 8D 05 CF 35 5F 00        lea     rax, aRevDpmPredly; "Rev Dpm PreDly"
0000000180398441  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398448  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039844C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398450  48 8D 87 C0 2C A4 00        lea     rax, [rdi+0A42CC0h]
0000000180398457  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039845E  0F 57 C0                    xorps   xmm0, xmm0
0000000180398461  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398465  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398469  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039846E  E8 CD 35 01 00              call    sub_1803ABA40
0000000180398473  66 0F 6F 05 B5 3B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039847B  48 8D 05 9E 35 5F 00        lea     rax, aRevEcfOn; "Rev Ecf On"
0000000180398482  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398486  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039848A  48 8D 87 D0 2C A4 00        lea     rax, [rdi+0A42CD0h]
0000000180398491  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398498  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039849C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803984A0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803984A5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803984AC  E8 8F 35 01 00              call    sub_1803ABA40
00000001803984B1  66 0F 6F 05 77 3B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803984B9  48 8D 05 70 35 5F 00        lea     rax, aRevEcfDensity; "Rev Ecf Density"
00000001803984C0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803984C4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803984C8  48 8D 87 E0 2C A4 00        lea     rax, [rdi+0A42CE0h]
00000001803984CF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803984D6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803984DA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803984DE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803984E3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803984EA  E8 51 35 01 00              call    sub_1803ABA40
00000001803984EF  66 0F 6F 05 39 3B 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803984F7  48 8D 05 42 35 5F 00        lea     rax, aRevEcfLevel; "Rev Ecf Level"
00000001803984FE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398502  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398506  48 8D 87 F0 2C A4 00        lea     rax, [rdi+0A42CF0h]
000000018039850D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398514  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398518  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039851D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398524  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398528  E8 13 35 01 00              call    sub_1803ABA40
000000018039852D  66 0F 6F 05 FB 3A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398535  48 8D 05 14 35 5F 00        lea     rax, aRevEcfDirLev; "Rev Ecf Dir Lev"
000000018039853C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398540  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398544  48 8D 87 00 2D A4 00        lea     rax, [rdi+0A42D00h]
000000018039854B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398552  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398556  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039855A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039855F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398566  E8 D5 34 01 00              call    sub_1803ABA40
000000018039856B  66 0F 6F 05 BD 3A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398573  48 8D 05 E6 34 5F 00        lea     rax, aRevEcfGlbLev; "Rev Ecf Glb Lev"
000000018039857A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039857E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398582  48 8D 87 10 2D A4 00        lea     rax, [rdi+0A42D10h]
0000000180398589  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398590  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398594  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398598  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039859D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803985A4  E8 97 34 01 00              call    sub_1803ABA40
00000001803985A9  66 0F 6F 05 7F 3A 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803985B1  48 8D 05 B8 34 5F 00        lea     rax, aRevEcfMute; "Rev Ecf Mute"
00000001803985B8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803985BC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803985C0  48 8D 87 20 2D A4 00        lea     rax, [rdi+0A42D20h]
00000001803985C7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803985CE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803985D2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803985D6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803985DB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803985E2  E8 59 34 01 00              call    sub_1803ABA40
00000001803985E7  F3 0F 10 05 89 26 5F 00     movss   xmm0, cs:dword_18098AC78
00000001803985EF  48 8D 05 8A 34 5F 00        lea     rax, aRevEcfInAtt; "Rev Ecf In Att "
00000001803985F6  66 0F 6F 0D 32 3A 5F 00     movdqa  xmm1, cs:xmmword_18098C030
00000001803985FE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398602  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398606  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039860A  48 8D 87 30 2D A4 00        lea     rax, [rdi+0A42D30h]
0000000180398611  F3 0F 11 45 8F              movss   [rbp+57h+var_C8], xmm0
0000000180398616  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039861A  F3 0F 7F 4D 93              movdqu  [rbp+57h+var_C4], xmm1
000000018039861F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398626  E8 15 34 01 00              call    sub_1803ABA40
000000018039862B  66 0F 6F 05 FD 39 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398633  48 8D 05 56 34 5F 00        lea     rax, aRevEcfDepth; "Rev Ecf Depth"
000000018039863A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039863E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398642  48 8D 87 40 2D A4 00        lea     rax, [rdi+0A42D40h]
0000000180398649  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398650  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398654  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398658  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039865D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398664  E8 D7 33 01 00              call    sub_1803ABA40
0000000180398669  F3 0F 10 05 F3 35 5F 00     movss   xmm0, cs:dword_18098BC64
0000000180398671  48 8D 05 28 34 5F 00        lea     rax, aRevEcfRate; "Rev Ecf Rate"
0000000180398678  66 0F 6F 0D B0 39 5F 00     movdqa  xmm1, cs:xmmword_18098C030
0000000180398680  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398684  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398688  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039868C  48 8D 87 50 2D A4 00        lea     rax, [rdi+0A42D50h]
0000000180398693  F3 0F 11 45 8F              movss   [rbp+57h+var_C8], xmm0
0000000180398698  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039869C  F3 0F 7F 4D 93              movdqu  [rbp+57h+var_C4], xmm1
00000001803986A1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803986A8  E8 93 33 01 00              call    sub_1803ABA40
00000001803986AD  66 0F 6F 05 7B 39 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803986B5  48 8D 05 F4 33 5F 00        lea     rax, aRevEcfHpfC0; "Rev Ecf HPF C0"
00000001803986BC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803986C0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803986C4  48 8D 87 60 2D A4 00        lea     rax, [rdi+0A42D60h]
00000001803986CB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803986D2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803986D6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803986DA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803986DF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803986E6  E8 55 33 01 00              call    sub_1803ABA40
00000001803986EB  66 0F 6F 05 3D 39 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803986F3  48 8D 05 C6 33 5F 00        lea     rax, aRevEcfHpfA0; "Rev Ecf HPF A0"
00000001803986FA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803986FE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398702  48 8D 87 70 2D A4 00        lea     rax, [rdi+0A42D70h]
0000000180398709  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398710  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398714  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398718  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039871D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398724  E8 17 33 01 00              call    sub_1803ABA40
0000000180398729  66 0F 6F 05 FF 38 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398731  48 8D 05 98 33 5F 00        lea     rax, aRevEcfHpfB0; "Rev Ecf HPF B0"
0000000180398738  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039873C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398740  48 8D 87 80 2D A4 00        lea     rax, [rdi+0A42D80h]
0000000180398747  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039874E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398752  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398756  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039875B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398762  E8 D9 32 01 00              call    sub_1803ABA40
0000000180398767  66 0F 6F 05 C1 38 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039876F  48 8D 05 6A 33 5F 00        lea     rax, aRevEcfLpfC0; "Rev Ecf LPF C0"
0000000180398776  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039877A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039877E  48 8D 87 90 2D A4 00        lea     rax, [rdi+0A42D90h]
0000000180398785  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039878C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398790  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398794  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398799  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803987A0  E8 9B 32 01 00              call    sub_1803ABA40
00000001803987A5  66 0F 6F 05 83 38 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803987AD  48 8D 05 3C 33 5F 00        lea     rax, aRevEcfLpfA0; "Rev Ecf LPF A0"
00000001803987B4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803987B8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803987BC  48 8D 87 A0 2D A4 00        lea     rax, [rdi+0A42DA0h]
00000001803987C3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803987CA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803987CE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803987D2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803987D7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803987DE  E8 5D 32 01 00              call    sub_1803ABA40
00000001803987E3  66 0F 6F 05 45 38 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803987EB  48 8D 05 0E 33 5F 00        lea     rax, aRevEcfLpfA1; "Rev Ecf LPF A1"
00000001803987F2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803987F6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803987FA  48 8D 87 B0 2D A4 00        lea     rax, [rdi+0A42DB0h]
0000000180398801  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398808  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039880C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398810  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398815  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039881C  E8 1F 32 01 00              call    sub_1803ABA40
0000000180398821  66 0F 6F 05 07 38 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398829  48 8D 05 E0 32 5F 00        lea     rax, aRevEcfLpfB0; "Rev Ecf LPF B0"
0000000180398830  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398834  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398838  48 8D 87 C0 2D A4 00        lea     rax, [rdi+0A42DC0h]
000000018039883F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398846  48 8D 4F 38                 lea     rcx, [rdi+38h]
000000018039884A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039884E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398853  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
000000018039885A  E8 E1 31 01 00              call    sub_1803ABA40
000000018039885F  66 0F 6F 05 C9 37 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398867  48 8D 05 B2 32 5F 00        lea     rax, aRevEcfLpfB1; "Rev Ecf LPF B1"
000000018039886E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398872  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398876  48 8D 87 D0 2D A4 00        lea     rax, [rdi+0A42DD0h]
000000018039887D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398884  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398888  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
000000018039888C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398891  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398898  E8 A3 31 01 00              call    sub_1803ABA40
000000018039889D  66 0F 6F 05 8B 37 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803988A5  48 8D 05 84 32 5F 00        lea     rax, aRevEcfDpf0Fc; "Rev Ecf DPF0 Fc"
00000001803988AC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803988B0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803988B7  48 8D 87 E0 2D A4 00        lea     rax, [rdi+0A42DE0h]
00000001803988BE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803988C5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803988C9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803988CD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803988D1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803988D6  E8 65 31 01 00              call    sub_1803ABA40
00000001803988DB  66 0F 6F 05 4D 37 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803988E3  48 8D 05 56 32 5F 00        lea     rax, aRevEcfDpf0Hp; "Rev Ecf DPF0 Hp"
00000001803988EA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803988EE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803988F2  48 8D 87 F0 2D A4 00        lea     rax, [rdi+0A42DF0h]
00000001803988F9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398900  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398904  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398908  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039890D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398914  E8 27 31 01 00              call    sub_1803ABA40
0000000180398919  66 0F 6F 05 0F 37 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398921  48 8D 05 28 32 5F 00        lea     rax, aRevEcfDpf0Lp; "Rev Ecf DPF0 Lp"
0000000180398928  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039892C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398930  48 8D 87 00 2E A4 00        lea     rax, [rdi+0A42E00h]
0000000180398937  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039893E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398942  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398946  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
000000018039894B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398952  E8 E9 30 01 00              call    sub_1803ABA40
0000000180398957  66 0F 6F 05 D1 36 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039895F  48 8D 05 FA 31 5F 00        lea     rax, aRevEcfDpf1Fc; "Rev Ecf DPF1 Fc"
0000000180398966  48 89 45 87                 mov     [rbp+57h+var_D0], rax
000000018039896A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
000000018039896E  48 8D 87 10 2E A4 00        lea     rax, [rdi+0A42E10h]
0000000180398975  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
000000018039897C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398980  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398984  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398989  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398990  E8 AB 30 01 00              call    sub_1803ABA40
0000000180398995  66 0F 6F 05 93 36 5F 00     movdqa  xmm0, cs:xmmword_18098C030
000000018039899D  48 8D 05 CC 31 5F 00        lea     rax, aRevEcfDpf1Hp; "Rev Ecf DPF1 Hp"
00000001803989A4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803989A8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803989AC  48 8D 87 20 2E A4 00        lea     rax, [rdi+0A42E20h]
00000001803989B3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803989BA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803989BE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00000001803989C2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00000001803989C7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00000001803989CE  E8 6D 30 01 00              call    sub_1803ABA40
00000001803989D3  66 0F 6F 05 55 36 5F 00     movdqa  xmm0, cs:xmmword_18098C030
00000001803989DB  48 8D 05 9E 31 5F 00        lea     rax, aRevEcfDpf1Lp; "Rev Ecf DPF1 Lp"
00000001803989E2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00000001803989E6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00000001803989EA  48 8D 87 30 2E A4 00        lea     rax, [rdi+0A42E30h]
00000001803989F1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00000001803989F8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00000001803989FC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398A00  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398A05  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398A0C  E8 2F 30 01 00              call    sub_1803ABA40
0000000180398A11  66 0F 6F 05 17 36 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398A19  48 8D 05 70 31 5F 00        lea     rax, aRevEcfDpf2Fc; "Rev Ecf DPF2 Fc"
0000000180398A20  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398A24  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398A28  48 8D 87 40 2E A4 00        lea     rax, [rdi+0A42E40h]
0000000180398A2F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398A36  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398A3A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398A3E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398A43  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398A4A  E8 F1 2F 01 00              call    sub_1803ABA40
0000000180398A4F  66 0F 6F 05 D9 35 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398A57  48 8D 05 42 31 5F 00        lea     rax, aRevEcfDpf2Hp; "Rev Ecf DPF2 Hp"
0000000180398A5E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398A62  48 8D 87 50 2E A4 00        lea     rax, [rdi+0A42E50h]
0000000180398A69  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398A6D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398A74  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398A79  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398A80  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398A84  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398A88  E8 B3 2F 01 00              call    sub_1803ABA40
0000000180398A8D  66 0F 6F 05 9B 35 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398A95  48 8D 05 14 31 5F 00        lea     rax, aRevEcfDpf2Lp; "Rev Ecf DPF2 Lp"
0000000180398A9C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398AA0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398AA4  48 8D 87 60 2E A4 00        lea     rax, [rdi+0A42E60h]
0000000180398AAB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398AB2  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398AB6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398ABA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398ABF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398AC6  E8 75 2F 01 00              call    sub_1803ABA40
0000000180398ACB  66 0F 6F 05 5D 35 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398AD3  48 8D 05 E6 30 5F 00        lea     rax, aRevEcfDpf3Fc; "Rev Ecf DPF3 Fc"
0000000180398ADA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398ADE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398AE2  48 8D 87 70 2E A4 00        lea     rax, [rdi+0A42E70h]
0000000180398AE9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398AF0  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398AF4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398AF8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398AFD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398B04  E8 37 2F 01 00              call    sub_1803ABA40
0000000180398B09  66 0F 6F 05 1F 35 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398B11  48 8D 05 B8 30 5F 00        lea     rax, aRevEcfDpf3Hp; "Rev Ecf DPF3 Hp"
0000000180398B18  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398B1C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398B20  48 8D 87 80 2E A4 00        lea     rax, [rdi+0A42E80h]
0000000180398B27  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398B2E  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398B32  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398B36  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398B3B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398B42  E8 F9 2E 01 00              call    sub_1803ABA40
0000000180398B47  66 0F 6F 05 E1 34 5F 00     movdqa  xmm0, cs:xmmword_18098C030
0000000180398B4F  48 8D 05 8A 30 5F 00        lea     rax, aRevEcfDpf3Lp; "Rev Ecf DPF3 Lp"
0000000180398B56  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398B5A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398B5E  48 8D 87 90 2E A4 00        lea     rax, [rdi+0A42E90h]
0000000180398B65  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
0000000180398B6C  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398B70  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398B74  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
0000000180398B79  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398B80  E8 BB 2E 01 00              call    sub_1803ABA40
0000000180398B85  F3 0F 10 05 8F 32 5F 00     movss   xmm0, cs:dword_18098BE1C
0000000180398B8D  48 8D 05 5C 30 5F 00        lea     rax, aRevEcfDlymute; "Rev Ecf DlyMute"
0000000180398B94  66 0F 6F 0D 94 34 5F 00     movdqa  xmm1, cs:xmmword_18098C030
0000000180398B9C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
0000000180398BA0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
0000000180398BA4  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398BA8  48 8D 87 A0 2E A4 00        lea     rax, [rdi+0A42EA0h]
0000000180398BAF  F3 0F 11 45 8F              movss   [rbp+57h+var_C8], xmm0
0000000180398BB4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
0000000180398BB8  F3 0F 7F 4D 93              movdqu  [rbp+57h+var_C4], xmm1
0000000180398BBD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
0000000180398BC4  E8 77 2E 01 00              call    sub_1803ABA40
0000000180398BC9  48 8D 4F 38                 lea     rcx, [rdi+38h]
0000000180398BCD  E8 AE 2E 01 00              call    sub_1803ABA80
0000000180398BD2  4C 8D 9C 24 F0 00 00 00     lea     r11, [rsp+0F0h+var_s0]
0000000180398BDA  89 47 50                    mov     [rdi+50h], eax
0000000180398BDD  49 8B 5B 20                 mov     rbx, [r11+20h]
0000000180398BE1  49 8B 7B 28                 mov     rdi, [r11+28h]
0000000180398BE5  49 8B E3                    mov     rsp, r11
0000000180398BE8  5D                          pop     rbp
0000000180398BE9  C3                          retn
