; sub_7FF91DFE8170 @ 0x7FF91DFE8170 (RVA 0x7FF79DFE8170)

00007FF91DFE8170  48 89 5C 24 18              mov     [rsp-8+arg_10], rbx
00007FF91DFE8175  48 89 7C 24 20              mov     [rsp-8+arg_18], rdi
00007FF91DFE817A  55                          push    rbp
00007FF91DFE817B  48 8D 6C 24 A9              lea     rbp, [rsp-57h]
00007FF91DFE8180  48 81 EC F0 00 00 00        sub     rsp, 0F0h
00007FF91DFE8187  48 8B 51 48                 mov     rdx, [rcx+48h]
00007FF91DFE818B  48 B8 67 66 66 66 66 66 66 66  mov     rax, 6666666666666667h
00007FF91DFE8195  48 2B 51 38                 sub     rdx, [rcx+38h]
00007FF91DFE8199  48 8B F9                    mov     rdi, rcx
00007FF91DFE819C  48 F7 EA                    imul    rdx
00007FF91DFE819F  48 C1 FA 04                 sar     rdx, 4
00007FF91DFE81A3  48 8B C2                    mov     rax, rdx
00007FF91DFE81A6  48 C1 E8 3F                 shr     rax, 3Fh
00007FF91DFE81AA  48 03 D0                    add     rdx, rax
00007FF91DFE81AD  48 81 FA 61 04 00 00        cmp     rdx, 461h
00007FF91DFE81B4  73 2A                       jnb     short loc_7FF91DFE81E0
00007FF91DFE81B6  48 B8 66 66 66 66 66 66 66 06  mov     rax, 666666666666666h
00007FF91DFE81C0  BA 61 04 00 00              mov     edx, 461h
00007FF91DFE81C5  48 89 45 67                 mov     [rbp+57h+arg_0], rax
00007FF91DFE81C9  48 83 C1 38                 add     rcx, 38h ; '8'
00007FF91DFE81CD  48 B8 FF FF FF FF FF FF FF 7F  mov     rax, 7FFFFFFFFFFFFFFFh
00007FF91DFE81D7  48 89 45 6F                 mov     [rbp+57h+arg_8], rax
00007FF91DFE81DB  E8 20 35 02 00              call    sub_7FF91E00B700
00007FF91DFE81E0  48 8D 05 39 2D 60 00        lea     rax, aUseextjack; "UseExtJack"
00007FF91DFE81E7  C7 45 B7 00 00 00 00        mov     dword ptr [rbp+57h+var_A8+8], 0
00007FF91DFE81EE  48 89 45 AF                 mov     qword ptr [rbp+57h+var_A8], rax
00007FF91DFE81F2  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFE81F5  F3 0F 7F 4D BB              movdqu  [rbp+57h+var_A8+0Ch], xmm1
00007FF91DFE81FA  C7 45 CB 01 00 00 00        mov     [rbp+57h+var_8C], 1
00007FF91DFE8201  48 8D 87 10 01 00 00        lea     rax, [rdi+110h]
00007FF91DFE8208  48 89 45 CF                 mov     [rbp+57h+var_88], rax
00007FF91DFE820C  48 8B 57 40                 mov     rdx, [rdi+40h]
00007FF91DFE8210  48 39 57 48                 cmp     [rdi+48h], rdx
00007FF91DFE8214  74 20                       jz      short loc_7FF91DFE8236
00007FF91DFE8216  0F 10 45 AF                 movups  xmm0, [rbp+57h+var_A8]
00007FF91DFE821A  0F 11 02                    movups  xmmword ptr [rdx], xmm0
00007FF91DFE821D  0F 10 4D BF                 movups  xmm1, xmmword ptr [rbp-41h]
00007FF91DFE8221  0F 11 4A 10                 movups  xmmword ptr [rdx+10h], xmm1
00007FF91DFE8225  F2 0F 10 45 CF              movsd   xmm0, [rbp+57h+var_88]
00007FF91DFE822A  F2 0F 11 42 20              movsd   qword ptr [rdx+20h], xmm0
00007FF91DFE822F  48 83 47 40 28              add     qword ptr [rdi+40h], 28h ; '('
00007FF91DFE8234  EB 0D                       jmp     short loc_7FF91DFE8243
00007FF91DFE8236  4C 8D 45 AF                 lea     r8, [rbp+57h+var_A8]
00007FF91DFE823A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE823E  E8 3D FD FF FF              call    sub_7FF91DFE7F80
00007FF91DFE8243  48 8D 05 E2 2C 60 00        lea     rax, aMCv; "M.CV"
00007FF91DFE824A  C7 45 DF 00 00 00 00        mov     dword ptr [rbp+57h+var_80+8], 0
00007FF91DFE8251  48 89 45 D7                 mov     qword ptr [rbp+57h+var_80], rax
00007FF91DFE8255  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE8258  F3 0F 7F 45 E3              movdqu  [rbp+57h+var_80+0Ch], xmm0
00007FF91DFE825D  C7 45 F3 01 00 00 00        mov     [rbp+57h+var_64], 1
00007FF91DFE8264  48 8D 87 30 01 00 00        lea     rax, [rdi+130h]
00007FF91DFE826B  48 89 45 F7                 mov     [rbp+57h+var_60], rax
00007FF91DFE826F  48 8B 57 40                 mov     rdx, [rdi+40h]
00007FF91DFE8273  48 39 57 48                 cmp     [rdi+48h], rdx
00007FF91DFE8277  74 20                       jz      short loc_7FF91DFE8299
00007FF91DFE8279  0F 10 45 D7                 movups  xmm0, [rbp+57h+var_80]
00007FF91DFE827D  0F 11 02                    movups  xmmword ptr [rdx], xmm0
00007FF91DFE8280  0F 10 4D E7                 movups  xmm1, xmmword ptr [rbp-19h]
00007FF91DFE8284  0F 11 4A 10                 movups  xmmword ptr [rdx+10h], xmm1
00007FF91DFE8288  F2 0F 10 45 F7              movsd   xmm0, [rbp+57h+var_60]
00007FF91DFE828D  F2 0F 11 42 20              movsd   qword ptr [rdx+20h], xmm0
00007FF91DFE8292  48 83 47 40 28              add     qword ptr [rdi+40h], 28h ; '('
00007FF91DFE8297  EB 0D                       jmp     short loc_7FF91DFE82A6
00007FF91DFE8299  4C 8D 45 D7                 lea     r8, [rbp+57h+var_80]
00007FF91DFE829D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE82A1  E8 DA FC FF FF              call    sub_7FF91DFE7F80
00007FF91DFE82A6  48 8D 05 87 2C 60 00        lea     rax, aMGate; "M.Gate"
00007FF91DFE82AD  C7 45 07 00 00 00 00        mov     dword ptr [rbp+57h+var_58+8], 0
00007FF91DFE82B4  48 89 45 FF                 mov     qword ptr [rbp+57h+var_58], rax
00007FF91DFE82B8  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE82BB  F3 0F 7F 45 0B              movdqu  [rbp+57h+var_58+0Ch], xmm0
00007FF91DFE82C0  C7 45 1B 01 00 00 00        mov     [rbp+57h+var_3C], 1
00007FF91DFE82C7  48 8D 87 40 01 00 00        lea     rax, [rdi+140h]
00007FF91DFE82CE  48 89 45 1F                 mov     [rbp+57h+var_38], rax
00007FF91DFE82D2  48 8B 57 40                 mov     rdx, [rdi+40h]
00007FF91DFE82D6  48 39 57 48                 cmp     [rdi+48h], rdx
00007FF91DFE82DA  74 20                       jz      short loc_7FF91DFE82FC
00007FF91DFE82DC  0F 10 45 FF                 movups  xmm0, [rbp+57h+var_58]
00007FF91DFE82E0  0F 11 02                    movups  xmmword ptr [rdx], xmm0
00007FF91DFE82E3  0F 10 4D 0F                 movups  xmm1, xmmword ptr [rbp+0Fh]
00007FF91DFE82E7  0F 11 4A 10                 movups  xmmword ptr [rdx+10h], xmm1
00007FF91DFE82EB  F2 0F 10 45 1F              movsd   xmm0, [rbp+57h+var_38]
00007FF91DFE82F0  F2 0F 11 42 20              movsd   qword ptr [rdx+20h], xmm0
00007FF91DFE82F5  48 83 47 40 28              add     qword ptr [rdi+40h], 28h ; '('
00007FF91DFE82FA  EB 0D                       jmp     short loc_7FF91DFE8309
00007FF91DFE82FC  4C 8D 45 FF                 lea     r8, [rbp+57h+var_58]
00007FF91DFE8300  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8304  E8 77 FC FF FF              call    sub_7FF91DFE7F80
00007FF91DFE8309  66 0F 6F 05 1F 3D 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8311  48 8D 05 28 2C 60 00        lea     rax, aMasterTune; "Master Tune"
00007FF91DFE8318  48 89 45 27                 mov     qword ptr [rbp+57h+var_30], rax
00007FF91DFE831C  48 8D 87 70 01 00 00        lea     rax, [rdi+170h]
00007FF91DFE8323  48 89 45 47                 mov     [rbp+57h+var_10], rax
00007FF91DFE8327  C7 45 2F 00 00 00 00        mov     dword ptr [rbp+57h+var_30+8], 0
00007FF91DFE832E  F3 0F 7F 45 33              movdqu  [rbp+57h+var_30+0Ch], xmm0
00007FF91DFE8333  C7 45 43 01 00 00 00        mov     [rbp+57h+var_14], 1
00007FF91DFE833A  48 8B 57 40                 mov     rdx, [rdi+40h]
00007FF91DFE833E  48 39 57 48                 cmp     [rdi+48h], rdx
00007FF91DFE8342  74 20                       jz      short loc_7FF91DFE8364
00007FF91DFE8344  0F 10 45 27                 movups  xmm0, [rbp+57h+var_30]
00007FF91DFE8348  0F 11 02                    movups  xmmword ptr [rdx], xmm0
00007FF91DFE834B  0F 10 4D 37                 movups  xmm1, xmmword ptr [rbp+37h]
00007FF91DFE834F  0F 11 4A 10                 movups  xmmword ptr [rdx+10h], xmm1
00007FF91DFE8353  F2 0F 10 45 47              movsd   xmm0, [rbp+57h+var_10]
00007FF91DFE8358  F2 0F 11 42 20              movsd   qword ptr [rdx+20h], xmm0
00007FF91DFE835D  48 83 47 40 28              add     qword ptr [rdi+40h], 28h ; '('
00007FF91DFE8362  EB 0D                       jmp     short loc_7FF91DFE8371
00007FF91DFE8364  4C 8D 45 27                 lea     r8, [rbp+57h+var_30]
00007FF91DFE8368  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE836C  E8 0F FC FF FF              call    sub_7FF91DFE7F80
00007FF91DFE8371  66 0F 6F 05 B7 3C 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8379  48 8D 05 D0 2B 60 00        lea     rax, aPartTune; "Part Tune"
00007FF91DFE8380  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8384  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8388  48 8D 87 80 01 00 00        lea     rax, [rdi+180h]
00007FF91DFE838F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8396  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE839A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE839E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE83A3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE83AA  E8 51 36 02 00              call    sub_7FF91E00BA00
00007FF91DFE83AF  48 8D 05 AA 2B 60 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
00007FF91DFE83B6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE83BD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE83C1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE83C5  48 8D 87 50 02 00 00        lea     rax, [rdi+250h]
00007FF91DFE83CC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE83D3  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE83D6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE83DA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE83DE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE83E3  E8 18 36 02 00              call    sub_7FF91E00BA00
00007FF91DFE83E8  48 8D 05 89 2B 60 00        lea     rax, aPortamentoMode; "Portamento Mode"
00007FF91DFE83EF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE83F6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE83FA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE83FE  48 8D 87 60 02 00 00        lea     rax, [rdi+260h]
00007FF91DFE8405  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE840C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE840F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8413  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8417  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE841C  E8 DF 35 02 00              call    sub_7FF91E00BA00
00007FF91DFE8421  66 0F 6F 05 07 3C 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8429  48 8D 05 58 2B 60 00        lea     rax, aPortamentoTime; "Portamento Time"
00007FF91DFE8430  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8434  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8438  48 8D 87 70 02 00 00        lea     rax, [rdi+270h]
00007FF91DFE843F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8446  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE844A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE844E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8453  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE845A  E8 A1 35 02 00              call    sub_7FF91E00BA00
00007FF91DFE845F  48 8D 05 32 2B 60 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
00007FF91DFE8466  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE846D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8471  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8475  48 8D 87 10 04 00 00        lea     rax, [rdi+410h]
00007FF91DFE847C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8483  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE8486  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE848A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE848E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8493  E8 68 35 02 00              call    sub_7FF91E00BA00
00007FF91DFE8498  48 8D 05 11 2B 60 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
00007FF91DFE849F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE84A6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE84AA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE84AE  48 8D 87 20 04 00 00        lea     rax, [rdi+420h]
00007FF91DFE84B5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE84BC  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE84BF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE84C3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE84C7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE84CC  E8 2F 35 02 00              call    sub_7FF91E00BA00
00007FF91DFE84D1  48 8D 05 F0 2A 60 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
00007FF91DFE84D8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE84DF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE84E3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE84E7  48 8D 87 30 04 00 00        lea     rax, [rdi+430h]
00007FF91DFE84EE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE84F5  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE84F8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE84FC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8500  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8505  E8 F6 34 02 00              call    sub_7FF91E00BA00
00007FF91DFE850A  66 0F 6F 05 1E 3B 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8512  48 8D 05 BF 2A 60 00        lea     rax, aLfoRate; "LFO Rate"
00007FF91DFE8519  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE851D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8524  48 8D 87 40 04 00 00        lea     rax, [rdi+440h]
00007FF91DFE852B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8532  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8536  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE853A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE853E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8543  E8 B8 34 02 00              call    sub_7FF91E00BA00
00007FF91DFE8548  48 8D 05 95 2A 60 00        lea     rax, aGate; "Gate"
00007FF91DFE854F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8556  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE855A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE855E  48 8D 87 40 07 00 00        lea     rax, [rdi+740h]
00007FF91DFE8565  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE856C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE856F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8573  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8577  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE857C  E8 7F 34 02 00              call    sub_7FF91E00BA00
00007FF91DFE8581  48 8D 05 68 2A 60 00        lea     rax, aLfoTrig; "LFO Trig"
00007FF91DFE8588  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE858F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8593  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8597  48 8D 87 50 07 00 00        lea     rax, [rdi+750h]
00007FF91DFE859E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE85A5  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE85A8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE85AC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE85B0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE85B5  E8 46 34 02 00              call    sub_7FF91E00BA00
00007FF91DFE85BA  48 8D 05 3F 2A 60 00        lea     rax, aResetSw; "Reset Sw"
00007FF91DFE85C1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE85C8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE85CC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE85D0  48 8D 87 60 07 00 00        lea     rax, [rdi+760h]
00007FF91DFE85D7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE85DE  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE85E1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE85E5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE85E9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE85EE  E8 0D 34 02 00              call    sub_7FF91E00BA00
00007FF91DFE85F3  66 0F 6F 05 35 3A 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE85FB  48 8D 05 0E 2A 60 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
00007FF91DFE8602  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8606  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE860A  48 8D 87 70 07 00 00        lea     rax, [rdi+770h]
00007FF91DFE8611  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8618  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE861C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8620  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8625  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE862C  E8 CF 33 02 00              call    sub_7FF91E00BA00
00007FF91DFE8631  66 0F 6F 05 F7 39 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8639  48 8D 05 E0 29 60 00        lea     rax, aLfoDelay; "LFO Delay"
00007FF91DFE8640  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8644  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8648  48 8D 87 80 07 00 00        lea     rax, [rdi+780h]
00007FF91DFE864F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8656  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE865A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE865E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8663  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE866A  E8 91 33 02 00              call    sub_7FF91E00BA00
00007FF91DFE866F  66 0F 6F 05 B9 39 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8677  48 8D 05 B2 29 60 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
00007FF91DFE867E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8682  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8686  48 8D 87 90 07 00 00        lea     rax, [rdi+790h]
00007FF91DFE868D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8694  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8698  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE869C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE86A1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE86A8  E8 53 33 02 00              call    sub_7FF91E00BA00
00007FF91DFE86AD  66 0F 6F 05 7B 39 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE86B5  48 8D 05 84 29 60 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
00007FF91DFE86BC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE86C0  48 8D 87 A0 07 00 00        lea     rax, [rdi+7A0h]
00007FF91DFE86C7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE86CB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE86D2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE86D7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE86DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE86E2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE86E6  E8 15 33 02 00              call    sub_7FF91E00BA00
00007FF91DFE86EB  66 0F 6F 05 3D 39 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE86F3  48 8D 05 56 29 60 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
00007FF91DFE86FA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE86FE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8702  48 8D 87 B0 07 00 00        lea     rax, [rdi+7B0h]
00007FF91DFE8709  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8710  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8714  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8718  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE871D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8724  E8 D7 32 02 00              call    sub_7FF91E00BA00
00007FF91DFE8729  66 0F 6F 05 FF 38 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8731  48 8D 05 28 29 60 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
00007FF91DFE8738  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE873C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8740  48 8D 87 C0 07 00 00        lea     rax, [rdi+7C0h]
00007FF91DFE8747  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE874E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8752  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8756  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE875B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8762  E8 99 32 02 00              call    sub_7FF91E00BA00
00007FF91DFE8767  66 0F 6F 05 C1 38 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE876F  48 8D 05 FA 28 60 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
00007FF91DFE8776  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE877A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE877E  48 8D 87 D0 07 00 00        lea     rax, [rdi+7D0h]
00007FF91DFE8785  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE878C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8790  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8794  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8799  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE87A0  E8 5B 32 02 00              call    sub_7FF91E00BA00
00007FF91DFE87A5  66 0F 6F 05 83 38 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE87AD  48 8D 05 CC 28 60 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
00007FF91DFE87B4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE87B8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE87BC  48 8D 87 E0 07 00 00        lea     rax, [rdi+7E0h]
00007FF91DFE87C3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE87CA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE87CE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE87D2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE87D7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE87DE  E8 1D 32 02 00              call    sub_7FF91E00BA00
00007FF91DFE87E3  66 0F 6F 05 45 38 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE87EB  48 8D 05 9E 28 60 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
00007FF91DFE87F2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE87F6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE87FA  48 8D 87 F0 07 00 00        lea     rax, [rdi+7F0h]
00007FF91DFE8801  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8808  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE880C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8810  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8815  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE881C  E8 DF 31 02 00              call    sub_7FF91E00BA00
00007FF91DFE8821  66 0F 6F 05 07 38 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8829  48 8D 05 70 28 60 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
00007FF91DFE8830  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8834  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8838  48 8D 87 00 08 00 00        lea     rax, [rdi+800h]
00007FF91DFE883F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8846  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE884A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE884E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8853  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE885A  E8 A1 31 02 00              call    sub_7FF91E00BA00
00007FF91DFE885F  66 0F 6F 05 C9 37 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8867  48 8D 05 42 28 60 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
00007FF91DFE886E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8872  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8876  48 8D 87 10 08 00 00        lea     rax, [rdi+810h]
00007FF91DFE887D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8884  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8888  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE888C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8891  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8898  E8 63 31 02 00              call    sub_7FF91E00BA00
00007FF91DFE889D  48 8D 05 1C 28 60 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
00007FF91DFE88A4  66 0F 6F 05 84 37 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE88AC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE88B0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE88B4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE88B8  48 8D 87 20 08 00 00        lea     rax, [rdi+820h]
00007FF91DFE88BF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE88C6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE88CA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE88CF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE88D6  E8 25 31 02 00              call    sub_7FF91E00BA00
00007FF91DFE88DB  66 0F 6F 05 4D 37 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE88E3  48 8D 05 E6 27 60 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
00007FF91DFE88EA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE88EE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE88F2  48 8D 87 30 08 00 00        lea     rax, [rdi+830h]
00007FF91DFE88F9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8900  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8904  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8908  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE890D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8914  E8 E7 30 02 00              call    sub_7FF91E00BA00
00007FF91DFE8919  66 0F 6F 05 0F 37 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8921  48 8D 05 C0 27 60 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
00007FF91DFE8928  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE892C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8930  48 8D 87 40 08 00 00        lea     rax, [rdi+840h]
00007FF91DFE8937  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE893E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8942  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8946  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE894B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8952  E8 A9 30 02 00              call    sub_7FF91E00BA00
00007FF91DFE8957  48 8D 05 A2 27 60 00        lea     rax, aReadOnly; "read only"
00007FF91DFE895E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8965  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8969  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE896D  48 8D 87 E0 09 00 00        lea     rax, [rdi+9E0h]
00007FF91DFE8974  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE897B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE897E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8982  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8986  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE898B  E8 70 30 02 00              call    sub_7FF91E00BA00
00007FF91DFE8990  48 8D 05 69 27 60 00        lea     rax, aReadOnly; "read only"
00007FF91DFE8997  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE899E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE89A2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE89A6  48 8D 87 F0 09 00 00        lea     rax, [rdi+9F0h]
00007FF91DFE89AD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE89B4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE89B7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE89BB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE89BF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE89C4  E8 37 30 02 00              call    sub_7FF91E00BA00
00007FF91DFE89C9  48 8D 05 40 27 60 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFE89D0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE89D7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE89DB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE89DF  48 8D 87 00 0A 00 00        lea     rax, [rdi+0A00h]
00007FF91DFE89E6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE89ED  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE89F0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE89F4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE89F8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE89FD  E8 FE 2F 02 00              call    sub_7FF91E00BA00
00007FF91DFE8A02  66 0F 6F 05 26 36 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8A0A  48 8D 05 17 27 60 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFE8A11  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8A15  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8A19  48 8D 87 E0 0A 00 00        lea     rax, [rdi+0AE0h]
00007FF91DFE8A20  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8A27  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8A2B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8A2F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8A34  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8A3B  E8 C0 2F 02 00              call    sub_7FF91E00BA00
00007FF91DFE8A40  66 0F 6F 05 E8 35 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8A48  48 8D 05 E9 26 60 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFE8A4F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8A53  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8A58  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8A5F  48 8D 87 F0 0A 00 00        lea     rax, [rdi+0AF0h]
00007FF91DFE8A66  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8A6D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8A71  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8A75  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8A79  E8 82 2F 02 00              call    sub_7FF91E00BA00
00007FF91DFE8A7E  66 0F 6F 05 AA 35 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8A86  48 8D 05 BB 26 60 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFE8A8D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8A91  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8A95  48 8D 87 00 0B 00 00        lea     rax, [rdi+0B00h]
00007FF91DFE8A9C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8AA3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8AA7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8AAB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8AB0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8AB7  E8 44 2F 02 00              call    sub_7FF91E00BA00
00007FF91DFE8ABC  66 0F 6F 05 6C 35 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8AC4  48 8D 05 8D 26 60 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFE8ACB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8ACF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8AD3  48 8D 87 10 0B 00 00        lea     rax, [rdi+0B10h]
00007FF91DFE8ADA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8AE1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8AE5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8AE9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8AEE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8AF5  E8 06 2F 02 00              call    sub_7FF91E00BA00
00007FF91DFE8AFA  66 0F 6F 05 2E 35 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8B02  48 8D 05 5F 26 60 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFE8B09  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8B0D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8B11  48 8D 87 20 0B 00 00        lea     rax, [rdi+0B20h]
00007FF91DFE8B18  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8B1F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8B23  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8B27  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8B2C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8B33  E8 C8 2E 02 00              call    sub_7FF91E00BA00
00007FF91DFE8B38  48 8D 05 D1 25 60 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFE8B3F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8B46  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8B4A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8B4E  48 8D 87 E0 0B 00 00        lea     rax, [rdi+0BE0h]
00007FF91DFE8B55  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8B5C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE8B5F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8B63  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8B67  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8B6C  E8 8F 2E 02 00              call    sub_7FF91E00BA00
00007FF91DFE8B71  66 0F 6F 05 B7 34 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8B79  48 8D 05 A8 25 60 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFE8B80  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8B84  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8B88  48 8D 87 C0 0C 00 00        lea     rax, [rdi+0CC0h]
00007FF91DFE8B8F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8B96  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8B9A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8B9E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8BA3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8BAA  E8 51 2E 02 00              call    sub_7FF91E00BA00
00007FF91DFE8BAF  66 0F 6F 05 79 34 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8BB7  48 8D 05 7A 25 60 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFE8BBE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8BC2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8BC6  48 8D 87 D0 0C 00 00        lea     rax, [rdi+0CD0h]
00007FF91DFE8BCD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8BD4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8BD8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8BDC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8BE1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8BE8  E8 13 2E 02 00              call    sub_7FF91E00BA00
00007FF91DFE8BED  66 0F 6F 05 3B 34 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8BF5  48 8D 05 4C 25 60 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFE8BFC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8C00  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8C04  48 8D 87 E0 0C 00 00        lea     rax, [rdi+0CE0h]
00007FF91DFE8C0B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8C12  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8C16  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8C1B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8C22  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8C26  E8 D5 2D 02 00              call    sub_7FF91E00BA00
00007FF91DFE8C2B  66 0F 6F 05 FD 33 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8C33  48 8D 05 1E 25 60 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFE8C3A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8C3E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8C42  48 8D 87 F0 0C 00 00        lea     rax, [rdi+0CF0h]
00007FF91DFE8C49  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8C50  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8C54  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8C58  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8C5D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8C64  E8 97 2D 02 00              call    sub_7FF91E00BA00
00007FF91DFE8C69  66 0F 6F 05 BF 33 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8C71  48 8D 05 F0 24 60 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFE8C78  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8C7C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8C80  48 8D 87 00 0D 00 00        lea     rax, [rdi+0D00h]
00007FF91DFE8C87  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8C8E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8C92  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8C96  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8C9B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8CA2  E8 59 2D 02 00              call    sub_7FF91E00BA00
00007FF91DFE8CA7  48 8D 05 CA 24 60 00        lea     rax, aOsc1Feet; "OSC1 Feet"
00007FF91DFE8CAE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8CB5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8CB9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8CBD  48 8D 87 00 0F 00 00        lea     rax, [rdi+0F00h]
00007FF91DFE8CC4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8CCB  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE8CCE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8CD2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8CD6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8CDB  E8 20 2D 02 00              call    sub_7FF91E00BA00
00007FF91DFE8CE0  48 8D 05 A1 24 60 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
00007FF91DFE8CE7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8CEE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8CF2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8CF6  48 8D 87 10 0F 00 00        lea     rax, [rdi+0F10h]
00007FF91DFE8CFD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8D04  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE8D07  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8D0B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8D0F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8D14  E8 E7 2C 02 00              call    sub_7FF91E00BA00
00007FF91DFE8D19  48 8D 05 78 24 60 00        lea     rax, aBendEnableSw; "Bend Enable SW"
00007FF91DFE8D20  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8D27  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8D2B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8D2F  48 8D 87 20 0F 00 00        lea     rax, [rdi+0F20h]
00007FF91DFE8D36  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8D3D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE8D40  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8D44  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8D48  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8D4D  E8 AE 2C 02 00              call    sub_7FF91E00BA00
00007FF91DFE8D52  48 8D 05 4F 24 60 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
00007FF91DFE8D59  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8D60  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8D64  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8D68  48 8D 87 30 0F 00 00        lea     rax, [rdi+0F30h]
00007FF91DFE8D6F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8D76  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE8D79  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8D7D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8D81  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8D86  E8 75 2C 02 00              call    sub_7FF91E00BA00
00007FF91DFE8D8B  48 8D 05 26 24 60 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
00007FF91DFE8D92  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8D99  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8D9D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8DA1  48 8D 87 40 0F 00 00        lea     rax, [rdi+0F40h]
00007FF91DFE8DA8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8DAF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE8DB2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8DB6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8DBA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8DBF  E8 3C 2C 02 00              call    sub_7FF91E00BA00
00007FF91DFE8DC4  48 8D 05 FD 23 60 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
00007FF91DFE8DCB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8DCF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE8DD2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8DD9  48 8D 87 50 0F 00 00        lea     rax, [rdi+0F50h]
00007FF91DFE8DE0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8DE7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8DEB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8DEF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8DF3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8DF8  E8 03 2C 02 00              call    sub_7FF91E00BA00
00007FF91DFE8DFD  48 8D 05 D4 23 60 00        lea     rax, aPwmSwManual; "PWM SW Manual"
00007FF91DFE8E04  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8E0B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8E0F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8E13  48 8D 87 60 0F 00 00        lea     rax, [rdi+0F60h]
00007FF91DFE8E1A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8E21  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE8E24  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8E28  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8E2C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8E31  E8 CA 2B 02 00              call    sub_7FF91E00BA00
00007FF91DFE8E36  66 0F 6F 05 F2 31 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8E3E  48 8D 05 A3 23 60 00        lea     rax, aTune; "Tune"
00007FF91DFE8E45  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8E49  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8E4D  48 8D 87 70 0F 00 00        lea     rax, [rdi+0F70h]
00007FF91DFE8E54  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8E5B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8E5F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8E63  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8E68  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8E6F  E8 8C 2B 02 00              call    sub_7FF91E00BA00
00007FF91DFE8E74  66 0F 6F 05 B4 31 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8E7C  48 8D 05 6D 23 60 00        lea     rax, aDetune; "Detune"
00007FF91DFE8E83  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8E87  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8E8B  48 8D 87 80 0F 00 00        lea     rax, [rdi+0F80h]
00007FF91DFE8E92  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8E99  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8E9D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8EA1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8EA6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8EAD  E8 4E 2B 02 00              call    sub_7FF91E00BA00
00007FF91DFE8EB2  66 0F 6F 05 76 31 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8EBA  48 8D 05 37 23 60 00        lea     rax, aModSens; "Mod Sens"
00007FF91DFE8EC1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8EC5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8EC9  48 8D 87 90 0F 00 00        lea     rax, [rdi+0F90h]
00007FF91DFE8ED0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8ED7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8EDB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8EDF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8EE4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8EEB  E8 10 2B 02 00              call    sub_7FF91E00BA00
00007FF91DFE8EF0  66 0F 6F 05 38 31 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8EF8  48 8D 05 05 23 60 00        lea     rax, aModSw; "Mod Sw"
00007FF91DFE8EFF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8F03  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8F07  48 8D 87 A0 0F 00 00        lea     rax, [rdi+0FA0h]
00007FF91DFE8F0E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8F15  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8F19  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8F1D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8F22  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8F29  E8 D2 2A 02 00              call    sub_7FF91E00BA00
00007FF91DFE8F2E  66 0F 6F 05 FA 30 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8F36  48 8D 05 D3 22 60 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFE8F3D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8F41  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8F45  48 8D 87 B0 0F 00 00        lea     rax, [rdi+0FB0h]
00007FF91DFE8F4C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8F53  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8F57  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8F5B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8F60  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8F67  E8 94 2A 02 00              call    sub_7FF91E00BA00
00007FF91DFE8F6C  66 0F 6F 05 BC 30 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8F74  48 8D 05 A5 22 60 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFE8F7B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8F7F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8F84  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8F8B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8F92  48 8D 87 C0 0F 00 00        lea     rax, [rdi+0FC0h]
00007FF91DFE8F99  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8F9D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8FA1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8FA5  E8 56 2A 02 00              call    sub_7FF91E00BA00
00007FF91DFE8FAA  66 0F 6F 05 7E 30 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8FB2  48 8D 05 73 22 60 00        lea     rax, aLfoSw; "LFO Sw"
00007FF91DFE8FB9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8FBD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8FC1  48 8D 87 D0 0F 00 00        lea     rax, [rdi+0FD0h]
00007FF91DFE8FC8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE8FCF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE8FD3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE8FD7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE8FDC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE8FE3  E8 18 2A 02 00              call    sub_7FF91E00BA00
00007FF91DFE8FE8  66 0F 6F 05 40 30 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE8FF0  48 8D 05 41 22 60 00        lea     rax, aEnv1Level; "ENV1 Level"
00007FF91DFE8FF7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE8FFB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE8FFF  48 8D 87 E0 0F 00 00        lea     rax, [rdi+0FE0h]
00007FF91DFE9006  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE900D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9011  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9015  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE901A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9021  E8 DA 29 02 00              call    sub_7FF91E00BA00
00007FF91DFE9026  66 0F 6F 05 02 30 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE902E  48 8D 05 13 22 60 00        lea     rax, aEnv2Level; "ENV2 Level"
00007FF91DFE9035  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9039  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE903D  48 8D 87 F0 0F 00 00        lea     rax, [rdi+0FF0h]
00007FF91DFE9044  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE904B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE904F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9053  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9058  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE905F  E8 9C 29 02 00              call    sub_7FF91E00BA00
00007FF91DFE9064  66 0F 6F 05 C4 2F 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE906C  48 8D 05 E1 21 60 00        lea     rax, aEnvSw; "ENV Sw"
00007FF91DFE9073  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9077  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE907B  48 8D 87 00 10 00 00        lea     rax, [rdi+1000h]
00007FF91DFE9082  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9089  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE908D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9091  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9096  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE909D  E8 5E 29 02 00              call    sub_7FF91E00BA00
00007FF91DFE90A2  66 0F 6F 05 86 2F 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE90AA  48 8D 05 AF 21 60 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFE90B1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE90B5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE90B9  48 8D 87 10 10 00 00        lea     rax, [rdi+1010h]
00007FF91DFE90C0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE90C7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE90CB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE90CF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE90D4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE90DB  E8 20 29 02 00              call    sub_7FF91E00BA00
00007FF91DFE90E0  66 0F 6F 05 48 2F 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE90E8  48 8D 05 81 21 60 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFE90EF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE90F3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE90F7  48 8D 87 20 10 00 00        lea     rax, [rdi+1020h]
00007FF91DFE90FE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9105  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9109  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE910D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9112  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9119  E8 E2 28 02 00              call    sub_7FF91E00BA00
00007FF91DFE911E  66 0F 6F 05 0A 2F 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9126  48 8D 05 53 21 60 00        lea     rax, aPwmLevel; "PWM Level"
00007FF91DFE912D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9131  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9135  48 8D 87 30 10 00 00        lea     rax, [rdi+1030h]
00007FF91DFE913C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9143  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9147  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE914B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9150  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9157  E8 A4 28 02 00              call    sub_7FF91E00BA00
00007FF91DFE915C  66 0F 6F 05 CC 2E 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9164  48 8D 05 25 21 60 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
00007FF91DFE916B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE916F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9173  48 8D 87 60 10 00 00        lea     rax, [rdi+1060h]
00007FF91DFE917A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9181  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9185  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9189  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE918E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9195  E8 66 28 02 00              call    sub_7FF91E00BA00
00007FF91DFE919A  66 0F 6F 05 8E 2E 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE91A2  48 8D 05 F7 20 60 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
00007FF91DFE91A9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE91AD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE91B1  48 8D 87 70 10 00 00        lea     rax, [rdi+1070h]
00007FF91DFE91B8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE91BF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE91C3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE91C7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE91CC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE91D3  E8 28 28 02 00              call    sub_7FF91E00BA00
00007FF91DFE91D8  66 0F 6F 05 50 2E 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE91E0  48 8D 05 C9 20 60 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
00007FF91DFE91E7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE91EB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE91EF  48 8D 87 80 10 00 00        lea     rax, [rdi+1080h]
00007FF91DFE91F6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE91FD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9201  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9205  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE920A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9211  E8 EA 27 02 00              call    sub_7FF91E00BA00
00007FF91DFE9216  66 0F 6F 05 12 2E 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE921E  48 8D 05 9B 20 60 00        lea     rax, aDutyTune; "Duty Tune"
00007FF91DFE9225  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9229  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE922D  48 8D 87 90 15 00 00        lea     rax, [rdi+1590h]
00007FF91DFE9234  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE923B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE923F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9243  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9248  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE924F  E8 AC 27 02 00              call    sub_7FF91E00BA00
00007FF91DFE9254  66 0F 6F 05 D4 2D 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE925C  48 8D 05 6D 20 60 00        lea     rax, aOsc1Mute; "Osc1 Mute"
00007FF91DFE9263  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9267  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE926B  48 8D 87 30 19 00 00        lea     rax, [rdi+1930h]
00007FF91DFE9272  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9279  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE927D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9281  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9286  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE928D  E8 6E 27 02 00              call    sub_7FF91E00BA00
00007FF91DFE9292  66 0F 6F 05 96 2D 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE929A  48 8D 05 3F 20 60 00        lea     rax, aOsc1Level; "Osc1 Level"
00007FF91DFE92A1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE92A5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE92A9  48 8D 87 70 19 00 00        lea     rax, [rdi+1970h]
00007FF91DFE92B0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE92B7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE92BB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE92BF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE92C4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE92CB  E8 30 27 02 00              call    sub_7FF91E00BA00
00007FF91DFE92D0  66 0F 6F 05 58 2D 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE92D8  48 8D 05 11 20 60 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
00007FF91DFE92DF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE92E3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE92E7  48 8D 87 80 19 00 00        lea     rax, [rdi+1980h]
00007FF91DFE92EE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE92F5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE92F9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE92FD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9302  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9309  E8 F2 26 02 00              call    sub_7FF91E00BA00
00007FF91DFE930E  48 8D 05 EB 1F 60 00        lea     rax, aGrifferSw; "Griffer SW"
00007FF91DFE9315  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE931C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9320  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9323  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE932A  48 8D 87 40 1A 00 00        lea     rax, [rdi+1A40h]
00007FF91DFE9331  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9335  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9339  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE933D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9342  E8 B9 26 02 00              call    sub_7FF91E00BA00
00007FF91DFE9347  66 0F 6F 05 E1 2C 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE934F  48 8D 05 BA 1F 60 00        lea     rax, aLpfCutoff; "LPF Cutoff"
00007FF91DFE9356  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE935A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE935E  48 8D 87 50 1A 00 00        lea     rax, [rdi+1A50h]
00007FF91DFE9365  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE936C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9370  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9374  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9379  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9380  E8 7B 26 02 00              call    sub_7FF91E00BA00
00007FF91DFE9385  66 0F 6F 05 A3 2C 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE938D  48 8D 05 8C 1F 60 00        lea     rax, aLpfResonance; "LPF Resonance"
00007FF91DFE9394  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9398  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE939C  48 8D 87 B0 1A 00 00        lea     rax, [rdi+1AB0h]
00007FF91DFE93A3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE93AA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE93AE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE93B2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE93B7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE93BE  E8 3D 26 02 00              call    sub_7FF91E00BA00
00007FF91DFE93C3  48 8D 05 66 1F 60 00        lea     rax, aVelocity; "Velocity"
00007FF91DFE93CA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE93D1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE93D5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE93D9  48 8D 87 D0 1A 00 00        lea     rax, [rdi+1AD0h]
00007FF91DFE93E0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE93E7  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE93EA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE93EE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE93F2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE93F7  E8 04 26 02 00              call    sub_7FF91E00BA00
00007FF91DFE93FC  48 8D 05 39 1F 60 00        lea     rax, aEnv12; "Env1/2"
00007FF91DFE9403  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE940A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE940E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9412  48 8D 87 60 1B 00 00        lea     rax, [rdi+1B60h]
00007FF91DFE9419  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9420  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9423  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9427  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE942B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9430  E8 CB 25 02 00              call    sub_7FF91E00BA00
00007FF91DFE9435  48 8D 05 0C 1F 60 00        lea     rax, aIntEnv; "Int/Env"
00007FF91DFE943C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9443  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9447  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE944B  48 8D 87 70 1B 00 00        lea     rax, [rdi+1B70h]
00007FF91DFE9452  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9459  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE945C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9460  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9464  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9469  E8 92 25 02 00              call    sub_7FF91E00BA00
00007FF91DFE946E  48 8D 05 9B 1D 60 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFE9475  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE947C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9480  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9484  48 8D 87 80 1C 00 00        lea     rax, [rdi+1C80h]
00007FF91DFE948B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9492  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9495  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9499  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE949D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE94A2  E8 59 25 02 00              call    sub_7FF91E00BA00
00007FF91DFE94A7  48 8D 05 A2 1E 60 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
00007FF91DFE94AE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE94B5  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE94B8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE94BC  48 8D 87 90 1C 00 00        lea     rax, [rdi+1C90h]
00007FF91DFE94C3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE94CA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE94CF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE94D3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE94D7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE94DB  E8 20 25 02 00              call    sub_7FF91E00BA00
00007FF91DFE94E0  48 8D 05 79 1E 60 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
00007FF91DFE94E7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE94EE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE94F2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE94F6  48 8D 87 A0 1C 00 00        lea     rax, [rdi+1CA0h]
00007FF91DFE94FD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9504  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9507  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE950B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE950F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9514  E8 E7 24 02 00              call    sub_7FF91E00BA00
00007FF91DFE9519  66 0F 6F 05 0F 2B 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9521  48 8D 05 F8 1C 60 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFE9528  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE952C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9530  48 8D 87 B0 1C 00 00        lea     rax, [rdi+1CB0h]
00007FF91DFE9537  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE953E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9542  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9546  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE954B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9552  E8 A9 24 02 00              call    sub_7FF91E00BA00
00007FF91DFE9557  66 0F 6F 05 D1 2A 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE955F  48 8D 05 0A 1E 60 00        lea     rax, aModSens_0; "MOD Sens"
00007FF91DFE9566  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE956A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE956E  48 8D 87 C0 1C 00 00        lea     rax, [rdi+1CC0h]
00007FF91DFE9575  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE957C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9580  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9584  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9589  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9590  E8 6B 24 02 00              call    sub_7FF91E00BA00
00007FF91DFE9595  66 0F 6F 05 93 2A 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE959D  48 8D 05 D8 1D 60 00        lea     rax, aModSw_0; "MOD SW"
00007FF91DFE95A4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE95A8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE95AC  48 8D 87 D0 1C 00 00        lea     rax, [rdi+1CD0h]
00007FF91DFE95B3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE95BA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE95BE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE95C2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE95C7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE95CE  E8 2D 24 02 00              call    sub_7FF91E00BA00
00007FF91DFE95D3  66 0F 6F 05 55 2A 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE95DB  48 8D 05 A6 1D 60 00        lea     rax, aEnvLevel; "ENV Level"
00007FF91DFE95E2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE95E6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE95EA  48 8D 87 E0 1C 00 00        lea     rax, [rdi+1CE0h]
00007FF91DFE95F1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE95F8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE95FC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9600  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9605  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE960C  E8 EF 23 02 00              call    sub_7FF91E00BA00
00007FF91DFE9611  66 0F 6F 05 17 2A 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9619  48 8D 05 78 1D 60 00        lea     rax, aKcvLevel; "KCV Level"
00007FF91DFE9620  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9624  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9628  48 8D 87 F0 1C 00 00        lea     rax, [rdi+1CF0h]
00007FF91DFE962F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9636  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE963A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE963E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9643  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE964A  E8 B1 23 02 00              call    sub_7FF91E00BA00
00007FF91DFE964F  66 0F 6F 05 D9 29 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9657  48 8D 05 4A 1D 60 00        lea     rax, aVelocitySens; "Velocity Sens"
00007FF91DFE965E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9662  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9666  48 8D 87 00 1D 00 00        lea     rax, [rdi+1D00h]
00007FF91DFE966D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9674  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9678  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE967C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9681  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9688  E8 73 23 02 00              call    sub_7FF91E00BA00
00007FF91DFE968D  66 0F 6F 05 9B 29 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9695  48 8D 05 1C 1D 60 00        lea     rax, aVelocityOffset; "Velocity Offset"
00007FF91DFE969C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE96A0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE96A4  48 8D 87 10 1D 00 00        lea     rax, [rdi+1D10h]
00007FF91DFE96AB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE96B2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE96B6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE96BA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE96BF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE96C6  E8 35 23 02 00              call    sub_7FF91E00BA00
00007FF91DFE96CB  66 0F 6F 05 5D 29 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE96D3  48 8D 05 86 1B 60 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFE96DA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE96DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE96E2  48 8D 87 20 1D 00 00        lea     rax, [rdi+1D20h]
00007FF91DFE96E9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE96F0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE96F4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE96F8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE96FD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9704  E8 F7 22 02 00              call    sub_7FF91E00BA00
00007FF91DFE9709  66 0F 6F 05 1F 29 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9711  48 8D 05 58 1B 60 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFE9718  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE971C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9720  48 8D 87 30 1D 00 00        lea     rax, [rdi+1D30h]
00007FF91DFE9727  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE972E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9732  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9736  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE973B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9742  E8 B9 22 02 00              call    sub_7FF91E00BA00
00007FF91DFE9747  66 0F 6F 05 E1 28 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE974F  48 8D 05 72 1C 60 00        lea     rax, aCutoffTune; "Cutoff Tune"
00007FF91DFE9756  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE975A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE975E  48 8D 87 B0 1D 00 00        lea     rax, [rdi+1DB0h]
00007FF91DFE9765  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE976C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9770  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9774  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9779  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9780  E8 7B 22 02 00              call    sub_7FF91E00BA00
00007FF91DFE9785  66 0F 6F 05 A3 28 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE978D  48 8D 05 44 1C 60 00        lea     rax, aResonanceTune; "Resonance Tune"
00007FF91DFE9794  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9798  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE979C  48 8D 87 C0 1D 00 00        lea     rax, [rdi+1DC0h]
00007FF91DFE97A3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE97AA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE97AE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE97B2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE97B7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE97BE  E8 3D 22 02 00              call    sub_7FF91E00BA00
00007FF91DFE97C3  48 8D 05 1E 1C 60 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFE97CA  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFE97D1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE97D5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE97D9  48 8D 87 D0 1D 00 00        lea     rax, [rdi+1DD0h]
00007FF91DFE97E0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE97E7  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFE97EA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE97EE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE97F2  F3 0F 7F 4D 93              movdqu  [rbp+57h+var_C4], xmm1
00007FF91DFE97F7  E8 04 22 02 00              call    sub_7FF91E00BA00
00007FF91DFE97FC  48 8D 05 E5 1B 60 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFE9803  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFE980A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE980E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9812  48 8D 87 60 23 00 00        lea     rax, [rdi+2360h]
00007FF91DFE9819  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9820  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9823  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9827  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE982B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9830  E8 CB 21 02 00              call    sub_7FF91E00BA00
00007FF91DFE9835  66 0F 6F 05 F3 27 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE983D  48 8D 05 B4 1B 60 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
00007FF91DFE9844  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9848  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE984F  48 8D 87 70 23 00 00        lea     rax, [rdi+2370h]
00007FF91DFE9856  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE985D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9861  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9865  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9869  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE986E  E8 8D 21 02 00              call    sub_7FF91E00BA00
00007FF91DFE9873  66 0F 6F 05 B5 27 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE987B  48 8D 05 86 1B 60 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
00007FF91DFE9882  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9886  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE988A  48 8D 87 80 23 00 00        lea     rax, [rdi+2380h]
00007FF91DFE9891  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9898  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE989C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE98A0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE98A5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE98AC  E8 4F 21 02 00              call    sub_7FF91E00BA00
00007FF91DFE98B1  66 0F 6F 05 77 27 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE98B9  48 8D 05 58 1B 60 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
00007FF91DFE98C0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE98C4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE98C8  48 8D 87 90 23 00 00        lea     rax, [rdi+2390h]
00007FF91DFE98CF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE98D6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE98DA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE98DE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE98E3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE98EA  E8 11 21 02 00              call    sub_7FF91E00BA00
00007FF91DFE98EF  66 0F 6F 05 39 27 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE98F7  48 8D 05 2A 1B 60 00        lea     rax, aAmpTone; "AMP TONE"
00007FF91DFE98FE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9902  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9906  48 8D 87 70 25 00 00        lea     rax, [rdi+2570h]
00007FF91DFE990D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9914  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9918  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE991C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9921  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9928  E8 D3 20 02 00              call    sub_7FF91E00BA00
00007FF91DFE992D  66 0F 6F 05 FB 26 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9935  48 8D 05 FC 1A 60 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
00007FF91DFE993C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9940  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9944  48 8D 87 80 25 00 00        lea     rax, [rdi+2580h]
00007FF91DFE994B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9952  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9956  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE995A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE995F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9966  E8 95 20 02 00              call    sub_7FF91E00BA00
00007FF91DFE996B  66 0F 6F 05 BD 26 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9973  48 8D 05 D6 1A 60 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
00007FF91DFE997A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE997E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9982  48 8D 87 90 25 00 00        lea     rax, [rdi+2590h]
00007FF91DFE9989  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9990  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9994  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9998  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE999D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE99A4  E8 57 20 02 00              call    sub_7FF91E00BA00
00007FF91DFE99A9  48 8D 05 80 19 60 00        lea     rax, aVelocity; "Velocity"
00007FF91DFE99B0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE99B7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE99BB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE99BF  48 8D 87 D0 25 00 00        lea     rax, [rdi+25D0h]
00007FF91DFE99C6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE99CD  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE99D0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE99D4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE99D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE99DD  E8 1E 20 02 00              call    sub_7FF91E00BA00
00007FF91DFE99E2  48 8D 05 7F 1A 60 00        lea     rax, aMute; "Mute"
00007FF91DFE99E9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE99F0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE99F4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE99F7  48 8D 87 60 26 00 00        lea     rax, [rdi+2660h]
00007FF91DFE99FE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9A05  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9A09  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9A0E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9A12  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9A16  E8 E5 1F 02 00              call    sub_7FF91E00BA00
00007FF91DFE9A1B  48 8D 05 4E 1A 60 00        lea     rax, aGateSw; "Gate SW"
00007FF91DFE9A22  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9A29  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9A2D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9A31  48 8D 87 C0 27 00 00        lea     rax, [rdi+27C0h]
00007FF91DFE9A38  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9A3F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9A42  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9A46  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9A4A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9A4F  E8 AC 1F 02 00              call    sub_7FF91E00BA00
00007FF91DFE9A54  48 8D 05 1D 1A 60 00        lea     rax, aEnv1Sw; "ENV1 SW"
00007FF91DFE9A5B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9A62  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9A66  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9A6A  48 8D 87 D0 27 00 00        lea     rax, [rdi+27D0h]
00007FF91DFE9A71  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9A78  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9A7B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9A7F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9A83  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9A88  E8 73 1F 02 00              call    sub_7FF91E00BA00
00007FF91DFE9A8D  48 8D 05 EC 19 60 00        lea     rax, aEnv2Sw; "ENV2 SW"
00007FF91DFE9A94  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9A9B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9A9F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9AA3  48 8D 87 E0 27 00 00        lea     rax, [rdi+27E0h]
00007FF91DFE9AAA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9AB1  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9AB4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9AB8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9ABC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9AC1  E8 3A 1F 02 00              call    sub_7FF91E00BA00
00007FF91DFE9AC6  48 8D 05 BB 19 60 00        lea     rax, aExtEnvSw; "Ext ENV SW"
00007FF91DFE9ACD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9AD4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9AD8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9ADC  48 8D 87 F0 27 00 00        lea     rax, [rdi+27F0h]
00007FF91DFE9AE3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9AEA  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9AED  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9AF1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9AF5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9AFA  E8 01 1F 02 00              call    sub_7FF91E00BA00
00007FF91DFE9AFF  66 0F 6F 05 29 25 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9B07  48 8D 05 8A 19 60 00        lea     rax, aHpfCutoff; "HPF Cutoff"
00007FF91DFE9B0E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9B12  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9B16  48 8D 87 00 28 00 00        lea     rax, [rdi+2800h]
00007FF91DFE9B1D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9B24  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9B28  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9B2C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9B31  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9B38  E8 C3 1E 02 00              call    sub_7FF91E00BA00
00007FF91DFE9B3D  66 0F 6F 05 EB 24 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9B45  48 8D 05 5C 19 60 00        lea     rax, aHpfSwitch; "HPF Switch"
00007FF91DFE9B4C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9B50  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9B54  48 8D 87 10 28 00 00        lea     rax, [rdi+2810h]
00007FF91DFE9B5B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9B62  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9B66  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9B6A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9B6F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9B76  E8 85 1E 02 00              call    sub_7FF91E00BA00
00007FF91DFE9B7B  66 0F 6F 05 AD 24 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9B83  48 8D 05 2E 19 60 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
00007FF91DFE9B8A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9B8E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9B92  48 8D 87 20 28 00 00        lea     rax, [rdi+2820h]
00007FF91DFE9B99  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9BA0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9BA4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9BA8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9BAD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9BB4  E8 47 1E 02 00              call    sub_7FF91E00BA00
00007FF91DFE9BB9  48 8D 05 08 19 60 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
00007FF91DFE9BC0  66 0F 6F 05 68 24 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9BC8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9BCC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9BD0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9BD4  48 8D 87 30 28 00 00        lea     rax, [rdi+2830h]
00007FF91DFE9BDB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9BE2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9BE6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9BEB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9BF2  E8 09 1E 02 00              call    sub_7FF91E00BA00
00007FF91DFE9BF7  66 0F 6F 05 31 24 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9BFF  48 8D 05 DA 18 60 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
00007FF91DFE9C06  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9C0A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9C0E  48 8D 87 40 28 00 00        lea     rax, [rdi+2840h]
00007FF91DFE9C15  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9C1C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9C20  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9C24  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9C29  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9C30  E8 CB 1D 02 00              call    sub_7FF91E00BA00
00007FF91DFE9C35  66 0F 6F 05 F3 23 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9C3D  48 8D 05 AC 18 60 00        lea     rax, aAmpLevel; "AMP LEVEL"
00007FF91DFE9C44  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9C48  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9C4C  48 8D 87 50 28 00 00        lea     rax, [rdi+2850h]
00007FF91DFE9C53  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9C5A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9C5E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9C62  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9C67  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9C6E  E8 8D 1D 02 00              call    sub_7FF91E00BA00
00007FF91DFE9C73  48 8D 05 A6 12 60 00        lea     rax, aUseextjack; "UseExtJack"
00007FF91DFE9C7A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9C81  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9C85  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9C89  48 8D 87 20 2A 00 00        lea     rax, [rdi+2A20h]
00007FF91DFE9C90  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9C97  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9C9A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9C9E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9CA2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9CA7  E8 54 1D 02 00              call    sub_7FF91E00BA00
00007FF91DFE9CAC  48 8D 05 79 12 60 00        lea     rax, aMCv; "M.CV"
00007FF91DFE9CB3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9CBA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9CBE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9CC2  48 8D 87 40 2A 00 00        lea     rax, [rdi+2A40h]
00007FF91DFE9CC9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9CD0  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9CD3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9CD7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9CDB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9CE0  E8 1B 1D 02 00              call    sub_7FF91E00BA00
00007FF91DFE9CE5  48 8D 05 48 12 60 00        lea     rax, aMGate; "M.Gate"
00007FF91DFE9CEC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9CF3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9CF7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9CFB  48 8D 87 50 2A 00 00        lea     rax, [rdi+2A50h]
00007FF91DFE9D02  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9D09  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9D0C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9D10  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9D14  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9D19  E8 E2 1C 02 00              call    sub_7FF91E00BA00
00007FF91DFE9D1E  66 0F 6F 05 0A 23 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9D26  48 8D 05 13 12 60 00        lea     rax, aMasterTune; "Master Tune"
00007FF91DFE9D2D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9D31  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9D35  48 8D 87 80 2A 00 00        lea     rax, [rdi+2A80h]
00007FF91DFE9D3C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9D43  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9D47  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9D4B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9D50  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9D57  E8 A4 1C 02 00              call    sub_7FF91E00BA00
00007FF91DFE9D5C  66 0F 6F 05 CC 22 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9D64  48 8D 05 E5 11 60 00        lea     rax, aPartTune; "Part Tune"
00007FF91DFE9D6B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9D6F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9D74  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9D7B  48 8D 87 90 2A 00 00        lea     rax, [rdi+2A90h]
00007FF91DFE9D82  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9D89  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9D8D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9D91  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9D95  E8 66 1C 02 00              call    sub_7FF91E00BA00
00007FF91DFE9D9A  48 8D 05 BF 11 60 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
00007FF91DFE9DA1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9DA8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9DAC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9DB0  48 8D 87 60 2B 00 00        lea     rax, [rdi+2B60h]
00007FF91DFE9DB7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9DBE  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9DC1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9DC5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9DC9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9DCE  E8 2D 1C 02 00              call    sub_7FF91E00BA00
00007FF91DFE9DD3  48 8D 05 9E 11 60 00        lea     rax, aPortamentoMode; "Portamento Mode"
00007FF91DFE9DDA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9DE1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9DE5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9DE9  48 8D 87 70 2B 00 00        lea     rax, [rdi+2B70h]
00007FF91DFE9DF0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9DF7  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9DFA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9DFE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9E02  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9E07  E8 F4 1B 02 00              call    sub_7FF91E00BA00
00007FF91DFE9E0C  66 0F 6F 05 1C 22 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9E14  48 8D 05 6D 11 60 00        lea     rax, aPortamentoTime; "Portamento Time"
00007FF91DFE9E1B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9E1F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9E23  48 8D 87 80 2B 00 00        lea     rax, [rdi+2B80h]
00007FF91DFE9E2A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9E31  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9E35  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9E39  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9E3E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9E45  E8 B6 1B 02 00              call    sub_7FF91E00BA00
00007FF91DFE9E4A  48 8D 05 47 11 60 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
00007FF91DFE9E51  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9E58  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9E5C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9E60  48 8D 87 20 2D 00 00        lea     rax, [rdi+2D20h]
00007FF91DFE9E67  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9E6E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9E71  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9E75  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9E79  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9E7E  E8 7D 1B 02 00              call    sub_7FF91E00BA00
00007FF91DFE9E83  48 8D 05 26 11 60 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
00007FF91DFE9E8A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9E91  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9E95  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9E99  48 8D 87 30 2D 00 00        lea     rax, [rdi+2D30h]
00007FF91DFE9EA0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9EA7  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9EAA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9EAE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9EB2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9EB7  E8 44 1B 02 00              call    sub_7FF91E00BA00
00007FF91DFE9EBC  48 8D 05 05 11 60 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
00007FF91DFE9EC3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9ECA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9ECE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9ED2  48 8D 87 40 2D 00 00        lea     rax, [rdi+2D40h]
00007FF91DFE9ED9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9EE0  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9EE3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9EE7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9EEB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9EF0  E8 0B 1B 02 00              call    sub_7FF91E00BA00
00007FF91DFE9EF5  66 0F 6F 05 33 21 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9EFD  48 8D 05 D4 10 60 00        lea     rax, aLfoRate; "LFO Rate"
00007FF91DFE9F04  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9F08  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9F0C  48 8D 87 50 2D 00 00        lea     rax, [rdi+2D50h]
00007FF91DFE9F13  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9F1A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9F1E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9F23  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9F2A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9F2E  E8 CD 1A 02 00              call    sub_7FF91E00BA00
00007FF91DFE9F33  48 8D 05 AA 10 60 00        lea     rax, aGate; "Gate"
00007FF91DFE9F3A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9F41  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9F45  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9F49  48 8D 87 50 30 00 00        lea     rax, [rdi+3050h]
00007FF91DFE9F50  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9F57  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9F5A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9F5E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9F62  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9F67  E8 94 1A 02 00              call    sub_7FF91E00BA00
00007FF91DFE9F6C  48 8D 05 7D 10 60 00        lea     rax, aLfoTrig; "LFO Trig"
00007FF91DFE9F73  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9F7A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9F7E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9F82  48 8D 87 60 30 00 00        lea     rax, [rdi+3060h]
00007FF91DFE9F89  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9F90  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9F93  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9F97  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9F9B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9FA0  E8 5B 1A 02 00              call    sub_7FF91E00BA00
00007FF91DFE9FA5  48 8D 05 54 10 60 00        lea     rax, aResetSw; "Reset Sw"
00007FF91DFE9FAC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFE9FB3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9FB7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9FBB  48 8D 87 70 30 00 00        lea     rax, [rdi+3070h]
00007FF91DFE9FC2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFE9FC9  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE9FCC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFE9FD0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFE9FD4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFE9FD9  E8 22 1A 02 00              call    sub_7FF91E00BA00
00007FF91DFE9FDE  66 0F 6F 05 4A 20 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFE9FE6  48 8D 05 23 10 60 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
00007FF91DFE9FED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFE9FF1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFE9FF5  48 8D 87 80 30 00 00        lea     rax, [rdi+3080h]
00007FF91DFE9FFC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA003  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA007  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA00B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA010  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA017  E8 E4 19 02 00              call    sub_7FF91E00BA00
00007FF91DFEA01C  66 0F 6F 05 0C 20 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA024  48 8D 05 F5 0F 60 00        lea     rax, aLfoDelay; "LFO Delay"
00007FF91DFEA02B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA02F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA033  48 8D 87 90 30 00 00        lea     rax, [rdi+3090h]
00007FF91DFEA03A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA041  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA045  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA049  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA04E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA055  E8 A6 19 02 00              call    sub_7FF91E00BA00
00007FF91DFEA05A  66 0F 6F 05 CE 1F 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA062  48 8D 05 C7 0F 60 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
00007FF91DFEA069  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA06D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA071  48 8D 87 A0 30 00 00        lea     rax, [rdi+30A0h]
00007FF91DFEA078  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA07F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA083  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA087  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA08C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA093  E8 68 19 02 00              call    sub_7FF91E00BA00
00007FF91DFEA098  66 0F 6F 05 90 1F 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA0A0  48 8D 05 99 0F 60 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
00007FF91DFEA0A7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA0AB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA0AF  48 8D 87 B0 30 00 00        lea     rax, [rdi+30B0h]
00007FF91DFEA0B6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA0BD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA0C1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA0C5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA0CA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA0D1  E8 2A 19 02 00              call    sub_7FF91E00BA00
00007FF91DFEA0D6  48 8D 05 73 0F 60 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
00007FF91DFEA0DD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA0E1  66 0F 6F 05 47 1F 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA0E9  48 8D 87 C0 30 00 00        lea     rax, [rdi+30C0h]
00007FF91DFEA0F0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA0F4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA0F8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA0FC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA103  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA108  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA10F  E8 EC 18 02 00              call    sub_7FF91E00BA00
00007FF91DFEA114  66 0F 6F 05 14 1F 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA11C  48 8D 05 3D 0F 60 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
00007FF91DFEA123  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA127  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA12B  48 8D 87 D0 30 00 00        lea     rax, [rdi+30D0h]
00007FF91DFEA132  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA139  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA13D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA141  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA146  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA14D  E8 AE 18 02 00              call    sub_7FF91E00BA00
00007FF91DFEA152  66 0F 6F 05 D6 1E 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA15A  48 8D 05 0F 0F 60 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
00007FF91DFEA161  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA165  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA169  48 8D 87 E0 30 00 00        lea     rax, [rdi+30E0h]
00007FF91DFEA170  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA177  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA17B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA17F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA184  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA18B  E8 70 18 02 00              call    sub_7FF91E00BA00
00007FF91DFEA190  66 0F 6F 05 98 1E 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA198  48 8D 05 E1 0E 60 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
00007FF91DFEA19F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA1A3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA1A7  48 8D 87 F0 30 00 00        lea     rax, [rdi+30F0h]
00007FF91DFEA1AE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA1B5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA1B9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA1BD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA1C2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA1C9  E8 32 18 02 00              call    sub_7FF91E00BA00
00007FF91DFEA1CE  66 0F 6F 05 5A 1E 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA1D6  48 8D 05 B3 0E 60 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
00007FF91DFEA1DD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA1E1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA1E5  48 8D 87 00 31 00 00        lea     rax, [rdi+3100h]
00007FF91DFEA1EC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA1F3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA1F7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA1FB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA200  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA207  E8 F4 17 02 00              call    sub_7FF91E00BA00
00007FF91DFEA20C  66 0F 6F 05 1C 1E 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA214  48 8D 05 85 0E 60 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
00007FF91DFEA21B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA21F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA223  48 8D 87 10 31 00 00        lea     rax, [rdi+3110h]
00007FF91DFEA22A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA231  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA235  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA239  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA23E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA245  E8 B6 17 02 00              call    sub_7FF91E00BA00
00007FF91DFEA24A  66 0F 6F 05 DE 1D 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA252  48 8D 05 57 0E 60 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
00007FF91DFEA259  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA25D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA261  48 8D 87 20 31 00 00        lea     rax, [rdi+3120h]
00007FF91DFEA268  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA26F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA273  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA277  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA27C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA283  E8 78 17 02 00              call    sub_7FF91E00BA00
00007FF91DFEA288  66 0F 6F 05 A0 1D 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA290  48 8D 05 29 0E 60 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
00007FF91DFEA297  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA29B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA2A0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA2A7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA2AE  48 8D 87 30 31 00 00        lea     rax, [rdi+3130h]
00007FF91DFEA2B5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA2B9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA2BD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA2C1  E8 3A 17 02 00              call    sub_7FF91E00BA00
00007FF91DFEA2C6  66 0F 6F 05 62 1D 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA2CE  48 8D 05 FB 0D 60 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
00007FF91DFEA2D5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA2D9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA2DD  48 8D 87 40 31 00 00        lea     rax, [rdi+3140h]
00007FF91DFEA2E4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA2EB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA2EF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA2F3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA2F8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA2FF  E8 FC 16 02 00              call    sub_7FF91E00BA00
00007FF91DFEA304  66 0F 6F 05 24 1D 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA30C  48 8D 05 D5 0D 60 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
00007FF91DFEA313  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA317  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA31B  48 8D 87 50 31 00 00        lea     rax, [rdi+3150h]
00007FF91DFEA322  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA329  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA32D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA331  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA336  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA33D  E8 BE 16 02 00              call    sub_7FF91E00BA00
00007FF91DFEA342  48 8D 05 B7 0D 60 00        lea     rax, aReadOnly; "read only"
00007FF91DFEA349  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA350  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA354  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA358  48 8D 87 F0 32 00 00        lea     rax, [rdi+32F0h]
00007FF91DFEA35F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA366  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEA369  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA36D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA371  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA376  E8 85 16 02 00              call    sub_7FF91E00BA00
00007FF91DFEA37B  48 8D 05 7E 0D 60 00        lea     rax, aReadOnly; "read only"
00007FF91DFEA382  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA389  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA38D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA391  48 8D 87 00 33 00 00        lea     rax, [rdi+3300h]
00007FF91DFEA398  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA39F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEA3A2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA3A6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA3AA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA3AF  E8 4C 16 02 00              call    sub_7FF91E00BA00
00007FF91DFEA3B4  48 8D 05 55 0D 60 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFEA3BB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA3C2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA3C6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA3CA  48 8D 87 10 33 00 00        lea     rax, [rdi+3310h]
00007FF91DFEA3D1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA3D8  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEA3DB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA3DF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA3E3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA3E8  E8 13 16 02 00              call    sub_7FF91E00BA00
00007FF91DFEA3ED  66 0F 6F 05 3B 1C 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA3F5  48 8D 05 2C 0D 60 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFEA3FC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA400  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA404  48 8D 87 F0 33 00 00        lea     rax, [rdi+33F0h]
00007FF91DFEA40B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA412  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA416  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA41A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA41F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA426  E8 D5 15 02 00              call    sub_7FF91E00BA00
00007FF91DFEA42B  66 0F 6F 05 FD 1B 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA433  48 8D 05 FE 0C 60 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFEA43A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA43E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA442  48 8D 87 00 34 00 00        lea     rax, [rdi+3400h]
00007FF91DFEA449  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA450  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA454  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA458  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA45D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA464  E8 97 15 02 00              call    sub_7FF91E00BA00
00007FF91DFEA469  66 0F 6F 05 BF 1B 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA471  48 8D 05 D0 0C 60 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFEA478  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA47C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA480  48 8D 87 10 34 00 00        lea     rax, [rdi+3410h]
00007FF91DFEA487  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA48E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA492  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA496  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA49B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA4A2  E8 59 15 02 00              call    sub_7FF91E00BA00
00007FF91DFEA4A7  66 0F 6F 05 81 1B 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA4AF  48 8D 05 A2 0C 60 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFEA4B6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA4BA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA4BE  48 8D 87 20 34 00 00        lea     rax, [rdi+3420h]
00007FF91DFEA4C5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA4CC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA4D0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA4D4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA4D9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA4E0  E8 1B 15 02 00              call    sub_7FF91E00BA00
00007FF91DFEA4E5  66 0F 6F 05 43 1B 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA4ED  48 8D 05 74 0C 60 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFEA4F4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA4F8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA4FC  48 8D 87 30 34 00 00        lea     rax, [rdi+3430h]
00007FF91DFEA503  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA50A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA50E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA512  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA517  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA51E  E8 DD 14 02 00              call    sub_7FF91E00BA00
00007FF91DFEA523  48 8D 05 E6 0B 60 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFEA52A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA531  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA535  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA539  48 8D 87 F0 34 00 00        lea     rax, [rdi+34F0h]
00007FF91DFEA540  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA547  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEA54A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA54E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA552  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA557  E8 A4 14 02 00              call    sub_7FF91E00BA00
00007FF91DFEA55C  66 0F 6F 05 CC 1A 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA564  48 8D 05 BD 0B 60 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFEA56B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA56F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA573  48 8D 87 D0 35 00 00        lea     rax, [rdi+35D0h]
00007FF91DFEA57A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA581  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA585  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA589  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA58E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA595  E8 66 14 02 00              call    sub_7FF91E00BA00
00007FF91DFEA59A  66 0F 6F 05 8E 1A 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA5A2  48 8D 05 8F 0B 60 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFEA5A9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA5AD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA5B1  48 8D 87 E0 35 00 00        lea     rax, [rdi+35E0h]
00007FF91DFEA5B8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA5BF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA5C3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA5C7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA5CC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA5D3  E8 28 14 02 00              call    sub_7FF91E00BA00
00007FF91DFEA5D8  66 0F 6F 05 50 1A 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA5E0  48 8D 05 61 0B 60 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFEA5E7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA5EB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA5EF  48 8D 87 F0 35 00 00        lea     rax, [rdi+35F0h]
00007FF91DFEA5F6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA5FD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA601  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA605  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA60A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA611  E8 EA 13 02 00              call    sub_7FF91E00BA00
00007FF91DFEA616  48 8D 05 3B 0B 60 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFEA61D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA624  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA628  66 0F 6F 05 00 1A 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA630  48 8D 87 00 36 00 00        lea     rax, [rdi+3600h]
00007FF91DFEA637  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA63B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA63F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA643  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA64A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA64F  E8 AC 13 02 00              call    sub_7FF91E00BA00
00007FF91DFEA654  66 0F 6F 05 D4 19 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA65C  48 8D 05 05 0B 60 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFEA663  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA667  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA66B  48 8D 87 10 36 00 00        lea     rax, [rdi+3610h]
00007FF91DFEA672  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA679  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA67D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA681  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA686  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA68D  E8 6E 13 02 00              call    sub_7FF91E00BA00
00007FF91DFEA692  48 8D 05 DF 0A 60 00        lea     rax, aOsc1Feet; "OSC1 Feet"
00007FF91DFEA699  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA6A0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA6A4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA6A8  48 8D 87 10 38 00 00        lea     rax, [rdi+3810h]
00007FF91DFEA6AF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA6B6  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEA6B9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA6BD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA6C1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA6C6  E8 35 13 02 00              call    sub_7FF91E00BA00
00007FF91DFEA6CB  48 8D 05 B6 0A 60 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
00007FF91DFEA6D2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA6D9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA6DD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA6E1  48 8D 87 20 38 00 00        lea     rax, [rdi+3820h]
00007FF91DFEA6E8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA6EF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEA6F2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA6F6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA6FA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA6FF  E8 FC 12 02 00              call    sub_7FF91E00BA00
00007FF91DFEA704  48 8D 05 8D 0A 60 00        lea     rax, aBendEnableSw; "Bend Enable SW"
00007FF91DFEA70B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA712  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA716  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA71A  48 8D 87 30 38 00 00        lea     rax, [rdi+3830h]
00007FF91DFEA721  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA728  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEA72B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA72F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA733  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA738  E8 C3 12 02 00              call    sub_7FF91E00BA00
00007FF91DFEA73D  48 8D 05 64 0A 60 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
00007FF91DFEA744  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA74B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA74F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA753  48 8D 87 40 38 00 00        lea     rax, [rdi+3840h]
00007FF91DFEA75A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA761  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEA764  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA768  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA76C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA771  E8 8A 12 02 00              call    sub_7FF91E00BA00
00007FF91DFEA776  48 8D 05 3B 0A 60 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
00007FF91DFEA77D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA784  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA788  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA78C  48 8D 87 50 38 00 00        lea     rax, [rdi+3850h]
00007FF91DFEA793  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA79A  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEA79D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA7A1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA7A5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA7AA  E8 51 12 02 00              call    sub_7FF91E00BA00
00007FF91DFEA7AF  48 8D 05 12 0A 60 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
00007FF91DFEA7B6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA7BD  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEA7C0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA7C4  48 8D 87 60 38 00 00        lea     rax, [rdi+3860h]
00007FF91DFEA7CB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA7D2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA7D7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA7DB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA7DF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA7E3  E8 18 12 02 00              call    sub_7FF91E00BA00
00007FF91DFEA7E8  48 8D 05 E9 09 60 00        lea     rax, aPwmSwManual; "PWM SW Manual"
00007FF91DFEA7EF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA7F6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA7FA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA7FE  48 8D 87 70 38 00 00        lea     rax, [rdi+3870h]
00007FF91DFEA805  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA80C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEA80F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA813  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA817  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA81C  E8 DF 11 02 00              call    sub_7FF91E00BA00
00007FF91DFEA821  66 0F 6F 05 07 18 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA829  48 8D 05 B8 09 60 00        lea     rax, aTune; "Tune"
00007FF91DFEA830  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA834  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA838  48 8D 87 80 38 00 00        lea     rax, [rdi+3880h]
00007FF91DFEA83F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA846  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA84A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA84E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA853  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA85A  E8 A1 11 02 00              call    sub_7FF91E00BA00
00007FF91DFEA85F  66 0F 6F 05 C9 17 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA867  48 8D 05 82 09 60 00        lea     rax, aDetune; "Detune"
00007FF91DFEA86E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA872  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA876  48 8D 87 90 38 00 00        lea     rax, [rdi+3890h]
00007FF91DFEA87D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA884  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA888  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA88C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA891  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA898  E8 63 11 02 00              call    sub_7FF91E00BA00
00007FF91DFEA89D  66 0F 6F 05 8B 17 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA8A5  48 8D 05 4C 09 60 00        lea     rax, aModSens; "Mod Sens"
00007FF91DFEA8AC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA8B0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA8B4  48 8D 87 A0 38 00 00        lea     rax, [rdi+38A0h]
00007FF91DFEA8BB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA8C2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA8C6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA8CA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA8CF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA8D6  E8 25 11 02 00              call    sub_7FF91E00BA00
00007FF91DFEA8DB  66 0F 6F 05 4D 17 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA8E3  48 8D 05 1A 09 60 00        lea     rax, aModSw; "Mod Sw"
00007FF91DFEA8EA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA8EE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA8F2  48 8D 87 B0 38 00 00        lea     rax, [rdi+38B0h]
00007FF91DFEA8F9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA900  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA904  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA908  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA90D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA914  E8 E7 10 02 00              call    sub_7FF91E00BA00
00007FF91DFEA919  66 0F 6F 05 0F 17 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA921  48 8D 05 E8 08 60 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFEA928  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA92C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA930  48 8D 87 C0 38 00 00        lea     rax, [rdi+38C0h]
00007FF91DFEA937  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA93E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA942  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA946  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA94B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA952  E8 A9 10 02 00              call    sub_7FF91E00BA00
00007FF91DFEA957  66 0F 6F 05 D1 16 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA95F  48 8D 05 BA 08 60 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFEA966  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA96A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA96E  48 8D 87 D0 38 00 00        lea     rax, [rdi+38D0h]
00007FF91DFEA975  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA97C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA980  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA984  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA989  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA990  E8 6B 10 02 00              call    sub_7FF91E00BA00
00007FF91DFEA995  66 0F 6F 05 93 16 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA99D  48 8D 05 88 08 60 00        lea     rax, aLfoSw; "LFO Sw"
00007FF91DFEA9A4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA9A8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA9AC  48 8D 87 E0 38 00 00        lea     rax, [rdi+38E0h]
00007FF91DFEA9B3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA9BA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA9BE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEA9C2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEA9C7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEA9CE  E8 2D 10 02 00              call    sub_7FF91E00BA00
00007FF91DFEA9D3  66 0F 6F 05 55 16 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEA9DB  48 8D 05 56 08 60 00        lea     rax, aEnv1Level; "ENV1 Level"
00007FF91DFEA9E2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEA9E6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEA9EA  48 8D 87 F0 38 00 00        lea     rax, [rdi+38F0h]
00007FF91DFEA9F1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEA9F8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEA9FC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAA00  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAA05  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAA0C  E8 EF 0F 02 00              call    sub_7FF91E00BA00
00007FF91DFEAA11  66 0F 6F 05 17 16 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAA19  48 8D 05 28 08 60 00        lea     rax, aEnv2Level; "ENV2 Level"
00007FF91DFEAA20  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAA24  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAA28  48 8D 87 00 39 00 00        lea     rax, [rdi+3900h]
00007FF91DFEAA2F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAA36  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAA3A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAA3E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAA43  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAA4A  E8 B1 0F 02 00              call    sub_7FF91E00BA00
00007FF91DFEAA4F  66 0F 6F 05 D9 15 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAA57  48 8D 05 F6 07 60 00        lea     rax, aEnvSw; "ENV Sw"
00007FF91DFEAA5E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAA62  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAA66  48 8D 87 10 39 00 00        lea     rax, [rdi+3910h]
00007FF91DFEAA6D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAA74  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAA78  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAA7C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAA81  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAA88  E8 73 0F 02 00              call    sub_7FF91E00BA00
00007FF91DFEAA8D  66 0F 6F 05 9B 15 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAA95  48 8D 05 C4 07 60 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFEAA9C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAAA0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAAA4  48 8D 87 20 39 00 00        lea     rax, [rdi+3920h]
00007FF91DFEAAAB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAAB2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAAB6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAABA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAABF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAAC6  E8 35 0F 02 00              call    sub_7FF91E00BA00
00007FF91DFEAACB  66 0F 6F 05 5D 15 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAAD3  48 8D 05 96 07 60 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFEAADA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAADE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAAE2  48 8D 87 30 39 00 00        lea     rax, [rdi+3930h]
00007FF91DFEAAE9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAAF0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAAF4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAAF8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAAFD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAB04  E8 F7 0E 02 00              call    sub_7FF91E00BA00
00007FF91DFEAB09  66 0F 6F 05 1F 15 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAB11  48 8D 05 68 07 60 00        lea     rax, aPwmLevel; "PWM Level"
00007FF91DFEAB18  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAB1C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAB20  48 8D 87 40 39 00 00        lea     rax, [rdi+3940h]
00007FF91DFEAB27  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAB2E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAB32  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAB36  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAB3B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAB42  E8 B9 0E 02 00              call    sub_7FF91E00BA00
00007FF91DFEAB47  66 0F 6F 05 E1 14 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAB4F  48 8D 05 3A 07 60 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
00007FF91DFEAB56  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAB5A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAB61  48 8D 87 70 39 00 00        lea     rax, [rdi+3970h]
00007FF91DFEAB68  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAB6F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAB73  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAB77  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAB7B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAB80  E8 7B 0E 02 00              call    sub_7FF91E00BA00
00007FF91DFEAB85  66 0F 6F 05 A3 14 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAB8D  48 8D 05 0C 07 60 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
00007FF91DFEAB94  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAB98  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAB9C  48 8D 87 80 39 00 00        lea     rax, [rdi+3980h]
00007FF91DFEABA3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEABAA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEABAE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEABB2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEABB7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEABBE  E8 3D 0E 02 00              call    sub_7FF91E00BA00
00007FF91DFEABC3  66 0F 6F 05 65 14 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEABCB  48 8D 05 DE 06 60 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
00007FF91DFEABD2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEABD6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEABDA  48 8D 87 90 39 00 00        lea     rax, [rdi+3990h]
00007FF91DFEABE1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEABE8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEABEC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEABF0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEABF5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEABFC  E8 FF 0D 02 00              call    sub_7FF91E00BA00
00007FF91DFEAC01  66 0F 6F 05 27 14 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAC09  48 8D 05 B0 06 60 00        lea     rax, aDutyTune; "Duty Tune"
00007FF91DFEAC10  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAC14  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAC18  48 8D 87 A0 3E 00 00        lea     rax, [rdi+3EA0h]
00007FF91DFEAC1F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAC26  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAC2A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAC2E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAC33  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAC3A  E8 C1 0D 02 00              call    sub_7FF91E00BA00
00007FF91DFEAC3F  66 0F 6F 05 E9 13 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAC47  48 8D 05 82 06 60 00        lea     rax, aOsc1Mute; "Osc1 Mute"
00007FF91DFEAC4E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAC52  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAC56  48 8D 87 40 42 00 00        lea     rax, [rdi+4240h]
00007FF91DFEAC5D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAC64  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAC68  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAC6C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAC71  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAC78  E8 83 0D 02 00              call    sub_7FF91E00BA00
00007FF91DFEAC7D  66 0F 6F 05 AB 13 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAC85  48 8D 05 54 06 60 00        lea     rax, aOsc1Level; "Osc1 Level"
00007FF91DFEAC8C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAC90  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAC94  48 8D 87 80 42 00 00        lea     rax, [rdi+4280h]
00007FF91DFEAC9B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEACA2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEACA6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEACAA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEACAF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEACB6  E8 45 0D 02 00              call    sub_7FF91E00BA00
00007FF91DFEACBB  66 0F 6F 05 6D 13 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEACC3  48 8D 05 26 06 60 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
00007FF91DFEACCA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEACCE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEACD2  48 8D 87 90 42 00 00        lea     rax, [rdi+4290h]
00007FF91DFEACD9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEACE0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEACE4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEACE8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEACED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEACF4  E8 07 0D 02 00              call    sub_7FF91E00BA00
00007FF91DFEACF9  48 8D 05 00 06 60 00        lea     rax, aGrifferSw; "Griffer SW"
00007FF91DFEAD00  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAD07  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAD0B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEAD0E  48 8D 87 50 43 00 00        lea     rax, [rdi+4350h]
00007FF91DFEAD15  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAD1C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAD20  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAD25  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAD29  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAD2D  E8 CE 0C 02 00              call    sub_7FF91E00BA00
00007FF91DFEAD32  66 0F 6F 05 F6 12 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAD3A  48 8D 05 CF 05 60 00        lea     rax, aLpfCutoff; "LPF Cutoff"
00007FF91DFEAD41  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAD45  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAD49  48 8D 87 60 43 00 00        lea     rax, [rdi+4360h]
00007FF91DFEAD50  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAD57  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAD5B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAD5F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAD64  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAD6B  E8 90 0C 02 00              call    sub_7FF91E00BA00
00007FF91DFEAD70  66 0F 6F 05 B8 12 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAD78  48 8D 05 A1 05 60 00        lea     rax, aLpfResonance; "LPF Resonance"
00007FF91DFEAD7F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAD83  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAD87  48 8D 87 C0 43 00 00        lea     rax, [rdi+43C0h]
00007FF91DFEAD8E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAD95  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAD99  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAD9D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEADA2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEADA9  E8 52 0C 02 00              call    sub_7FF91E00BA00
00007FF91DFEADAE  48 8D 05 7B 05 60 00        lea     rax, aVelocity; "Velocity"
00007FF91DFEADB5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEADBC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEADC0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEADC4  48 8D 87 E0 43 00 00        lea     rax, [rdi+43E0h]
00007FF91DFEADCB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEADD2  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEADD5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEADD9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEADDD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEADE2  E8 19 0C 02 00              call    sub_7FF91E00BA00
00007FF91DFEADE7  48 8D 05 4E 05 60 00        lea     rax, aEnv12; "Env1/2"
00007FF91DFEADEE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEADF5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEADF9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEADFD  48 8D 87 70 44 00 00        lea     rax, [rdi+4470h]
00007FF91DFEAE04  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAE0B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEAE0E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAE12  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAE16  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAE1B  E8 E0 0B 02 00              call    sub_7FF91E00BA00
00007FF91DFEAE20  48 8D 05 21 05 60 00        lea     rax, aIntEnv; "Int/Env"
00007FF91DFEAE27  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAE2E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAE32  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAE36  48 8D 87 80 44 00 00        lea     rax, [rdi+4480h]
00007FF91DFEAE3D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAE44  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEAE47  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAE4B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAE4F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAE54  E8 A7 0B 02 00              call    sub_7FF91E00BA00
00007FF91DFEAE59  48 8D 05 B0 03 60 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFEAE60  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAE67  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAE6B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAE6F  48 8D 87 90 45 00 00        lea     rax, [rdi+4590h]
00007FF91DFEAE76  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAE7D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEAE80  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAE84  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAE88  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAE8D  E8 6E 0B 02 00              call    sub_7FF91E00BA00
00007FF91DFEAE92  48 8D 05 B7 04 60 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
00007FF91DFEAE99  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAEA0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAEA4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAEA8  48 8D 87 A0 45 00 00        lea     rax, [rdi+45A0h]
00007FF91DFEAEAF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAEB6  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEAEB9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAEBD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAEC1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAEC6  E8 35 0B 02 00              call    sub_7FF91E00BA00
00007FF91DFEAECB  48 8D 05 8E 04 60 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
00007FF91DFEAED2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAED6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAEDA  48 8D 87 B0 45 00 00        lea     rax, [rdi+45B0h]
00007FF91DFEAEE1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAEE8  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEAEEB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAEEF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAEF3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAEFA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAEFF  E8 FC 0A 02 00              call    sub_7FF91E00BA00
00007FF91DFEAF04  66 0F 6F 05 24 11 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAF0C  48 8D 05 0D 03 60 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFEAF13  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAF17  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAF1B  48 8D 87 C0 45 00 00        lea     rax, [rdi+45C0h]
00007FF91DFEAF22  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAF29  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAF2D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAF31  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAF36  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAF3D  E8 BE 0A 02 00              call    sub_7FF91E00BA00
00007FF91DFEAF42  66 0F 6F 05 E6 10 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAF4A  48 8D 05 1F 04 60 00        lea     rax, aModSens_0; "MOD Sens"
00007FF91DFEAF51  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAF55  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAF59  48 8D 87 D0 45 00 00        lea     rax, [rdi+45D0h]
00007FF91DFEAF60  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAF67  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAF6B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAF6F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAF74  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAF7B  E8 80 0A 02 00              call    sub_7FF91E00BA00
00007FF91DFEAF80  66 0F 6F 05 A8 10 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAF88  48 8D 05 ED 03 60 00        lea     rax, aModSw_0; "MOD SW"
00007FF91DFEAF8F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAF93  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAF97  48 8D 87 E0 45 00 00        lea     rax, [rdi+45E0h]
00007FF91DFEAF9E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAFA5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAFA9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAFAD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAFB2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAFB9  E8 42 0A 02 00              call    sub_7FF91E00BA00
00007FF91DFEAFBE  66 0F 6F 05 6A 10 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEAFC6  48 8D 05 BB 03 60 00        lea     rax, aEnvLevel; "ENV Level"
00007FF91DFEAFCD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEAFD1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEAFD5  48 8D 87 F0 45 00 00        lea     rax, [rdi+45F0h]
00007FF91DFEAFDC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEAFE3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEAFE7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEAFEB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEAFF0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEAFF7  E8 04 0A 02 00              call    sub_7FF91E00BA00
00007FF91DFEAFFC  66 0F 6F 05 2C 10 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB004  48 8D 05 8D 03 60 00        lea     rax, aKcvLevel; "KCV Level"
00007FF91DFEB00B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB00F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB013  48 8D 87 00 46 00 00        lea     rax, [rdi+4600h]
00007FF91DFEB01A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB021  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB025  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB029  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB02E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB035  E8 C6 09 02 00              call    sub_7FF91E00BA00
00007FF91DFEB03A  66 0F 6F 05 EE 0F 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB042  48 8D 05 5F 03 60 00        lea     rax, aVelocitySens; "Velocity Sens"
00007FF91DFEB049  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB04D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB051  48 8D 87 10 46 00 00        lea     rax, [rdi+4610h]
00007FF91DFEB058  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB05F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB063  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB067  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB06C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB073  E8 88 09 02 00              call    sub_7FF91E00BA00
00007FF91DFEB078  66 0F 6F 05 B0 0F 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB080  48 8D 05 31 03 60 00        lea     rax, aVelocityOffset; "Velocity Offset"
00007FF91DFEB087  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB08B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB090  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB097  48 8D 87 20 46 00 00        lea     rax, [rdi+4620h]
00007FF91DFEB09E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB0A5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB0A9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB0AD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB0B1  E8 4A 09 02 00              call    sub_7FF91E00BA00
00007FF91DFEB0B6  66 0F 6F 05 72 0F 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB0BE  48 8D 05 9B 01 60 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFEB0C5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB0C9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB0CD  48 8D 87 30 46 00 00        lea     rax, [rdi+4630h]
00007FF91DFEB0D4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB0DB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB0DF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB0E3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB0E8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB0EF  E8 0C 09 02 00              call    sub_7FF91E00BA00
00007FF91DFEB0F4  66 0F 6F 05 34 0F 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB0FC  48 8D 05 6D 01 60 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFEB103  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB107  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB10B  48 8D 87 40 46 00 00        lea     rax, [rdi+4640h]
00007FF91DFEB112  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB119  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB11D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB121  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB126  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB12D  E8 CE 08 02 00              call    sub_7FF91E00BA00
00007FF91DFEB132  66 0F 6F 05 F6 0E 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB13A  48 8D 05 87 02 60 00        lea     rax, aCutoffTune; "Cutoff Tune"
00007FF91DFEB141  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB145  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB149  48 8D 87 C0 46 00 00        lea     rax, [rdi+46C0h]
00007FF91DFEB150  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB157  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB15B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB15F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB164  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB16B  E8 90 08 02 00              call    sub_7FF91E00BA00
00007FF91DFEB170  66 0F 6F 05 B8 0E 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB178  48 8D 05 59 02 60 00        lea     rax, aResonanceTune; "Resonance Tune"
00007FF91DFEB17F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB183  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB187  48 8D 87 D0 46 00 00        lea     rax, [rdi+46D0h]
00007FF91DFEB18E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB195  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB199  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB19D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB1A2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB1A9  E8 52 08 02 00              call    sub_7FF91E00BA00
00007FF91DFEB1AE  48 8D 05 33 02 60 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFEB1B5  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFEB1BC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB1C0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB1C4  48 8D 87 E0 46 00 00        lea     rax, [rdi+46E0h]
00007FF91DFEB1CB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB1D2  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB1D5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB1D9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB1DD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB1E2  E8 19 08 02 00              call    sub_7FF91E00BA00
00007FF91DFEB1E7  48 8D 05 FA 01 60 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFEB1EE  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFEB1F5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB1F9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB1FD  48 8D 87 70 4C 00 00        lea     rax, [rdi+4C70h]
00007FF91DFEB204  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB20B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB20E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB212  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB216  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB21B  E8 E0 07 02 00              call    sub_7FF91E00BA00
00007FF91DFEB220  66 0F 6F 05 08 0E 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB228  48 8D 05 C9 01 60 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
00007FF91DFEB22F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB233  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB237  48 8D 87 80 4C 00 00        lea     rax, [rdi+4C80h]
00007FF91DFEB23E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB245  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB249  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB24E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB255  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB259  E8 A2 07 02 00              call    sub_7FF91E00BA00
00007FF91DFEB25E  66 0F 6F 05 CA 0D 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB266  48 8D 05 9B 01 60 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
00007FF91DFEB26D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB271  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB275  48 8D 87 90 4C 00 00        lea     rax, [rdi+4C90h]
00007FF91DFEB27C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB283  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB287  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB28B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB290  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB297  E8 64 07 02 00              call    sub_7FF91E00BA00
00007FF91DFEB29C  66 0F 6F 05 8C 0D 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB2A4  48 8D 05 6D 01 60 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
00007FF91DFEB2AB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB2AF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB2B3  48 8D 87 A0 4C 00 00        lea     rax, [rdi+4CA0h]
00007FF91DFEB2BA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB2C1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB2C5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB2C9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB2CE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB2D5  E8 26 07 02 00              call    sub_7FF91E00BA00
00007FF91DFEB2DA  66 0F 6F 05 4E 0D 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB2E2  48 8D 05 3F 01 60 00        lea     rax, aAmpTone; "AMP TONE"
00007FF91DFEB2E9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB2ED  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB2F1  48 8D 87 80 4E 00 00        lea     rax, [rdi+4E80h]
00007FF91DFEB2F8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB2FF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB303  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB307  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB30C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB313  E8 E8 06 02 00              call    sub_7FF91E00BA00
00007FF91DFEB318  66 0F 6F 05 10 0D 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB320  48 8D 05 11 01 60 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
00007FF91DFEB327  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB32B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB32F  48 8D 87 90 4E 00 00        lea     rax, [rdi+4E90h]
00007FF91DFEB336  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB33D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB341  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB345  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB34A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB351  E8 AA 06 02 00              call    sub_7FF91E00BA00
00007FF91DFEB356  66 0F 6F 05 D2 0C 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB35E  48 8D 05 EB 00 60 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
00007FF91DFEB365  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB369  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB36D  48 8D 87 A0 4E 00 00        lea     rax, [rdi+4EA0h]
00007FF91DFEB374  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB37B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB37F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB383  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB388  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB38F  E8 6C 06 02 00              call    sub_7FF91E00BA00
00007FF91DFEB394  48 8D 05 95 FF 5F 00        lea     rax, aVelocity; "Velocity"
00007FF91DFEB39B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB3A2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB3A6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB3AA  48 8D 87 E0 4E 00 00        lea     rax, [rdi+4EE0h]
00007FF91DFEB3B1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB3B8  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB3BB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB3BF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB3C3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB3C8  E8 33 06 02 00              call    sub_7FF91E00BA00
00007FF91DFEB3CD  48 8D 05 94 00 60 00        lea     rax, aMute; "Mute"
00007FF91DFEB3D4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB3DB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB3DF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB3E3  48 8D 87 70 4F 00 00        lea     rax, [rdi+4F70h]
00007FF91DFEB3EA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB3F1  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB3F4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB3F8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB3FC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB401  E8 FA 05 02 00              call    sub_7FF91E00BA00
00007FF91DFEB406  48 8D 05 63 00 60 00        lea     rax, aGateSw; "Gate SW"
00007FF91DFEB40D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB411  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB414  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB41B  48 8D 87 D0 50 00 00        lea     rax, [rdi+50D0h]
00007FF91DFEB422  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB429  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB42D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB431  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB435  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB43A  E8 C1 05 02 00              call    sub_7FF91E00BA00
00007FF91DFEB43F  48 8D 05 32 00 60 00        lea     rax, aEnv1Sw; "ENV1 SW"
00007FF91DFEB446  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB44D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB451  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB455  48 8D 87 E0 50 00 00        lea     rax, [rdi+50E0h]
00007FF91DFEB45C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB463  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB466  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB46A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB46E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB473  E8 88 05 02 00              call    sub_7FF91E00BA00
00007FF91DFEB478  48 8D 05 01 00 60 00        lea     rax, aEnv2Sw; "ENV2 SW"
00007FF91DFEB47F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB486  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB48A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB48E  48 8D 87 F0 50 00 00        lea     rax, [rdi+50F0h]
00007FF91DFEB495  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB49C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB49F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB4A3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB4A7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB4AC  E8 4F 05 02 00              call    sub_7FF91E00BA00
00007FF91DFEB4B1  48 8D 05 D0 FF 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
00007FF91DFEB4B8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB4BF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB4C3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB4C7  48 8D 87 00 51 00 00        lea     rax, [rdi+5100h]
00007FF91DFEB4CE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB4D5  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB4D8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB4DC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB4E0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB4E5  E8 16 05 02 00              call    sub_7FF91E00BA00
00007FF91DFEB4EA  66 0F 6F 05 3E 0B 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB4F2  48 8D 05 9F FF 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
00007FF91DFEB4F9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB4FD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB501  48 8D 87 10 51 00 00        lea     rax, [rdi+5110h]
00007FF91DFEB508  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB50F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB513  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB517  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB51C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB523  E8 D8 04 02 00              call    sub_7FF91E00BA00
00007FF91DFEB528  66 0F 6F 05 00 0B 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB530  48 8D 05 71 FF 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
00007FF91DFEB537  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB53B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB53F  48 8D 87 20 51 00 00        lea     rax, [rdi+5120h]
00007FF91DFEB546  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB54D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB551  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB555  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB55A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB561  E8 9A 04 02 00              call    sub_7FF91E00BA00
00007FF91DFEB566  66 0F 6F 05 C2 0A 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB56E  48 8D 05 43 FF 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
00007FF91DFEB575  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB579  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB57D  48 8D 87 30 51 00 00        lea     rax, [rdi+5130h]
00007FF91DFEB584  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB58B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB58F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB593  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB598  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB59F  E8 5C 04 02 00              call    sub_7FF91E00BA00
00007FF91DFEB5A4  66 0F 6F 05 84 0A 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB5AC  48 8D 05 15 FF 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
00007FF91DFEB5B3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB5B7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB5BC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB5C3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB5CA  48 8D 87 40 51 00 00        lea     rax, [rdi+5140h]
00007FF91DFEB5D1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB5D5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB5D9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB5DD  E8 1E 04 02 00              call    sub_7FF91E00BA00
00007FF91DFEB5E2  66 0F 6F 05 46 0A 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB5EA  48 8D 05 EF FE 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
00007FF91DFEB5F1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB5F5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB5F9  48 8D 87 50 51 00 00        lea     rax, [rdi+5150h]
00007FF91DFEB600  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB607  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB60B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB60F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB614  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB61B  E8 E0 03 02 00              call    sub_7FF91E00BA00
00007FF91DFEB620  66 0F 6F 05 08 0A 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB628  48 8D 05 C1 FE 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
00007FF91DFEB62F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB633  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB637  48 8D 87 60 51 00 00        lea     rax, [rdi+5160h]
00007FF91DFEB63E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB645  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB649  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB64D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB652  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB659  E8 A2 03 02 00              call    sub_7FF91E00BA00
00007FF91DFEB65E  48 8D 05 BB F8 5F 00        lea     rax, aUseextjack; "UseExtJack"
00007FF91DFEB665  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB66C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB670  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB674  48 8D 87 30 53 00 00        lea     rax, [rdi+5330h]
00007FF91DFEB67B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB682  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB685  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB689  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB68D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB692  E8 69 03 02 00              call    sub_7FF91E00BA00
00007FF91DFEB697  48 8D 05 8E F8 5F 00        lea     rax, aMCv; "M.CV"
00007FF91DFEB69E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB6A5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB6A9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB6AD  48 8D 87 50 53 00 00        lea     rax, [rdi+5350h]
00007FF91DFEB6B4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB6BB  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB6BE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB6C2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB6C6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB6CB  E8 30 03 02 00              call    sub_7FF91E00BA00
00007FF91DFEB6D0  48 8D 05 5D F8 5F 00        lea     rax, aMGate; "M.Gate"
00007FF91DFEB6D7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB6DE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB6E2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB6E6  48 8D 87 60 53 00 00        lea     rax, [rdi+5360h]
00007FF91DFEB6ED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB6F4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB6F7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB6FB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB6FF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB704  E8 F7 02 02 00              call    sub_7FF91E00BA00
00007FF91DFEB709  66 0F 6F 05 1F 09 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB711  48 8D 05 28 F8 5F 00        lea     rax, aMasterTune; "Master Tune"
00007FF91DFEB718  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB71C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB720  48 8D 87 90 53 00 00        lea     rax, [rdi+5390h]
00007FF91DFEB727  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB72E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB732  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB736  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB73B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB742  E8 B9 02 02 00              call    sub_7FF91E00BA00
00007FF91DFEB747  66 0F 6F 05 E1 08 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB74F  48 8D 05 FA F7 5F 00        lea     rax, aPartTune; "Part Tune"
00007FF91DFEB756  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB75A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB75E  48 8D 87 A0 53 00 00        lea     rax, [rdi+53A0h]
00007FF91DFEB765  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB76C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB770  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB774  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB779  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB780  E8 7B 02 02 00              call    sub_7FF91E00BA00
00007FF91DFEB785  48 8D 05 D4 F7 5F 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
00007FF91DFEB78C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB793  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB797  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB79B  48 8D 87 70 54 00 00        lea     rax, [rdi+5470h]
00007FF91DFEB7A2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB7A9  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB7AC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB7B0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB7B4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB7B9  E8 42 02 02 00              call    sub_7FF91E00BA00
00007FF91DFEB7BE  48 8D 05 B3 F7 5F 00        lea     rax, aPortamentoMode; "Portamento Mode"
00007FF91DFEB7C5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB7CC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB7D0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB7D4  48 8D 87 80 54 00 00        lea     rax, [rdi+5480h]
00007FF91DFEB7DB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB7E2  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB7E5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB7E9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB7ED  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB7F2  E8 09 02 02 00              call    sub_7FF91E00BA00
00007FF91DFEB7F7  66 0F 6F 05 31 08 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB7FF  48 8D 05 82 F7 5F 00        lea     rax, aPortamentoTime; "Portamento Time"
00007FF91DFEB806  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB80A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB80E  48 8D 87 90 54 00 00        lea     rax, [rdi+5490h]
00007FF91DFEB815  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB81C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB820  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB824  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB829  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB830  E8 CB 01 02 00              call    sub_7FF91E00BA00
00007FF91DFEB835  48 8D 05 5C F7 5F 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
00007FF91DFEB83C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB843  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB847  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB84B  48 8D 87 30 56 00 00        lea     rax, [rdi+5630h]
00007FF91DFEB852  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB859  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB85C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB860  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB864  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB869  E8 92 01 02 00              call    sub_7FF91E00BA00
00007FF91DFEB86E  48 8D 05 3B F7 5F 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
00007FF91DFEB875  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB87C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB880  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB884  48 8D 87 40 56 00 00        lea     rax, [rdi+5640h]
00007FF91DFEB88B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB892  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB895  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB899  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB89D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB8A2  E8 59 01 02 00              call    sub_7FF91E00BA00
00007FF91DFEB8A7  48 8D 05 1A F7 5F 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
00007FF91DFEB8AE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB8B5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB8B9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB8BD  48 8D 87 50 56 00 00        lea     rax, [rdi+5650h]
00007FF91DFEB8C4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB8CB  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB8CE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB8D2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB8D6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB8DB  E8 20 01 02 00              call    sub_7FF91E00BA00
00007FF91DFEB8E0  66 0F 6F 05 48 07 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB8E8  48 8D 05 E9 F6 5F 00        lea     rax, aLfoRate; "LFO Rate"
00007FF91DFEB8EF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB8F3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB8F7  48 8D 87 60 56 00 00        lea     rax, [rdi+5660h]
00007FF91DFEB8FE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB905  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB909  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB90D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB912  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB919  E8 E2 00 02 00              call    sub_7FF91E00BA00
00007FF91DFEB91E  48 8D 05 BF F6 5F 00        lea     rax, aGate; "Gate"
00007FF91DFEB925  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB92C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB930  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB933  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB93A  48 8D 87 60 59 00 00        lea     rax, [rdi+5960h]
00007FF91DFEB941  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB945  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB949  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB94D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB952  E8 A9 00 02 00              call    sub_7FF91E00BA00
00007FF91DFEB957  48 8D 05 92 F6 5F 00        lea     rax, aLfoTrig; "LFO Trig"
00007FF91DFEB95E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB965  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB969  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB96D  48 8D 87 70 59 00 00        lea     rax, [rdi+5970h]
00007FF91DFEB974  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB97B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB97E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB982  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB986  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB98B  E8 70 00 02 00              call    sub_7FF91E00BA00
00007FF91DFEB990  48 8D 05 69 F6 5F 00        lea     rax, aResetSw; "Reset Sw"
00007FF91DFEB997  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB99E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB9A2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB9A6  48 8D 87 80 59 00 00        lea     rax, [rdi+5980h]
00007FF91DFEB9AD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEB9B4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEB9B7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB9BB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB9BF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB9C4  E8 37 00 02 00              call    sub_7FF91E00BA00
00007FF91DFEB9C9  66 0F 6F 05 5F 06 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEB9D1  48 8D 05 38 F6 5F 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
00007FF91DFEB9D8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEB9DC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEB9E0  48 8D 87 90 59 00 00        lea     rax, [rdi+5990h]
00007FF91DFEB9E7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEB9EE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEB9F2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEB9F6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEB9FB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBA02  E8 F9 FF 01 00              call    sub_7FF91E00BA00
00007FF91DFEBA07  66 0F 6F 05 21 06 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBA0F  48 8D 05 0A F6 5F 00        lea     rax, aLfoDelay; "LFO Delay"
00007FF91DFEBA16  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBA1A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBA1E  48 8D 87 A0 59 00 00        lea     rax, [rdi+59A0h]
00007FF91DFEBA25  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBA2C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBA30  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBA34  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBA39  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBA40  E8 BB FF 01 00              call    sub_7FF91E00BA00
00007FF91DFEBA45  66 0F 6F 05 E3 05 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBA4D  48 8D 05 DC F5 5F 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
00007FF91DFEBA54  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBA58  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBA5C  48 8D 87 B0 59 00 00        lea     rax, [rdi+59B0h]
00007FF91DFEBA63  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBA6A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBA6E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBA72  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBA77  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBA7E  E8 7D FF 01 00              call    sub_7FF91E00BA00
00007FF91DFEBA83  66 0F 6F 05 A5 05 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBA8B  48 8D 05 AE F5 5F 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
00007FF91DFEBA92  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBA96  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBA9A  48 8D 87 C0 59 00 00        lea     rax, [rdi+59C0h]
00007FF91DFEBAA1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBAA8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBAAC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBAB0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBAB5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBABC  E8 3F FF 01 00              call    sub_7FF91E00BA00
00007FF91DFEBAC1  66 0F 6F 05 67 05 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBAC9  48 8D 05 80 F5 5F 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
00007FF91DFEBAD0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBAD4  48 8D 87 D0 59 00 00        lea     rax, [rdi+59D0h]
00007FF91DFEBADB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBAE2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBAE7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBAEE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBAF2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBAF6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBAFA  E8 01 FF 01 00              call    sub_7FF91E00BA00
00007FF91DFEBAFF  66 0F 6F 05 29 05 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBB07  48 8D 05 52 F5 5F 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
00007FF91DFEBB0E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBB12  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBB16  48 8D 87 E0 59 00 00        lea     rax, [rdi+59E0h]
00007FF91DFEBB1D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBB24  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBB28  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBB2C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBB31  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBB38  E8 C3 FE 01 00              call    sub_7FF91E00BA00
00007FF91DFEBB3D  66 0F 6F 05 EB 04 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBB45  48 8D 05 24 F5 5F 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
00007FF91DFEBB4C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBB50  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBB54  48 8D 87 F0 59 00 00        lea     rax, [rdi+59F0h]
00007FF91DFEBB5B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBB62  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBB66  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBB6A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBB6F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBB76  E8 85 FE 01 00              call    sub_7FF91E00BA00
00007FF91DFEBB7B  66 0F 6F 05 AD 04 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBB83  48 8D 05 F6 F4 5F 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
00007FF91DFEBB8A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBB8E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBB92  48 8D 87 00 5A 00 00        lea     rax, [rdi+5A00h]
00007FF91DFEBB99  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBBA0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBBA4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBBA8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBBAD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBBB4  E8 47 FE 01 00              call    sub_7FF91E00BA00
00007FF91DFEBBB9  66 0F 6F 05 6F 04 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBBC1  48 8D 05 C8 F4 5F 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
00007FF91DFEBBC8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBBCC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBBD0  48 8D 87 10 5A 00 00        lea     rax, [rdi+5A10h]
00007FF91DFEBBD7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBBDE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBBE2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBBE6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBBEB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBBF2  E8 09 FE 01 00              call    sub_7FF91E00BA00
00007FF91DFEBBF7  66 0F 6F 05 31 04 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBBFF  48 8D 05 9A F4 5F 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
00007FF91DFEBC06  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBC0A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBC0E  48 8D 87 20 5A 00 00        lea     rax, [rdi+5A20h]
00007FF91DFEBC15  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBC1C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBC20  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBC24  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBC29  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBC30  E8 CB FD 01 00              call    sub_7FF91E00BA00
00007FF91DFEBC35  66 0F 6F 05 F3 03 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBC3D  48 8D 05 6C F4 5F 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
00007FF91DFEBC44  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBC48  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBC4C  48 8D 87 30 5A 00 00        lea     rax, [rdi+5A30h]
00007FF91DFEBC53  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBC5A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBC5E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBC62  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBC67  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBC6E  E8 8D FD 01 00              call    sub_7FF91E00BA00
00007FF91DFEBC73  66 0F 6F 05 B5 03 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBC7B  48 8D 05 3E F4 5F 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
00007FF91DFEBC82  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBC86  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBC8A  48 8D 87 40 5A 00 00        lea     rax, [rdi+5A40h]
00007FF91DFEBC91  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBC98  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBC9C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBCA0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBCA5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBCAC  E8 4F FD 01 00              call    sub_7FF91E00BA00
00007FF91DFEBCB1  66 0F 6F 05 77 03 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBCB9  48 8D 05 10 F4 5F 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
00007FF91DFEBCC0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBCC4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBCC8  48 8D 87 50 5A 00 00        lea     rax, [rdi+5A50h]
00007FF91DFEBCCF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBCD6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBCDA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBCDE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBCE3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBCEA  E8 11 FD 01 00              call    sub_7FF91E00BA00
00007FF91DFEBCEF  66 0F 6F 05 39 03 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBCF7  48 8D 05 EA F3 5F 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
00007FF91DFEBCFE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBD02  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBD06  48 8D 87 60 5A 00 00        lea     rax, [rdi+5A60h]
00007FF91DFEBD0D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBD14  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBD18  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBD1C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBD21  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBD28  E8 D3 FC 01 00              call    sub_7FF91E00BA00
00007FF91DFEBD2D  48 8D 05 CC F3 5F 00        lea     rax, aReadOnly; "read only"
00007FF91DFEBD34  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBD3B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBD3F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBD43  48 8D 87 00 5C 00 00        lea     rax, [rdi+5C00h]
00007FF91DFEBD4A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBD51  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEBD54  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBD58  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBD5C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBD61  E8 9A FC 01 00              call    sub_7FF91E00BA00
00007FF91DFEBD66  48 8D 05 93 F3 5F 00        lea     rax, aReadOnly; "read only"
00007FF91DFEBD6D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBD74  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBD78  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBD7C  48 8D 87 10 5C 00 00        lea     rax, [rdi+5C10h]
00007FF91DFEBD83  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBD8A  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEBD8D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBD91  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBD95  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBD9A  E8 61 FC 01 00              call    sub_7FF91E00BA00
00007FF91DFEBD9F  48 8D 05 6A F3 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFEBDA6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBDAD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBDB1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBDB5  48 8D 87 20 5C 00 00        lea     rax, [rdi+5C20h]
00007FF91DFEBDBC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBDC3  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEBDC6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBDCA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBDCE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBDD3  E8 28 FC 01 00              call    sub_7FF91E00BA00
00007FF91DFEBDD8  66 0F 6F 05 50 02 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBDE0  48 8D 05 41 F3 5F 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFEBDE7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBDEB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBDEF  48 8D 87 00 5D 00 00        lea     rax, [rdi+5D00h]
00007FF91DFEBDF6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBDFD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBE01  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBE05  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBE0A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBE11  E8 EA FB 01 00              call    sub_7FF91E00BA00
00007FF91DFEBE16  66 0F 6F 05 12 02 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBE1E  48 8D 05 13 F3 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFEBE25  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBE29  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBE2D  48 8D 87 10 5D 00 00        lea     rax, [rdi+5D10h]
00007FF91DFEBE34  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBE3B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBE3F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBE43  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBE48  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBE4F  E8 AC FB 01 00              call    sub_7FF91E00BA00
00007FF91DFEBE54  66 0F 6F 05 D4 01 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBE5C  48 8D 05 E5 F2 5F 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFEBE63  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBE67  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBE6E  48 8D 87 20 5D 00 00        lea     rax, [rdi+5D20h]
00007FF91DFEBE75  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBE7C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBE80  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBE84  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBE88  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBE8D  E8 6E FB 01 00              call    sub_7FF91E00BA00
00007FF91DFEBE92  66 0F 6F 05 96 01 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBE9A  48 8D 05 B7 F2 5F 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFEBEA1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBEA5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBEA9  48 8D 87 30 5D 00 00        lea     rax, [rdi+5D30h]
00007FF91DFEBEB0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBEB7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBEBB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBEBF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBEC4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBECB  E8 30 FB 01 00              call    sub_7FF91E00BA00
00007FF91DFEBED0  66 0F 6F 05 58 01 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBED8  48 8D 05 89 F2 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFEBEDF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBEE3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBEE7  48 8D 87 40 5D 00 00        lea     rax, [rdi+5D40h]
00007FF91DFEBEEE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBEF5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBEF9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBEFD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBF02  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBF09  E8 F2 FA 01 00              call    sub_7FF91E00BA00
00007FF91DFEBF0E  48 8D 05 FB F1 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFEBF15  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBF1C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBF20  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBF24  48 8D 87 00 5E 00 00        lea     rax, [rdi+5E00h]
00007FF91DFEBF2B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBF32  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEBF35  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBF39  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBF3D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBF42  E8 B9 FA 01 00              call    sub_7FF91E00BA00
00007FF91DFEBF47  66 0F 6F 05 E1 00 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBF4F  48 8D 05 D2 F1 5F 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFEBF56  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBF5A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBF5E  48 8D 87 E0 5E 00 00        lea     rax, [rdi+5EE0h]
00007FF91DFEBF65  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBF6C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBF70  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBF74  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBF79  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBF80  E8 7B FA 01 00              call    sub_7FF91E00BA00
00007FF91DFEBF85  66 0F 6F 05 A3 00 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBF8D  48 8D 05 A4 F1 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFEBF94  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBF98  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBF9C  48 8D 87 F0 5E 00 00        lea     rax, [rdi+5EF0h]
00007FF91DFEBFA3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBFAA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBFAE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBFB2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBFB7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBFBE  E8 3D FA 01 00              call    sub_7FF91E00BA00
00007FF91DFEBFC3  66 0F 6F 05 65 00 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEBFCB  48 8D 05 76 F1 5F 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFEBFD2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEBFD6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEBFDA  48 8D 87 00 5F 00 00        lea     rax, [rdi+5F00h]
00007FF91DFEBFE1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEBFE8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEBFEC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEBFF0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEBFF5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEBFFC  E8 FF F9 01 00              call    sub_7FF91E00BA00
00007FF91DFEC001  66 0F 6F 05 27 00 60 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC009  48 8D 05 48 F1 5F 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFEC010  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC014  48 8D 87 10 5F 00 00        lea     rax, [rdi+5F10h]
00007FF91DFEC01B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC01F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC026  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC02B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC032  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC036  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC03A  E8 C1 F9 01 00              call    sub_7FF91E00BA00
00007FF91DFEC03F  66 0F 6F 05 E9 FF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC047  48 8D 05 1A F1 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFEC04E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC052  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC056  48 8D 87 20 5F 00 00        lea     rax, [rdi+5F20h]
00007FF91DFEC05D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC064  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC068  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC06C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC071  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC078  E8 83 F9 01 00              call    sub_7FF91E00BA00
00007FF91DFEC07D  48 8D 05 F4 F0 5F 00        lea     rax, aOsc1Feet; "OSC1 Feet"
00007FF91DFEC084  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC08B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC08F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC093  48 8D 87 20 61 00 00        lea     rax, [rdi+6120h]
00007FF91DFEC09A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC0A1  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC0A4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC0A8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC0AC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC0B1  E8 4A F9 01 00              call    sub_7FF91E00BA00
00007FF91DFEC0B6  48 8D 05 CB F0 5F 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
00007FF91DFEC0BD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC0C4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC0C8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC0CC  48 8D 87 30 61 00 00        lea     rax, [rdi+6130h]
00007FF91DFEC0D3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC0DA  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC0DD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC0E1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC0E5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC0EA  E8 11 F9 01 00              call    sub_7FF91E00BA00
00007FF91DFEC0EF  48 8D 05 A2 F0 5F 00        lea     rax, aBendEnableSw; "Bend Enable SW"
00007FF91DFEC0F6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC0FD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC101  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC105  48 8D 87 40 61 00 00        lea     rax, [rdi+6140h]
00007FF91DFEC10C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC113  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC116  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC11A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC11E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC123  E8 D8 F8 01 00              call    sub_7FF91E00BA00
00007FF91DFEC128  48 8D 05 79 F0 5F 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
00007FF91DFEC12F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC136  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC13A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC13E  48 8D 87 50 61 00 00        lea     rax, [rdi+6150h]
00007FF91DFEC145  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC14C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC14F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC153  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC157  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC15C  E8 9F F8 01 00              call    sub_7FF91E00BA00
00007FF91DFEC161  48 8D 05 50 F0 5F 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
00007FF91DFEC168  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC16F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC173  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC177  48 8D 87 60 61 00 00        lea     rax, [rdi+6160h]
00007FF91DFEC17E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC185  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC188  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC18C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC190  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC195  E8 66 F8 01 00              call    sub_7FF91E00BA00
00007FF91DFEC19A  48 8D 05 27 F0 5F 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
00007FF91DFEC1A1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC1A8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC1AC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC1B0  48 8D 87 70 61 00 00        lea     rax, [rdi+6170h]
00007FF91DFEC1B7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC1BE  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC1C1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC1C5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC1C9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC1CE  E8 2D F8 01 00              call    sub_7FF91E00BA00
00007FF91DFEC1D3  48 8D 05 FE EF 5F 00        lea     rax, aPwmSwManual; "PWM SW Manual"
00007FF91DFEC1DA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC1DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC1E2  48 8D 87 80 61 00 00        lea     rax, [rdi+6180h]
00007FF91DFEC1E9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC1F0  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC1F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC1F7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC1FB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC202  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC207  E8 F4 F7 01 00              call    sub_7FF91E00BA00
00007FF91DFEC20C  66 0F 6F 05 1C FE 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC214  48 8D 05 CD EF 5F 00        lea     rax, aTune; "Tune"
00007FF91DFEC21B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC21F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC223  48 8D 87 90 61 00 00        lea     rax, [rdi+6190h]
00007FF91DFEC22A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC231  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC235  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC239  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC23E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC245  E8 B6 F7 01 00              call    sub_7FF91E00BA00
00007FF91DFEC24A  66 0F 6F 05 DE FD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC252  48 8D 05 97 EF 5F 00        lea     rax, aDetune; "Detune"
00007FF91DFEC259  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC25D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC261  48 8D 87 A0 61 00 00        lea     rax, [rdi+61A0h]
00007FF91DFEC268  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC26F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC273  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC277  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC27C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC283  E8 78 F7 01 00              call    sub_7FF91E00BA00
00007FF91DFEC288  66 0F 6F 05 A0 FD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC290  48 8D 05 61 EF 5F 00        lea     rax, aModSens; "Mod Sens"
00007FF91DFEC297  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC29B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC29F  48 8D 87 B0 61 00 00        lea     rax, [rdi+61B0h]
00007FF91DFEC2A6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC2AD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC2B1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC2B5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC2BA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC2C1  E8 3A F7 01 00              call    sub_7FF91E00BA00
00007FF91DFEC2C6  66 0F 6F 05 62 FD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC2CE  48 8D 05 2F EF 5F 00        lea     rax, aModSw; "Mod Sw"
00007FF91DFEC2D5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC2D9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC2DD  48 8D 87 C0 61 00 00        lea     rax, [rdi+61C0h]
00007FF91DFEC2E4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC2EB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC2EF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC2F3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC2F8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC2FF  E8 FC F6 01 00              call    sub_7FF91E00BA00
00007FF91DFEC304  66 0F 6F 05 24 FD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC30C  48 8D 05 FD EE 5F 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFEC313  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC317  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC31B  48 8D 87 D0 61 00 00        lea     rax, [rdi+61D0h]
00007FF91DFEC322  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC329  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC32D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC331  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC336  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC33D  E8 BE F6 01 00              call    sub_7FF91E00BA00
00007FF91DFEC342  66 0F 6F 05 E6 FC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC34A  48 8D 05 CF EE 5F 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFEC351  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC355  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC359  48 8D 87 E0 61 00 00        lea     rax, [rdi+61E0h]
00007FF91DFEC360  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC367  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC36B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC36F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC374  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC37B  E8 80 F6 01 00              call    sub_7FF91E00BA00
00007FF91DFEC380  66 0F 6F 05 A8 FC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC388  48 8D 05 9D EE 5F 00        lea     rax, aLfoSw; "LFO Sw"
00007FF91DFEC38F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC393  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC398  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC39F  48 8D 87 F0 61 00 00        lea     rax, [rdi+61F0h]
00007FF91DFEC3A6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC3AD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC3B1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC3B5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC3B9  E8 42 F6 01 00              call    sub_7FF91E00BA00
00007FF91DFEC3BE  66 0F 6F 05 6A FC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC3C6  48 8D 05 6B EE 5F 00        lea     rax, aEnv1Level; "ENV1 Level"
00007FF91DFEC3CD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC3D1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC3D5  48 8D 87 00 62 00 00        lea     rax, [rdi+6200h]
00007FF91DFEC3DC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC3E3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC3E7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC3EB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC3F0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC3F7  E8 04 F6 01 00              call    sub_7FF91E00BA00
00007FF91DFEC3FC  66 0F 6F 05 2C FC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC404  48 8D 05 3D EE 5F 00        lea     rax, aEnv2Level; "ENV2 Level"
00007FF91DFEC40B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC40F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC413  48 8D 87 10 62 00 00        lea     rax, [rdi+6210h]
00007FF91DFEC41A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC421  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC425  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC429  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC42E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC435  E8 C6 F5 01 00              call    sub_7FF91E00BA00
00007FF91DFEC43A  66 0F 6F 05 EE FB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC442  48 8D 05 0B EE 5F 00        lea     rax, aEnvSw; "ENV Sw"
00007FF91DFEC449  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC44D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC451  48 8D 87 20 62 00 00        lea     rax, [rdi+6220h]
00007FF91DFEC458  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC45F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC463  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC467  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC46C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC473  E8 88 F5 01 00              call    sub_7FF91E00BA00
00007FF91DFEC478  66 0F 6F 05 B0 FB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC480  48 8D 05 D9 ED 5F 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFEC487  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC48B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC48F  48 8D 87 30 62 00 00        lea     rax, [rdi+6230h]
00007FF91DFEC496  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC49D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC4A1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC4A5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC4AA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC4B1  E8 4A F5 01 00              call    sub_7FF91E00BA00
00007FF91DFEC4B6  66 0F 6F 05 72 FB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC4BE  48 8D 05 AB ED 5F 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFEC4C5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC4C9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC4CD  48 8D 87 40 62 00 00        lea     rax, [rdi+6240h]
00007FF91DFEC4D4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC4DB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC4DF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC4E3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC4E8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC4EF  E8 0C F5 01 00              call    sub_7FF91E00BA00
00007FF91DFEC4F4  66 0F 6F 05 34 FB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC4FC  48 8D 05 7D ED 5F 00        lea     rax, aPwmLevel; "PWM Level"
00007FF91DFEC503  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC507  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC50B  48 8D 87 50 62 00 00        lea     rax, [rdi+6250h]
00007FF91DFEC512  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC519  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC51D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC521  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC526  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC52D  E8 CE F4 01 00              call    sub_7FF91E00BA00
00007FF91DFEC532  66 0F 6F 05 F6 FA 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC53A  48 8D 05 4F ED 5F 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
00007FF91DFEC541  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC545  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC549  48 8D 87 80 62 00 00        lea     rax, [rdi+6280h]
00007FF91DFEC550  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC557  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC55B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC560  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC567  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC56B  E8 90 F4 01 00              call    sub_7FF91E00BA00
00007FF91DFEC570  66 0F 6F 05 B8 FA 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC578  48 8D 05 21 ED 5F 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
00007FF91DFEC57F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC583  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC587  48 8D 87 90 62 00 00        lea     rax, [rdi+6290h]
00007FF91DFEC58E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC595  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC599  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC59D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC5A2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC5A9  E8 52 F4 01 00              call    sub_7FF91E00BA00
00007FF91DFEC5AE  66 0F 6F 05 7A FA 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC5B6  48 8D 05 F3 EC 5F 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
00007FF91DFEC5BD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC5C1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC5C5  48 8D 87 A0 62 00 00        lea     rax, [rdi+62A0h]
00007FF91DFEC5CC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC5D3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC5D7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC5DB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC5E0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC5E7  E8 14 F4 01 00              call    sub_7FF91E00BA00
00007FF91DFEC5EC  66 0F 6F 05 3C FA 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC5F4  48 8D 05 C5 EC 5F 00        lea     rax, aDutyTune; "Duty Tune"
00007FF91DFEC5FB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC5FF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC603  48 8D 87 B0 67 00 00        lea     rax, [rdi+67B0h]
00007FF91DFEC60A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC611  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC615  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC619  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC61E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC625  E8 D6 F3 01 00              call    sub_7FF91E00BA00
00007FF91DFEC62A  66 0F 6F 05 FE F9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC632  48 8D 05 97 EC 5F 00        lea     rax, aOsc1Mute; "Osc1 Mute"
00007FF91DFEC639  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC63D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC641  48 8D 87 50 6B 00 00        lea     rax, [rdi+6B50h]
00007FF91DFEC648  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC64F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC653  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC657  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC65C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC663  E8 98 F3 01 00              call    sub_7FF91E00BA00
00007FF91DFEC668  66 0F 6F 05 C0 F9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC670  48 8D 05 69 EC 5F 00        lea     rax, aOsc1Level; "Osc1 Level"
00007FF91DFEC677  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC67B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC67F  48 8D 87 90 6B 00 00        lea     rax, [rdi+6B90h]
00007FF91DFEC686  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC68D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC691  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC695  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC69A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC6A1  E8 5A F3 01 00              call    sub_7FF91E00BA00
00007FF91DFEC6A6  66 0F 6F 05 82 F9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC6AE  48 8D 05 3B EC 5F 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
00007FF91DFEC6B5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC6B9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC6BD  48 8D 87 A0 6B 00 00        lea     rax, [rdi+6BA0h]
00007FF91DFEC6C4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC6CB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC6CF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC6D3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC6D8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC6DF  E8 1C F3 01 00              call    sub_7FF91E00BA00
00007FF91DFEC6E4  48 8D 05 15 EC 5F 00        lea     rax, aGrifferSw; "Griffer SW"
00007FF91DFEC6EB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC6F2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC6F6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC6FA  48 8D 87 60 6C 00 00        lea     rax, [rdi+6C60h]
00007FF91DFEC701  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC708  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC70B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC70F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC713  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC718  E8 E3 F2 01 00              call    sub_7FF91E00BA00
00007FF91DFEC71D  48 8D 05 EC EB 5F 00        lea     rax, aLpfCutoff; "LPF Cutoff"
00007FF91DFEC724  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC728  66 0F 6F 05 00 F9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC730  48 8D 87 70 6C 00 00        lea     rax, [rdi+6C70h]
00007FF91DFEC737  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC73B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC73F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC743  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC74A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC74F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC756  E8 A5 F2 01 00              call    sub_7FF91E00BA00
00007FF91DFEC75B  66 0F 6F 05 CD F8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC763  48 8D 05 B6 EB 5F 00        lea     rax, aLpfResonance; "LPF Resonance"
00007FF91DFEC76A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC76E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC772  48 8D 87 D0 6C 00 00        lea     rax, [rdi+6CD0h]
00007FF91DFEC779  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC780  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC784  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC788  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC78D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC794  E8 67 F2 01 00              call    sub_7FF91E00BA00
00007FF91DFEC799  48 8D 05 90 EB 5F 00        lea     rax, aVelocity; "Velocity"
00007FF91DFEC7A0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC7A7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC7AB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC7AF  48 8D 87 F0 6C 00 00        lea     rax, [rdi+6CF0h]
00007FF91DFEC7B6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC7BD  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC7C0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC7C4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC7C8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC7CD  E8 2E F2 01 00              call    sub_7FF91E00BA00
00007FF91DFEC7D2  48 8D 05 63 EB 5F 00        lea     rax, aEnv12; "Env1/2"
00007FF91DFEC7D9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC7E0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC7E4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC7E8  48 8D 87 80 6D 00 00        lea     rax, [rdi+6D80h]
00007FF91DFEC7EF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC7F6  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC7F9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC7FD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC801  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC806  E8 F5 F1 01 00              call    sub_7FF91E00BA00
00007FF91DFEC80B  48 8D 05 36 EB 5F 00        lea     rax, aIntEnv; "Int/Env"
00007FF91DFEC812  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC819  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC81D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC821  48 8D 87 90 6D 00 00        lea     rax, [rdi+6D90h]
00007FF91DFEC828  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC82F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC832  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC836  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC83A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC83F  E8 BC F1 01 00              call    sub_7FF91E00BA00
00007FF91DFEC844  48 8D 05 C5 E9 5F 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFEC84B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC852  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC856  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC85A  48 8D 87 A0 6E 00 00        lea     rax, [rdi+6EA0h]
00007FF91DFEC861  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC868  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC86B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC86F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC873  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC878  E8 83 F1 01 00              call    sub_7FF91E00BA00
00007FF91DFEC87D  48 8D 05 CC EA 5F 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
00007FF91DFEC884  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC88B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC88F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC893  48 8D 87 B0 6E 00 00        lea     rax, [rdi+6EB0h]
00007FF91DFEC89A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC8A1  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC8A4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC8A8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC8AC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC8B1  E8 4A F1 01 00              call    sub_7FF91E00BA00
00007FF91DFEC8B6  48 8D 05 A3 EA 5F 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
00007FF91DFEC8BD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC8C4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEC8C7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC8CB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC8D0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC8D7  48 8D 87 C0 6E 00 00        lea     rax, [rdi+6EC0h]
00007FF91DFEC8DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC8E2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC8E6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC8EA  E8 11 F1 01 00              call    sub_7FF91E00BA00
00007FF91DFEC8EF  66 0F 6F 05 39 F7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC8F7  48 8D 05 22 E9 5F 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFEC8FE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC902  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC906  48 8D 87 D0 6E 00 00        lea     rax, [rdi+6ED0h]
00007FF91DFEC90D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC914  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC918  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC91C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC921  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC928  E8 D3 F0 01 00              call    sub_7FF91E00BA00
00007FF91DFEC92D  66 0F 6F 05 FB F6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC935  48 8D 05 34 EA 5F 00        lea     rax, aModSens_0; "MOD Sens"
00007FF91DFEC93C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC940  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC944  48 8D 87 E0 6E 00 00        lea     rax, [rdi+6EE0h]
00007FF91DFEC94B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC952  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC956  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC95A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC95F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC966  E8 95 F0 01 00              call    sub_7FF91E00BA00
00007FF91DFEC96B  66 0F 6F 05 BD F6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC973  48 8D 05 02 EA 5F 00        lea     rax, aModSw_0; "MOD SW"
00007FF91DFEC97A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC97E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC982  48 8D 87 F0 6E 00 00        lea     rax, [rdi+6EF0h]
00007FF91DFEC989  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC990  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC994  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC998  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC99D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC9A4  E8 57 F0 01 00              call    sub_7FF91E00BA00
00007FF91DFEC9A9  66 0F 6F 05 7F F6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC9B1  48 8D 05 D0 E9 5F 00        lea     rax, aEnvLevel; "ENV Level"
00007FF91DFEC9B8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC9BC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC9C0  48 8D 87 00 6F 00 00        lea     rax, [rdi+6F00h]
00007FF91DFEC9C7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEC9CE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEC9D2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEC9D6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEC9DB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEC9E2  E8 19 F0 01 00              call    sub_7FF91E00BA00
00007FF91DFEC9E7  66 0F 6F 05 41 F6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEC9EF  48 8D 05 A2 E9 5F 00        lea     rax, aKcvLevel; "KCV Level"
00007FF91DFEC9F6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEC9FA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEC9FE  48 8D 87 10 6F 00 00        lea     rax, [rdi+6F10h]
00007FF91DFECA05  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECA0C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECA10  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECA14  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECA19  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECA20  E8 DB EF 01 00              call    sub_7FF91E00BA00
00007FF91DFECA25  66 0F 6F 05 03 F6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECA2D  48 8D 05 74 E9 5F 00        lea     rax, aVelocitySens; "Velocity Sens"
00007FF91DFECA34  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECA38  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECA3C  48 8D 87 20 6F 00 00        lea     rax, [rdi+6F20h]
00007FF91DFECA43  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECA4A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECA4E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECA52  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECA57  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECA5E  E8 9D EF 01 00              call    sub_7FF91E00BA00
00007FF91DFECA63  66 0F 6F 05 C5 F5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECA6B  48 8D 05 46 E9 5F 00        lea     rax, aVelocityOffset; "Velocity Offset"
00007FF91DFECA72  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECA76  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECA7A  48 8D 87 30 6F 00 00        lea     rax, [rdi+6F30h]
00007FF91DFECA81  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECA88  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECA8C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECA90  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECA95  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECA9C  E8 5F EF 01 00              call    sub_7FF91E00BA00
00007FF91DFECAA1  66 0F 6F 05 87 F5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECAA9  48 8D 05 B0 E7 5F 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFECAB0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECAB4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECAB8  48 8D 87 40 6F 00 00        lea     rax, [rdi+6F40h]
00007FF91DFECABF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECAC6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECACA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECACE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECAD3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECADA  E8 21 EF 01 00              call    sub_7FF91E00BA00
00007FF91DFECADF  66 0F 6F 05 49 F5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECAE7  48 8D 05 82 E7 5F 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFECAEE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECAF2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECAF6  48 8D 87 50 6F 00 00        lea     rax, [rdi+6F50h]
00007FF91DFECAFD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECB04  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECB08  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECB0C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECB11  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECB18  E8 E3 EE 01 00              call    sub_7FF91E00BA00
00007FF91DFECB1D  66 0F 6F 05 0B F5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECB25  48 8D 05 9C E8 5F 00        lea     rax, aCutoffTune; "Cutoff Tune"
00007FF91DFECB2C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECB30  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECB34  48 8D 87 D0 6F 00 00        lea     rax, [rdi+6FD0h]
00007FF91DFECB3B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECB42  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECB46  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECB4A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECB4F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECB56  E8 A5 EE 01 00              call    sub_7FF91E00BA00
00007FF91DFECB5B  66 0F 6F 05 CD F4 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECB63  48 8D 05 6E E8 5F 00        lea     rax, aResonanceTune; "Resonance Tune"
00007FF91DFECB6A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECB6E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECB72  48 8D 87 E0 6F 00 00        lea     rax, [rdi+6FE0h]
00007FF91DFECB79  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECB80  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECB84  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECB88  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECB8D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECB94  E8 67 EE 01 00              call    sub_7FF91E00BA00
00007FF91DFECB99  48 8D 05 48 E8 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFECBA0  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFECBA7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECBAB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECBAF  48 8D 87 F0 6F 00 00        lea     rax, [rdi+6FF0h]
00007FF91DFECBB6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECBBD  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFECBC0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECBC4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECBC8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECBCD  E8 2E EE 01 00              call    sub_7FF91E00BA00
00007FF91DFECBD2  48 8D 05 0F E8 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFECBD9  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFECBE0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECBE4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECBE8  48 8D 87 80 75 00 00        lea     rax, [rdi+7580h]
00007FF91DFECBEF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECBF6  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFECBF9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECBFD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECC01  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECC06  E8 F5 ED 01 00              call    sub_7FF91E00BA00
00007FF91DFECC0B  66 0F 6F 05 1D F4 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECC13  48 8D 05 DE E7 5F 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
00007FF91DFECC1A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECC1E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECC22  48 8D 87 90 75 00 00        lea     rax, [rdi+7590h]
00007FF91DFECC29  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECC30  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECC34  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECC38  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECC3D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECC44  E8 B7 ED 01 00              call    sub_7FF91E00BA00
00007FF91DFECC49  48 8D 05 B8 E7 5F 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
00007FF91DFECC50  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECC57  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECC5B  66 0F 6F 05 CD F3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECC63  48 8D 87 A0 75 00 00        lea     rax, [rdi+75A0h]
00007FF91DFECC6A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECC6E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECC72  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECC76  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECC7D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECC82  E8 79 ED 01 00              call    sub_7FF91E00BA00
00007FF91DFECC87  66 0F 6F 05 A1 F3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECC8F  48 8D 05 82 E7 5F 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
00007FF91DFECC96  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECC9A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECC9E  48 8D 87 B0 75 00 00        lea     rax, [rdi+75B0h]
00007FF91DFECCA5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECCAC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECCB0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECCB4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECCB9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECCC0  E8 3B ED 01 00              call    sub_7FF91E00BA00
00007FF91DFECCC5  66 0F 6F 05 63 F3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECCCD  48 8D 05 54 E7 5F 00        lea     rax, aAmpTone; "AMP TONE"
00007FF91DFECCD4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECCD8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECCDC  48 8D 87 90 77 00 00        lea     rax, [rdi+7790h]
00007FF91DFECCE3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECCEA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECCEE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECCF2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECCF7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECCFE  E8 FD EC 01 00              call    sub_7FF91E00BA00
00007FF91DFECD03  66 0F 6F 05 25 F3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECD0B  48 8D 05 26 E7 5F 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
00007FF91DFECD12  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECD16  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECD1A  48 8D 87 A0 77 00 00        lea     rax, [rdi+77A0h]
00007FF91DFECD21  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECD28  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECD2C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECD30  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECD35  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECD3C  E8 BF EC 01 00              call    sub_7FF91E00BA00
00007FF91DFECD41  66 0F 6F 05 E7 F2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECD49  48 8D 05 00 E7 5F 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
00007FF91DFECD50  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECD54  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECD58  48 8D 87 B0 77 00 00        lea     rax, [rdi+77B0h]
00007FF91DFECD5F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECD66  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECD6A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECD6E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECD73  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECD7A  E8 81 EC 01 00              call    sub_7FF91E00BA00
00007FF91DFECD7F  48 8D 05 AA E5 5F 00        lea     rax, aVelocity; "Velocity"
00007FF91DFECD86  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECD8D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECD91  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECD95  48 8D 87 F0 77 00 00        lea     rax, [rdi+77F0h]
00007FF91DFECD9C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECDA3  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFECDA6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECDAA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECDAE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECDB3  E8 48 EC 01 00              call    sub_7FF91E00BA00
00007FF91DFECDB8  48 8D 05 A9 E6 5F 00        lea     rax, aMute; "Mute"
00007FF91DFECDBF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECDC6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECDCA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECDCE  48 8D 87 80 78 00 00        lea     rax, [rdi+7880h]
00007FF91DFECDD5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECDDC  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFECDDF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECDE3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECDE7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECDEC  E8 0F EC 01 00              call    sub_7FF91E00BA00
00007FF91DFECDF1  48 8D 05 78 E6 5F 00        lea     rax, aGateSw; "Gate SW"
00007FF91DFECDF8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECDFF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFECE02  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECE06  48 8D 87 E0 79 00 00        lea     rax, [rdi+79E0h]
00007FF91DFECE0D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECE14  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECE19  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECE1D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECE21  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECE25  E8 D6 EB 01 00              call    sub_7FF91E00BA00
00007FF91DFECE2A  48 8D 05 47 E6 5F 00        lea     rax, aEnv1Sw; "ENV1 SW"
00007FF91DFECE31  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECE38  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECE3C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECE40  48 8D 87 F0 79 00 00        lea     rax, [rdi+79F0h]
00007FF91DFECE47  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECE4E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFECE51  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECE55  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECE59  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECE5E  E8 9D EB 01 00              call    sub_7FF91E00BA00
00007FF91DFECE63  48 8D 05 16 E6 5F 00        lea     rax, aEnv2Sw; "ENV2 SW"
00007FF91DFECE6A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECE71  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECE75  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECE79  48 8D 87 00 7A 00 00        lea     rax, [rdi+7A00h]
00007FF91DFECE80  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECE87  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFECE8A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECE8E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECE92  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECE97  E8 64 EB 01 00              call    sub_7FF91E00BA00
00007FF91DFECE9C  48 8D 05 E5 E5 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
00007FF91DFECEA3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECEAA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECEAE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECEB2  48 8D 87 10 7A 00 00        lea     rax, [rdi+7A10h]
00007FF91DFECEB9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECEC0  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFECEC3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECEC7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECECB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECED0  E8 2B EB 01 00              call    sub_7FF91E00BA00
00007FF91DFECED5  66 0F 6F 05 53 F1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECEDD  48 8D 05 B4 E5 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
00007FF91DFECEE4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECEE8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECEEC  48 8D 87 20 7A 00 00        lea     rax, [rdi+7A20h]
00007FF91DFECEF3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECEFA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECEFE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECF02  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECF07  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECF0E  E8 ED EA 01 00              call    sub_7FF91E00BA00
00007FF91DFECF13  66 0F 6F 05 15 F1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECF1B  48 8D 05 86 E5 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
00007FF91DFECF22  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECF26  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECF2A  48 8D 87 30 7A 00 00        lea     rax, [rdi+7A30h]
00007FF91DFECF31  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECF38  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECF3C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECF40  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECF45  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECF4C  E8 AF EA 01 00              call    sub_7FF91E00BA00
00007FF91DFECF51  66 0F 6F 05 D7 F0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECF59  48 8D 05 58 E5 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
00007FF91DFECF60  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECF64  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECF68  48 8D 87 40 7A 00 00        lea     rax, [rdi+7A40h]
00007FF91DFECF6F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECF76  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECF7A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECF7E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECF83  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECF8A  E8 71 EA 01 00              call    sub_7FF91E00BA00
00007FF91DFECF8F  66 0F 6F 05 99 F0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECF97  48 8D 05 2A E5 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
00007FF91DFECF9E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECFA2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECFA6  48 8D 87 50 7A 00 00        lea     rax, [rdi+7A50h]
00007FF91DFECFAD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECFB4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECFB8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECFBC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECFC1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFECFC8  E8 33 EA 01 00              call    sub_7FF91E00BA00
00007FF91DFECFCD  66 0F 6F 05 5B F0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFECFD5  48 8D 05 04 E5 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
00007FF91DFECFDC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFECFE0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFECFE4  48 8D 87 60 7A 00 00        lea     rax, [rdi+7A60h]
00007FF91DFECFEB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFECFF2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFECFF6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFECFFA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFECFFF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED006  E8 F5 E9 01 00              call    sub_7FF91E00BA00
00007FF91DFED00B  66 0F 6F 05 1D F0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED013  48 8D 05 D6 E4 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
00007FF91DFED01A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED01E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED022  48 8D 87 70 7A 00 00        lea     rax, [rdi+7A70h]
00007FF91DFED029  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED030  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED034  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED038  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED03D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED044  E8 B7 E9 01 00              call    sub_7FF91E00BA00
00007FF91DFED049  48 8D 05 D0 DE 5F 00        lea     rax, aUseextjack; "UseExtJack"
00007FF91DFED050  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED057  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED05B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED05F  48 8D 87 40 7C 00 00        lea     rax, [rdi+7C40h]
00007FF91DFED066  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED06D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED070  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED074  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED078  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED07D  E8 7E E9 01 00              call    sub_7FF91E00BA00
00007FF91DFED082  48 8D 05 A3 DE 5F 00        lea     rax, aMCv; "M.CV"
00007FF91DFED089  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED090  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED094  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED098  48 8D 87 60 7C 00 00        lea     rax, [rdi+7C60h]
00007FF91DFED09F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED0A6  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED0A9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED0AD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED0B1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED0B6  E8 45 E9 01 00              call    sub_7FF91E00BA00
00007FF91DFED0BB  48 8D 05 72 DE 5F 00        lea     rax, aMGate; "M.Gate"
00007FF91DFED0C2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED0C9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED0CD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED0D1  48 8D 87 70 7C 00 00        lea     rax, [rdi+7C70h]
00007FF91DFED0D8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED0DF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED0E2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED0E6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED0EA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED0EF  E8 0C E9 01 00              call    sub_7FF91E00BA00
00007FF91DFED0F4  66 0F 6F 05 34 EF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED0FC  48 8D 05 3D DE 5F 00        lea     rax, aMasterTune; "Master Tune"
00007FF91DFED103  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED107  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED10B  48 8D 87 A0 7C 00 00        lea     rax, [rdi+7CA0h]
00007FF91DFED112  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED119  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED11D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED121  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED126  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED12D  E8 CE E8 01 00              call    sub_7FF91E00BA00
00007FF91DFED132  66 0F 6F 05 F6 EE 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED13A  48 8D 05 0F DE 5F 00        lea     rax, aPartTune; "Part Tune"
00007FF91DFED141  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED145  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED149  48 8D 87 B0 7C 00 00        lea     rax, [rdi+7CB0h]
00007FF91DFED150  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED157  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED15B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED15F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED164  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED16B  E8 90 E8 01 00              call    sub_7FF91E00BA00
00007FF91DFED170  48 8D 05 E9 DD 5F 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
00007FF91DFED177  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED17E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED182  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED185  48 8D 87 80 7D 00 00        lea     rax, [rdi+7D80h]
00007FF91DFED18C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED193  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED197  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED19B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED19F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED1A4  E8 57 E8 01 00              call    sub_7FF91E00BA00
00007FF91DFED1A9  48 8D 05 C8 DD 5F 00        lea     rax, aPortamentoMode; "Portamento Mode"
00007FF91DFED1B0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED1B7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED1BB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED1BF  48 8D 87 90 7D 00 00        lea     rax, [rdi+7D90h]
00007FF91DFED1C6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED1CD  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED1D0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED1D4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED1D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED1DD  E8 1E E8 01 00              call    sub_7FF91E00BA00
00007FF91DFED1E2  66 0F 6F 05 46 EE 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED1EA  48 8D 05 97 DD 5F 00        lea     rax, aPortamentoTime; "Portamento Time"
00007FF91DFED1F1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED1F5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED1F9  48 8D 87 A0 7D 00 00        lea     rax, [rdi+7DA0h]
00007FF91DFED200  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED207  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED20B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED20F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED214  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED21B  E8 E0 E7 01 00              call    sub_7FF91E00BA00
00007FF91DFED220  48 8D 05 71 DD 5F 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
00007FF91DFED227  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED22E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED232  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED236  48 8D 87 40 7F 00 00        lea     rax, [rdi+7F40h]
00007FF91DFED23D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED244  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED247  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED24B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED24F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED254  E8 A7 E7 01 00              call    sub_7FF91E00BA00
00007FF91DFED259  48 8D 05 50 DD 5F 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
00007FF91DFED260  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED267  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED26B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED26F  48 8D 87 50 7F 00 00        lea     rax, [rdi+7F50h]
00007FF91DFED276  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED27D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED280  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED284  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED288  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED28D  E8 6E E7 01 00              call    sub_7FF91E00BA00
00007FF91DFED292  48 8D 05 2F DD 5F 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
00007FF91DFED299  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED2A0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED2A4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED2A8  48 8D 87 60 7F 00 00        lea     rax, [rdi+7F60h]
00007FF91DFED2AF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED2B6  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED2B9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED2BD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED2C1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED2C6  E8 35 E7 01 00              call    sub_7FF91E00BA00
00007FF91DFED2CB  66 0F 6F 05 5D ED 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED2D3  48 8D 05 FE DC 5F 00        lea     rax, aLfoRate; "LFO Rate"
00007FF91DFED2DA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED2DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED2E2  48 8D 87 70 7F 00 00        lea     rax, [rdi+7F70h]
00007FF91DFED2E9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED2F0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED2F4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED2F8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED2FD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED304  E8 F7 E6 01 00              call    sub_7FF91E00BA00
00007FF91DFED309  48 8D 05 D4 DC 5F 00        lea     rax, aGate; "Gate"
00007FF91DFED310  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED317  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED31B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED31E  48 8D 87 70 82 00 00        lea     rax, [rdi+8270h]
00007FF91DFED325  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED32C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED330  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED335  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED339  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED33D  E8 BE E6 01 00              call    sub_7FF91E00BA00
00007FF91DFED342  48 8D 05 A7 DC 5F 00        lea     rax, aLfoTrig; "LFO Trig"
00007FF91DFED349  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED350  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED354  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED358  48 8D 87 80 82 00 00        lea     rax, [rdi+8280h]
00007FF91DFED35F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED366  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED369  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED36D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED371  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED376  E8 85 E6 01 00              call    sub_7FF91E00BA00
00007FF91DFED37B  48 8D 05 7E DC 5F 00        lea     rax, aResetSw; "Reset Sw"
00007FF91DFED382  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED389  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED38D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED391  48 8D 87 90 82 00 00        lea     rax, [rdi+8290h]
00007FF91DFED398  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED39F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED3A2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED3A6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED3AA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED3AF  E8 4C E6 01 00              call    sub_7FF91E00BA00
00007FF91DFED3B4  66 0F 6F 05 74 EC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED3BC  48 8D 05 4D DC 5F 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
00007FF91DFED3C3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED3C7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED3CB  48 8D 87 A0 82 00 00        lea     rax, [rdi+82A0h]
00007FF91DFED3D2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED3D9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED3DD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED3E1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED3E6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED3ED  E8 0E E6 01 00              call    sub_7FF91E00BA00
00007FF91DFED3F2  66 0F 6F 05 36 EC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED3FA  48 8D 05 1F DC 5F 00        lea     rax, aLfoDelay; "LFO Delay"
00007FF91DFED401  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED405  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED409  48 8D 87 B0 82 00 00        lea     rax, [rdi+82B0h]
00007FF91DFED410  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED417  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED41B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED41F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED424  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED42B  E8 D0 E5 01 00              call    sub_7FF91E00BA00
00007FF91DFED430  66 0F 6F 05 F8 EB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED438  48 8D 05 F1 DB 5F 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
00007FF91DFED43F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED443  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED447  48 8D 87 C0 82 00 00        lea     rax, [rdi+82C0h]
00007FF91DFED44E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED455  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED459  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED45D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED462  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED469  E8 92 E5 01 00              call    sub_7FF91E00BA00
00007FF91DFED46E  66 0F 6F 05 BA EB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED476  48 8D 05 C3 DB 5F 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
00007FF91DFED47D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED481  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED485  48 8D 87 D0 82 00 00        lea     rax, [rdi+82D0h]
00007FF91DFED48C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED493  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED497  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED49B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED4A0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED4A7  E8 54 E5 01 00              call    sub_7FF91E00BA00
00007FF91DFED4AC  66 0F 6F 05 7C EB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED4B4  48 8D 05 95 DB 5F 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
00007FF91DFED4BB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED4BF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED4C3  48 8D 87 E0 82 00 00        lea     rax, [rdi+82E0h]
00007FF91DFED4CA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED4D1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED4D5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED4D9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED4DE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED4E5  E8 16 E5 01 00              call    sub_7FF91E00BA00
00007FF91DFED4EA  48 8D 05 6F DB 5F 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
00007FF91DFED4F1  66 0F 6F 05 37 EB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED4F9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED4FD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED501  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED505  48 8D 87 F0 82 00 00        lea     rax, [rdi+82F0h]
00007FF91DFED50C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED513  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED517  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED51C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED523  E8 D8 E4 01 00              call    sub_7FF91E00BA00
00007FF91DFED528  66 0F 6F 05 00 EB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED530  48 8D 05 39 DB 5F 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
00007FF91DFED537  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED53B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED53F  48 8D 87 00 83 00 00        lea     rax, [rdi+8300h]
00007FF91DFED546  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED54D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED551  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED555  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED55A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED561  E8 9A E4 01 00              call    sub_7FF91E00BA00
00007FF91DFED566  66 0F 6F 05 C2 EA 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED56E  48 8D 05 0B DB 5F 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
00007FF91DFED575  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED579  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED57D  48 8D 87 10 83 00 00        lea     rax, [rdi+8310h]
00007FF91DFED584  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED58B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED58F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED593  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED598  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED59F  E8 5C E4 01 00              call    sub_7FF91E00BA00
00007FF91DFED5A4  66 0F 6F 05 84 EA 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED5AC  48 8D 05 DD DA 5F 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
00007FF91DFED5B3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED5B7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED5BB  48 8D 87 20 83 00 00        lea     rax, [rdi+8320h]
00007FF91DFED5C2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED5C9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED5CD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED5D1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED5D6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED5DD  E8 1E E4 01 00              call    sub_7FF91E00BA00
00007FF91DFED5E2  66 0F 6F 05 46 EA 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED5EA  48 8D 05 AF DA 5F 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
00007FF91DFED5F1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED5F5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED5F9  48 8D 87 30 83 00 00        lea     rax, [rdi+8330h]
00007FF91DFED600  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED607  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED60B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED60F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED614  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED61B  E8 E0 E3 01 00              call    sub_7FF91E00BA00
00007FF91DFED620  66 0F 6F 05 08 EA 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED628  48 8D 05 81 DA 5F 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
00007FF91DFED62F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED633  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED637  48 8D 87 40 83 00 00        lea     rax, [rdi+8340h]
00007FF91DFED63E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED645  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED649  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED64D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED652  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED659  E8 A2 E3 01 00              call    sub_7FF91E00BA00
00007FF91DFED65E  66 0F 6F 05 CA E9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED666  48 8D 05 53 DA 5F 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
00007FF91DFED66D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED671  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED675  48 8D 87 50 83 00 00        lea     rax, [rdi+8350h]
00007FF91DFED67C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED683  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED687  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED68B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED690  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED697  E8 64 E3 01 00              call    sub_7FF91E00BA00
00007FF91DFED69C  66 0F 6F 05 8C E9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED6A4  48 8D 05 25 DA 5F 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
00007FF91DFED6AB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED6AF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED6B4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED6BB  48 8D 87 60 83 00 00        lea     rax, [rdi+8360h]
00007FF91DFED6C2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED6C9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED6CD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED6D1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED6D5  E8 26 E3 01 00              call    sub_7FF91E00BA00
00007FF91DFED6DA  66 0F 6F 05 4E E9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED6E2  48 8D 05 FF D9 5F 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
00007FF91DFED6E9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED6ED  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED6F1  48 8D 87 70 83 00 00        lea     rax, [rdi+8370h]
00007FF91DFED6F8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED6FF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED703  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED707  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED70C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED713  E8 E8 E2 01 00              call    sub_7FF91E00BA00
00007FF91DFED718  48 8D 05 E1 D9 5F 00        lea     rax, aReadOnly; "read only"
00007FF91DFED71F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED726  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED72A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED72E  48 8D 87 10 85 00 00        lea     rax, [rdi+8510h]
00007FF91DFED735  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED73C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED73F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED743  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED747  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED74C  E8 AF E2 01 00              call    sub_7FF91E00BA00
00007FF91DFED751  48 8D 05 A8 D9 5F 00        lea     rax, aReadOnly; "read only"
00007FF91DFED758  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED75F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED763  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED767  48 8D 87 20 85 00 00        lea     rax, [rdi+8520h]
00007FF91DFED76E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED775  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED778  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED77C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED780  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED785  E8 76 E2 01 00              call    sub_7FF91E00BA00
00007FF91DFED78A  48 8D 05 7F D9 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFED791  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED798  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED79C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED7A0  48 8D 87 30 85 00 00        lea     rax, [rdi+8530h]
00007FF91DFED7A7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED7AE  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED7B1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED7B5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED7B9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED7BE  E8 3D E2 01 00              call    sub_7FF91E00BA00
00007FF91DFED7C3  66 0F 6F 05 65 E8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED7CB  48 8D 05 56 D9 5F 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFED7D2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED7D6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED7DA  48 8D 87 10 86 00 00        lea     rax, [rdi+8610h]
00007FF91DFED7E1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED7E8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED7EC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED7F0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED7F5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED7FC  E8 FF E1 01 00              call    sub_7FF91E00BA00
00007FF91DFED801  66 0F 6F 05 27 E8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED809  48 8D 05 28 D9 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFED810  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED814  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED818  48 8D 87 20 86 00 00        lea     rax, [rdi+8620h]
00007FF91DFED81F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED826  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED82A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED82E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED833  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED83A  E8 C1 E1 01 00              call    sub_7FF91E00BA00
00007FF91DFED83F  66 0F 6F 05 E9 E7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED847  48 8D 05 FA D8 5F 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFED84E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED852  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED856  48 8D 87 30 86 00 00        lea     rax, [rdi+8630h]
00007FF91DFED85D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED864  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED868  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED86D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED874  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED878  E8 83 E1 01 00              call    sub_7FF91E00BA00
00007FF91DFED87D  66 0F 6F 05 AB E7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED885  48 8D 05 CC D8 5F 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFED88C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED890  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED894  48 8D 87 40 86 00 00        lea     rax, [rdi+8640h]
00007FF91DFED89B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED8A2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED8A6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED8AA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED8AF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED8B6  E8 45 E1 01 00              call    sub_7FF91E00BA00
00007FF91DFED8BB  66 0F 6F 05 6D E7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED8C3  48 8D 05 9E D8 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFED8CA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED8CE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED8D2  48 8D 87 50 86 00 00        lea     rax, [rdi+8650h]
00007FF91DFED8D9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED8E0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED8E4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED8E8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED8ED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED8F4  E8 07 E1 01 00              call    sub_7FF91E00BA00
00007FF91DFED8F9  48 8D 05 10 D8 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFED900  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED907  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED90B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED90F  48 8D 87 10 87 00 00        lea     rax, [rdi+8710h]
00007FF91DFED916  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED91D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFED920  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED924  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED928  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED92D  E8 CE E0 01 00              call    sub_7FF91E00BA00
00007FF91DFED932  66 0F 6F 05 F6 E6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED93A  48 8D 05 E7 D7 5F 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFED941  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED945  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED949  48 8D 87 F0 87 00 00        lea     rax, [rdi+87F0h]
00007FF91DFED950  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED957  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED95B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED95F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED964  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED96B  E8 90 E0 01 00              call    sub_7FF91E00BA00
00007FF91DFED970  66 0F 6F 05 B8 E6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED978  48 8D 05 B9 D7 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFED97F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED983  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED987  48 8D 87 00 88 00 00        lea     rax, [rdi+8800h]
00007FF91DFED98E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED995  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED999  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED99D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED9A2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED9A9  E8 52 E0 01 00              call    sub_7FF91E00BA00
00007FF91DFED9AE  66 0F 6F 05 7A E6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED9B6  48 8D 05 8B D7 5F 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFED9BD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED9C1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFED9C5  48 8D 87 10 88 00 00        lea     rax, [rdi+8810h]
00007FF91DFED9CC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFED9D3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFED9D7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFED9DB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFED9E0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFED9E7  E8 14 E0 01 00              call    sub_7FF91E00BA00
00007FF91DFED9EC  66 0F 6F 05 3C E6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFED9F4  48 8D 05 5D D7 5F 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFED9FB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFED9FF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDA03  48 8D 87 20 88 00 00        lea     rax, [rdi+8820h]
00007FF91DFEDA0A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDA11  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDA15  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDA19  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDA1E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDA25  E8 D6 DF 01 00              call    sub_7FF91E00BA00
00007FF91DFEDA2A  48 8D 05 37 D7 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFEDA31  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDA35  66 0F 6F 05 F3 E5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDA3D  48 8D 87 30 88 00 00        lea     rax, [rdi+8830h]
00007FF91DFEDA44  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDA48  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDA4C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDA50  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDA57  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDA5C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDA63  E8 98 DF 01 00              call    sub_7FF91E00BA00
00007FF91DFEDA68  48 8D 05 09 D7 5F 00        lea     rax, aOsc1Feet; "OSC1 Feet"
00007FF91DFEDA6F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDA76  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDA7A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDA7E  48 8D 87 30 8A 00 00        lea     rax, [rdi+8A30h]
00007FF91DFEDA85  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDA8C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEDA8F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDA93  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDA97  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDA9C  E8 5F DF 01 00              call    sub_7FF91E00BA00
00007FF91DFEDAA1  48 8D 05 E0 D6 5F 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
00007FF91DFEDAA8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDAAF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDAB3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDAB7  48 8D 87 40 8A 00 00        lea     rax, [rdi+8A40h]
00007FF91DFEDABE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDAC5  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEDAC8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDACC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDAD0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDAD5  E8 26 DF 01 00              call    sub_7FF91E00BA00
00007FF91DFEDADA  48 8D 05 B7 D6 5F 00        lea     rax, aBendEnableSw; "Bend Enable SW"
00007FF91DFEDAE1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDAE8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDAEC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDAF0  48 8D 87 50 8A 00 00        lea     rax, [rdi+8A50h]
00007FF91DFEDAF7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDAFE  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEDB01  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDB05  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDB09  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDB0E  E8 ED DE 01 00              call    sub_7FF91E00BA00
00007FF91DFEDB13  48 8D 05 8E D6 5F 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
00007FF91DFEDB1A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDB21  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDB25  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDB29  48 8D 87 60 8A 00 00        lea     rax, [rdi+8A60h]
00007FF91DFEDB30  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDB37  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEDB3A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDB3E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDB42  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDB47  E8 B4 DE 01 00              call    sub_7FF91E00BA00
00007FF91DFEDB4C  48 8D 05 65 D6 5F 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
00007FF91DFEDB53  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDB5A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDB5E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDB62  48 8D 87 70 8A 00 00        lea     rax, [rdi+8A70h]
00007FF91DFEDB69  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDB70  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEDB73  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDB77  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDB7B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDB80  E8 7B DE 01 00              call    sub_7FF91E00BA00
00007FF91DFEDB85  48 8D 05 3C D6 5F 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
00007FF91DFEDB8C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDB93  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDB97  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDB9B  48 8D 87 80 8A 00 00        lea     rax, [rdi+8A80h]
00007FF91DFEDBA2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDBA9  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEDBAC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDBB0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDBB4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDBB9  E8 42 DE 01 00              call    sub_7FF91E00BA00
00007FF91DFEDBBE  48 8D 05 13 D6 5F 00        lea     rax, aPwmSwManual; "PWM SW Manual"
00007FF91DFEDBC5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDBCC  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEDBCF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDBD3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDBD8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDBDF  48 8D 87 90 8A 00 00        lea     rax, [rdi+8A90h]
00007FF91DFEDBE6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDBEA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDBEE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDBF2  E8 09 DE 01 00              call    sub_7FF91E00BA00
00007FF91DFEDBF7  66 0F 6F 05 31 E4 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDBFF  48 8D 05 E2 D5 5F 00        lea     rax, aTune; "Tune"
00007FF91DFEDC06  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDC0A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDC0E  48 8D 87 A0 8A 00 00        lea     rax, [rdi+8AA0h]
00007FF91DFEDC15  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDC1C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDC20  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDC24  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDC29  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDC30  E8 CB DD 01 00              call    sub_7FF91E00BA00
00007FF91DFEDC35  66 0F 6F 05 F3 E3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDC3D  48 8D 05 AC D5 5F 00        lea     rax, aDetune; "Detune"
00007FF91DFEDC44  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDC48  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDC4C  48 8D 87 B0 8A 00 00        lea     rax, [rdi+8AB0h]
00007FF91DFEDC53  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDC5A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDC5E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDC62  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDC67  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDC6E  E8 8D DD 01 00              call    sub_7FF91E00BA00
00007FF91DFEDC73  66 0F 6F 05 B5 E3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDC7B  48 8D 05 76 D5 5F 00        lea     rax, aModSens; "Mod Sens"
00007FF91DFEDC82  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDC86  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDC8A  48 8D 87 C0 8A 00 00        lea     rax, [rdi+8AC0h]
00007FF91DFEDC91  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDC98  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDC9C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDCA0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDCA5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDCAC  E8 4F DD 01 00              call    sub_7FF91E00BA00
00007FF91DFEDCB1  66 0F 6F 05 77 E3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDCB9  48 8D 05 44 D5 5F 00        lea     rax, aModSw; "Mod Sw"
00007FF91DFEDCC0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDCC4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDCC8  48 8D 87 D0 8A 00 00        lea     rax, [rdi+8AD0h]
00007FF91DFEDCCF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDCD6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDCDA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDCDE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDCE3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDCEA  E8 11 DD 01 00              call    sub_7FF91E00BA00
00007FF91DFEDCEF  66 0F 6F 05 39 E3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDCF7  48 8D 05 12 D5 5F 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFEDCFE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDD02  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDD06  48 8D 87 E0 8A 00 00        lea     rax, [rdi+8AE0h]
00007FF91DFEDD0D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDD14  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDD18  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDD1C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDD21  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDD28  E8 D3 DC 01 00              call    sub_7FF91E00BA00
00007FF91DFEDD2D  66 0F 6F 05 FB E2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDD35  48 8D 05 E4 D4 5F 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFEDD3C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDD40  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDD44  48 8D 87 F0 8A 00 00        lea     rax, [rdi+8AF0h]
00007FF91DFEDD4B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDD52  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDD56  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDD5A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDD5F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDD66  E8 95 DC 01 00              call    sub_7FF91E00BA00
00007FF91DFEDD6B  66 0F 6F 05 BD E2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDD73  48 8D 05 B2 D4 5F 00        lea     rax, aLfoSw; "LFO Sw"
00007FF91DFEDD7A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDD7E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDD82  48 8D 87 00 8B 00 00        lea     rax, [rdi+8B00h]
00007FF91DFEDD89  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDD90  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDD94  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDD98  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDD9D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDDA4  E8 57 DC 01 00              call    sub_7FF91E00BA00
00007FF91DFEDDA9  66 0F 6F 05 7F E2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDDB1  48 8D 05 80 D4 5F 00        lea     rax, aEnv1Level; "ENV1 Level"
00007FF91DFEDDB8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDDBC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDDC0  48 8D 87 10 8B 00 00        lea     rax, [rdi+8B10h]
00007FF91DFEDDC7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDDCE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDDD2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDDD6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDDDB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDDE2  E8 19 DC 01 00              call    sub_7FF91E00BA00
00007FF91DFEDDE7  66 0F 6F 05 41 E2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDDEF  48 8D 05 52 D4 5F 00        lea     rax, aEnv2Level; "ENV2 Level"
00007FF91DFEDDF6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDDFA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDDFE  48 8D 87 20 8B 00 00        lea     rax, [rdi+8B20h]
00007FF91DFEDE05  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDE0C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDE10  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDE14  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDE19  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDE20  E8 DB DB 01 00              call    sub_7FF91E00BA00
00007FF91DFEDE25  66 0F 6F 05 03 E2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDE2D  48 8D 05 20 D4 5F 00        lea     rax, aEnvSw; "ENV Sw"
00007FF91DFEDE34  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDE38  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDE3C  48 8D 87 30 8B 00 00        lea     rax, [rdi+8B30h]
00007FF91DFEDE43  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDE4A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDE4E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDE52  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDE57  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDE5E  E8 9D DB 01 00              call    sub_7FF91E00BA00
00007FF91DFEDE63  66 0F 6F 05 C5 E1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDE6B  48 8D 05 EE D3 5F 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFEDE72  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDE76  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDE7A  48 8D 87 40 8B 00 00        lea     rax, [rdi+8B40h]
00007FF91DFEDE81  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDE88  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDE8C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDE90  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDE95  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDE9C  E8 5F DB 01 00              call    sub_7FF91E00BA00
00007FF91DFEDEA1  66 0F 6F 05 87 E1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDEA9  48 8D 05 C0 D3 5F 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFEDEB0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDEB4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDEB8  48 8D 87 50 8B 00 00        lea     rax, [rdi+8B50h]
00007FF91DFEDEBF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDEC6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDECA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDECE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDED3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDEDA  E8 21 DB 01 00              call    sub_7FF91E00BA00
00007FF91DFEDEDF  66 0F 6F 05 49 E1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDEE7  48 8D 05 92 D3 5F 00        lea     rax, aPwmLevel; "PWM Level"
00007FF91DFEDEEE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDEF2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDEF6  48 8D 87 60 8B 00 00        lea     rax, [rdi+8B60h]
00007FF91DFEDEFD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDF04  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDF08  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDF0C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDF11  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDF18  E8 E3 DA 01 00              call    sub_7FF91E00BA00
00007FF91DFEDF1D  66 0F 6F 05 0B E1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDF25  48 8D 05 64 D3 5F 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
00007FF91DFEDF2C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDF30  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDF34  48 8D 87 90 8B 00 00        lea     rax, [rdi+8B90h]
00007FF91DFEDF3B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDF42  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDF46  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDF4A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDF4F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDF56  E8 A5 DA 01 00              call    sub_7FF91E00BA00
00007FF91DFEDF5B  48 8D 05 3E D3 5F 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
00007FF91DFEDF62  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDF69  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDF6D  66 0F 6F 05 BB E0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDF75  48 8D 87 A0 8B 00 00        lea     rax, [rdi+8BA0h]
00007FF91DFEDF7C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDF80  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDF84  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDF88  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDF8F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDF94  E8 67 DA 01 00              call    sub_7FF91E00BA00
00007FF91DFEDF99  66 0F 6F 05 8F E0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDFA1  48 8D 05 08 D3 5F 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
00007FF91DFEDFA8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDFAC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDFB0  48 8D 87 B0 8B 00 00        lea     rax, [rdi+8BB0h]
00007FF91DFEDFB7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDFBE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEDFC2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEDFC6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEDFCB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEDFD2  E8 29 DA 01 00              call    sub_7FF91E00BA00
00007FF91DFEDFD7  66 0F 6F 05 51 E0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEDFDF  48 8D 05 DA D2 5F 00        lea     rax, aDutyTune; "Duty Tune"
00007FF91DFEDFE6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEDFEA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEDFEE  48 8D 87 C0 90 00 00        lea     rax, [rdi+90C0h]
00007FF91DFEDFF5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEDFFC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE000  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE004  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE009  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE010  E8 EB D9 01 00              call    sub_7FF91E00BA00
00007FF91DFEE015  66 0F 6F 05 13 E0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE01D  48 8D 05 AC D2 5F 00        lea     rax, aOsc1Mute; "Osc1 Mute"
00007FF91DFEE024  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE028  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE02C  48 8D 87 60 94 00 00        lea     rax, [rdi+9460h]
00007FF91DFEE033  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE03A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE03E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE042  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE047  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE04E  E8 AD D9 01 00              call    sub_7FF91E00BA00
00007FF91DFEE053  66 0F 6F 05 D5 DF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE05B  48 8D 05 7E D2 5F 00        lea     rax, aOsc1Level; "Osc1 Level"
00007FF91DFEE062  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE066  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE06A  48 8D 87 A0 94 00 00        lea     rax, [rdi+94A0h]
00007FF91DFEE071  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE078  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE07C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE080  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE085  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE08C  E8 6F D9 01 00              call    sub_7FF91E00BA00
00007FF91DFEE091  66 0F 6F 05 97 DF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE099  48 8D 05 50 D2 5F 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
00007FF91DFEE0A0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE0A4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE0A8  48 8D 87 B0 94 00 00        lea     rax, [rdi+94B0h]
00007FF91DFEE0AF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE0B6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE0BA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE0BE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE0C3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE0CA  E8 31 D9 01 00              call    sub_7FF91E00BA00
00007FF91DFEE0CF  48 8D 05 2A D2 5F 00        lea     rax, aGrifferSw; "Griffer SW"
00007FF91DFEE0D6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE0DD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE0E1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE0E5  48 8D 87 70 95 00 00        lea     rax, [rdi+9570h]
00007FF91DFEE0EC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE0F3  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE0F6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE0FA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE0FE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE103  E8 F8 D8 01 00              call    sub_7FF91E00BA00
00007FF91DFEE108  66 0F 6F 05 20 DF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE110  48 8D 05 F9 D1 5F 00        lea     rax, aLpfCutoff; "LPF Cutoff"
00007FF91DFEE117  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE11B  48 8D 87 80 95 00 00        lea     rax, [rdi+9580h]
00007FF91DFEE122  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE129  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE12E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE135  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE139  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE13D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE141  E8 BA D8 01 00              call    sub_7FF91E00BA00
00007FF91DFEE146  66 0F 6F 05 E2 DE 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE14E  48 8D 05 CB D1 5F 00        lea     rax, aLpfResonance; "LPF Resonance"
00007FF91DFEE155  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE159  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE15D  48 8D 87 E0 95 00 00        lea     rax, [rdi+95E0h]
00007FF91DFEE164  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE16B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE16F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE173  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE178  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE17F  E8 7C D8 01 00              call    sub_7FF91E00BA00
00007FF91DFEE184  48 8D 05 A5 D1 5F 00        lea     rax, aVelocity; "Velocity"
00007FF91DFEE18B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE192  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE196  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE19A  48 8D 87 00 96 00 00        lea     rax, [rdi+9600h]
00007FF91DFEE1A1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE1A8  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE1AB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE1AF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE1B3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE1B8  E8 43 D8 01 00              call    sub_7FF91E00BA00
00007FF91DFEE1BD  48 8D 05 78 D1 5F 00        lea     rax, aEnv12; "Env1/2"
00007FF91DFEE1C4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE1CB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE1CF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE1D3  48 8D 87 90 96 00 00        lea     rax, [rdi+9690h]
00007FF91DFEE1DA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE1E1  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE1E4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE1E8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE1EC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE1F1  E8 0A D8 01 00              call    sub_7FF91E00BA00
00007FF91DFEE1F6  48 8D 05 4B D1 5F 00        lea     rax, aIntEnv; "Int/Env"
00007FF91DFEE1FD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE204  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE208  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE20C  48 8D 87 A0 96 00 00        lea     rax, [rdi+96A0h]
00007FF91DFEE213  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE21A  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE21D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE221  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE225  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE22A  E8 D1 D7 01 00              call    sub_7FF91E00BA00
00007FF91DFEE22F  48 8D 05 DA CF 5F 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFEE236  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE23D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE241  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE245  48 8D 87 B0 97 00 00        lea     rax, [rdi+97B0h]
00007FF91DFEE24C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE253  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE256  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE25A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE25E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE263  E8 98 D7 01 00              call    sub_7FF91E00BA00
00007FF91DFEE268  48 8D 05 E1 D0 5F 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
00007FF91DFEE26F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE276  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE27A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE27E  48 8D 87 C0 97 00 00        lea     rax, [rdi+97C0h]
00007FF91DFEE285  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE28C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE28F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE293  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE297  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE29C  E8 5F D7 01 00              call    sub_7FF91E00BA00
00007FF91DFEE2A1  48 8D 05 B8 D0 5F 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
00007FF91DFEE2A8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE2AF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE2B3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE2B7  48 8D 87 D0 97 00 00        lea     rax, [rdi+97D0h]
00007FF91DFEE2BE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE2C5  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE2C8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE2CC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE2D0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE2D5  E8 26 D7 01 00              call    sub_7FF91E00BA00
00007FF91DFEE2DA  66 0F 6F 05 4E DD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE2E2  48 8D 05 37 CF 5F 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFEE2E9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE2ED  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE2F1  48 8D 87 E0 97 00 00        lea     rax, [rdi+97E0h]
00007FF91DFEE2F8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE2FF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE303  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE307  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE30C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE313  E8 E8 D6 01 00              call    sub_7FF91E00BA00
00007FF91DFEE318  66 0F 6F 05 10 DD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE320  48 8D 05 49 D0 5F 00        lea     rax, aModSens_0; "MOD Sens"
00007FF91DFEE327  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE32B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE32F  48 8D 87 F0 97 00 00        lea     rax, [rdi+97F0h]
00007FF91DFEE336  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE33D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE341  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE345  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE34A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE351  E8 AA D6 01 00              call    sub_7FF91E00BA00
00007FF91DFEE356  66 0F 6F 05 D2 DC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE35E  48 8D 05 17 D0 5F 00        lea     rax, aModSw_0; "MOD SW"
00007FF91DFEE365  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE369  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE36D  48 8D 87 00 98 00 00        lea     rax, [rdi+9800h]
00007FF91DFEE374  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE37B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE37F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE383  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE388  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE38F  E8 6C D6 01 00              call    sub_7FF91E00BA00
00007FF91DFEE394  66 0F 6F 05 94 DC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE39C  48 8D 05 E5 CF 5F 00        lea     rax, aEnvLevel; "ENV Level"
00007FF91DFEE3A3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE3A7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE3AB  48 8D 87 10 98 00 00        lea     rax, [rdi+9810h]
00007FF91DFEE3B2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE3B9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE3BD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE3C1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE3C6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE3CD  E8 2E D6 01 00              call    sub_7FF91E00BA00
00007FF91DFEE3D2  66 0F 6F 05 56 DC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE3DA  48 8D 05 B7 CF 5F 00        lea     rax, aKcvLevel; "KCV Level"
00007FF91DFEE3E1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE3E5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE3E9  48 8D 87 20 98 00 00        lea     rax, [rdi+9820h]
00007FF91DFEE3F0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE3F7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE3FB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE3FF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE404  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE40B  E8 F0 D5 01 00              call    sub_7FF91E00BA00
00007FF91DFEE410  66 0F 6F 05 18 DC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE418  48 8D 05 89 CF 5F 00        lea     rax, aVelocitySens; "Velocity Sens"
00007FF91DFEE41F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE423  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE427  48 8D 87 30 98 00 00        lea     rax, [rdi+9830h]
00007FF91DFEE42E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE435  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE439  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE43D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE442  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE449  E8 B2 D5 01 00              call    sub_7FF91E00BA00
00007FF91DFEE44E  66 0F 6F 05 DA DB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE456  48 8D 05 5B CF 5F 00        lea     rax, aVelocityOffset; "Velocity Offset"
00007FF91DFEE45D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE461  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE465  48 8D 87 40 98 00 00        lea     rax, [rdi+9840h]
00007FF91DFEE46C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE473  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE477  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE47B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE480  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE487  E8 74 D5 01 00              call    sub_7FF91E00BA00
00007FF91DFEE48C  66 0F 6F 05 9C DB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE494  48 8D 05 C5 CD 5F 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFEE49B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE49F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE4A6  48 8D 87 50 98 00 00        lea     rax, [rdi+9850h]
00007FF91DFEE4AD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE4B4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE4B8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE4BC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE4C0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE4C5  E8 36 D5 01 00              call    sub_7FF91E00BA00
00007FF91DFEE4CA  66 0F 6F 05 5E DB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE4D2  48 8D 05 97 CD 5F 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFEE4D9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE4DD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE4E1  48 8D 87 60 98 00 00        lea     rax, [rdi+9860h]
00007FF91DFEE4E8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE4EF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE4F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE4F7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE4FC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE503  E8 F8 D4 01 00              call    sub_7FF91E00BA00
00007FF91DFEE508  66 0F 6F 05 20 DB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE510  48 8D 05 B1 CE 5F 00        lea     rax, aCutoffTune; "Cutoff Tune"
00007FF91DFEE517  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE51B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE51F  48 8D 87 E0 98 00 00        lea     rax, [rdi+98E0h]
00007FF91DFEE526  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE52D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE531  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE535  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE53A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE541  E8 BA D4 01 00              call    sub_7FF91E00BA00
00007FF91DFEE546  66 0F 6F 05 E2 DA 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE54E  48 8D 05 83 CE 5F 00        lea     rax, aResonanceTune; "Resonance Tune"
00007FF91DFEE555  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE559  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE55D  48 8D 87 F0 98 00 00        lea     rax, [rdi+98F0h]
00007FF91DFEE564  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE56B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE56F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE573  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE578  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE57F  E8 7C D4 01 00              call    sub_7FF91E00BA00
00007FF91DFEE584  48 8D 05 5D CE 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFEE58B  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFEE592  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE596  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE59A  48 8D 87 00 99 00 00        lea     rax, [rdi+9900h]
00007FF91DFEE5A1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE5A8  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE5AB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE5AF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE5B3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE5B8  E8 43 D4 01 00              call    sub_7FF91E00BA00
00007FF91DFEE5BD  48 8D 05 24 CE 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFEE5C4  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFEE5CB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE5CF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE5D3  48 8D 87 90 9E 00 00        lea     rax, [rdi+9E90h]
00007FF91DFEE5DA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE5E1  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE5E4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE5E8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE5EC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE5F1  E8 0A D4 01 00              call    sub_7FF91E00BA00
00007FF91DFEE5F6  66 0F 6F 05 32 DA 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE5FE  48 8D 05 F3 CD 5F 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
00007FF91DFEE605  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE609  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE60D  48 8D 87 A0 9E 00 00        lea     rax, [rdi+9EA0h]
00007FF91DFEE614  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE61B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE61F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE623  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE628  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE62F  E8 CC D3 01 00              call    sub_7FF91E00BA00
00007FF91DFEE634  66 0F 6F 05 F4 D9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE63C  48 8D 05 C5 CD 5F 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
00007FF91DFEE643  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE647  48 8D 87 B0 9E 00 00        lea     rax, [rdi+9EB0h]
00007FF91DFEE64E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE652  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE659  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE65E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE665  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE669  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE66D  E8 8E D3 01 00              call    sub_7FF91E00BA00
00007FF91DFEE672  66 0F 6F 05 B6 D9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE67A  48 8D 05 97 CD 5F 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
00007FF91DFEE681  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE685  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE689  48 8D 87 C0 9E 00 00        lea     rax, [rdi+9EC0h]
00007FF91DFEE690  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE697  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE69B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE69F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE6A4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE6AB  E8 50 D3 01 00              call    sub_7FF91E00BA00
00007FF91DFEE6B0  66 0F 6F 05 78 D9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE6B8  48 8D 05 69 CD 5F 00        lea     rax, aAmpTone; "AMP TONE"
00007FF91DFEE6BF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE6C3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE6C7  48 8D 87 A0 A0 00 00        lea     rax, [rdi+0A0A0h]
00007FF91DFEE6CE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE6D5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE6D9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE6DD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE6E2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE6E9  E8 12 D3 01 00              call    sub_7FF91E00BA00
00007FF91DFEE6EE  66 0F 6F 05 3A D9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE6F6  48 8D 05 3B CD 5F 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
00007FF91DFEE6FD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE701  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE705  48 8D 87 B0 A0 00 00        lea     rax, [rdi+0A0B0h]
00007FF91DFEE70C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE713  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE717  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE71B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE720  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE727  E8 D4 D2 01 00              call    sub_7FF91E00BA00
00007FF91DFEE72C  66 0F 6F 05 FC D8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE734  48 8D 05 15 CD 5F 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
00007FF91DFEE73B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE73F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE743  48 8D 87 C0 A0 00 00        lea     rax, [rdi+0A0C0h]
00007FF91DFEE74A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE751  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE755  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE759  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE75E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE765  E8 96 D2 01 00              call    sub_7FF91E00BA00
00007FF91DFEE76A  48 8D 05 BF CB 5F 00        lea     rax, aVelocity; "Velocity"
00007FF91DFEE771  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE778  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE77C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE780  48 8D 87 00 A1 00 00        lea     rax, [rdi+0A100h]
00007FF91DFEE787  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE78E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE791  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE795  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE799  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE79E  E8 5D D2 01 00              call    sub_7FF91E00BA00
00007FF91DFEE7A3  48 8D 05 BE CC 5F 00        lea     rax, aMute; "Mute"
00007FF91DFEE7AA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE7B1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE7B5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE7B9  48 8D 87 90 A1 00 00        lea     rax, [rdi+0A190h]
00007FF91DFEE7C0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE7C7  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE7CA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE7CE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE7D2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE7D7  E8 24 D2 01 00              call    sub_7FF91E00BA00
00007FF91DFEE7DC  48 8D 05 8D CC 5F 00        lea     rax, aGateSw; "Gate SW"
00007FF91DFEE7E3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE7EA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE7EE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE7F2  48 8D 87 F0 A2 00 00        lea     rax, [rdi+0A2F0h]
00007FF91DFEE7F9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE800  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE803  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE807  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE80B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE810  E8 EB D1 01 00              call    sub_7FF91E00BA00
00007FF91DFEE815  48 8D 05 5C CC 5F 00        lea     rax, aEnv1Sw; "ENV1 SW"
00007FF91DFEE81C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE820  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE824  48 8D 87 00 A3 00 00        lea     rax, [rdi+0A300h]
00007FF91DFEE82B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE832  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE835  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE839  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE83D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE844  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE849  E8 B2 D1 01 00              call    sub_7FF91E00BA00
00007FF91DFEE84E  48 8D 05 2B CC 5F 00        lea     rax, aEnv2Sw; "ENV2 SW"
00007FF91DFEE855  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE85C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE860  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE864  48 8D 87 10 A3 00 00        lea     rax, [rdi+0A310h]
00007FF91DFEE86B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE872  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE875  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE879  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE87D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE882  E8 79 D1 01 00              call    sub_7FF91E00BA00
00007FF91DFEE887  48 8D 05 FA CB 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
00007FF91DFEE88E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE895  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE899  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE89D  48 8D 87 20 A3 00 00        lea     rax, [rdi+0A320h]
00007FF91DFEE8A4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE8AB  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEE8AE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE8B2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE8B6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE8BB  E8 40 D1 01 00              call    sub_7FF91E00BA00
00007FF91DFEE8C0  66 0F 6F 05 68 D7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE8C8  48 8D 05 C9 CB 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
00007FF91DFEE8CF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE8D3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE8D7  48 8D 87 30 A3 00 00        lea     rax, [rdi+0A330h]
00007FF91DFEE8DE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE8E5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE8E9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE8ED  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE8F2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE8F9  E8 02 D1 01 00              call    sub_7FF91E00BA00
00007FF91DFEE8FE  66 0F 6F 05 2A D7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE906  48 8D 05 9B CB 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
00007FF91DFEE90D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE911  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE915  48 8D 87 40 A3 00 00        lea     rax, [rdi+0A340h]
00007FF91DFEE91C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE923  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE927  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE92B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE930  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE937  E8 C4 D0 01 00              call    sub_7FF91E00BA00
00007FF91DFEE93C  66 0F 6F 05 EC D6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE944  48 8D 05 6D CB 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
00007FF91DFEE94B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE94F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE953  48 8D 87 50 A3 00 00        lea     rax, [rdi+0A350h]
00007FF91DFEE95A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE961  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE965  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE969  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE96E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE975  E8 86 D0 01 00              call    sub_7FF91E00BA00
00007FF91DFEE97A  66 0F 6F 05 AE D6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE982  48 8D 05 3F CB 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
00007FF91DFEE989  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE98D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE991  48 8D 87 60 A3 00 00        lea     rax, [rdi+0A360h]
00007FF91DFEE998  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE99F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE9A3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE9A7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE9AC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE9B3  E8 48 D0 01 00              call    sub_7FF91E00BA00
00007FF91DFEE9B8  66 0F 6F 05 70 D6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE9C0  48 8D 05 19 CB 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
00007FF91DFEE9C7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEE9CB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEE9D0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEE9D7  48 8D 87 70 A3 00 00        lea     rax, [rdi+0A370h]
00007FF91DFEE9DE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEE9E5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEE9E9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEE9ED  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEE9F1  E8 0A D0 01 00              call    sub_7FF91E00BA00
00007FF91DFEE9F6  66 0F 6F 05 32 D6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEE9FE  48 8D 05 EB CA 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
00007FF91DFEEA05  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEA09  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEA0D  48 8D 87 80 A3 00 00        lea     rax, [rdi+0A380h]
00007FF91DFEEA14  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEA1B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEA1F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEA23  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEA28  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEA2F  E8 CC CF 01 00              call    sub_7FF91E00BA00
00007FF91DFEEA34  48 8D 05 E5 C4 5F 00        lea     rax, aUseextjack; "UseExtJack"
00007FF91DFEEA3B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEA42  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEA46  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEA4A  48 8D 87 50 A5 00 00        lea     rax, [rdi+0A550h]
00007FF91DFEEA51  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEA58  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEEA5B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEA5F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEA63  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEA68  E8 93 CF 01 00              call    sub_7FF91E00BA00
00007FF91DFEEA6D  48 8D 05 B8 C4 5F 00        lea     rax, aMCv; "M.CV"
00007FF91DFEEA74  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEA7B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEA7F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEA83  48 8D 87 70 A5 00 00        lea     rax, [rdi+0A570h]
00007FF91DFEEA8A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEA91  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEEA94  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEA98  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEA9C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEAA1  E8 5A CF 01 00              call    sub_7FF91E00BA00
00007FF91DFEEAA6  48 8D 05 87 C4 5F 00        lea     rax, aMGate; "M.Gate"
00007FF91DFEEAAD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEAB4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEAB8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEABC  48 8D 87 80 A5 00 00        lea     rax, [rdi+0A580h]
00007FF91DFEEAC3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEACA  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEEACD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEAD1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEAD5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEADA  E8 21 CF 01 00              call    sub_7FF91E00BA00
00007FF91DFEEADF  66 0F 6F 05 49 D5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEEAE7  48 8D 05 52 C4 5F 00        lea     rax, aMasterTune; "Master Tune"
00007FF91DFEEAEE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEAF2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEAF6  48 8D 87 B0 A5 00 00        lea     rax, [rdi+0A5B0h]
00007FF91DFEEAFD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEB04  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEB08  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEB0C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEB11  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEB18  E8 E3 CE 01 00              call    sub_7FF91E00BA00
00007FF91DFEEB1D  66 0F 6F 05 0B D5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEEB25  48 8D 05 24 C4 5F 00        lea     rax, aPartTune; "Part Tune"
00007FF91DFEEB2C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEB30  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEB34  48 8D 87 C0 A5 00 00        lea     rax, [rdi+0A5C0h]
00007FF91DFEEB3B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEB42  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEB46  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEB4A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEB4F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEB56  E8 A5 CE 01 00              call    sub_7FF91E00BA00
00007FF91DFEEB5B  48 8D 05 FE C3 5F 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
00007FF91DFEEB62  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEB69  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEB6D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEB71  48 8D 87 90 A6 00 00        lea     rax, [rdi+0A690h]
00007FF91DFEEB78  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEB7F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEEB82  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEB86  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEB8B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEB8F  E8 6C CE 01 00              call    sub_7FF91E00BA00
00007FF91DFEEB94  48 8D 05 DD C3 5F 00        lea     rax, aPortamentoMode; "Portamento Mode"
00007FF91DFEEB9B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEBA2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEBA6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEBAA  48 8D 87 A0 A6 00 00        lea     rax, [rdi+0A6A0h]
00007FF91DFEEBB1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEBB8  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEEBBB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEBBF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEBC3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEBC8  E8 33 CE 01 00              call    sub_7FF91E00BA00
00007FF91DFEEBCD  66 0F 6F 05 5B D4 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEEBD5  48 8D 05 AC C3 5F 00        lea     rax, aPortamentoTime; "Portamento Time"
00007FF91DFEEBDC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEBE0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEBE4  48 8D 87 B0 A6 00 00        lea     rax, [rdi+0A6B0h]
00007FF91DFEEBEB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEBF2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEBF6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEBFA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEBFF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEC06  E8 F5 CD 01 00              call    sub_7FF91E00BA00
00007FF91DFEEC0B  48 8D 05 86 C3 5F 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
00007FF91DFEEC12  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEC19  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEC1D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEC21  48 8D 87 50 A8 00 00        lea     rax, [rdi+0A850h]
00007FF91DFEEC28  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEC2F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEEC32  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEC36  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEC3A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEC3F  E8 BC CD 01 00              call    sub_7FF91E00BA00
00007FF91DFEEC44  48 8D 05 65 C3 5F 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
00007FF91DFEEC4B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEC52  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEC56  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEC5A  48 8D 87 60 A8 00 00        lea     rax, [rdi+0A860h]
00007FF91DFEEC61  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEC68  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEEC6B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEC6F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEC73  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEC78  E8 83 CD 01 00              call    sub_7FF91E00BA00
00007FF91DFEEC7D  48 8D 05 44 C3 5F 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
00007FF91DFEEC84  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEC8B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEC8F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEC93  48 8D 87 70 A8 00 00        lea     rax, [rdi+0A870h]
00007FF91DFEEC9A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEECA1  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEECA4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEECA8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEECAC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEECB1  E8 4A CD 01 00              call    sub_7FF91E00BA00
00007FF91DFEECB6  66 0F 6F 05 72 D3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEECBE  48 8D 05 13 C3 5F 00        lea     rax, aLfoRate; "LFO Rate"
00007FF91DFEECC5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEECC9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEECCD  48 8D 87 80 A8 00 00        lea     rax, [rdi+0A880h]
00007FF91DFEECD4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEECDB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEECDF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEECE3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEECE8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEECEF  E8 0C CD 01 00              call    sub_7FF91E00BA00
00007FF91DFEECF4  48 8D 05 E9 C2 5F 00        lea     rax, aGate; "Gate"
00007FF91DFEECFB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEED02  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEED06  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEED0A  48 8D 87 80 AB 00 00        lea     rax, [rdi+0AB80h]
00007FF91DFEED11  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEED18  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEED1B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEED1F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEED23  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEED28  E8 D3 CC 01 00              call    sub_7FF91E00BA00
00007FF91DFEED2D  48 8D 05 BC C2 5F 00        lea     rax, aLfoTrig; "LFO Trig"
00007FF91DFEED34  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEED38  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEED3B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEED42  48 8D 87 90 AB 00 00        lea     rax, [rdi+0AB90h]
00007FF91DFEED49  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEED50  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEED54  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEED58  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEED5C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEED61  E8 9A CC 01 00              call    sub_7FF91E00BA00
00007FF91DFEED66  48 8D 05 93 C2 5F 00        lea     rax, aResetSw; "Reset Sw"
00007FF91DFEED6D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEED74  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEED78  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEED7C  48 8D 87 A0 AB 00 00        lea     rax, [rdi+0ABA0h]
00007FF91DFEED83  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEED8A  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEED8D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEED91  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEED95  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEED9A  E8 61 CC 01 00              call    sub_7FF91E00BA00
00007FF91DFEED9F  66 0F 6F 05 89 D2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEEDA7  48 8D 05 62 C2 5F 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
00007FF91DFEEDAE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEDB2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEDB6  48 8D 87 B0 AB 00 00        lea     rax, [rdi+0ABB0h]
00007FF91DFEEDBD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEDC4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEDC8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEDCC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEDD1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEDD8  E8 23 CC 01 00              call    sub_7FF91E00BA00
00007FF91DFEEDDD  66 0F 6F 05 4B D2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEEDE5  48 8D 05 34 C2 5F 00        lea     rax, aLfoDelay; "LFO Delay"
00007FF91DFEEDEC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEDF0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEDF4  48 8D 87 C0 AB 00 00        lea     rax, [rdi+0ABC0h]
00007FF91DFEEDFB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEE02  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEE06  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEE0A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEE0F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEE16  E8 E5 CB 01 00              call    sub_7FF91E00BA00
00007FF91DFEEE1B  66 0F 6F 05 0D D2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEEE23  48 8D 05 06 C2 5F 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
00007FF91DFEEE2A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEE2E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEE32  48 8D 87 D0 AB 00 00        lea     rax, [rdi+0ABD0h]
00007FF91DFEEE39  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEE40  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEE44  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEE48  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEE4D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEE54  E8 A7 CB 01 00              call    sub_7FF91E00BA00
00007FF91DFEEE59  66 0F 6F 05 CF D1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEEE61  48 8D 05 D8 C1 5F 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
00007FF91DFEEE68  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEE6C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEE70  48 8D 87 E0 AB 00 00        lea     rax, [rdi+0ABE0h]
00007FF91DFEEE77  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEE7E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEE82  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEE86  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEE8B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEE92  E8 69 CB 01 00              call    sub_7FF91E00BA00
00007FF91DFEEE97  66 0F 6F 05 91 D1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEEE9F  48 8D 05 AA C1 5F 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
00007FF91DFEEEA6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEEAA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEEAE  48 8D 87 F0 AB 00 00        lea     rax, [rdi+0ABF0h]
00007FF91DFEEEB5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEEBC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEEC0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEEC4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEEC9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEED0  E8 2B CB 01 00              call    sub_7FF91E00BA00
00007FF91DFEEED5  66 0F 6F 05 53 D1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEEEDD  48 8D 05 7C C1 5F 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
00007FF91DFEEEE4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEEE8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEEED  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEEF4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEEFB  48 8D 87 00 AC 00 00        lea     rax, [rdi+0AC00h]
00007FF91DFEEF02  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEF06  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEF0A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEF0E  E8 ED CA 01 00              call    sub_7FF91E00BA00
00007FF91DFEEF13  66 0F 6F 05 15 D1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEEF1B  48 8D 05 4E C1 5F 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
00007FF91DFEEF22  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEF26  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEF2A  48 8D 87 10 AC 00 00        lea     rax, [rdi+0AC10h]
00007FF91DFEEF31  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEF38  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEF3C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEF40  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEF45  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEF4C  E8 AF CA 01 00              call    sub_7FF91E00BA00
00007FF91DFEEF51  66 0F 6F 05 D7 D0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEEF59  48 8D 05 20 C1 5F 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
00007FF91DFEEF60  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEF64  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEF68  48 8D 87 20 AC 00 00        lea     rax, [rdi+0AC20h]
00007FF91DFEEF6F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEF76  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEF7A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEF7E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEF83  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEF8A  E8 71 CA 01 00              call    sub_7FF91E00BA00
00007FF91DFEEF8F  66 0F 6F 05 99 D0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEEF97  48 8D 05 F2 C0 5F 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
00007FF91DFEEF9E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEFA2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEFA6  48 8D 87 30 AC 00 00        lea     rax, [rdi+0AC30h]
00007FF91DFEEFAD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEFB4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEFB8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEFBC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEFC1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEEFC8  E8 33 CA 01 00              call    sub_7FF91E00BA00
00007FF91DFEEFCD  66 0F 6F 05 5B D0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEEFD5  48 8D 05 C4 C0 5F 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
00007FF91DFEEFDC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEEFE0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEEFE4  48 8D 87 40 AC 00 00        lea     rax, [rdi+0AC40h]
00007FF91DFEEFEB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEEFF2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEEFF6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEEFFA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEEFFF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF006  E8 F5 C9 01 00              call    sub_7FF91E00BA00
00007FF91DFEF00B  66 0F 6F 05 1D D0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF013  48 8D 05 96 C0 5F 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
00007FF91DFEF01A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF01E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF022  48 8D 87 50 AC 00 00        lea     rax, [rdi+0AC50h]
00007FF91DFEF029  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF030  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF034  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF038  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF03D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF044  E8 B7 C9 01 00              call    sub_7FF91E00BA00
00007FF91DFEF049  66 0F 6F 05 DF CF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF051  48 8D 05 68 C0 5F 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
00007FF91DFEF058  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF05C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF060  48 8D 87 60 AC 00 00        lea     rax, [rdi+0AC60h]
00007FF91DFEF067  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF06E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF072  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF076  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF07B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF082  E8 79 C9 01 00              call    sub_7FF91E00BA00
00007FF91DFEF087  66 0F 6F 05 A1 CF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF08F  48 8D 05 3A C0 5F 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
00007FF91DFEF096  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF09A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF09E  48 8D 87 70 AC 00 00        lea     rax, [rdi+0AC70h]
00007FF91DFEF0A5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF0AC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF0B0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF0B4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF0B9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF0C0  E8 3B C9 01 00              call    sub_7FF91E00BA00
00007FF91DFEF0C5  66 0F 6F 05 63 CF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF0CD  48 8D 05 14 C0 5F 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
00007FF91DFEF0D4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF0D8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF0DC  48 8D 87 80 AC 00 00        lea     rax, [rdi+0AC80h]
00007FF91DFEF0E3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF0EA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF0EE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF0F2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF0F7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF0FE  E8 FD C8 01 00              call    sub_7FF91E00BA00
00007FF91DFEF103  48 8D 05 F6 BF 5F 00        lea     rax, aReadOnly; "read only"
00007FF91DFEF10A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF111  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF115  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF119  48 8D 87 20 AE 00 00        lea     rax, [rdi+0AE20h]
00007FF91DFEF120  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF127  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEF12A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF12E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF132  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF137  E8 C4 C8 01 00              call    sub_7FF91E00BA00
00007FF91DFEF13C  48 8D 05 BD BF 5F 00        lea     rax, aReadOnly; "read only"
00007FF91DFEF143  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF14A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF14E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF152  48 8D 87 30 AE 00 00        lea     rax, [rdi+0AE30h]
00007FF91DFEF159  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF160  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEF163  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF167  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF16B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF170  E8 8B C8 01 00              call    sub_7FF91E00BA00
00007FF91DFEF175  48 8D 05 94 BF 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFEF17C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF183  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF187  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF18B  48 8D 87 40 AE 00 00        lea     rax, [rdi+0AE40h]
00007FF91DFEF192  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF199  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEF19C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF1A0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF1A4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF1A9  E8 52 C8 01 00              call    sub_7FF91E00BA00
00007FF91DFEF1AE  66 0F 6F 05 7A CE 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF1B6  48 8D 05 6B BF 5F 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFEF1BD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF1C1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF1C5  48 8D 87 20 AF 00 00        lea     rax, [rdi+0AF20h]
00007FF91DFEF1CC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF1D3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF1D7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF1DB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF1E0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF1E7  E8 14 C8 01 00              call    sub_7FF91E00BA00
00007FF91DFEF1EC  66 0F 6F 05 3C CE 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF1F4  48 8D 05 3D BF 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFEF1FB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF1FF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF203  48 8D 87 30 AF 00 00        lea     rax, [rdi+0AF30h]
00007FF91DFEF20A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF211  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF215  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF219  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF21E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF225  E8 D6 C7 01 00              call    sub_7FF91E00BA00
00007FF91DFEF22A  66 0F 6F 05 FE CD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF232  48 8D 05 0F BF 5F 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFEF239  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF23D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF241  48 8D 87 40 AF 00 00        lea     rax, [rdi+0AF40h]
00007FF91DFEF248  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF24F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF253  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF257  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF25C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF263  E8 98 C7 01 00              call    sub_7FF91E00BA00
00007FF91DFEF268  48 8D 05 E9 BE 5F 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFEF26F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF276  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF27A  66 0F 6F 05 AE CD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF282  48 8D 87 50 AF 00 00        lea     rax, [rdi+0AF50h]
00007FF91DFEF289  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF28D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF291  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF295  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF29C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF2A1  E8 5A C7 01 00              call    sub_7FF91E00BA00
00007FF91DFEF2A6  66 0F 6F 05 82 CD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF2AE  48 8D 05 B3 BE 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFEF2B5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF2B9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF2BD  48 8D 87 60 AF 00 00        lea     rax, [rdi+0AF60h]
00007FF91DFEF2C4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF2CB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF2CF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF2D3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF2D8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF2DF  E8 1C C7 01 00              call    sub_7FF91E00BA00
00007FF91DFEF2E4  48 8D 05 25 BE 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFEF2EB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF2F2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF2F6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF2FA  48 8D 87 20 B0 00 00        lea     rax, [rdi+0B020h]
00007FF91DFEF301  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF308  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEF30B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF30F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF313  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF318  E8 E3 C6 01 00              call    sub_7FF91E00BA00
00007FF91DFEF31D  66 0F 6F 05 0B CD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF325  48 8D 05 FC BD 5F 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFEF32C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF330  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF334  48 8D 87 00 B1 00 00        lea     rax, [rdi+0B100h]
00007FF91DFEF33B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF342  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF346  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF34A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF34F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF356  E8 A5 C6 01 00              call    sub_7FF91E00BA00
00007FF91DFEF35B  66 0F 6F 05 CD CC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF363  48 8D 05 CE BD 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFEF36A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF36E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF372  48 8D 87 10 B1 00 00        lea     rax, [rdi+0B110h]
00007FF91DFEF379  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF380  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF384  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF388  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF38D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF394  E8 67 C6 01 00              call    sub_7FF91E00BA00
00007FF91DFEF399  66 0F 6F 05 8F CC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF3A1  48 8D 05 A0 BD 5F 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFEF3A8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF3AC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF3B0  48 8D 87 20 B1 00 00        lea     rax, [rdi+0B120h]
00007FF91DFEF3B7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF3BE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF3C2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF3C6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF3CB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF3D2  E8 29 C6 01 00              call    sub_7FF91E00BA00
00007FF91DFEF3D7  66 0F 6F 05 51 CC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF3DF  48 8D 05 72 BD 5F 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFEF3E6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF3EA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF3EE  48 8D 87 30 B1 00 00        lea     rax, [rdi+0B130h]
00007FF91DFEF3F5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF3FC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF400  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF404  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF409  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF410  E8 EB C5 01 00              call    sub_7FF91E00BA00
00007FF91DFEF415  66 0F 6F 05 13 CC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF41D  48 8D 05 44 BD 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFEF424  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF428  48 8D 87 40 B1 00 00        lea     rax, [rdi+0B140h]
00007FF91DFEF42F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF436  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF43B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF442  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF446  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF44A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF44E  E8 AD C5 01 00              call    sub_7FF91E00BA00
00007FF91DFEF453  48 8D 05 1E BD 5F 00        lea     rax, aOsc1Feet; "OSC1 Feet"
00007FF91DFEF45A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF461  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF465  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF469  48 8D 87 40 B3 00 00        lea     rax, [rdi+0B340h]
00007FF91DFEF470  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF477  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEF47A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF47E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF482  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF487  E8 74 C5 01 00              call    sub_7FF91E00BA00
00007FF91DFEF48C  48 8D 05 F5 BC 5F 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
00007FF91DFEF493  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF49A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF49E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF4A2  48 8D 87 50 B3 00 00        lea     rax, [rdi+0B350h]
00007FF91DFEF4A9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF4B0  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEF4B3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF4B7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF4BB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF4C0  E8 3B C5 01 00              call    sub_7FF91E00BA00
00007FF91DFEF4C5  48 8D 05 CC BC 5F 00        lea     rax, aBendEnableSw; "Bend Enable SW"
00007FF91DFEF4CC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF4D3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF4D7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF4DB  48 8D 87 60 B3 00 00        lea     rax, [rdi+0B360h]
00007FF91DFEF4E2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF4E9  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEF4EC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF4F0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF4F4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF4F9  E8 02 C5 01 00              call    sub_7FF91E00BA00
00007FF91DFEF4FE  48 8D 05 A3 BC 5F 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
00007FF91DFEF505  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF50C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF510  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF514  48 8D 87 70 B3 00 00        lea     rax, [rdi+0B370h]
00007FF91DFEF51B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF522  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEF525  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF529  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF52D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF532  E8 C9 C4 01 00              call    sub_7FF91E00BA00
00007FF91DFEF537  48 8D 05 7A BC 5F 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
00007FF91DFEF53E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF545  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF549  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF54D  48 8D 87 80 B3 00 00        lea     rax, [rdi+0B380h]
00007FF91DFEF554  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF55B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEF55E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF562  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF566  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF56B  E8 90 C4 01 00              call    sub_7FF91E00BA00
00007FF91DFEF570  48 8D 05 51 BC 5F 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
00007FF91DFEF577  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF57E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF582  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF586  48 8D 87 90 B3 00 00        lea     rax, [rdi+0B390h]
00007FF91DFEF58D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF594  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEF597  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF59B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF59F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF5A4  E8 57 C4 01 00              call    sub_7FF91E00BA00
00007FF91DFEF5A9  48 8D 05 28 BC 5F 00        lea     rax, aPwmSwManual; "PWM SW Manual"
00007FF91DFEF5B0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF5B7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF5BB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF5BF  48 8D 87 A0 B3 00 00        lea     rax, [rdi+0B3A0h]
00007FF91DFEF5C6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF5CD  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEF5D0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF5D4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF5D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF5DD  E8 1E C4 01 00              call    sub_7FF91E00BA00
00007FF91DFEF5E2  66 0F 6F 05 46 CA 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF5EA  48 8D 05 F7 BB 5F 00        lea     rax, aTune; "Tune"
00007FF91DFEF5F1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF5F5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF5F9  48 8D 87 B0 B3 00 00        lea     rax, [rdi+0B3B0h]
00007FF91DFEF600  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF607  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF60B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF60F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF614  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF61B  E8 E0 C3 01 00              call    sub_7FF91E00BA00
00007FF91DFEF620  66 0F 6F 05 08 CA 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF628  48 8D 05 C1 BB 5F 00        lea     rax, aDetune; "Detune"
00007FF91DFEF62F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF633  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF637  48 8D 87 C0 B3 00 00        lea     rax, [rdi+0B3C0h]
00007FF91DFEF63E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF645  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF649  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF64D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF652  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF659  E8 A2 C3 01 00              call    sub_7FF91E00BA00
00007FF91DFEF65E  66 0F 6F 05 CA C9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF666  48 8D 05 8B BB 5F 00        lea     rax, aModSens; "Mod Sens"
00007FF91DFEF66D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF671  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF675  48 8D 87 D0 B3 00 00        lea     rax, [rdi+0B3D0h]
00007FF91DFEF67C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF683  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF687  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF68B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF690  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF697  E8 64 C3 01 00              call    sub_7FF91E00BA00
00007FF91DFEF69C  66 0F 6F 05 8C C9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF6A4  48 8D 05 59 BB 5F 00        lea     rax, aModSw; "Mod Sw"
00007FF91DFEF6AB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF6AF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF6B3  48 8D 87 E0 B3 00 00        lea     rax, [rdi+0B3E0h]
00007FF91DFEF6BA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF6C1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF6C5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF6C9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF6CE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF6D5  E8 26 C3 01 00              call    sub_7FF91E00BA00
00007FF91DFEF6DA  66 0F 6F 05 4E C9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF6E2  48 8D 05 27 BB 5F 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFEF6E9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF6ED  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF6F1  48 8D 87 F0 B3 00 00        lea     rax, [rdi+0B3F0h]
00007FF91DFEF6F8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF6FF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF703  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF707  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF70C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF713  E8 E8 C2 01 00              call    sub_7FF91E00BA00
00007FF91DFEF718  66 0F 6F 05 10 C9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF720  48 8D 05 F9 BA 5F 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFEF727  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF72B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF72F  48 8D 87 00 B4 00 00        lea     rax, [rdi+0B400h]
00007FF91DFEF736  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF73D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF741  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF745  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF74A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF751  E8 AA C2 01 00              call    sub_7FF91E00BA00
00007FF91DFEF756  66 0F 6F 05 D2 C8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF75E  48 8D 05 C7 BA 5F 00        lea     rax, aLfoSw; "LFO Sw"
00007FF91DFEF765  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF769  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF76D  48 8D 87 10 B4 00 00        lea     rax, [rdi+0B410h]
00007FF91DFEF774  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF77B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF77F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF783  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF788  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF78F  E8 6C C2 01 00              call    sub_7FF91E00BA00
00007FF91DFEF794  66 0F 6F 05 94 C8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF79C  48 8D 05 95 BA 5F 00        lea     rax, aEnv1Level; "ENV1 Level"
00007FF91DFEF7A3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF7A7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF7AE  48 8D 87 20 B4 00 00        lea     rax, [rdi+0B420h]
00007FF91DFEF7B5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF7BC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF7C0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF7C4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF7C8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF7CD  E8 2E C2 01 00              call    sub_7FF91E00BA00
00007FF91DFEF7D2  66 0F 6F 05 56 C8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF7DA  48 8D 05 67 BA 5F 00        lea     rax, aEnv2Level; "ENV2 Level"
00007FF91DFEF7E1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF7E5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF7E9  48 8D 87 30 B4 00 00        lea     rax, [rdi+0B430h]
00007FF91DFEF7F0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF7F7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF7FB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF7FF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF804  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF80B  E8 F0 C1 01 00              call    sub_7FF91E00BA00
00007FF91DFEF810  66 0F 6F 05 18 C8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF818  48 8D 05 35 BA 5F 00        lea     rax, aEnvSw; "ENV Sw"
00007FF91DFEF81F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF823  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF827  48 8D 87 40 B4 00 00        lea     rax, [rdi+0B440h]
00007FF91DFEF82E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF835  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF839  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF83D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF842  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF849  E8 B2 C1 01 00              call    sub_7FF91E00BA00
00007FF91DFEF84E  66 0F 6F 05 DA C7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF856  48 8D 05 03 BA 5F 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFEF85D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF861  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF865  48 8D 87 50 B4 00 00        lea     rax, [rdi+0B450h]
00007FF91DFEF86C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF873  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF877  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF87B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF880  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF887  E8 74 C1 01 00              call    sub_7FF91E00BA00
00007FF91DFEF88C  66 0F 6F 05 9C C7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF894  48 8D 05 D5 B9 5F 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFEF89B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF89F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF8A3  48 8D 87 60 B4 00 00        lea     rax, [rdi+0B460h]
00007FF91DFEF8AA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF8B1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF8B5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF8B9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF8BE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF8C5  E8 36 C1 01 00              call    sub_7FF91E00BA00
00007FF91DFEF8CA  66 0F 6F 05 5E C7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF8D2  48 8D 05 A7 B9 5F 00        lea     rax, aPwmLevel; "PWM Level"
00007FF91DFEF8D9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF8DD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF8E1  48 8D 87 70 B4 00 00        lea     rax, [rdi+0B470h]
00007FF91DFEF8E8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF8EF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF8F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF8F7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF8FC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF903  E8 F8 C0 01 00              call    sub_7FF91E00BA00
00007FF91DFEF908  66 0F 6F 05 20 C7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF910  48 8D 05 79 B9 5F 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
00007FF91DFEF917  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF91B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF91F  48 8D 87 A0 B4 00 00        lea     rax, [rdi+0B4A0h]
00007FF91DFEF926  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF92D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF931  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF935  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF93A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF941  E8 BA C0 01 00              call    sub_7FF91E00BA00
00007FF91DFEF946  66 0F 6F 05 E2 C6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF94E  48 8D 05 4B B9 5F 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
00007FF91DFEF955  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF959  48 8D 87 B0 B4 00 00        lea     rax, [rdi+0B4B0h]
00007FF91DFEF960  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF964  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF96B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF970  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF977  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF97B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF97F  E8 7C C0 01 00              call    sub_7FF91E00BA00
00007FF91DFEF984  66 0F 6F 05 A4 C6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF98C  48 8D 05 1D B9 5F 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
00007FF91DFEF993  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF997  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF99B  48 8D 87 C0 B4 00 00        lea     rax, [rdi+0B4C0h]
00007FF91DFEF9A2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF9A9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF9AD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF9B1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF9B6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF9BD  E8 3E C0 01 00              call    sub_7FF91E00BA00
00007FF91DFEF9C2  66 0F 6F 05 66 C6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEF9CA  48 8D 05 EF B8 5F 00        lea     rax, aDutyTune; "Duty Tune"
00007FF91DFEF9D1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEF9D5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEF9D9  48 8D 87 D0 B9 00 00        lea     rax, [rdi+0B9D0h]
00007FF91DFEF9E0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEF9E7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEF9EB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEF9EF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEF9F4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEF9FB  E8 00 C0 01 00              call    sub_7FF91E00BA00
00007FF91DFEFA00  66 0F 6F 05 28 C6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFA08  48 8D 05 C1 B8 5F 00        lea     rax, aOsc1Mute; "Osc1 Mute"
00007FF91DFEFA0F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFA13  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFA17  48 8D 87 70 BD 00 00        lea     rax, [rdi+0BD70h]
00007FF91DFEFA1E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFA25  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFA29  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFA2D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFA32  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFA39  E8 C2 BF 01 00              call    sub_7FF91E00BA00
00007FF91DFEFA3E  66 0F 6F 05 EA C5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFA46  48 8D 05 93 B8 5F 00        lea     rax, aOsc1Level; "Osc1 Level"
00007FF91DFEFA4D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFA51  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFA55  48 8D 87 B0 BD 00 00        lea     rax, [rdi+0BDB0h]
00007FF91DFEFA5C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFA63  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFA67  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFA6B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFA70  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFA77  E8 84 BF 01 00              call    sub_7FF91E00BA00
00007FF91DFEFA7C  66 0F 6F 05 AC C5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFA84  48 8D 05 65 B8 5F 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
00007FF91DFEFA8B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFA8F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFA93  48 8D 87 C0 BD 00 00        lea     rax, [rdi+0BDC0h]
00007FF91DFEFA9A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFAA1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFAA5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFAA9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFAAE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFAB5  E8 46 BF 01 00              call    sub_7FF91E00BA00
00007FF91DFEFABA  48 8D 05 3F B8 5F 00        lea     rax, aGrifferSw; "Griffer SW"
00007FF91DFEFAC1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFAC8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFACC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFAD0  48 8D 87 80 BE 00 00        lea     rax, [rdi+0BE80h]
00007FF91DFEFAD7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFADE  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEFAE1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFAE5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFAE9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFAEE  E8 0D BF 01 00              call    sub_7FF91E00BA00
00007FF91DFEFAF3  66 0F 6F 05 35 C5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFAFB  48 8D 05 0E B8 5F 00        lea     rax, aLpfCutoff; "LPF Cutoff"
00007FF91DFEFB02  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFB06  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFB0A  48 8D 87 90 BE 00 00        lea     rax, [rdi+0BE90h]
00007FF91DFEFB11  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFB18  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFB1C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFB20  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFB25  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFB2C  E8 CF BE 01 00              call    sub_7FF91E00BA00
00007FF91DFEFB31  48 8D 05 E8 B7 5F 00        lea     rax, aLpfResonance; "LPF Resonance"
00007FF91DFEFB38  66 0F 6F 05 F0 C4 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFB40  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFB44  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFB48  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFB4C  48 8D 87 F0 BE 00 00        lea     rax, [rdi+0BEF0h]
00007FF91DFEFB53  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFB5A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFB5E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFB63  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFB6A  E8 91 BE 01 00              call    sub_7FF91E00BA00
00007FF91DFEFB6F  48 8D 05 BA B7 5F 00        lea     rax, aVelocity; "Velocity"
00007FF91DFEFB76  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFB7D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFB81  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFB85  48 8D 87 10 BF 00 00        lea     rax, [rdi+0BF10h]
00007FF91DFEFB8C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFB93  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEFB96  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFB9A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFB9E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFBA3  E8 58 BE 01 00              call    sub_7FF91E00BA00
00007FF91DFEFBA8  48 8D 05 8D B7 5F 00        lea     rax, aEnv12; "Env1/2"
00007FF91DFEFBAF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFBB6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFBBA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFBBE  48 8D 87 A0 BF 00 00        lea     rax, [rdi+0BFA0h]
00007FF91DFEFBC5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFBCC  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEFBCF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFBD3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFBD7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFBDC  E8 1F BE 01 00              call    sub_7FF91E00BA00
00007FF91DFEFBE1  48 8D 05 60 B7 5F 00        lea     rax, aIntEnv; "Int/Env"
00007FF91DFEFBE8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFBEF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFBF3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFBF7  48 8D 87 B0 BF 00 00        lea     rax, [rdi+0BFB0h]
00007FF91DFEFBFE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFC05  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEFC08  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFC0C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFC10  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFC15  E8 E6 BD 01 00              call    sub_7FF91E00BA00
00007FF91DFEFC1A  48 8D 05 EF B5 5F 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFEFC21  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFC28  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFC2C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFC30  48 8D 87 C0 C0 00 00        lea     rax, [rdi+0C0C0h]
00007FF91DFEFC37  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFC3E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEFC41  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFC45  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFC49  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFC4E  E8 AD BD 01 00              call    sub_7FF91E00BA00
00007FF91DFEFC53  48 8D 05 F6 B6 5F 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
00007FF91DFEFC5A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFC61  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFC65  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFC69  48 8D 87 D0 C0 00 00        lea     rax, [rdi+0C0D0h]
00007FF91DFEFC70  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFC77  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEFC7A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFC7E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFC82  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFC87  E8 74 BD 01 00              call    sub_7FF91E00BA00
00007FF91DFEFC8C  48 8D 05 CD B6 5F 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
00007FF91DFEFC93  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFC9A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFC9E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFCA2  48 8D 87 E0 C0 00 00        lea     rax, [rdi+0C0E0h]
00007FF91DFEFCA9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFCB0  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEFCB3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFCB7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFCBB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFCC0  E8 3B BD 01 00              call    sub_7FF91E00BA00
00007FF91DFEFCC5  66 0F 6F 05 63 C3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFCCD  48 8D 05 4C B5 5F 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFEFCD4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFCD8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFCDD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFCE4  48 8D 87 F0 C0 00 00        lea     rax, [rdi+0C0F0h]
00007FF91DFEFCEB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFCF2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFCF6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFCFA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFCFE  E8 FD BC 01 00              call    sub_7FF91E00BA00
00007FF91DFEFD03  66 0F 6F 05 25 C3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFD0B  48 8D 05 5E B6 5F 00        lea     rax, aModSens_0; "MOD Sens"
00007FF91DFEFD12  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFD16  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFD1A  48 8D 87 00 C1 00 00        lea     rax, [rdi+0C100h]
00007FF91DFEFD21  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFD28  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFD2C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFD30  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFD35  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFD3C  E8 BF BC 01 00              call    sub_7FF91E00BA00
00007FF91DFEFD41  66 0F 6F 05 E7 C2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFD49  48 8D 05 2C B6 5F 00        lea     rax, aModSw_0; "MOD SW"
00007FF91DFEFD50  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFD54  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFD58  48 8D 87 10 C1 00 00        lea     rax, [rdi+0C110h]
00007FF91DFEFD5F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFD66  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFD6A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFD6E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFD73  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFD7A  E8 81 BC 01 00              call    sub_7FF91E00BA00
00007FF91DFEFD7F  66 0F 6F 05 A9 C2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFD87  48 8D 05 FA B5 5F 00        lea     rax, aEnvLevel; "ENV Level"
00007FF91DFEFD8E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFD92  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFD96  48 8D 87 20 C1 00 00        lea     rax, [rdi+0C120h]
00007FF91DFEFD9D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFDA4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFDA8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFDAC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFDB1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFDB8  E8 43 BC 01 00              call    sub_7FF91E00BA00
00007FF91DFEFDBD  66 0F 6F 05 6B C2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFDC5  48 8D 05 CC B5 5F 00        lea     rax, aKcvLevel; "KCV Level"
00007FF91DFEFDCC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFDD0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFDD4  48 8D 87 30 C1 00 00        lea     rax, [rdi+0C130h]
00007FF91DFEFDDB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFDE2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFDE6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFDEA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFDEF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFDF6  E8 05 BC 01 00              call    sub_7FF91E00BA00
00007FF91DFEFDFB  66 0F 6F 05 2D C2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFE03  48 8D 05 9E B5 5F 00        lea     rax, aVelocitySens; "Velocity Sens"
00007FF91DFEFE0A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFE0E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFE12  48 8D 87 40 C1 00 00        lea     rax, [rdi+0C140h]
00007FF91DFEFE19  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFE20  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFE24  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFE28  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFE2D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFE34  E8 C7 BB 01 00              call    sub_7FF91E00BA00
00007FF91DFEFE39  66 0F 6F 05 EF C1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFE41  48 8D 05 70 B5 5F 00        lea     rax, aVelocityOffset; "Velocity Offset"
00007FF91DFEFE48  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFE4C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFE50  48 8D 87 50 C1 00 00        lea     rax, [rdi+0C150h]
00007FF91DFEFE57  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFE5E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFE62  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFE66  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFE6B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFE72  E8 89 BB 01 00              call    sub_7FF91E00BA00
00007FF91DFEFE77  66 0F 6F 05 B1 C1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFE7F  48 8D 05 DA B3 5F 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFEFE86  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFE8A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFE8E  48 8D 87 60 C1 00 00        lea     rax, [rdi+0C160h]
00007FF91DFEFE95  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFE9C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFEA0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFEA5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFEAC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFEB0  E8 4B BB 01 00              call    sub_7FF91E00BA00
00007FF91DFEFEB5  66 0F 6F 05 73 C1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFEBD  48 8D 05 AC B3 5F 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFEFEC4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFEC8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFECC  48 8D 87 70 C1 00 00        lea     rax, [rdi+0C170h]
00007FF91DFEFED3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFEDA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFEDE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFEE2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFEE7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFEEE  E8 0D BB 01 00              call    sub_7FF91E00BA00
00007FF91DFEFEF3  66 0F 6F 05 35 C1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFEFB  48 8D 05 C6 B4 5F 00        lea     rax, aCutoffTune; "Cutoff Tune"
00007FF91DFEFF02  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFF06  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFF0A  48 8D 87 F0 C1 00 00        lea     rax, [rdi+0C1F0h]
00007FF91DFEFF11  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFF18  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFF1C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFF20  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFF25  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFF2C  E8 CF BA 01 00              call    sub_7FF91E00BA00
00007FF91DFEFF31  66 0F 6F 05 F7 C0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFF39  48 8D 05 98 B4 5F 00        lea     rax, aResonanceTune; "Resonance Tune"
00007FF91DFEFF40  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFF44  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFF48  48 8D 87 00 C2 00 00        lea     rax, [rdi+0C200h]
00007FF91DFEFF4F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFEFF56  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFF5A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFF5E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFF63  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFF6A  E8 91 BA 01 00              call    sub_7FF91E00BA00
00007FF91DFEFF6F  48 8D 05 72 B4 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFEFF76  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFEFF7D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFF81  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFF85  48 8D 87 10 C2 00 00        lea     rax, [rdi+0C210h]
00007FF91DFEFF8C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFF93  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEFF96  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFF9A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFF9E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFFA3  E8 58 BA 01 00              call    sub_7FF91E00BA00
00007FF91DFEFFA8  48 8D 05 39 B4 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFEFFAF  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFEFFB6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFFBA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFFBE  48 8D 87 A0 C7 00 00        lea     rax, [rdi+0C7A0h]
00007FF91DFEFFC5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFEFFCC  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFEFFCF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFEFFD3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFEFFD7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFEFFDC  E8 1F BA 01 00              call    sub_7FF91E00BA00
00007FF91DFEFFE1  66 0F 6F 05 47 C0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFEFFE9  48 8D 05 08 B4 5F 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
00007FF91DFEFFF0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFEFFF4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFEFFF8  48 8D 87 B0 C7 00 00        lea     rax, [rdi+0C7B0h]
00007FF91DFEFFFF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0006  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF000A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF000E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0013  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF001A  E8 E1 B9 01 00              call    sub_7FF91E00BA00
00007FF91DFF001F  66 0F 6F 05 09 C0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0027  48 8D 05 DA B3 5F 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
00007FF91DFF002E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0032  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0036  48 8D 87 C0 C7 00 00        lea     rax, [rdi+0C7C0h]
00007FF91DFF003D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0044  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0048  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF004C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0051  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0058  E8 A3 B9 01 00              call    sub_7FF91E00BA00
00007FF91DFF005D  48 8D 05 B4 B3 5F 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
00007FF91DFF0064  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0068  66 0F 6F 05 C0 BF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0070  48 8D 87 D0 C7 00 00        lea     rax, [rdi+0C7D0h]
00007FF91DFF0077  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF007B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF007F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0083  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF008A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF008F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0096  E8 65 B9 01 00              call    sub_7FF91E00BA00
00007FF91DFF009B  66 0F 6F 05 8D BF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF00A3  48 8D 05 7E B3 5F 00        lea     rax, aAmpTone; "AMP TONE"
00007FF91DFF00AA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF00AE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF00B2  48 8D 87 B0 C9 00 00        lea     rax, [rdi+0C9B0h]
00007FF91DFF00B9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF00C0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF00C4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF00C8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF00CD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF00D4  E8 27 B9 01 00              call    sub_7FF91E00BA00
00007FF91DFF00D9  66 0F 6F 05 4F BF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF00E1  48 8D 05 50 B3 5F 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
00007FF91DFF00E8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF00EC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF00F0  48 8D 87 C0 C9 00 00        lea     rax, [rdi+0C9C0h]
00007FF91DFF00F7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF00FE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0102  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0106  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF010B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0112  E8 E9 B8 01 00              call    sub_7FF91E00BA00
00007FF91DFF0117  66 0F 6F 05 11 BF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF011F  48 8D 05 2A B3 5F 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
00007FF91DFF0126  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF012A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF012E  48 8D 87 D0 C9 00 00        lea     rax, [rdi+0C9D0h]
00007FF91DFF0135  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF013C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0140  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0144  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0149  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0150  E8 AB B8 01 00              call    sub_7FF91E00BA00
00007FF91DFF0155  48 8D 05 D4 B1 5F 00        lea     rax, aVelocity; "Velocity"
00007FF91DFF015C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0163  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0167  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF016B  48 8D 87 10 CA 00 00        lea     rax, [rdi+0CA10h]
00007FF91DFF0172  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0179  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF017C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0180  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0184  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0189  E8 72 B8 01 00              call    sub_7FF91E00BA00
00007FF91DFF018E  48 8D 05 D3 B2 5F 00        lea     rax, aMute; "Mute"
00007FF91DFF0195  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF019C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF01A0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF01A4  48 8D 87 A0 CA 00 00        lea     rax, [rdi+0CAA0h]
00007FF91DFF01AB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF01B2  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF01B5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF01B9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF01BD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF01C2  E8 39 B8 01 00              call    sub_7FF91E00BA00
00007FF91DFF01C7  48 8D 05 A2 B2 5F 00        lea     rax, aGateSw; "Gate SW"
00007FF91DFF01CE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF01D5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF01D9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF01DD  48 8D 87 00 CC 00 00        lea     rax, [rdi+0CC00h]
00007FF91DFF01E4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF01EB  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF01EE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF01F2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF01F6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF01FB  E8 00 B8 01 00              call    sub_7FF91E00BA00
00007FF91DFF0200  48 8D 05 71 B2 5F 00        lea     rax, aEnv1Sw; "ENV1 SW"
00007FF91DFF0207  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF020E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0211  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0215  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF021A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0221  48 8D 87 10 CC 00 00        lea     rax, [rdi+0CC10h]
00007FF91DFF0228  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF022C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0230  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0234  E8 C7 B7 01 00              call    sub_7FF91E00BA00
00007FF91DFF0239  48 8D 05 40 B2 5F 00        lea     rax, aEnv2Sw; "ENV2 SW"
00007FF91DFF0240  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0247  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF024B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF024F  48 8D 87 20 CC 00 00        lea     rax, [rdi+0CC20h]
00007FF91DFF0256  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF025D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0260  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0264  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0268  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF026D  E8 8E B7 01 00              call    sub_7FF91E00BA00
00007FF91DFF0272  48 8D 05 0F B2 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
00007FF91DFF0279  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0280  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0284  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0288  48 8D 87 30 CC 00 00        lea     rax, [rdi+0CC30h]
00007FF91DFF028F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0296  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0299  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF029D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF02A1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF02A6  E8 55 B7 01 00              call    sub_7FF91E00BA00
00007FF91DFF02AB  66 0F 6F 05 7D BD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF02B3  48 8D 05 DE B1 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
00007FF91DFF02BA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF02BE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF02C2  48 8D 87 40 CC 00 00        lea     rax, [rdi+0CC40h]
00007FF91DFF02C9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF02D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF02D4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF02D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF02DD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF02E4  E8 17 B7 01 00              call    sub_7FF91E00BA00
00007FF91DFF02E9  66 0F 6F 05 3F BD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF02F1  48 8D 05 B0 B1 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
00007FF91DFF02F8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF02FC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0300  48 8D 87 50 CC 00 00        lea     rax, [rdi+0CC50h]
00007FF91DFF0307  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF030E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0312  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0316  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF031B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0322  E8 D9 B6 01 00              call    sub_7FF91E00BA00
00007FF91DFF0327  66 0F 6F 05 01 BD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF032F  48 8D 05 82 B1 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
00007FF91DFF0336  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF033A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF033E  48 8D 87 60 CC 00 00        lea     rax, [rdi+0CC60h]
00007FF91DFF0345  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF034C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0350  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0354  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0359  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0360  E8 9B B6 01 00              call    sub_7FF91E00BA00
00007FF91DFF0365  66 0F 6F 05 C3 BC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF036D  48 8D 05 54 B1 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
00007FF91DFF0374  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0378  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF037C  48 8D 87 70 CC 00 00        lea     rax, [rdi+0CC70h]
00007FF91DFF0383  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF038A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF038E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0392  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0397  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF039E  E8 5D B6 01 00              call    sub_7FF91E00BA00
00007FF91DFF03A3  66 0F 6F 05 85 BC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF03AB  48 8D 05 2E B1 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
00007FF91DFF03B2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF03B6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF03BA  48 8D 87 80 CC 00 00        lea     rax, [rdi+0CC80h]
00007FF91DFF03C1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF03C8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF03CC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF03D0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF03D5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF03DC  E8 1F B6 01 00              call    sub_7FF91E00BA00
00007FF91DFF03E1  66 0F 6F 05 47 BC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF03E9  48 8D 05 00 B1 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
00007FF91DFF03F0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF03F4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF03F8  48 8D 87 90 CC 00 00        lea     rax, [rdi+0CC90h]
00007FF91DFF03FF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0406  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF040A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF040E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0413  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF041A  E8 E1 B5 01 00              call    sub_7FF91E00BA00
00007FF91DFF041F  48 8D 05 FA AA 5F 00        lea     rax, aUseextjack; "UseExtJack"
00007FF91DFF0426  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF042D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0431  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0435  48 8D 87 60 CE 00 00        lea     rax, [rdi+0CE60h]
00007FF91DFF043C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0443  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0446  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF044A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF044E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0453  E8 A8 B5 01 00              call    sub_7FF91E00BA00
00007FF91DFF0458  48 8D 05 CD AA 5F 00        lea     rax, aMCv; "M.CV"
00007FF91DFF045F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0466  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF046A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF046E  48 8D 87 80 CE 00 00        lea     rax, [rdi+0CE80h]
00007FF91DFF0475  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF047C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF047F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0483  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0487  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF048C  E8 6F B5 01 00              call    sub_7FF91E00BA00
00007FF91DFF0491  48 8D 05 9C AA 5F 00        lea     rax, aMGate; "M.Gate"
00007FF91DFF0498  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF049F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF04A3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF04A7  48 8D 87 90 CE 00 00        lea     rax, [rdi+0CE90h]
00007FF91DFF04AE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF04B5  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF04B8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF04BC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF04C0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF04C5  E8 36 B5 01 00              call    sub_7FF91E00BA00
00007FF91DFF04CA  66 0F 6F 05 5E BB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF04D2  48 8D 05 67 AA 5F 00        lea     rax, aMasterTune; "Master Tune"
00007FF91DFF04D9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF04DD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF04E1  48 8D 87 C0 CE 00 00        lea     rax, [rdi+0CEC0h]
00007FF91DFF04E8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF04EF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF04F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF04F7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF04FC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0503  E8 F8 B4 01 00              call    sub_7FF91E00BA00
00007FF91DFF0508  66 0F 6F 05 20 BB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0510  48 8D 05 39 AA 5F 00        lea     rax, aPartTune; "Part Tune"
00007FF91DFF0517  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF051B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF051F  48 8D 87 D0 CE 00 00        lea     rax, [rdi+0CED0h]
00007FF91DFF0526  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF052D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0531  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0535  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF053A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0541  E8 BA B4 01 00              call    sub_7FF91E00BA00
00007FF91DFF0546  48 8D 05 13 AA 5F 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
00007FF91DFF054D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0554  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0558  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF055C  48 8D 87 A0 CF 00 00        lea     rax, [rdi+0CFA0h]
00007FF91DFF0563  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF056A  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF056D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0571  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0575  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF057A  E8 81 B4 01 00              call    sub_7FF91E00BA00
00007FF91DFF057F  48 8D 05 F2 A9 5F 00        lea     rax, aPortamentoMode; "Portamento Mode"
00007FF91DFF0586  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF058D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0591  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0594  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF059B  48 8D 87 B0 CF 00 00        lea     rax, [rdi+0CFB0h]
00007FF91DFF05A2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF05A6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF05AA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF05AE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF05B3  E8 48 B4 01 00              call    sub_7FF91E00BA00
00007FF91DFF05B8  66 0F 6F 05 70 BA 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF05C0  48 8D 05 C1 A9 5F 00        lea     rax, aPortamentoTime; "Portamento Time"
00007FF91DFF05C7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF05CB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF05CF  48 8D 87 C0 CF 00 00        lea     rax, [rdi+0CFC0h]
00007FF91DFF05D6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF05DD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF05E1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF05E5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF05EA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF05F1  E8 0A B4 01 00              call    sub_7FF91E00BA00
00007FF91DFF05F6  48 8D 05 9B A9 5F 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
00007FF91DFF05FD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0604  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0608  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF060C  48 8D 87 60 D1 00 00        lea     rax, [rdi+0D160h]
00007FF91DFF0613  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF061A  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF061D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0621  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0625  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF062A  E8 D1 B3 01 00              call    sub_7FF91E00BA00
00007FF91DFF062F  48 8D 05 7A A9 5F 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
00007FF91DFF0636  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF063D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0641  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0645  48 8D 87 70 D1 00 00        lea     rax, [rdi+0D170h]
00007FF91DFF064C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0653  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0656  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF065A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF065E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0663  E8 98 B3 01 00              call    sub_7FF91E00BA00
00007FF91DFF0668  48 8D 05 59 A9 5F 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
00007FF91DFF066F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0676  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF067A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF067E  48 8D 87 80 D1 00 00        lea     rax, [rdi+0D180h]
00007FF91DFF0685  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF068C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF068F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0693  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0697  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF069C  E8 5F B3 01 00              call    sub_7FF91E00BA00
00007FF91DFF06A1  66 0F 6F 05 87 B9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF06A9  48 8D 05 28 A9 5F 00        lea     rax, aLfoRate; "LFO Rate"
00007FF91DFF06B0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF06B4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF06B8  48 8D 87 90 D1 00 00        lea     rax, [rdi+0D190h]
00007FF91DFF06BF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF06C6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF06CA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF06CE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF06D3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF06DA  E8 21 B3 01 00              call    sub_7FF91E00BA00
00007FF91DFF06DF  48 8D 05 FE A8 5F 00        lea     rax, aGate; "Gate"
00007FF91DFF06E6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF06ED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF06F1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF06F5  48 8D 87 90 D4 00 00        lea     rax, [rdi+0D490h]
00007FF91DFF06FC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0703  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0706  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF070A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF070E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0713  E8 E8 B2 01 00              call    sub_7FF91E00BA00
00007FF91DFF0718  48 8D 05 D1 A8 5F 00        lea     rax, aLfoTrig; "LFO Trig"
00007FF91DFF071F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0726  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0729  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF072D  48 8D 87 A0 D4 00 00        lea     rax, [rdi+0D4A0h]
00007FF91DFF0734  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF073B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0740  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0744  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0748  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF074C  E8 AF B2 01 00              call    sub_7FF91E00BA00
00007FF91DFF0751  48 8D 05 A8 A8 5F 00        lea     rax, aResetSw; "Reset Sw"
00007FF91DFF0758  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF075F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0763  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0767  48 8D 87 B0 D4 00 00        lea     rax, [rdi+0D4B0h]
00007FF91DFF076E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0775  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0778  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF077C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0780  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0785  E8 76 B2 01 00              call    sub_7FF91E00BA00
00007FF91DFF078A  66 0F 6F 05 9E B8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0792  48 8D 05 77 A8 5F 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
00007FF91DFF0799  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF079D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF07A1  48 8D 87 C0 D4 00 00        lea     rax, [rdi+0D4C0h]
00007FF91DFF07A8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF07AF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF07B3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF07B7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF07BC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF07C3  E8 38 B2 01 00              call    sub_7FF91E00BA00
00007FF91DFF07C8  66 0F 6F 05 60 B8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF07D0  48 8D 05 49 A8 5F 00        lea     rax, aLfoDelay; "LFO Delay"
00007FF91DFF07D7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF07DB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF07DF  48 8D 87 D0 D4 00 00        lea     rax, [rdi+0D4D0h]
00007FF91DFF07E6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF07ED  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF07F1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF07F5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF07FA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0801  E8 FA B1 01 00              call    sub_7FF91E00BA00
00007FF91DFF0806  66 0F 6F 05 22 B8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF080E  48 8D 05 1B A8 5F 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
00007FF91DFF0815  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0819  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF081D  48 8D 87 E0 D4 00 00        lea     rax, [rdi+0D4E0h]
00007FF91DFF0824  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF082B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF082F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0833  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0838  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF083F  E8 BC B1 01 00              call    sub_7FF91E00BA00
00007FF91DFF0844  66 0F 6F 05 E4 B7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF084C  48 8D 05 ED A7 5F 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
00007FF91DFF0853  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0857  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF085B  48 8D 87 F0 D4 00 00        lea     rax, [rdi+0D4F0h]
00007FF91DFF0862  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0869  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF086D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0871  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0876  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF087D  E8 7E B1 01 00              call    sub_7FF91E00BA00
00007FF91DFF0882  66 0F 6F 05 A6 B7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF088A  48 8D 05 BF A7 5F 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
00007FF91DFF0891  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0895  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0899  48 8D 87 00 D5 00 00        lea     rax, [rdi+0D500h]
00007FF91DFF08A0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF08A7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF08AB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF08AF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF08B4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF08BB  E8 40 B1 01 00              call    sub_7FF91E00BA00
00007FF91DFF08C0  66 0F 6F 05 68 B7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF08C8  48 8D 05 91 A7 5F 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
00007FF91DFF08CF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF08D3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF08D7  48 8D 87 10 D5 00 00        lea     rax, [rdi+0D510h]
00007FF91DFF08DE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF08E5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF08E9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF08ED  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF08F2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF08F9  E8 02 B1 01 00              call    sub_7FF91E00BA00
00007FF91DFF08FE  66 0F 6F 05 2A B7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0906  48 8D 05 63 A7 5F 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
00007FF91DFF090D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0911  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0915  48 8D 87 20 D5 00 00        lea     rax, [rdi+0D520h]
00007FF91DFF091C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0923  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0927  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF092B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0930  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0937  E8 C4 B0 01 00              call    sub_7FF91E00BA00
00007FF91DFF093C  66 0F 6F 05 EC B6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0944  48 8D 05 35 A7 5F 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
00007FF91DFF094B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF094F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0953  48 8D 87 30 D5 00 00        lea     rax, [rdi+0D530h]
00007FF91DFF095A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0961  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0965  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0969  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF096E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0975  E8 86 B0 01 00              call    sub_7FF91E00BA00
00007FF91DFF097A  66 0F 6F 05 AE B6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0982  48 8D 05 07 A7 5F 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
00007FF91DFF0989  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF098D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0991  48 8D 87 40 D5 00 00        lea     rax, [rdi+0D540h]
00007FF91DFF0998  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF099F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF09A3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF09A7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF09AC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF09B3  E8 48 B0 01 00              call    sub_7FF91E00BA00
00007FF91DFF09B8  66 0F 6F 05 70 B6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF09C0  48 8D 05 D9 A6 5F 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
00007FF91DFF09C7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF09CB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF09CF  48 8D 87 50 D5 00 00        lea     rax, [rdi+0D550h]
00007FF91DFF09D6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF09DD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF09E1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF09E5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF09EA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF09F1  E8 0A B0 01 00              call    sub_7FF91E00BA00
00007FF91DFF09F6  66 0F 6F 05 32 B6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF09FE  48 8D 05 AB A6 5F 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
00007FF91DFF0A05  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0A09  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0A0D  48 8D 87 60 D5 00 00        lea     rax, [rdi+0D560h]
00007FF91DFF0A14  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0A1B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0A1F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0A23  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0A28  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0A2F  E8 CC AF 01 00              call    sub_7FF91E00BA00
00007FF91DFF0A34  66 0F 6F 05 F4 B5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0A3C  48 8D 05 7D A6 5F 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
00007FF91DFF0A43  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0A47  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0A4B  48 8D 87 70 D5 00 00        lea     rax, [rdi+0D570h]
00007FF91DFF0A52  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0A59  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0A5D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0A61  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0A66  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0A6D  E8 8E AF 01 00              call    sub_7FF91E00BA00
00007FF91DFF0A72  66 0F 6F 05 B6 B5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0A7A  48 8D 05 4F A6 5F 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
00007FF91DFF0A81  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0A85  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0A89  48 8D 87 80 D5 00 00        lea     rax, [rdi+0D580h]
00007FF91DFF0A90  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0A97  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0A9B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0A9F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0AA4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0AAB  E8 50 AF 01 00              call    sub_7FF91E00BA00
00007FF91DFF0AB0  66 0F 6F 05 78 B5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0AB8  48 8D 05 29 A6 5F 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
00007FF91DFF0ABF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0AC3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0ACA  48 8D 87 90 D5 00 00        lea     rax, [rdi+0D590h]
00007FF91DFF0AD1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0AD8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0ADC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0AE0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0AE4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0AE9  E8 12 AF 01 00              call    sub_7FF91E00BA00
00007FF91DFF0AEE  48 8D 05 0B A6 5F 00        lea     rax, aReadOnly; "read only"
00007FF91DFF0AF5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0AFC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0B00  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0B04  48 8D 87 30 D7 00 00        lea     rax, [rdi+0D730h]
00007FF91DFF0B0B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0B12  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0B15  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0B19  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0B1D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0B22  E8 D9 AE 01 00              call    sub_7FF91E00BA00
00007FF91DFF0B27  48 8D 05 D2 A5 5F 00        lea     rax, aReadOnly; "read only"
00007FF91DFF0B2E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0B35  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0B39  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0B3D  48 8D 87 40 D7 00 00        lea     rax, [rdi+0D740h]
00007FF91DFF0B44  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0B4B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0B4E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0B52  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0B56  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0B5B  E8 A0 AE 01 00              call    sub_7FF91E00BA00
00007FF91DFF0B60  48 8D 05 A9 A5 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFF0B67  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0B6E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0B72  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0B76  48 8D 87 50 D7 00 00        lea     rax, [rdi+0D750h]
00007FF91DFF0B7D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0B84  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0B87  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0B8B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0B8F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0B94  E8 67 AE 01 00              call    sub_7FF91E00BA00
00007FF91DFF0B99  66 0F 6F 05 8F B4 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0BA1  48 8D 05 80 A5 5F 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFF0BA8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0BAC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0BB0  48 8D 87 30 D8 00 00        lea     rax, [rdi+0D830h]
00007FF91DFF0BB7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0BBE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0BC2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0BC6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0BCB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0BD2  E8 29 AE 01 00              call    sub_7FF91E00BA00
00007FF91DFF0BD7  66 0F 6F 05 51 B4 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0BDF  48 8D 05 52 A5 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFF0BE6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0BEA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0BEE  48 8D 87 40 D8 00 00        lea     rax, [rdi+0D840h]
00007FF91DFF0BF5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0BFC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0C00  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0C04  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0C09  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0C10  E8 EB AD 01 00              call    sub_7FF91E00BA00
00007FF91DFF0C15  66 0F 6F 05 13 B4 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0C1D  48 8D 05 24 A5 5F 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFF0C24  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0C28  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0C2C  48 8D 87 50 D8 00 00        lea     rax, [rdi+0D850h]
00007FF91DFF0C33  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0C3A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0C3E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0C42  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0C47  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0C4E  E8 AD AD 01 00              call    sub_7FF91E00BA00
00007FF91DFF0C53  66 0F 6F 05 D5 B3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0C5B  48 8D 05 F6 A4 5F 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFF0C62  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0C66  48 8D 87 60 D8 00 00        lea     rax, [rdi+0D860h]
00007FF91DFF0C6D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0C71  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0C78  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0C7D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0C84  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0C88  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0C8C  E8 6F AD 01 00              call    sub_7FF91E00BA00
00007FF91DFF0C91  66 0F 6F 05 97 B3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0C99  48 8D 05 C8 A4 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFF0CA0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0CA4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0CA8  48 8D 87 70 D8 00 00        lea     rax, [rdi+0D870h]
00007FF91DFF0CAF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0CB6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0CBA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0CBE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0CC3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0CCA  E8 31 AD 01 00              call    sub_7FF91E00BA00
00007FF91DFF0CCF  48 8D 05 3A A4 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFF0CD6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0CDD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0CE1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0CE5  48 8D 87 30 D9 00 00        lea     rax, [rdi+0D930h]
00007FF91DFF0CEC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0CF3  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0CF6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0CFA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0CFE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0D03  E8 F8 AC 01 00              call    sub_7FF91E00BA00
00007FF91DFF0D08  66 0F 6F 05 20 B3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0D10  48 8D 05 11 A4 5F 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFF0D17  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0D1B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0D1F  48 8D 87 10 DA 00 00        lea     rax, [rdi+0DA10h]
00007FF91DFF0D26  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0D2D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0D31  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0D35  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0D3A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0D41  E8 BA AC 01 00              call    sub_7FF91E00BA00
00007FF91DFF0D46  66 0F 6F 05 E2 B2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0D4E  48 8D 05 E3 A3 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFF0D55  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0D59  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0D5D  48 8D 87 20 DA 00 00        lea     rax, [rdi+0DA20h]
00007FF91DFF0D64  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0D6B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0D6F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0D73  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0D78  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0D7F  E8 7C AC 01 00              call    sub_7FF91E00BA00
00007FF91DFF0D84  66 0F 6F 05 A4 B2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0D8C  48 8D 05 B5 A3 5F 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFF0D93  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0D97  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0D9B  48 8D 87 30 DA 00 00        lea     rax, [rdi+0DA30h]
00007FF91DFF0DA2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0DA9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0DAD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0DB1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0DB6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0DBD  E8 3E AC 01 00              call    sub_7FF91E00BA00
00007FF91DFF0DC2  66 0F 6F 05 66 B2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0DCA  48 8D 05 87 A3 5F 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFF0DD1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0DD5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0DD9  48 8D 87 40 DA 00 00        lea     rax, [rdi+0DA40h]
00007FF91DFF0DE0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0DE7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0DEB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0DEF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0DF4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0DFB  E8 00 AC 01 00              call    sub_7FF91E00BA00
00007FF91DFF0E00  66 0F 6F 05 28 B2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0E08  48 8D 05 59 A3 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFF0E0F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0E13  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0E17  48 8D 87 50 DA 00 00        lea     rax, [rdi+0DA50h]
00007FF91DFF0E1E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0E25  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0E29  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0E2D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0E32  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0E39  E8 C2 AB 01 00              call    sub_7FF91E00BA00
00007FF91DFF0E3E  48 8D 05 33 A3 5F 00        lea     rax, aOsc1Feet; "OSC1 Feet"
00007FF91DFF0E45  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0E49  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0E4D  48 8D 87 50 DC 00 00        lea     rax, [rdi+0DC50h]
00007FF91DFF0E54  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0E5B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0E5E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0E62  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0E66  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0E6D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0E72  E8 89 AB 01 00              call    sub_7FF91E00BA00
00007FF91DFF0E77  48 8D 05 0A A3 5F 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
00007FF91DFF0E7E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0E85  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0E89  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0E8D  48 8D 87 60 DC 00 00        lea     rax, [rdi+0DC60h]
00007FF91DFF0E94  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0E9B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0E9E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0EA2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0EA6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0EAB  E8 50 AB 01 00              call    sub_7FF91E00BA00
00007FF91DFF0EB0  48 8D 05 E1 A2 5F 00        lea     rax, aBendEnableSw; "Bend Enable SW"
00007FF91DFF0EB7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0EBE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0EC2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0EC6  48 8D 87 70 DC 00 00        lea     rax, [rdi+0DC70h]
00007FF91DFF0ECD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0ED4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0ED7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0EDB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0EDF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0EE4  E8 17 AB 01 00              call    sub_7FF91E00BA00
00007FF91DFF0EE9  48 8D 05 B8 A2 5F 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
00007FF91DFF0EF0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0EF7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0EFB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0EFF  48 8D 87 80 DC 00 00        lea     rax, [rdi+0DC80h]
00007FF91DFF0F06  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0F0D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0F10  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0F14  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0F18  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0F1D  E8 DE AA 01 00              call    sub_7FF91E00BA00
00007FF91DFF0F22  48 8D 05 8F A2 5F 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
00007FF91DFF0F29  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0F30  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0F34  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0F38  48 8D 87 90 DC 00 00        lea     rax, [rdi+0DC90h]
00007FF91DFF0F3F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0F46  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0F49  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0F4D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0F51  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0F56  E8 A5 AA 01 00              call    sub_7FF91E00BA00
00007FF91DFF0F5B  48 8D 05 66 A2 5F 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
00007FF91DFF0F62  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0F69  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0F6D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0F71  48 8D 87 A0 DC 00 00        lea     rax, [rdi+0DCA0h]
00007FF91DFF0F78  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0F7F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0F82  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0F86  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0F8A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0F8F  E8 6C AA 01 00              call    sub_7FF91E00BA00
00007FF91DFF0F94  48 8D 05 3D A2 5F 00        lea     rax, aPwmSwManual; "PWM SW Manual"
00007FF91DFF0F9B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0FA2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0FA6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0FAA  48 8D 87 B0 DC 00 00        lea     rax, [rdi+0DCB0h]
00007FF91DFF0FB1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0FB8  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF0FBB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF0FBF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF0FC3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0FC8  E8 33 AA 01 00              call    sub_7FF91E00BA00
00007FF91DFF0FCD  66 0F 6F 05 5B B0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF0FD5  48 8D 05 0C A2 5F 00        lea     rax, aTune; "Tune"
00007FF91DFF0FDC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF0FE0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF0FE5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF0FEC  48 8D 87 C0 DC 00 00        lea     rax, [rdi+0DCC0h]
00007FF91DFF0FF3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF0FFA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF0FFE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1002  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1006  E8 F5 A9 01 00              call    sub_7FF91E00BA00
00007FF91DFF100B  66 0F 6F 05 1D B0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1013  48 8D 05 D6 A1 5F 00        lea     rax, aDetune; "Detune"
00007FF91DFF101A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF101E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1022  48 8D 87 D0 DC 00 00        lea     rax, [rdi+0DCD0h]
00007FF91DFF1029  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1030  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1034  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1038  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF103D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1044  E8 B7 A9 01 00              call    sub_7FF91E00BA00
00007FF91DFF1049  66 0F 6F 05 DF AF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1051  48 8D 05 A0 A1 5F 00        lea     rax, aModSens; "Mod Sens"
00007FF91DFF1058  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF105C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1060  48 8D 87 E0 DC 00 00        lea     rax, [rdi+0DCE0h]
00007FF91DFF1067  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF106E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1072  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1076  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF107B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1082  E8 79 A9 01 00              call    sub_7FF91E00BA00
00007FF91DFF1087  66 0F 6F 05 A1 AF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF108F  48 8D 05 6E A1 5F 00        lea     rax, aModSw; "Mod Sw"
00007FF91DFF1096  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF109A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF109E  48 8D 87 F0 DC 00 00        lea     rax, [rdi+0DCF0h]
00007FF91DFF10A5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF10AC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF10B0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF10B4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF10B9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF10C0  E8 3B A9 01 00              call    sub_7FF91E00BA00
00007FF91DFF10C5  66 0F 6F 05 63 AF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF10CD  48 8D 05 3C A1 5F 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFF10D4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF10D8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF10DC  48 8D 87 00 DD 00 00        lea     rax, [rdi+0DD00h]
00007FF91DFF10E3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF10EA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF10EE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF10F2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF10F7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF10FE  E8 FD A8 01 00              call    sub_7FF91E00BA00
00007FF91DFF1103  66 0F 6F 05 25 AF 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF110B  48 8D 05 0E A1 5F 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFF1112  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1116  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF111A  48 8D 87 10 DD 00 00        lea     rax, [rdi+0DD10h]
00007FF91DFF1121  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1128  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF112C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1130  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1135  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF113C  E8 BF A8 01 00              call    sub_7FF91E00BA00
00007FF91DFF1141  66 0F 6F 05 E7 AE 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1149  48 8D 05 DC A0 5F 00        lea     rax, aLfoSw; "LFO Sw"
00007FF91DFF1150  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1154  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1158  48 8D 87 20 DD 00 00        lea     rax, [rdi+0DD20h]
00007FF91DFF115F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1166  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF116A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF116E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1173  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF117A  E8 81 A8 01 00              call    sub_7FF91E00BA00
00007FF91DFF117F  66 0F 6F 05 A9 AE 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1187  48 8D 05 AA A0 5F 00        lea     rax, aEnv1Level; "ENV1 Level"
00007FF91DFF118E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1192  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1196  48 8D 87 30 DD 00 00        lea     rax, [rdi+0DD30h]
00007FF91DFF119D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF11A4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF11A8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF11AD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF11B4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF11B8  E8 43 A8 01 00              call    sub_7FF91E00BA00
00007FF91DFF11BD  66 0F 6F 05 6B AE 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF11C5  48 8D 05 7C A0 5F 00        lea     rax, aEnv2Level; "ENV2 Level"
00007FF91DFF11CC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF11D0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF11D4  48 8D 87 40 DD 00 00        lea     rax, [rdi+0DD40h]
00007FF91DFF11DB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF11E2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF11E6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF11EA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF11EF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF11F6  E8 05 A8 01 00              call    sub_7FF91E00BA00
00007FF91DFF11FB  66 0F 6F 05 2D AE 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1203  48 8D 05 4A A0 5F 00        lea     rax, aEnvSw; "ENV Sw"
00007FF91DFF120A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF120E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1212  48 8D 87 50 DD 00 00        lea     rax, [rdi+0DD50h]
00007FF91DFF1219  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1220  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1224  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1228  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF122D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1234  E8 C7 A7 01 00              call    sub_7FF91E00BA00
00007FF91DFF1239  66 0F 6F 05 EF AD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1241  48 8D 05 18 A0 5F 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFF1248  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF124C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1250  48 8D 87 60 DD 00 00        lea     rax, [rdi+0DD60h]
00007FF91DFF1257  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF125E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1262  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1266  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF126B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1272  E8 89 A7 01 00              call    sub_7FF91E00BA00
00007FF91DFF1277  66 0F 6F 05 B1 AD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF127F  48 8D 05 EA 9F 5F 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFF1286  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF128A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF128E  48 8D 87 70 DD 00 00        lea     rax, [rdi+0DD70h]
00007FF91DFF1295  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF129C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF12A0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF12A4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF12A9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF12B0  E8 4B A7 01 00              call    sub_7FF91E00BA00
00007FF91DFF12B5  66 0F 6F 05 73 AD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF12BD  48 8D 05 BC 9F 5F 00        lea     rax, aPwmLevel; "PWM Level"
00007FF91DFF12C4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF12C8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF12CC  48 8D 87 80 DD 00 00        lea     rax, [rdi+0DD80h]
00007FF91DFF12D3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF12DA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF12DE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF12E2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF12E7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF12EE  E8 0D A7 01 00              call    sub_7FF91E00BA00
00007FF91DFF12F3  66 0F 6F 05 35 AD 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF12FB  48 8D 05 8E 9F 5F 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
00007FF91DFF1302  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1306  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF130A  48 8D 87 B0 DD 00 00        lea     rax, [rdi+0DDB0h]
00007FF91DFF1311  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1318  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF131C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1320  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1325  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF132C  E8 CF A6 01 00              call    sub_7FF91E00BA00
00007FF91DFF1331  66 0F 6F 05 F7 AC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1339  48 8D 05 60 9F 5F 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
00007FF91DFF1340  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1344  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1348  48 8D 87 C0 DD 00 00        lea     rax, [rdi+0DDC0h]
00007FF91DFF134F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1356  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF135A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF135E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1363  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF136A  E8 91 A6 01 00              call    sub_7FF91E00BA00
00007FF91DFF136F  48 8D 05 3A 9F 5F 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
00007FF91DFF1376  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF137A  66 0F 6F 05 AE AC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1382  48 8D 87 D0 DD 00 00        lea     rax, [rdi+0DDD0h]
00007FF91DFF1389  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF138D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1391  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1395  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF139C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF13A1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF13A8  E8 53 A6 01 00              call    sub_7FF91E00BA00
00007FF91DFF13AD  66 0F 6F 05 7B AC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF13B5  48 8D 05 04 9F 5F 00        lea     rax, aDutyTune; "Duty Tune"
00007FF91DFF13BC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF13C0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF13C4  48 8D 87 E0 E2 00 00        lea     rax, [rdi+0E2E0h]
00007FF91DFF13CB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF13D2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF13D6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF13DA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF13DF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF13E6  E8 15 A6 01 00              call    sub_7FF91E00BA00
00007FF91DFF13EB  66 0F 6F 05 3D AC 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF13F3  48 8D 05 D6 9E 5F 00        lea     rax, aOsc1Mute; "Osc1 Mute"
00007FF91DFF13FA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF13FE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1402  48 8D 87 80 E6 00 00        lea     rax, [rdi+0E680h]
00007FF91DFF1409  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1410  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1414  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1418  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF141D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1424  E8 D7 A5 01 00              call    sub_7FF91E00BA00
00007FF91DFF1429  66 0F 6F 05 FF AB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1431  48 8D 05 A8 9E 5F 00        lea     rax, aOsc1Level; "Osc1 Level"
00007FF91DFF1438  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF143C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1440  48 8D 87 C0 E6 00 00        lea     rax, [rdi+0E6C0h]
00007FF91DFF1447  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF144E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1452  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1456  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF145B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1462  E8 99 A5 01 00              call    sub_7FF91E00BA00
00007FF91DFF1467  66 0F 6F 05 C1 AB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF146F  48 8D 05 7A 9E 5F 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
00007FF91DFF1476  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF147A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF147E  48 8D 87 D0 E6 00 00        lea     rax, [rdi+0E6D0h]
00007FF91DFF1485  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF148C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1490  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1494  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1499  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF14A0  E8 5B A5 01 00              call    sub_7FF91E00BA00
00007FF91DFF14A5  48 8D 05 54 9E 5F 00        lea     rax, aGrifferSw; "Griffer SW"
00007FF91DFF14AC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF14B3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF14B7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF14BB  48 8D 87 90 E7 00 00        lea     rax, [rdi+0E790h]
00007FF91DFF14C2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF14C9  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF14CC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF14D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF14D4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF14D9  E8 22 A5 01 00              call    sub_7FF91E00BA00
00007FF91DFF14DE  66 0F 6F 05 4A AB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF14E6  48 8D 05 23 9E 5F 00        lea     rax, aLpfCutoff; "LPF Cutoff"
00007FF91DFF14ED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF14F1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF14F5  48 8D 87 A0 E7 00 00        lea     rax, [rdi+0E7A0h]
00007FF91DFF14FC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1503  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1507  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF150B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1510  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1517  E8 E4 A4 01 00              call    sub_7FF91E00BA00
00007FF91DFF151C  66 0F 6F 05 0C AB 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1524  48 8D 05 F5 9D 5F 00        lea     rax, aLpfResonance; "LPF Resonance"
00007FF91DFF152B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF152F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1534  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF153B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1542  48 8D 87 00 E8 00 00        lea     rax, [rdi+0E800h]
00007FF91DFF1549  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF154D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1551  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1555  E8 A6 A4 01 00              call    sub_7FF91E00BA00
00007FF91DFF155A  48 8D 05 CF 9D 5F 00        lea     rax, aVelocity; "Velocity"
00007FF91DFF1561  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1568  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF156C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1570  48 8D 87 20 E8 00 00        lea     rax, [rdi+0E820h]
00007FF91DFF1577  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF157E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1581  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1585  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1589  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF158E  E8 6D A4 01 00              call    sub_7FF91E00BA00
00007FF91DFF1593  48 8D 05 A2 9D 5F 00        lea     rax, aEnv12; "Env1/2"
00007FF91DFF159A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF15A1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF15A5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF15A9  48 8D 87 B0 E8 00 00        lea     rax, [rdi+0E8B0h]
00007FF91DFF15B0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF15B7  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF15BA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF15BE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF15C2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF15C7  E8 34 A4 01 00              call    sub_7FF91E00BA00
00007FF91DFF15CC  48 8D 05 75 9D 5F 00        lea     rax, aIntEnv; "Int/Env"
00007FF91DFF15D3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF15DA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF15DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF15E2  48 8D 87 C0 E8 00 00        lea     rax, [rdi+0E8C0h]
00007FF91DFF15E9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF15F0  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF15F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF15F7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF15FB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1600  E8 FB A3 01 00              call    sub_7FF91E00BA00
00007FF91DFF1605  48 8D 05 04 9C 5F 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFF160C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1613  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1617  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF161B  48 8D 87 D0 E9 00 00        lea     rax, [rdi+0E9D0h]
00007FF91DFF1622  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1629  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF162C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1630  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1634  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1639  E8 C2 A3 01 00              call    sub_7FF91E00BA00
00007FF91DFF163E  48 8D 05 0B 9D 5F 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
00007FF91DFF1645  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF164C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1650  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1654  48 8D 87 E0 E9 00 00        lea     rax, [rdi+0E9E0h]
00007FF91DFF165B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1662  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1665  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1669  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF166D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1672  E8 89 A3 01 00              call    sub_7FF91E00BA00
00007FF91DFF1677  48 8D 05 E2 9C 5F 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
00007FF91DFF167E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1685  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1689  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF168D  48 8D 87 F0 E9 00 00        lea     rax, [rdi+0E9F0h]
00007FF91DFF1694  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF169B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF169E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF16A2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF16A6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF16AB  E8 50 A3 01 00              call    sub_7FF91E00BA00
00007FF91DFF16B0  66 0F 6F 05 78 A9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF16B8  48 8D 05 61 9B 5F 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFF16BF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF16C3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF16C7  48 8D 87 00 EA 00 00        lea     rax, [rdi+0EA00h]
00007FF91DFF16CE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF16D5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF16D9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF16DD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF16E2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF16E9  E8 12 A3 01 00              call    sub_7FF91E00BA00
00007FF91DFF16EE  66 0F 6F 05 3A A9 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF16F6  48 8D 05 73 9C 5F 00        lea     rax, aModSens_0; "MOD Sens"
00007FF91DFF16FD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1701  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1705  48 8D 87 10 EA 00 00        lea     rax, [rdi+0EA10h]
00007FF91DFF170C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1713  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1717  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF171B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1720  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1727  E8 D4 A2 01 00              call    sub_7FF91E00BA00
00007FF91DFF172C  66 0F 6F 05 FC A8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1734  48 8D 05 41 9C 5F 00        lea     rax, aModSw_0; "MOD SW"
00007FF91DFF173B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF173F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1743  48 8D 87 20 EA 00 00        lea     rax, [rdi+0EA20h]
00007FF91DFF174A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1751  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1755  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1759  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF175E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1765  E8 96 A2 01 00              call    sub_7FF91E00BA00
00007FF91DFF176A  66 0F 6F 05 BE A8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1772  48 8D 05 0F 9C 5F 00        lea     rax, aEnvLevel; "ENV Level"
00007FF91DFF1779  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF177D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1781  48 8D 87 30 EA 00 00        lea     rax, [rdi+0EA30h]
00007FF91DFF1788  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF178F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1793  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1797  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF179C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF17A3  E8 58 A2 01 00              call    sub_7FF91E00BA00
00007FF91DFF17A8  66 0F 6F 05 80 A8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF17B0  48 8D 05 E1 9B 5F 00        lea     rax, aKcvLevel; "KCV Level"
00007FF91DFF17B7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF17BB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF17BF  48 8D 87 40 EA 00 00        lea     rax, [rdi+0EA40h]
00007FF91DFF17C6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF17CD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF17D1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF17D5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF17DA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF17E1  E8 1A A2 01 00              call    sub_7FF91E00BA00
00007FF91DFF17E6  66 0F 6F 05 42 A8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF17EE  48 8D 05 B3 9B 5F 00        lea     rax, aVelocitySens; "Velocity Sens"
00007FF91DFF17F5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF17F9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF17FD  48 8D 87 50 EA 00 00        lea     rax, [rdi+0EA50h]
00007FF91DFF1804  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF180B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF180F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1813  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1818  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF181F  E8 DC A1 01 00              call    sub_7FF91E00BA00
00007FF91DFF1824  66 0F 6F 05 04 A8 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF182C  48 8D 05 85 9B 5F 00        lea     rax, aVelocityOffset; "Velocity Offset"
00007FF91DFF1833  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1837  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF183B  48 8D 87 60 EA 00 00        lea     rax, [rdi+0EA60h]
00007FF91DFF1842  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1849  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF184D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1851  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1856  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF185D  E8 9E A1 01 00              call    sub_7FF91E00BA00
00007FF91DFF1862  66 0F 6F 05 C6 A7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF186A  48 8D 05 EF 99 5F 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFF1871  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1875  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1879  48 8D 87 70 EA 00 00        lea     rax, [rdi+0EA70h]
00007FF91DFF1880  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1887  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF188B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF188F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1894  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF189B  E8 60 A1 01 00              call    sub_7FF91E00BA00
00007FF91DFF18A0  48 8D 05 C9 99 5F 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFF18A7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF18AE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF18B2  66 0F 6F 05 76 A7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF18BA  48 8D 87 80 EA 00 00        lea     rax, [rdi+0EA80h]
00007FF91DFF18C1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF18C5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF18C9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF18CD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF18D4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF18D9  E8 22 A1 01 00              call    sub_7FF91E00BA00
00007FF91DFF18DE  66 0F 6F 05 4A A7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF18E6  48 8D 05 DB 9A 5F 00        lea     rax, aCutoffTune; "Cutoff Tune"
00007FF91DFF18ED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF18F1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF18F5  48 8D 87 00 EB 00 00        lea     rax, [rdi+0EB00h]
00007FF91DFF18FC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1903  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1907  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF190B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1910  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1917  E8 E4 A0 01 00              call    sub_7FF91E00BA00
00007FF91DFF191C  66 0F 6F 05 0C A7 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1924  48 8D 05 AD 9A 5F 00        lea     rax, aResonanceTune; "Resonance Tune"
00007FF91DFF192B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF192F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1933  48 8D 87 10 EB 00 00        lea     rax, [rdi+0EB10h]
00007FF91DFF193A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1941  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1945  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1949  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF194E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1955  E8 A6 A0 01 00              call    sub_7FF91E00BA00
00007FF91DFF195A  48 8D 05 87 9A 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFF1961  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFF1968  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF196C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1970  48 8D 87 20 EB 00 00        lea     rax, [rdi+0EB20h]
00007FF91DFF1977  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF197E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1981  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1985  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1989  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF198E  E8 6D A0 01 00              call    sub_7FF91E00BA00
00007FF91DFF1993  48 8D 05 4E 9A 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFF199A  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFF19A1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF19A5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF19A9  48 8D 87 B0 F0 00 00        lea     rax, [rdi+0F0B0h]
00007FF91DFF19B0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF19B7  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF19BA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF19BE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF19C2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF19C7  E8 34 A0 01 00              call    sub_7FF91E00BA00
00007FF91DFF19CC  66 0F 6F 05 5C A6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF19D4  48 8D 05 1D 9A 5F 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
00007FF91DFF19DB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF19DF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF19E3  48 8D 87 C0 F0 00 00        lea     rax, [rdi+0F0C0h]
00007FF91DFF19EA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF19F1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF19F5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF19F9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF19FE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1A05  E8 F6 9F 01 00              call    sub_7FF91E00BA00
00007FF91DFF1A0A  66 0F 6F 05 1E A6 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1A12  48 8D 05 EF 99 5F 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
00007FF91DFF1A19  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1A1D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1A21  48 8D 87 D0 F0 00 00        lea     rax, [rdi+0F0D0h]
00007FF91DFF1A28  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1A2F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1A33  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1A37  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1A3C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1A43  E8 B8 9F 01 00              call    sub_7FF91E00BA00
00007FF91DFF1A48  66 0F 6F 05 E0 A5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1A50  48 8D 05 C1 99 5F 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
00007FF91DFF1A57  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1A5B  48 8D 87 E0 F0 00 00        lea     rax, [rdi+0F0E0h]
00007FF91DFF1A62  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1A69  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1A6E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1A75  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1A79  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1A7D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1A81  E8 7A 9F 01 00              call    sub_7FF91E00BA00
00007FF91DFF1A86  66 0F 6F 05 A2 A5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1A8E  48 8D 05 93 99 5F 00        lea     rax, aAmpTone; "AMP TONE"
00007FF91DFF1A95  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1A99  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1A9D  48 8D 87 C0 F2 00 00        lea     rax, [rdi+0F2C0h]
00007FF91DFF1AA4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1AAB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1AAF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1AB3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1AB8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1ABF  E8 3C 9F 01 00              call    sub_7FF91E00BA00
00007FF91DFF1AC4  66 0F 6F 05 64 A5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1ACC  48 8D 05 65 99 5F 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
00007FF91DFF1AD3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1AD7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1ADB  48 8D 87 D0 F2 00 00        lea     rax, [rdi+0F2D0h]
00007FF91DFF1AE2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1AE9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1AED  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1AF1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1AF6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1AFD  E8 FE 9E 01 00              call    sub_7FF91E00BA00
00007FF91DFF1B02  66 0F 6F 05 26 A5 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1B0A  48 8D 05 3F 99 5F 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
00007FF91DFF1B11  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1B15  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1B19  48 8D 87 E0 F2 00 00        lea     rax, [rdi+0F2E0h]
00007FF91DFF1B20  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1B27  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1B2B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1B2F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1B34  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1B3B  E8 C0 9E 01 00              call    sub_7FF91E00BA00
00007FF91DFF1B40  48 8D 05 E9 97 5F 00        lea     rax, aVelocity; "Velocity"
00007FF91DFF1B47  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1B4E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1B52  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1B56  48 8D 87 20 F3 00 00        lea     rax, [rdi+0F320h]
00007FF91DFF1B5D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1B64  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1B67  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1B6B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1B6F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1B74  E8 87 9E 01 00              call    sub_7FF91E00BA00
00007FF91DFF1B79  48 8D 05 E8 98 5F 00        lea     rax, aMute; "Mute"
00007FF91DFF1B80  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1B87  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1B8B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1B8F  48 8D 87 B0 F3 00 00        lea     rax, [rdi+0F3B0h]
00007FF91DFF1B96  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1B9D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1BA0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1BA4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1BA8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1BAD  E8 4E 9E 01 00              call    sub_7FF91E00BA00
00007FF91DFF1BB2  48 8D 05 B7 98 5F 00        lea     rax, aGateSw; "Gate SW"
00007FF91DFF1BB9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1BC0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1BC4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1BC8  48 8D 87 10 F5 00 00        lea     rax, [rdi+0F510h]
00007FF91DFF1BCF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1BD6  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1BD9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1BDD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1BE1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1BE6  E8 15 9E 01 00              call    sub_7FF91E00BA00
00007FF91DFF1BEB  48 8D 05 86 98 5F 00        lea     rax, aEnv1Sw; "ENV1 SW"
00007FF91DFF1BF2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1BF9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1BFD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1C01  48 8D 87 20 F5 00 00        lea     rax, [rdi+0F520h]
00007FF91DFF1C08  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1C0F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1C12  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1C16  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1C1A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1C1F  E8 DC 9D 01 00              call    sub_7FF91E00BA00
00007FF91DFF1C24  48 8D 05 55 98 5F 00        lea     rax, aEnv2Sw; "ENV2 SW"
00007FF91DFF1C2B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1C32  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1C36  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1C3A  48 8D 87 30 F5 00 00        lea     rax, [rdi+0F530h]
00007FF91DFF1C41  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1C48  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1C4B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1C4F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1C53  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1C58  E8 A3 9D 01 00              call    sub_7FF91E00BA00
00007FF91DFF1C5D  48 8D 05 24 98 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
00007FF91DFF1C64  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1C6B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1C6F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1C73  48 8D 87 40 F5 00 00        lea     rax, [rdi+0F540h]
00007FF91DFF1C7A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1C81  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1C84  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1C88  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1C8C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1C91  E8 6A 9D 01 00              call    sub_7FF91E00BA00
00007FF91DFF1C96  66 0F 6F 05 92 A3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1C9E  48 8D 05 F3 97 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
00007FF91DFF1CA5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1CA9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1CAD  48 8D 87 50 F5 00 00        lea     rax, [rdi+0F550h]
00007FF91DFF1CB4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1CBB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1CBF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1CC3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1CC8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1CCF  E8 2C 9D 01 00              call    sub_7FF91E00BA00
00007FF91DFF1CD4  66 0F 6F 05 54 A3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1CDC  48 8D 05 C5 97 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
00007FF91DFF1CE3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1CE7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1CEB  48 8D 87 60 F5 00 00        lea     rax, [rdi+0F560h]
00007FF91DFF1CF2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1CF9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1CFD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1D01  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1D06  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1D0D  E8 EE 9C 01 00              call    sub_7FF91E00BA00
00007FF91DFF1D12  66 0F 6F 05 16 A3 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1D1A  48 8D 05 97 97 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
00007FF91DFF1D21  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1D25  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1D29  48 8D 87 70 F5 00 00        lea     rax, [rdi+0F570h]
00007FF91DFF1D30  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1D37  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1D3B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1D3F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1D44  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1D4B  E8 B0 9C 01 00              call    sub_7FF91E00BA00
00007FF91DFF1D50  66 0F 6F 05 D8 A2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1D58  48 8D 05 69 97 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
00007FF91DFF1D5F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1D63  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1D67  48 8D 87 80 F5 00 00        lea     rax, [rdi+0F580h]
00007FF91DFF1D6E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1D75  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1D79  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1D7D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1D82  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1D89  E8 72 9C 01 00              call    sub_7FF91E00BA00
00007FF91DFF1D8E  66 0F 6F 05 9A A2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1D96  48 8D 05 43 97 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
00007FF91DFF1D9D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1DA1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1DA5  48 8D 87 90 F5 00 00        lea     rax, [rdi+0F590h]
00007FF91DFF1DAC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1DB3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1DB7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1DBB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1DC0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1DC7  E8 34 9C 01 00              call    sub_7FF91E00BA00
00007FF91DFF1DCC  66 0F 6F 05 5C A2 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1DD4  48 8D 05 15 97 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
00007FF91DFF1DDB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1DDF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1DE6  48 8D 87 A0 F5 00 00        lea     rax, [rdi+0F5A0h]
00007FF91DFF1DED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1DF4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1DF8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1DFC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1E00  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1E05  E8 F6 9B 01 00              call    sub_7FF91E00BA00
00007FF91DFF1E0A  48 8D 05 0F 91 5F 00        lea     rax, aUseextjack; "UseExtJack"
00007FF91DFF1E11  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1E18  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1E1C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1E20  48 8D 87 70 F7 00 00        lea     rax, [rdi+0F770h]
00007FF91DFF1E27  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1E2E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1E31  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1E35  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1E39  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1E3E  E8 BD 9B 01 00              call    sub_7FF91E00BA00
00007FF91DFF1E43  48 8D 05 E2 90 5F 00        lea     rax, aMCv; "M.CV"
00007FF91DFF1E4A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1E51  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1E55  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1E59  48 8D 87 90 F7 00 00        lea     rax, [rdi+0F790h]
00007FF91DFF1E60  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1E67  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1E6A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1E6E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1E72  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1E77  E8 84 9B 01 00              call    sub_7FF91E00BA00
00007FF91DFF1E7C  48 8D 05 B1 90 5F 00        lea     rax, aMGate; "M.Gate"
00007FF91DFF1E83  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1E8A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1E8E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1E92  48 8D 87 A0 F7 00 00        lea     rax, [rdi+0F7A0h]
00007FF91DFF1E99  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1EA0  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1EA3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1EA7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1EAB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1EB0  E8 4B 9B 01 00              call    sub_7FF91E00BA00
00007FF91DFF1EB5  66 0F 6F 05 73 A1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1EBD  48 8D 05 7C 90 5F 00        lea     rax, aMasterTune; "Master Tune"
00007FF91DFF1EC4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1EC8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1ECC  48 8D 87 D0 F7 00 00        lea     rax, [rdi+0F7D0h]
00007FF91DFF1ED3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1EDA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1EDE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1EE2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1EE7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1EEE  E8 0D 9B 01 00              call    sub_7FF91E00BA00
00007FF91DFF1EF3  66 0F 6F 05 35 A1 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1EFB  48 8D 05 4E 90 5F 00        lea     rax, aPartTune; "Part Tune"
00007FF91DFF1F02  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1F06  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1F0A  48 8D 87 E0 F7 00 00        lea     rax, [rdi+0F7E0h]
00007FF91DFF1F11  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1F18  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1F1C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1F20  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1F25  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1F2C  E8 CF 9A 01 00              call    sub_7FF91E00BA00
00007FF91DFF1F31  48 8D 05 28 90 5F 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
00007FF91DFF1F38  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1F3F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1F43  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1F47  48 8D 87 B0 F8 00 00        lea     rax, [rdi+0F8B0h]
00007FF91DFF1F4E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1F55  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1F58  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1F5C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1F60  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1F65  E8 96 9A 01 00              call    sub_7FF91E00BA00
00007FF91DFF1F6A  48 8D 05 07 90 5F 00        lea     rax, aPortamentoMode; "Portamento Mode"
00007FF91DFF1F71  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1F78  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1F7C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF1F7F  48 8D 87 C0 F8 00 00        lea     rax, [rdi+0F8C0h]
00007FF91DFF1F86  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1F8D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1F91  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1F96  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1F9A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1F9E  E8 5D 9A 01 00              call    sub_7FF91E00BA00
00007FF91DFF1FA3  66 0F 6F 05 85 A0 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF1FAB  48 8D 05 D6 8F 5F 00        lea     rax, aPortamentoTime; "Portamento Time"
00007FF91DFF1FB2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1FB6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1FBA  48 8D 87 D0 F8 00 00        lea     rax, [rdi+0F8D0h]
00007FF91DFF1FC1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1FC8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF1FCC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF1FD0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF1FD5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF1FDC  E8 1F 9A 01 00              call    sub_7FF91E00BA00
00007FF91DFF1FE1  48 8D 05 B0 8F 5F 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
00007FF91DFF1FE8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF1FEF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF1FF3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF1FF7  48 8D 87 70 FA 00 00        lea     rax, [rdi+0FA70h]
00007FF91DFF1FFE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2005  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF2008  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF200C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2010  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2015  E8 E6 99 01 00              call    sub_7FF91E00BA00
00007FF91DFF201A  48 8D 05 8F 8F 5F 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
00007FF91DFF2021  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2028  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF202C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2030  48 8D 87 80 FA 00 00        lea     rax, [rdi+0FA80h]
00007FF91DFF2037  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF203E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF2041  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2045  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2049  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF204E  E8 AD 99 01 00              call    sub_7FF91E00BA00
00007FF91DFF2053  48 8D 05 6E 8F 5F 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
00007FF91DFF205A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2061  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2065  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2069  48 8D 87 90 FA 00 00        lea     rax, [rdi+0FA90h]
00007FF91DFF2070  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2077  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF207A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF207E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2082  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2087  E8 74 99 01 00              call    sub_7FF91E00BA00
00007FF91DFF208C  66 0F 6F 05 9C 9F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2094  48 8D 05 3D 8F 5F 00        lea     rax, aLfoRate; "LFO Rate"
00007FF91DFF209B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF209F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF20A3  48 8D 87 A0 FA 00 00        lea     rax, [rdi+0FAA0h]
00007FF91DFF20AA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF20B1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF20B5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF20B9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF20BE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF20C5  E8 36 99 01 00              call    sub_7FF91E00BA00
00007FF91DFF20CA  48 8D 05 13 8F 5F 00        lea     rax, aGate; "Gate"
00007FF91DFF20D1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF20D8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF20DC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF20E0  48 8D 87 A0 FD 00 00        lea     rax, [rdi+0FDA0h]
00007FF91DFF20E7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF20EE  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF20F1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF20F5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF20F9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF20FE  E8 FD 98 01 00              call    sub_7FF91E00BA00
00007FF91DFF2103  48 8D 05 E6 8E 5F 00        lea     rax, aLfoTrig; "LFO Trig"
00007FF91DFF210A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2111  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2115  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2119  48 8D 87 B0 FD 00 00        lea     rax, [rdi+0FDB0h]
00007FF91DFF2120  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2127  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF212A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF212E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2132  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2137  E8 C4 98 01 00              call    sub_7FF91E00BA00
00007FF91DFF213C  48 8D 05 BD 8E 5F 00        lea     rax, aResetSw; "Reset Sw"
00007FF91DFF2143  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2147  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF214B  48 8D 87 C0 FD 00 00        lea     rax, [rdi+0FDC0h]
00007FF91DFF2152  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2159  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF215C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2160  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2164  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF216B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2170  E8 8B 98 01 00              call    sub_7FF91E00BA00
00007FF91DFF2175  66 0F 6F 05 B3 9E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF217D  48 8D 05 8C 8E 5F 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
00007FF91DFF2184  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2188  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF218C  48 8D 87 D0 FD 00 00        lea     rax, [rdi+0FDD0h]
00007FF91DFF2193  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF219A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF219E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF21A2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF21A7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF21AE  E8 4D 98 01 00              call    sub_7FF91E00BA00
00007FF91DFF21B3  66 0F 6F 05 75 9E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF21BB  48 8D 05 5E 8E 5F 00        lea     rax, aLfoDelay; "LFO Delay"
00007FF91DFF21C2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF21C6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF21CA  48 8D 87 E0 FD 00 00        lea     rax, [rdi+0FDE0h]
00007FF91DFF21D1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF21D8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF21DC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF21E0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF21E5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF21EC  E8 0F 98 01 00              call    sub_7FF91E00BA00
00007FF91DFF21F1  66 0F 6F 05 37 9E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF21F9  48 8D 05 30 8E 5F 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
00007FF91DFF2200  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2204  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2208  48 8D 87 F0 FD 00 00        lea     rax, [rdi+0FDF0h]
00007FF91DFF220F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2216  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF221A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF221E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2223  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF222A  E8 D1 97 01 00              call    sub_7FF91E00BA00
00007FF91DFF222F  66 0F 6F 05 F9 9D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2237  48 8D 05 02 8E 5F 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
00007FF91DFF223E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2242  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2246  48 8D 87 00 FE 00 00        lea     rax, [rdi+0FE00h]
00007FF91DFF224D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2254  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2258  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF225C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2261  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2268  E8 93 97 01 00              call    sub_7FF91E00BA00
00007FF91DFF226D  66 0F 6F 05 BB 9D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2275  48 8D 05 D4 8D 5F 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
00007FF91DFF227C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2280  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2284  48 8D 87 10 FE 00 00        lea     rax, [rdi+0FE10h]
00007FF91DFF228B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2292  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2296  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF229A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF229F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF22A6  E8 55 97 01 00              call    sub_7FF91E00BA00
00007FF91DFF22AB  66 0F 6F 05 7D 9D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF22B3  48 8D 05 A6 8D 5F 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
00007FF91DFF22BA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF22BE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF22C2  48 8D 87 20 FE 00 00        lea     rax, [rdi+0FE20h]
00007FF91DFF22C9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF22D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF22D4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF22D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF22DD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF22E4  E8 17 97 01 00              call    sub_7FF91E00BA00
00007FF91DFF22E9  66 0F 6F 05 3F 9D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF22F1  48 8D 05 78 8D 5F 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
00007FF91DFF22F8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF22FC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2301  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2308  48 8D 87 30 FE 00 00        lea     rax, [rdi+0FE30h]
00007FF91DFF230F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2316  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF231A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF231E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2322  E8 D9 96 01 00              call    sub_7FF91E00BA00
00007FF91DFF2327  66 0F 6F 05 01 9D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF232F  48 8D 05 4A 8D 5F 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
00007FF91DFF2336  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF233A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF233E  48 8D 87 40 FE 00 00        lea     rax, [rdi+0FE40h]
00007FF91DFF2345  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF234C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2350  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2354  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2359  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2360  E8 9B 96 01 00              call    sub_7FF91E00BA00
00007FF91DFF2365  66 0F 6F 05 C3 9C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF236D  48 8D 05 1C 8D 5F 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
00007FF91DFF2374  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2378  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF237C  48 8D 87 50 FE 00 00        lea     rax, [rdi+0FE50h]
00007FF91DFF2383  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF238A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF238E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2392  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2397  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF239E  E8 5D 96 01 00              call    sub_7FF91E00BA00
00007FF91DFF23A3  66 0F 6F 05 85 9C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF23AB  48 8D 05 EE 8C 5F 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
00007FF91DFF23B2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF23B6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF23BA  48 8D 87 60 FE 00 00        lea     rax, [rdi+0FE60h]
00007FF91DFF23C1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF23C8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF23CC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF23D0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF23D5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF23DC  E8 1F 96 01 00              call    sub_7FF91E00BA00
00007FF91DFF23E1  66 0F 6F 05 47 9C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF23E9  48 8D 05 C0 8C 5F 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
00007FF91DFF23F0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF23F4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF23F8  48 8D 87 70 FE 00 00        lea     rax, [rdi+0FE70h]
00007FF91DFF23FF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2406  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF240A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF240E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2413  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF241A  E8 E1 95 01 00              call    sub_7FF91E00BA00
00007FF91DFF241F  66 0F 6F 05 09 9C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2427  48 8D 05 92 8C 5F 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
00007FF91DFF242E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2432  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2436  48 8D 87 80 FE 00 00        lea     rax, [rdi+0FE80h]
00007FF91DFF243D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2444  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2448  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF244C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2451  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2458  E8 A3 95 01 00              call    sub_7FF91E00BA00
00007FF91DFF245D  66 0F 6F 05 CB 9B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2465  48 8D 05 64 8C 5F 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
00007FF91DFF246C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2470  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2474  48 8D 87 90 FE 00 00        lea     rax, [rdi+0FE90h]
00007FF91DFF247B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2482  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2486  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF248A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF248F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2496  E8 65 95 01 00              call    sub_7FF91E00BA00
00007FF91DFF249B  66 0F 6F 05 8D 9B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF24A3  48 8D 05 3E 8C 5F 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
00007FF91DFF24AA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF24AE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF24B2  48 8D 87 A0 FE 00 00        lea     rax, [rdi+0FEA0h]
00007FF91DFF24B9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF24C0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF24C4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF24C9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF24D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF24D4  E8 27 95 01 00              call    sub_7FF91E00BA00
00007FF91DFF24D9  48 8D 05 20 8C 5F 00        lea     rax, aReadOnly; "read only"
00007FF91DFF24E0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF24E7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF24EB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF24EF  48 8D 87 40 00 01 00        lea     rax, [rdi+10040h]
00007FF91DFF24F6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF24FD  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF2500  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2504  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2508  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF250D  E8 EE 94 01 00              call    sub_7FF91E00BA00
00007FF91DFF2512  48 8D 05 E7 8B 5F 00        lea     rax, aReadOnly; "read only"
00007FF91DFF2519  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2520  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2524  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2528  48 8D 87 50 00 01 00        lea     rax, [rdi+10050h]
00007FF91DFF252F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2536  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF2539  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF253D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2541  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2546  E8 B5 94 01 00              call    sub_7FF91E00BA00
00007FF91DFF254B  48 8D 05 BE 8B 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFF2552  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2559  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF255D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2561  48 8D 87 60 00 01 00        lea     rax, [rdi+10060h]
00007FF91DFF2568  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF256F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF2572  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2576  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF257A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF257F  E8 7C 94 01 00              call    sub_7FF91E00BA00
00007FF91DFF2584  66 0F 6F 05 A4 9A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF258C  48 8D 05 95 8B 5F 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFF2593  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2597  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF259B  48 8D 87 40 01 01 00        lea     rax, [rdi+10140h]
00007FF91DFF25A2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF25A9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF25AD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF25B1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF25B6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF25BD  E8 3E 94 01 00              call    sub_7FF91E00BA00
00007FF91DFF25C2  66 0F 6F 05 66 9A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF25CA  48 8D 05 67 8B 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFF25D1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF25D5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF25D9  48 8D 87 50 01 01 00        lea     rax, [rdi+10150h]
00007FF91DFF25E0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF25E7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF25EB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF25EF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF25F4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF25FB  E8 00 94 01 00              call    sub_7FF91E00BA00
00007FF91DFF2600  66 0F 6F 05 28 9A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2608  48 8D 05 39 8B 5F 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFF260F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2613  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2617  48 8D 87 60 01 01 00        lea     rax, [rdi+10160h]
00007FF91DFF261E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2625  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2629  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF262D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2632  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2639  E8 C2 93 01 00              call    sub_7FF91E00BA00
00007FF91DFF263E  66 0F 6F 05 EA 99 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2646  48 8D 05 0B 8B 5F 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFF264D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2651  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2655  48 8D 87 70 01 01 00        lea     rax, [rdi+10170h]
00007FF91DFF265C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2663  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2667  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF266B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2670  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2677  E8 84 93 01 00              call    sub_7FF91E00BA00
00007FF91DFF267C  48 8D 05 E5 8A 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFF2683  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2687  66 0F 6F 05 A1 99 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF268F  48 8D 87 80 01 01 00        lea     rax, [rdi+10180h]
00007FF91DFF2696  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF269A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF269E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF26A2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF26A9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF26AE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF26B5  E8 46 93 01 00              call    sub_7FF91E00BA00
00007FF91DFF26BA  48 8D 05 4F 8A 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFF26C1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF26C8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF26CC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF26D0  48 8D 87 40 02 01 00        lea     rax, [rdi+10240h]
00007FF91DFF26D7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF26DE  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF26E1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF26E5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF26E9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF26EE  E8 0D 93 01 00              call    sub_7FF91E00BA00
00007FF91DFF26F3  66 0F 6F 05 35 99 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF26FB  48 8D 05 26 8A 5F 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFF2702  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2706  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF270A  48 8D 87 20 03 01 00        lea     rax, [rdi+10320h]
00007FF91DFF2711  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2718  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF271C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2720  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2725  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF272C  E8 CF 92 01 00              call    sub_7FF91E00BA00
00007FF91DFF2731  66 0F 6F 05 F7 98 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2739  48 8D 05 F8 89 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFF2740  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2744  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2748  48 8D 87 30 03 01 00        lea     rax, [rdi+10330h]
00007FF91DFF274F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2756  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF275A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF275E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2763  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF276A  E8 91 92 01 00              call    sub_7FF91E00BA00
00007FF91DFF276F  66 0F 6F 05 B9 98 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2777  48 8D 05 CA 89 5F 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFF277E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2782  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2786  48 8D 87 40 03 01 00        lea     rax, [rdi+10340h]
00007FF91DFF278D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2794  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2798  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF279C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF27A1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF27A8  E8 53 92 01 00              call    sub_7FF91E00BA00
00007FF91DFF27AD  66 0F 6F 05 7B 98 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF27B5  48 8D 05 9C 89 5F 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFF27BC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF27C0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF27C4  48 8D 87 50 03 01 00        lea     rax, [rdi+10350h]
00007FF91DFF27CB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF27D2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF27D6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF27DA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF27DF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF27E6  E8 15 92 01 00              call    sub_7FF91E00BA00
00007FF91DFF27EB  66 0F 6F 05 3D 98 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF27F3  48 8D 05 6E 89 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFF27FA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF27FE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2802  48 8D 87 60 03 01 00        lea     rax, [rdi+10360h]
00007FF91DFF2809  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2810  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2814  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2818  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF281D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2824  E8 D7 91 01 00              call    sub_7FF91E00BA00
00007FF91DFF2829  48 8D 05 48 89 5F 00        lea     rax, aOsc1Feet; "OSC1 Feet"
00007FF91DFF2830  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2837  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF283A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF283E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2843  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF284A  48 8D 87 60 05 01 00        lea     rax, [rdi+10560h]
00007FF91DFF2851  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2855  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2859  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF285D  E8 9E 91 01 00              call    sub_7FF91E00BA00
00007FF91DFF2862  48 8D 05 1F 89 5F 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
00007FF91DFF2869  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2870  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2874  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2878  48 8D 87 70 05 01 00        lea     rax, [rdi+10570h]
00007FF91DFF287F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2886  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF2889  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF288D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2891  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2896  E8 65 91 01 00              call    sub_7FF91E00BA00
00007FF91DFF289B  48 8D 05 F6 88 5F 00        lea     rax, aBendEnableSw; "Bend Enable SW"
00007FF91DFF28A2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF28A9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF28AD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF28B1  48 8D 87 80 05 01 00        lea     rax, [rdi+10580h]
00007FF91DFF28B8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF28BF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF28C2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF28C6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF28CA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF28CF  E8 2C 91 01 00              call    sub_7FF91E00BA00
00007FF91DFF28D4  48 8D 05 CD 88 5F 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
00007FF91DFF28DB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF28E2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF28E6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF28EA  48 8D 87 90 05 01 00        lea     rax, [rdi+10590h]
00007FF91DFF28F1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF28F8  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF28FB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF28FF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2903  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2908  E8 F3 90 01 00              call    sub_7FF91E00BA00
00007FF91DFF290D  48 8D 05 A4 88 5F 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
00007FF91DFF2914  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF291B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF291F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2923  48 8D 87 A0 05 01 00        lea     rax, [rdi+105A0h]
00007FF91DFF292A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2931  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF2934  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2938  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF293C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2941  E8 BA 90 01 00              call    sub_7FF91E00BA00
00007FF91DFF2946  48 8D 05 7B 88 5F 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
00007FF91DFF294D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2954  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2958  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF295C  48 8D 87 B0 05 01 00        lea     rax, [rdi+105B0h]
00007FF91DFF2963  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF296A  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF296D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2971  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2975  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF297A  E8 81 90 01 00              call    sub_7FF91E00BA00
00007FF91DFF297F  48 8D 05 52 88 5F 00        lea     rax, aPwmSwManual; "PWM SW Manual"
00007FF91DFF2986  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF298D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2991  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2995  48 8D 87 C0 05 01 00        lea     rax, [rdi+105C0h]
00007FF91DFF299C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF29A3  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF29A6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF29AA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF29AE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF29B3  E8 48 90 01 00              call    sub_7FF91E00BA00
00007FF91DFF29B8  66 0F 6F 05 70 96 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF29C0  48 8D 05 21 88 5F 00        lea     rax, aTune; "Tune"
00007FF91DFF29C7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF29CB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF29CF  48 8D 87 D0 05 01 00        lea     rax, [rdi+105D0h]
00007FF91DFF29D6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF29DD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF29E1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF29E5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF29EA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF29F1  E8 0A 90 01 00              call    sub_7FF91E00BA00
00007FF91DFF29F6  66 0F 6F 05 32 96 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF29FE  48 8D 05 EB 87 5F 00        lea     rax, aDetune; "Detune"
00007FF91DFF2A05  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2A09  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2A0D  48 8D 87 E0 05 01 00        lea     rax, [rdi+105E0h]
00007FF91DFF2A14  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2A1B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2A1F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2A23  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2A28  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2A2F  E8 CC 8F 01 00              call    sub_7FF91E00BA00
00007FF91DFF2A34  66 0F 6F 05 F4 95 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2A3C  48 8D 05 B5 87 5F 00        lea     rax, aModSens; "Mod Sens"
00007FF91DFF2A43  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2A47  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2A4B  48 8D 87 F0 05 01 00        lea     rax, [rdi+105F0h]
00007FF91DFF2A52  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2A59  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2A5D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2A61  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2A66  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2A6D  E8 8E 8F 01 00              call    sub_7FF91E00BA00
00007FF91DFF2A72  66 0F 6F 05 B6 95 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2A7A  48 8D 05 83 87 5F 00        lea     rax, aModSw; "Mod Sw"
00007FF91DFF2A81  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2A85  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2A89  48 8D 87 00 06 01 00        lea     rax, [rdi+10600h]
00007FF91DFF2A90  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2A97  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2A9B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2A9F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2AA4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2AAB  E8 50 8F 01 00              call    sub_7FF91E00BA00
00007FF91DFF2AB0  66 0F 6F 05 78 95 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2AB8  48 8D 05 51 87 5F 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFF2ABF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2AC3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2AC7  48 8D 87 10 06 01 00        lea     rax, [rdi+10610h]
00007FF91DFF2ACE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2AD5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2AD9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2ADD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2AE2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2AE9  E8 12 8F 01 00              call    sub_7FF91E00BA00
00007FF91DFF2AEE  66 0F 6F 05 3A 95 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2AF6  48 8D 05 23 87 5F 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFF2AFD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2B01  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2B05  48 8D 87 20 06 01 00        lea     rax, [rdi+10620h]
00007FF91DFF2B0C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2B13  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2B17  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2B1B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2B20  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2B27  E8 D4 8E 01 00              call    sub_7FF91E00BA00
00007FF91DFF2B2C  66 0F 6F 05 FC 94 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2B34  48 8D 05 F1 86 5F 00        lea     rax, aLfoSw; "LFO Sw"
00007FF91DFF2B3B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2B3F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2B43  48 8D 87 30 06 01 00        lea     rax, [rdi+10630h]
00007FF91DFF2B4A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2B51  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2B55  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2B59  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2B5E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2B65  E8 96 8E 01 00              call    sub_7FF91E00BA00
00007FF91DFF2B6A  66 0F 6F 05 BE 94 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2B72  48 8D 05 BF 86 5F 00        lea     rax, aEnv1Level; "ENV1 Level"
00007FF91DFF2B79  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2B7D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2B81  48 8D 87 40 06 01 00        lea     rax, [rdi+10640h]
00007FF91DFF2B88  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2B8F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2B93  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2B97  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2B9C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2BA3  E8 58 8E 01 00              call    sub_7FF91E00BA00
00007FF91DFF2BA8  48 8D 05 99 86 5F 00        lea     rax, aEnv2Level; "ENV2 Level"
00007FF91DFF2BAF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2BB6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2BBA  66 0F 6F 05 6E 94 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2BC2  48 8D 87 50 06 01 00        lea     rax, [rdi+10650h]
00007FF91DFF2BC9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2BCD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2BD1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2BD5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2BDC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2BE1  E8 1A 8E 01 00              call    sub_7FF91E00BA00
00007FF91DFF2BE6  66 0F 6F 05 42 94 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2BEE  48 8D 05 5F 86 5F 00        lea     rax, aEnvSw; "ENV Sw"
00007FF91DFF2BF5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2BF9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2BFD  48 8D 87 60 06 01 00        lea     rax, [rdi+10660h]
00007FF91DFF2C04  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2C0B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2C0F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2C13  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2C18  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2C1F  E8 DC 8D 01 00              call    sub_7FF91E00BA00
00007FF91DFF2C24  66 0F 6F 05 04 94 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2C2C  48 8D 05 2D 86 5F 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFF2C33  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2C37  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2C3B  48 8D 87 70 06 01 00        lea     rax, [rdi+10670h]
00007FF91DFF2C42  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2C49  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2C4D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2C51  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2C56  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2C5D  E8 9E 8D 01 00              call    sub_7FF91E00BA00
00007FF91DFF2C62  66 0F 6F 05 C6 93 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2C6A  48 8D 05 FF 85 5F 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFF2C71  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2C75  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2C79  48 8D 87 80 06 01 00        lea     rax, [rdi+10680h]
00007FF91DFF2C80  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2C87  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2C8B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2C8F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2C94  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2C9B  E8 60 8D 01 00              call    sub_7FF91E00BA00
00007FF91DFF2CA0  66 0F 6F 05 88 93 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2CA8  48 8D 05 D1 85 5F 00        lea     rax, aPwmLevel; "PWM Level"
00007FF91DFF2CAF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2CB3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2CB7  48 8D 87 90 06 01 00        lea     rax, [rdi+10690h]
00007FF91DFF2CBE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2CC5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2CC9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2CCD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2CD2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2CD9  E8 22 8D 01 00              call    sub_7FF91E00BA00
00007FF91DFF2CDE  66 0F 6F 05 4A 93 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2CE6  48 8D 05 A3 85 5F 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
00007FF91DFF2CED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2CF1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2CF5  48 8D 87 C0 06 01 00        lea     rax, [rdi+106C0h]
00007FF91DFF2CFC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2D03  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2D07  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2D0B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2D10  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2D17  E8 E4 8C 01 00              call    sub_7FF91E00BA00
00007FF91DFF2D1C  66 0F 6F 05 0C 93 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2D24  48 8D 05 75 85 5F 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
00007FF91DFF2D2B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2D2F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2D33  48 8D 87 D0 06 01 00        lea     rax, [rdi+106D0h]
00007FF91DFF2D3A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2D41  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2D45  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2D49  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2D4E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2D55  E8 A6 8C 01 00              call    sub_7FF91E00BA00
00007FF91DFF2D5A  66 0F 6F 05 CE 92 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2D62  48 8D 05 47 85 5F 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
00007FF91DFF2D69  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2D6D  48 8D 87 E0 06 01 00        lea     rax, [rdi+106E0h]
00007FF91DFF2D74  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2D7B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2D80  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2D87  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2D8B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2D8F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2D93  E8 68 8C 01 00              call    sub_7FF91E00BA00
00007FF91DFF2D98  66 0F 6F 05 90 92 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2DA0  48 8D 05 19 85 5F 00        lea     rax, aDutyTune; "Duty Tune"
00007FF91DFF2DA7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2DAB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2DAF  48 8D 87 F0 0B 01 00        lea     rax, [rdi+10BF0h]
00007FF91DFF2DB6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2DBD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2DC1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2DC5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2DCA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2DD1  E8 2A 8C 01 00              call    sub_7FF91E00BA00
00007FF91DFF2DD6  66 0F 6F 05 52 92 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2DDE  48 8D 05 EB 84 5F 00        lea     rax, aOsc1Mute; "Osc1 Mute"
00007FF91DFF2DE5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2DE9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2DED  48 8D 87 90 0F 01 00        lea     rax, [rdi+10F90h]
00007FF91DFF2DF4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2DFB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2DFF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2E03  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2E08  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2E0F  E8 EC 8B 01 00              call    sub_7FF91E00BA00
00007FF91DFF2E14  66 0F 6F 05 14 92 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2E1C  48 8D 05 BD 84 5F 00        lea     rax, aOsc1Level; "Osc1 Level"
00007FF91DFF2E23  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2E27  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2E2B  48 8D 87 D0 0F 01 00        lea     rax, [rdi+10FD0h]
00007FF91DFF2E32  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2E39  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2E3D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2E41  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2E46  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2E4D  E8 AE 8B 01 00              call    sub_7FF91E00BA00
00007FF91DFF2E52  66 0F 6F 05 D6 91 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2E5A  48 8D 05 8F 84 5F 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
00007FF91DFF2E61  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2E65  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2E69  48 8D 87 E0 0F 01 00        lea     rax, [rdi+10FE0h]
00007FF91DFF2E70  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2E77  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2E7B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2E7F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2E84  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2E8B  E8 70 8B 01 00              call    sub_7FF91E00BA00
00007FF91DFF2E90  48 8D 05 69 84 5F 00        lea     rax, aGrifferSw; "Griffer SW"
00007FF91DFF2E97  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2E9E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2EA2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2EA6  48 8D 87 A0 10 01 00        lea     rax, [rdi+110A0h]
00007FF91DFF2EAD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2EB4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF2EB7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2EBB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2EBF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2EC4  E8 37 8B 01 00              call    sub_7FF91E00BA00
00007FF91DFF2EC9  66 0F 6F 05 5F 91 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2ED1  48 8D 05 38 84 5F 00        lea     rax, aLpfCutoff; "LPF Cutoff"
00007FF91DFF2ED8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2EDC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2EE0  48 8D 87 B0 10 01 00        lea     rax, [rdi+110B0h]
00007FF91DFF2EE7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2EEE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2EF2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2EF6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2EFB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2F02  E8 F9 8A 01 00              call    sub_7FF91E00BA00
00007FF91DFF2F07  66 0F 6F 05 21 91 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF2F0F  48 8D 05 0A 84 5F 00        lea     rax, aLpfResonance; "LPF Resonance"
00007FF91DFF2F16  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2F1A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2F1E  48 8D 87 10 11 01 00        lea     rax, [rdi+11110h]
00007FF91DFF2F25  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2F2C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2F30  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2F34  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2F39  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2F40  E8 BB 8A 01 00              call    sub_7FF91E00BA00
00007FF91DFF2F45  48 8D 05 E4 83 5F 00        lea     rax, aVelocity; "Velocity"
00007FF91DFF2F4C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2F53  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2F57  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2F5B  48 8D 87 30 11 01 00        lea     rax, [rdi+11130h]
00007FF91DFF2F62  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2F69  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF2F6C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2F70  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2F74  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2F79  E8 82 8A 01 00              call    sub_7FF91E00BA00
00007FF91DFF2F7E  48 8D 05 B7 83 5F 00        lea     rax, aEnv12; "Env1/2"
00007FF91DFF2F85  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2F8C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2F90  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2F94  48 8D 87 C0 11 01 00        lea     rax, [rdi+111C0h]
00007FF91DFF2F9B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2FA2  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF2FA5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2FA9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2FAD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2FB2  E8 49 8A 01 00              call    sub_7FF91E00BA00
00007FF91DFF2FB7  48 8D 05 8A 83 5F 00        lea     rax, aIntEnv; "Int/Env"
00007FF91DFF2FBE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2FC5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF2FC9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF2FCD  48 8D 87 D0 11 01 00        lea     rax, [rdi+111D0h]
00007FF91DFF2FD4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF2FDB  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF2FDE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF2FE2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF2FE6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF2FEB  E8 10 8A 01 00              call    sub_7FF91E00BA00
00007FF91DFF2FF0  48 8D 05 19 82 5F 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFF2FF7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF2FFE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3002  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3006  48 8D 87 E0 12 01 00        lea     rax, [rdi+112E0h]
00007FF91DFF300D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3014  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3017  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF301B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF301F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3024  E8 D7 89 01 00              call    sub_7FF91E00BA00
00007FF91DFF3029  48 8D 05 20 83 5F 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
00007FF91DFF3030  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3037  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF303B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF303F  48 8D 87 F0 12 01 00        lea     rax, [rdi+112F0h]
00007FF91DFF3046  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF304D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3050  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3054  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3058  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF305D  E8 9E 89 01 00              call    sub_7FF91E00BA00
00007FF91DFF3062  48 8D 05 F7 82 5F 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
00007FF91DFF3069  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3070  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3074  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3078  48 8D 87 00 13 01 00        lea     rax, [rdi+11300h]
00007FF91DFF307F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3086  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3089  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF308D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3091  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3096  E8 65 89 01 00              call    sub_7FF91E00BA00
00007FF91DFF309B  66 0F 6F 05 8D 8F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF30A3  48 8D 05 76 81 5F 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFF30AA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF30AE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF30B2  48 8D 87 10 13 01 00        lea     rax, [rdi+11310h]
00007FF91DFF30B9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF30C0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF30C4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF30C8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF30CD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF30D4  E8 27 89 01 00              call    sub_7FF91E00BA00
00007FF91DFF30D9  66 0F 6F 05 4F 8F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF30E1  48 8D 05 88 82 5F 00        lea     rax, aModSens_0; "MOD Sens"
00007FF91DFF30E8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF30EC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF30F3  48 8D 87 20 13 01 00        lea     rax, [rdi+11320h]
00007FF91DFF30FA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3101  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3105  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3109  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF310D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3112  E8 E9 88 01 00              call    sub_7FF91E00BA00
00007FF91DFF3117  66 0F 6F 05 11 8F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF311F  48 8D 05 56 82 5F 00        lea     rax, aModSw_0; "MOD SW"
00007FF91DFF3126  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF312A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF312E  48 8D 87 30 13 01 00        lea     rax, [rdi+11330h]
00007FF91DFF3135  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF313C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3140  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3144  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3149  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3150  E8 AB 88 01 00              call    sub_7FF91E00BA00
00007FF91DFF3155  66 0F 6F 05 D3 8E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF315D  48 8D 05 24 82 5F 00        lea     rax, aEnvLevel; "ENV Level"
00007FF91DFF3164  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3168  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF316C  48 8D 87 40 13 01 00        lea     rax, [rdi+11340h]
00007FF91DFF3173  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF317A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF317E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3182  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3187  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF318E  E8 6D 88 01 00              call    sub_7FF91E00BA00
00007FF91DFF3193  66 0F 6F 05 95 8E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF319B  48 8D 05 F6 81 5F 00        lea     rax, aKcvLevel; "KCV Level"
00007FF91DFF31A2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF31A6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF31AA  48 8D 87 50 13 01 00        lea     rax, [rdi+11350h]
00007FF91DFF31B1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF31B8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF31BC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF31C0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF31C5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF31CC  E8 2F 88 01 00              call    sub_7FF91E00BA00
00007FF91DFF31D1  66 0F 6F 05 57 8E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF31D9  48 8D 05 C8 81 5F 00        lea     rax, aVelocitySens; "Velocity Sens"
00007FF91DFF31E0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF31E4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF31E8  48 8D 87 60 13 01 00        lea     rax, [rdi+11360h]
00007FF91DFF31EF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF31F6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF31FA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF31FE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3203  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF320A  E8 F1 87 01 00              call    sub_7FF91E00BA00
00007FF91DFF320F  66 0F 6F 05 19 8E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3217  48 8D 05 9A 81 5F 00        lea     rax, aVelocityOffset; "Velocity Offset"
00007FF91DFF321E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3222  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3226  48 8D 87 70 13 01 00        lea     rax, [rdi+11370h]
00007FF91DFF322D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3234  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3238  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF323C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3241  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3248  E8 B3 87 01 00              call    sub_7FF91E00BA00
00007FF91DFF324D  66 0F 6F 05 DB 8D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3255  48 8D 05 04 80 5F 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFF325C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3260  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3264  48 8D 87 80 13 01 00        lea     rax, [rdi+11380h]
00007FF91DFF326B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3272  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3276  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF327A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF327F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3286  E8 75 87 01 00              call    sub_7FF91E00BA00
00007FF91DFF328B  66 0F 6F 05 9D 8D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3293  48 8D 05 D6 7F 5F 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFF329A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF329E  48 8D 87 90 13 01 00        lea     rax, [rdi+11390h]
00007FF91DFF32A5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF32A9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF32B0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF32B5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF32BC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF32C0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF32C4  E8 37 87 01 00              call    sub_7FF91E00BA00
00007FF91DFF32C9  66 0F 6F 05 5F 8D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF32D1  48 8D 05 F0 80 5F 00        lea     rax, aCutoffTune; "Cutoff Tune"
00007FF91DFF32D8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF32DC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF32E0  48 8D 87 10 14 01 00        lea     rax, [rdi+11410h]
00007FF91DFF32E7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF32EE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF32F2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF32F6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF32FB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3302  E8 F9 86 01 00              call    sub_7FF91E00BA00
00007FF91DFF3307  66 0F 6F 05 21 8D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF330F  48 8D 05 C2 80 5F 00        lea     rax, aResonanceTune; "Resonance Tune"
00007FF91DFF3316  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF331A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF331E  48 8D 87 20 14 01 00        lea     rax, [rdi+11420h]
00007FF91DFF3325  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF332C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3330  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3334  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3339  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3340  E8 BB 86 01 00              call    sub_7FF91E00BA00
00007FF91DFF3345  48 8D 05 9C 80 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFF334C  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFF3353  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3357  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF335B  48 8D 87 30 14 01 00        lea     rax, [rdi+11430h]
00007FF91DFF3362  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3369  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF336C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3370  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3374  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3379  E8 82 86 01 00              call    sub_7FF91E00BA00
00007FF91DFF337E  48 8D 05 63 80 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFF3385  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFF338C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3390  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3394  48 8D 87 C0 19 01 00        lea     rax, [rdi+119C0h]
00007FF91DFF339B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF33A2  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF33A5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF33A9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF33AD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF33B2  E8 49 86 01 00              call    sub_7FF91E00BA00
00007FF91DFF33B7  66 0F 6F 05 71 8C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF33BF  48 8D 05 32 80 5F 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
00007FF91DFF33C6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF33CA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF33CE  48 8D 87 D0 19 01 00        lea     rax, [rdi+119D0h]
00007FF91DFF33D5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF33DC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF33E0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF33E4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF33E9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF33F0  E8 0B 86 01 00              call    sub_7FF91E00BA00
00007FF91DFF33F5  66 0F 6F 05 33 8C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF33FD  48 8D 05 04 80 5F 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
00007FF91DFF3404  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3408  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF340C  48 8D 87 E0 19 01 00        lea     rax, [rdi+119E0h]
00007FF91DFF3413  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF341A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF341E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3422  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3427  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF342E  E8 CD 85 01 00              call    sub_7FF91E00BA00
00007FF91DFF3433  66 0F 6F 05 F5 8B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF343B  48 8D 05 D6 7F 5F 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
00007FF91DFF3442  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3446  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF344A  48 8D 87 F0 19 01 00        lea     rax, [rdi+119F0h]
00007FF91DFF3451  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3458  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF345C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3460  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3465  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF346C  E8 8F 85 01 00              call    sub_7FF91E00BA00
00007FF91DFF3471  48 8D 05 B0 7F 5F 00        lea     rax, aAmpTone; "AMP TONE"
00007FF91DFF3478  66 0F 6F 05 B0 8B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3480  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3484  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3488  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF348C  48 8D 87 D0 1B 01 00        lea     rax, [rdi+11BD0h]
00007FF91DFF3493  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF349A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF349E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF34A3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF34AA  E8 51 85 01 00              call    sub_7FF91E00BA00
00007FF91DFF34AF  66 0F 6F 05 79 8B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF34B7  48 8D 05 7A 7F 5F 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
00007FF91DFF34BE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF34C2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF34C6  48 8D 87 E0 1B 01 00        lea     rax, [rdi+11BE0h]
00007FF91DFF34CD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF34D4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF34D8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF34DC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF34E1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF34E8  E8 13 85 01 00              call    sub_7FF91E00BA00
00007FF91DFF34ED  66 0F 6F 05 3B 8B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF34F5  48 8D 05 54 7F 5F 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
00007FF91DFF34FC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3500  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3504  48 8D 87 F0 1B 01 00        lea     rax, [rdi+11BF0h]
00007FF91DFF350B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3512  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3516  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF351A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF351F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3526  E8 D5 84 01 00              call    sub_7FF91E00BA00
00007FF91DFF352B  48 8D 05 FE 7D 5F 00        lea     rax, aVelocity; "Velocity"
00007FF91DFF3532  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3539  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF353D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3541  48 8D 87 30 1C 01 00        lea     rax, [rdi+11C30h]
00007FF91DFF3548  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF354F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3552  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3556  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF355A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF355F  E8 9C 84 01 00              call    sub_7FF91E00BA00
00007FF91DFF3564  48 8D 05 FD 7E 5F 00        lea     rax, aMute; "Mute"
00007FF91DFF356B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3572  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3576  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF357A  48 8D 87 C0 1C 01 00        lea     rax, [rdi+11CC0h]
00007FF91DFF3581  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3588  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF358B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF358F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3593  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3598  E8 63 84 01 00              call    sub_7FF91E00BA00
00007FF91DFF359D  48 8D 05 CC 7E 5F 00        lea     rax, aGateSw; "Gate SW"
00007FF91DFF35A4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF35AB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF35AF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF35B3  48 8D 87 20 1E 01 00        lea     rax, [rdi+11E20h]
00007FF91DFF35BA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF35C1  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF35C4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF35C8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF35CC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF35D1  E8 2A 84 01 00              call    sub_7FF91E00BA00
00007FF91DFF35D6  48 8D 05 9B 7E 5F 00        lea     rax, aEnv1Sw; "ENV1 SW"
00007FF91DFF35DD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF35E4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF35E8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF35EC  48 8D 87 30 1E 01 00        lea     rax, [rdi+11E30h]
00007FF91DFF35F3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF35FA  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF35FD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3601  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3605  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF360A  E8 F1 83 01 00              call    sub_7FF91E00BA00
00007FF91DFF360F  48 8D 05 6A 7E 5F 00        lea     rax, aEnv2Sw; "ENV2 SW"
00007FF91DFF3616  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF361D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3620  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3624  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3629  48 8D 87 40 1E 01 00        lea     rax, [rdi+11E40h]
00007FF91DFF3630  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3637  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF363B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF363F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3643  E8 B8 83 01 00              call    sub_7FF91E00BA00
00007FF91DFF3648  48 8D 05 39 7E 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
00007FF91DFF364F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3656  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF365A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF365E  48 8D 87 50 1E 01 00        lea     rax, [rdi+11E50h]
00007FF91DFF3665  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF366C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF366F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3673  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3677  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF367C  E8 7F 83 01 00              call    sub_7FF91E00BA00
00007FF91DFF3681  66 0F 6F 05 A7 89 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3689  48 8D 05 08 7E 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
00007FF91DFF3690  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3694  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3698  48 8D 87 60 1E 01 00        lea     rax, [rdi+11E60h]
00007FF91DFF369F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF36A6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF36AA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF36AE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF36B3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF36BA  E8 41 83 01 00              call    sub_7FF91E00BA00
00007FF91DFF36BF  66 0F 6F 05 69 89 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF36C7  48 8D 05 DA 7D 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
00007FF91DFF36CE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF36D2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF36D6  48 8D 87 70 1E 01 00        lea     rax, [rdi+11E70h]
00007FF91DFF36DD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF36E4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF36E8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF36EC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF36F1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF36F8  E8 03 83 01 00              call    sub_7FF91E00BA00
00007FF91DFF36FD  66 0F 6F 05 2B 89 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3705  48 8D 05 AC 7D 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
00007FF91DFF370C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3710  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3714  48 8D 87 80 1E 01 00        lea     rax, [rdi+11E80h]
00007FF91DFF371B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3722  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3726  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF372A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF372F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3736  E8 C5 82 01 00              call    sub_7FF91E00BA00
00007FF91DFF373B  66 0F 6F 05 ED 88 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3743  48 8D 05 7E 7D 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
00007FF91DFF374A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF374E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3752  48 8D 87 90 1E 01 00        lea     rax, [rdi+11E90h]
00007FF91DFF3759  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3760  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3764  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3768  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF376D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3774  E8 87 82 01 00              call    sub_7FF91E00BA00
00007FF91DFF3779  66 0F 6F 05 AF 88 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3781  48 8D 05 58 7D 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
00007FF91DFF3788  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF378C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3790  48 8D 87 A0 1E 01 00        lea     rax, [rdi+11EA0h]
00007FF91DFF3797  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF379E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF37A2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF37A6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF37AB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF37B2  E8 49 82 01 00              call    sub_7FF91E00BA00
00007FF91DFF37B7  66 0F 6F 05 71 88 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF37BF  48 8D 05 2A 7D 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
00007FF91DFF37C6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF37CA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF37CE  48 8D 87 B0 1E 01 00        lea     rax, [rdi+11EB0h]
00007FF91DFF37D5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF37DC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF37E0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF37E5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF37EC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF37F0  E8 0B 82 01 00              call    sub_7FF91E00BA00
00007FF91DFF37F5  48 8D 05 24 77 5F 00        lea     rax, aUseextjack; "UseExtJack"
00007FF91DFF37FC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3803  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3807  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF380B  48 8D 87 80 20 01 00        lea     rax, [rdi+12080h]
00007FF91DFF3812  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3819  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF381C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3820  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3824  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3829  E8 D2 81 01 00              call    sub_7FF91E00BA00
00007FF91DFF382E  48 8D 05 F7 76 5F 00        lea     rax, aMCv; "M.CV"
00007FF91DFF3835  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF383C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3840  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3844  48 8D 87 A0 20 01 00        lea     rax, [rdi+120A0h]
00007FF91DFF384B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3852  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3855  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3859  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF385D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3862  E8 99 81 01 00              call    sub_7FF91E00BA00
00007FF91DFF3867  48 8D 05 C6 76 5F 00        lea     rax, aMGate; "M.Gate"
00007FF91DFF386E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3875  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3879  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF387D  48 8D 87 B0 20 01 00        lea     rax, [rdi+120B0h]
00007FF91DFF3884  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF388B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF388E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3892  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3896  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF389B  E8 60 81 01 00              call    sub_7FF91E00BA00
00007FF91DFF38A0  66 0F 6F 05 88 87 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF38A8  48 8D 05 91 76 5F 00        lea     rax, aMasterTune; "Master Tune"
00007FF91DFF38AF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF38B3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF38B7  48 8D 87 E0 20 01 00        lea     rax, [rdi+120E0h]
00007FF91DFF38BE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF38C5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF38C9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF38CD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF38D2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF38D9  E8 22 81 01 00              call    sub_7FF91E00BA00
00007FF91DFF38DE  66 0F 6F 05 4A 87 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF38E6  48 8D 05 63 76 5F 00        lea     rax, aPartTune; "Part Tune"
00007FF91DFF38ED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF38F1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF38F5  48 8D 87 F0 20 01 00        lea     rax, [rdi+120F0h]
00007FF91DFF38FC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3903  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3907  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF390B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3910  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3917  E8 E4 80 01 00              call    sub_7FF91E00BA00
00007FF91DFF391C  48 8D 05 3D 76 5F 00        lea     rax, aPortamentoOnof; "Portamento OnOff"
00007FF91DFF3923  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF392A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF392E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3932  48 8D 87 C0 21 01 00        lea     rax, [rdi+121C0h]
00007FF91DFF3939  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3940  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3943  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3947  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF394B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3950  E8 AB 80 01 00              call    sub_7FF91E00BA00
00007FF91DFF3955  48 8D 05 1C 76 5F 00        lea     rax, aPortamentoMode; "Portamento Mode"
00007FF91DFF395C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3963  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3967  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF396B  48 8D 87 D0 21 01 00        lea     rax, [rdi+121D0h]
00007FF91DFF3972  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3979  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF397C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3980  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3984  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3989  E8 72 80 01 00              call    sub_7FF91E00BA00
00007FF91DFF398E  48 8D 05 F3 75 5F 00        lea     rax, aPortamentoTime; "Portamento Time"
00007FF91DFF3995  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3999  66 0F 6F 05 8F 86 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF39A1  48 8D 87 E0 21 01 00        lea     rax, [rdi+121E0h]
00007FF91DFF39A8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF39AC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF39B0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF39B4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF39BB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF39C0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF39C7  E8 34 80 01 00              call    sub_7FF91E00BA00
00007FF91DFF39CC  48 8D 05 C5 75 5F 00        lea     rax, aLfoGrifferRate; "LFO Griffer Rate Sw"
00007FF91DFF39D3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF39DA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF39DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF39E2  48 8D 87 80 23 01 00        lea     rax, [rdi+12380h]
00007FF91DFF39E9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF39F0  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF39F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF39F7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF39FB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3A00  E8 FB 7F 01 00              call    sub_7FF91E00BA00
00007FF91DFF3A05  48 8D 05 A4 75 5F 00        lea     rax, aLfoTempoRateSw; "LFO Tempo Rate Sw"
00007FF91DFF3A0C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3A13  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3A17  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3A1B  48 8D 87 90 23 01 00        lea     rax, [rdi+12390h]
00007FF91DFF3A22  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3A29  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3A2C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3A30  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3A34  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3A39  E8 C2 7F 01 00              call    sub_7FF91E00BA00
00007FF91DFF3A3E  48 8D 05 83 75 5F 00        lea     rax, aLfoTempoRate; "LFO Tempo Rate"
00007FF91DFF3A45  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3A4C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3A50  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3A54  48 8D 87 A0 23 01 00        lea     rax, [rdi+123A0h]
00007FF91DFF3A5B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3A62  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3A65  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3A69  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3A6D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3A72  E8 89 7F 01 00              call    sub_7FF91E00BA00
00007FF91DFF3A77  66 0F 6F 05 B1 85 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3A7F  48 8D 05 52 75 5F 00        lea     rax, aLfoRate; "LFO Rate"
00007FF91DFF3A86  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3A8A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3A8E  48 8D 87 B0 23 01 00        lea     rax, [rdi+123B0h]
00007FF91DFF3A95  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3A9C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3AA0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3AA4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3AA9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3AB0  E8 4B 7F 01 00              call    sub_7FF91E00BA00
00007FF91DFF3AB5  48 8D 05 28 75 5F 00        lea     rax, aGate; "Gate"
00007FF91DFF3ABC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3AC3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3AC7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3ACB  48 8D 87 B0 26 01 00        lea     rax, [rdi+126B0h]
00007FF91DFF3AD2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3AD9  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3ADC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3AE0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3AE4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3AE9  E8 12 7F 01 00              call    sub_7FF91E00BA00
00007FF91DFF3AEE  48 8D 05 FB 74 5F 00        lea     rax, aLfoTrig; "LFO Trig"
00007FF91DFF3AF5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3AFC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3B00  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3B04  48 8D 87 C0 26 01 00        lea     rax, [rdi+126C0h]
00007FF91DFF3B0B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3B12  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3B15  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3B19  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3B1D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3B22  E8 D9 7E 01 00              call    sub_7FF91E00BA00
00007FF91DFF3B27  48 8D 05 D2 74 5F 00        lea     rax, aResetSw; "Reset Sw"
00007FF91DFF3B2E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3B35  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3B38  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3B3C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3B41  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3B48  48 8D 87 D0 26 01 00        lea     rax, [rdi+126D0h]
00007FF91DFF3B4F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3B53  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3B57  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3B5B  E8 A0 7E 01 00              call    sub_7FF91E00BA00
00007FF91DFF3B60  66 0F 6F 05 C8 84 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3B68  48 8D 05 A1 74 5F 00        lea     rax, aLfoUseextgate; "LFO UseExtGate"
00007FF91DFF3B6F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3B73  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3B77  48 8D 87 E0 26 01 00        lea     rax, [rdi+126E0h]
00007FF91DFF3B7E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3B85  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3B89  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3B8D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3B92  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3B99  E8 62 7E 01 00              call    sub_7FF91E00BA00
00007FF91DFF3B9E  66 0F 6F 05 8A 84 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3BA6  48 8D 05 73 74 5F 00        lea     rax, aLfoDelay; "LFO Delay"
00007FF91DFF3BAD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3BB1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3BB5  48 8D 87 F0 26 01 00        lea     rax, [rdi+126F0h]
00007FF91DFF3BBC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3BC3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3BC7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3BCB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3BD0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3BD7  E8 24 7E 01 00              call    sub_7FF91E00BA00
00007FF91DFF3BDC  66 0F 6F 05 4C 84 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3BE4  48 8D 05 45 74 5F 00        lea     rax, aLfoDelaySw; "LFO Delay Sw"
00007FF91DFF3BEB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3BEF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3BF3  48 8D 87 00 27 01 00        lea     rax, [rdi+12700h]
00007FF91DFF3BFA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3C01  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3C05  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3C09  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3C0E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3C15  E8 E6 7D 01 00              call    sub_7FF91E00BA00
00007FF91DFF3C1A  66 0F 6F 05 0E 84 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3C22  48 8D 05 17 74 5F 00        lea     rax, aLfoSinSw; "LFO Sin Sw"
00007FF91DFF3C29  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3C2D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3C31  48 8D 87 10 27 01 00        lea     rax, [rdi+12710h]
00007FF91DFF3C38  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3C3F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3C43  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3C47  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3C4C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3C53  E8 A8 7D 01 00              call    sub_7FF91E00BA00
00007FF91DFF3C58  66 0F 6F 05 D0 83 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3C60  48 8D 05 E9 73 5F 00        lea     rax, aLfoTriSw; "LFO Tri Sw"
00007FF91DFF3C67  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3C6B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3C6F  48 8D 87 20 27 01 00        lea     rax, [rdi+12720h]
00007FF91DFF3C76  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3C7D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3C81  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3C85  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3C8A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3C91  E8 6A 7D 01 00              call    sub_7FF91E00BA00
00007FF91DFF3C96  66 0F 6F 05 92 83 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3C9E  48 8D 05 BB 73 5F 00        lea     rax, aLfoSqrSw; "LFO Sqr Sw"
00007FF91DFF3CA5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3CA9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3CAD  48 8D 87 30 27 01 00        lea     rax, [rdi+12730h]
00007FF91DFF3CB4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3CBB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3CBF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3CC3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3CC8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3CCF  E8 2C 7D 01 00              call    sub_7FF91E00BA00
00007FF91DFF3CD4  66 0F 6F 05 54 83 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3CDC  48 8D 05 8D 73 5F 00        lea     rax, aLfoSawSw; "LFO Saw Sw"
00007FF91DFF3CE3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3CE7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3CEB  48 8D 87 40 27 01 00        lea     rax, [rdi+12740h]
00007FF91DFF3CF2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3CF9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3CFD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3D01  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3D06  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3D0D  E8 EE 7C 01 00              call    sub_7FF91E00BA00
00007FF91DFF3D12  66 0F 6F 05 16 83 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3D1A  48 8D 05 5F 73 5F 00        lea     rax, aLfoSawInvSw; "LFO Saw(Inv) Sw"
00007FF91DFF3D21  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3D25  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3D29  48 8D 87 50 27 01 00        lea     rax, [rdi+12750h]
00007FF91DFF3D30  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3D37  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3D3B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3D3F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3D44  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3D4B  E8 B0 7C 01 00              call    sub_7FF91E00BA00
00007FF91DFF3D50  66 0F 6F 05 D8 82 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3D58  48 8D 05 31 73 5F 00        lea     rax, aLfoSHSw; "LFO S&H Sw"
00007FF91DFF3D5F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3D63  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3D67  48 8D 87 60 27 01 00        lea     rax, [rdi+12760h]
00007FF91DFF3D6E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3D75  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3D79  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3D7D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3D82  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3D89  E8 72 7C 01 00              call    sub_7FF91E00BA00
00007FF91DFF3D8E  66 0F 6F 05 9A 82 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3D96  48 8D 05 03 73 5F 00        lea     rax, aLfoNoiseSw; "LFO Noise Sw"
00007FF91DFF3D9D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3DA1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3DA5  48 8D 87 70 27 01 00        lea     rax, [rdi+12770h]
00007FF91DFF3DAC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3DB3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3DB7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3DBB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3DC0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3DC7  E8 34 7C 01 00              call    sub_7FF91E00BA00
00007FF91DFF3DCC  66 0F 6F 05 5C 82 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3DD4  48 8D 05 D5 72 5F 00        lea     rax, aLfoNoiseMix; "LFO Noise Mix"
00007FF91DFF3DDB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3DDF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3DE3  48 8D 87 80 27 01 00        lea     rax, [rdi+12780h]
00007FF91DFF3DEA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3DF1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3DF5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3DF9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3DFE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3E05  E8 F6 7B 01 00              call    sub_7FF91E00BA00
00007FF91DFF3E0A  66 0F 6F 05 1E 82 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3E12  48 8D 05 A7 72 5F 00        lea     rax, aLfoInternalSw; "LFO Internal Sw"
00007FF91DFF3E19  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3E1D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3E21  48 8D 87 90 27 01 00        lea     rax, [rdi+12790h]
00007FF91DFF3E28  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3E2F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3E33  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3E37  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3E3C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3E43  E8 B8 7B 01 00              call    sub_7FF91E00BA00
00007FF91DFF3E48  66 0F 6F 05 E0 81 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3E50  48 8D 05 79 72 5F 00        lea     rax, aLfoExternal0Sw; "LFO External0 Sw"
00007FF91DFF3E57  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3E5B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3E5F  48 8D 87 A0 27 01 00        lea     rax, [rdi+127A0h]
00007FF91DFF3E66  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3E6D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3E71  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3E75  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3E7A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3E81  E8 7A 7B 01 00              call    sub_7FF91E00BA00
00007FF91DFF3E86  66 0F 6F 05 A2 81 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3E8E  48 8D 05 53 72 5F 00        lea     rax, aLfoExternal1Sw; "LFO External1 Sw"
00007FF91DFF3E95  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3E99  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3E9D  48 8D 87 B0 27 01 00        lea     rax, [rdi+127B0h]
00007FF91DFF3EA4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3EAB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3EAF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3EB3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3EB8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3EBF  E8 3C 7B 01 00              call    sub_7FF91E00BA00
00007FF91DFF3EC4  48 8D 05 35 72 5F 00        lea     rax, aReadOnly; "read only"
00007FF91DFF3ECB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3ED2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3ED6  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3ED9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3EE0  48 8D 87 50 29 01 00        lea     rax, [rdi+12950h]
00007FF91DFF3EE7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3EEB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3EEF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3EF3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3EF8  E8 03 7B 01 00              call    sub_7FF91E00BA00
00007FF91DFF3EFD  48 8D 05 FC 71 5F 00        lea     rax, aReadOnly; "read only"
00007FF91DFF3F04  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3F0B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3F0F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3F13  48 8D 87 60 29 01 00        lea     rax, [rdi+12960h]
00007FF91DFF3F1A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3F21  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3F24  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3F28  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3F2C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3F31  E8 CA 7A 01 00              call    sub_7FF91E00BA00
00007FF91DFF3F36  48 8D 05 D3 71 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFF3F3D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3F44  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3F48  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3F4C  48 8D 87 70 29 01 00        lea     rax, [rdi+12970h]
00007FF91DFF3F53  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3F5A  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF3F5D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3F61  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3F65  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3F6A  E8 91 7A 01 00              call    sub_7FF91E00BA00
00007FF91DFF3F6F  66 0F 6F 05 B9 80 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3F77  48 8D 05 AA 71 5F 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFF3F7E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3F82  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3F86  48 8D 87 50 2A 01 00        lea     rax, [rdi+12A50h]
00007FF91DFF3F8D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3F94  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3F98  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3F9C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3FA1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3FA8  E8 53 7A 01 00              call    sub_7FF91E00BA00
00007FF91DFF3FAD  66 0F 6F 05 7B 80 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3FB5  48 8D 05 7C 71 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFF3FBC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3FC0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF3FC4  48 8D 87 60 2A 01 00        lea     rax, [rdi+12A60h]
00007FF91DFF3FCB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF3FD2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF3FD6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF3FDA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF3FDF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF3FE6  E8 15 7A 01 00              call    sub_7FF91E00BA00
00007FF91DFF3FEB  66 0F 6F 05 3D 80 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF3FF3  48 8D 05 4E 71 5F 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFF3FFA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF3FFE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4002  48 8D 87 70 2A 01 00        lea     rax, [rdi+12A70h]
00007FF91DFF4009  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4010  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4014  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4018  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF401D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4024  E8 D7 79 01 00              call    sub_7FF91E00BA00
00007FF91DFF4029  66 0F 6F 05 FF 7F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4031  48 8D 05 20 71 5F 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFF4038  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF403C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4040  48 8D 87 80 2A 01 00        lea     rax, [rdi+12A80h]
00007FF91DFF4047  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF404E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4052  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4056  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF405B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4062  E8 99 79 01 00              call    sub_7FF91E00BA00
00007FF91DFF4067  66 0F 6F 05 C1 7F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF406F  48 8D 05 F2 70 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFF4076  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF407A  48 8D 87 90 2A 01 00        lea     rax, [rdi+12A90h]
00007FF91DFF4081  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4088  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF408D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4094  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4098  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF409C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF40A0  E8 5B 79 01 00              call    sub_7FF91E00BA00
00007FF91DFF40A5  48 8D 05 64 70 5F 00        lea     rax, aLfoTriggerEnvS; "LFO trigger env sw"
00007FF91DFF40AC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF40B3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF40B7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF40BB  48 8D 87 50 2B 01 00        lea     rax, [rdi+12B50h]
00007FF91DFF40C2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF40C9  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF40CC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF40D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF40D4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF40D9  E8 22 79 01 00              call    sub_7FF91E00BA00
00007FF91DFF40DE  66 0F 6F 05 4A 7F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF40E6  48 8D 05 3B 70 5F 00        lea     rax, aEnvAttack; "ENV Attack"
00007FF91DFF40ED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF40F1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF40F5  48 8D 87 30 2C 01 00        lea     rax, [rdi+12C30h]
00007FF91DFF40FC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4103  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4107  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF410B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4110  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4117  E8 E4 78 01 00              call    sub_7FF91E00BA00
00007FF91DFF411C  66 0F 6F 05 0C 7F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4124  48 8D 05 0D 70 5F 00        lea     rax, aEnvSustain; "ENV Sustain"
00007FF91DFF412B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF412F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4133  48 8D 87 40 2C 01 00        lea     rax, [rdi+12C40h]
00007FF91DFF413A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4141  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4145  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4149  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF414E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4155  E8 A6 78 01 00              call    sub_7FF91E00BA00
00007FF91DFF415A  66 0F 6F 05 CE 7E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4162  48 8D 05 DF 6F 5F 00        lea     rax, aEnvDecay; "ENV Decay"
00007FF91DFF4169  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF416D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4171  48 8D 87 50 2C 01 00        lea     rax, [rdi+12C50h]
00007FF91DFF4178  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF417F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4183  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4187  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF418C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4193  E8 68 78 01 00              call    sub_7FF91E00BA00
00007FF91DFF4198  66 0F 6F 05 90 7E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF41A0  48 8D 05 B1 6F 5F 00        lea     rax, aEnvRelease; "ENV Release"
00007FF91DFF41A7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF41AB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF41AF  48 8D 87 60 2C 01 00        lea     rax, [rdi+12C60h]
00007FF91DFF41B6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF41BD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF41C1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF41C5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF41CA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF41D1  E8 2A 78 01 00              call    sub_7FF91E00BA00
00007FF91DFF41D6  66 0F 6F 05 52 7E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF41DE  48 8D 05 83 6F 5F 00        lea     rax, aQ24cInitialize; "Q24C Initialize"
00007FF91DFF41E5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF41E9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF41ED  48 8D 87 70 2C 01 00        lea     rax, [rdi+12C70h]
00007FF91DFF41F4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF41FB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF41FF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4203  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4208  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF420F  E8 EC 77 01 00              call    sub_7FF91E00BA00
00007FF91DFF4214  48 8D 05 5D 6F 5F 00        lea     rax, aOsc1Feet; "OSC1 Feet"
00007FF91DFF421B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4222  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4226  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF422A  48 8D 87 70 2E 01 00        lea     rax, [rdi+12E70h]
00007FF91DFF4231  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4238  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF423B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF423F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4243  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4248  E8 B3 77 01 00              call    sub_7FF91E00BA00
00007FF91DFF424D  48 8D 05 34 6F 5F 00        lea     rax, aGrifferBendSw; "Griffer Bend SW"
00007FF91DFF4254  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF425B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF425F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4263  48 8D 87 80 2E 01 00        lea     rax, [rdi+12E80h]
00007FF91DFF426A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4271  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4274  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4278  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF427C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4281  E8 7A 77 01 00              call    sub_7FF91E00BA00
00007FF91DFF4286  48 8D 05 0B 6F 5F 00        lea     rax, aBendEnableSw; "Bend Enable SW"
00007FF91DFF428D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4294  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4298  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF429C  48 8D 87 90 2E 01 00        lea     rax, [rdi+12E90h]
00007FF91DFF42A3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF42AA  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF42AD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF42B1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF42B5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF42BA  E8 41 77 01 00              call    sub_7FF91E00BA00
00007FF91DFF42BF  48 8D 05 E2 6E 5F 00        lea     rax, aPwmSwLfo; "PWM SW LFO"
00007FF91DFF42C6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF42CD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF42D1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF42D5  48 8D 87 A0 2E 01 00        lea     rax, [rdi+12EA0h]
00007FF91DFF42DC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF42E3  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF42E6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF42EA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF42EE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF42F3  E8 08 77 01 00              call    sub_7FF91E00BA00
00007FF91DFF42F8  48 8D 05 B9 6E 5F 00        lea     rax, aPwmSwEnv1; "PWM SW ENV1"
00007FF91DFF42FF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4306  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF430A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF430E  48 8D 87 B0 2E 01 00        lea     rax, [rdi+12EB0h]
00007FF91DFF4315  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF431C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF431F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4323  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4327  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF432C  E8 CF 76 01 00              call    sub_7FF91E00BA00
00007FF91DFF4331  48 8D 05 90 6E 5F 00        lea     rax, aPwmSwEnv2; "PWM SW ENV2"
00007FF91DFF4338  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF433F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4343  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4347  48 8D 87 C0 2E 01 00        lea     rax, [rdi+12EC0h]
00007FF91DFF434E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4355  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4358  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF435C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4360  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4365  E8 96 76 01 00              call    sub_7FF91E00BA00
00007FF91DFF436A  48 8D 05 67 6E 5F 00        lea     rax, aPwmSwManual; "PWM SW Manual"
00007FF91DFF4371  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4378  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF437C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4380  48 8D 87 D0 2E 01 00        lea     rax, [rdi+12ED0h]
00007FF91DFF4387  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF438E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4391  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4395  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4399  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF439E  E8 5D 76 01 00              call    sub_7FF91E00BA00
00007FF91DFF43A3  66 0F 6F 05 85 7C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF43AB  48 8D 05 36 6E 5F 00        lea     rax, aTune; "Tune"
00007FF91DFF43B2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF43B6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF43BA  48 8D 87 E0 2E 01 00        lea     rax, [rdi+12EE0h]
00007FF91DFF43C1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF43C8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF43CC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF43D0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF43D5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF43DC  E8 1F 76 01 00              call    sub_7FF91E00BA00
00007FF91DFF43E1  66 0F 6F 05 47 7C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF43E9  48 8D 05 00 6E 5F 00        lea     rax, aDetune; "Detune"
00007FF91DFF43F0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF43F4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF43FB  48 8D 87 F0 2E 01 00        lea     rax, [rdi+12EF0h]
00007FF91DFF4402  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4409  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF440D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4411  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4415  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF441A  E8 E1 75 01 00              call    sub_7FF91E00BA00
00007FF91DFF441F  66 0F 6F 05 09 7C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4427  48 8D 05 CA 6D 5F 00        lea     rax, aModSens; "Mod Sens"
00007FF91DFF442E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4432  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4436  48 8D 87 00 2F 01 00        lea     rax, [rdi+12F00h]
00007FF91DFF443D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4444  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4448  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF444C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4451  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4458  E8 A3 75 01 00              call    sub_7FF91E00BA00
00007FF91DFF445D  66 0F 6F 05 CB 7B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4465  48 8D 05 98 6D 5F 00        lea     rax, aModSw; "Mod Sw"
00007FF91DFF446C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4470  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4474  48 8D 87 10 2F 01 00        lea     rax, [rdi+12F10h]
00007FF91DFF447B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4482  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4486  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF448A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF448F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4496  E8 65 75 01 00              call    sub_7FF91E00BA00
00007FF91DFF449B  66 0F 6F 05 8D 7B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF44A3  48 8D 05 66 6D 5F 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFF44AA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF44AE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF44B2  48 8D 87 20 2F 01 00        lea     rax, [rdi+12F20h]
00007FF91DFF44B9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF44C0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF44C4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF44C8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF44CD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF44D4  E8 27 75 01 00              call    sub_7FF91E00BA00
00007FF91DFF44D9  66 0F 6F 05 4F 7B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF44E1  48 8D 05 38 6D 5F 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFF44E8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF44EC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF44F0  48 8D 87 30 2F 01 00        lea     rax, [rdi+12F30h]
00007FF91DFF44F7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF44FE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4502  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4506  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF450B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4512  E8 E9 74 01 00              call    sub_7FF91E00BA00
00007FF91DFF4517  66 0F 6F 05 11 7B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF451F  48 8D 05 06 6D 5F 00        lea     rax, aLfoSw; "LFO Sw"
00007FF91DFF4526  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF452A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF452E  48 8D 87 40 2F 01 00        lea     rax, [rdi+12F40h]
00007FF91DFF4535  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF453C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4540  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4544  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4549  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4550  E8 AB 74 01 00              call    sub_7FF91E00BA00
00007FF91DFF4555  66 0F 6F 05 D3 7A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF455D  48 8D 05 D4 6C 5F 00        lea     rax, aEnv1Level; "ENV1 Level"
00007FF91DFF4564  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4568  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF456C  48 8D 87 50 2F 01 00        lea     rax, [rdi+12F50h]
00007FF91DFF4573  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF457A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF457E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4582  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4587  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF458E  E8 6D 74 01 00              call    sub_7FF91E00BA00
00007FF91DFF4593  66 0F 6F 05 95 7A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF459B  48 8D 05 A6 6C 5F 00        lea     rax, aEnv2Level; "ENV2 Level"
00007FF91DFF45A2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF45A6  48 8D 87 60 2F 01 00        lea     rax, [rdi+12F60h]
00007FF91DFF45AD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF45B1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF45B8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF45BD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF45C4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF45C8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF45CC  E8 2F 74 01 00              call    sub_7FF91E00BA00
00007FF91DFF45D1  66 0F 6F 05 57 7A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF45D9  48 8D 05 74 6C 5F 00        lea     rax, aEnvSw; "ENV Sw"
00007FF91DFF45E0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF45E4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF45E8  48 8D 87 70 2F 01 00        lea     rax, [rdi+12F70h]
00007FF91DFF45EF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF45F6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF45FA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF45FE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4603  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF460A  E8 F1 73 01 00              call    sub_7FF91E00BA00
00007FF91DFF460F  66 0F 6F 05 19 7A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4617  48 8D 05 42 6C 5F 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFF461E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4622  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4626  48 8D 87 80 2F 01 00        lea     rax, [rdi+12F80h]
00007FF91DFF462D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4634  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4638  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF463C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4641  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4648  E8 B3 73 01 00              call    sub_7FF91E00BA00
00007FF91DFF464D  66 0F 6F 05 DB 79 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4655  48 8D 05 14 6C 5F 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFF465C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4660  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4664  48 8D 87 90 2F 01 00        lea     rax, [rdi+12F90h]
00007FF91DFF466B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4672  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4676  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF467A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF467F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4686  E8 75 73 01 00              call    sub_7FF91E00BA00
00007FF91DFF468B  66 0F 6F 05 9D 79 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4693  48 8D 05 E6 6B 5F 00        lea     rax, aPwmLevel; "PWM Level"
00007FF91DFF469A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF469E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF46A2  48 8D 87 A0 2F 01 00        lea     rax, [rdi+12FA0h]
00007FF91DFF46A9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF46B0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF46B4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF46B8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF46BD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF46C4  E8 37 73 01 00              call    sub_7FF91E00BA00
00007FF91DFF46C9  66 0F 6F 05 5F 79 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF46D1  48 8D 05 B8 6B 5F 00        lea     rax, aJuOscSawLev; "JU OSC Saw Lev"
00007FF91DFF46D8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF46DC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF46E0  48 8D 87 D0 2F 01 00        lea     rax, [rdi+12FD0h]
00007FF91DFF46E7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF46EE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF46F2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF46F6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF46FB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4702  E8 F9 72 01 00              call    sub_7FF91E00BA00
00007FF91DFF4707  66 0F 6F 05 21 79 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF470F  48 8D 05 8A 6B 5F 00        lea     rax, aJuOscSqrLev; "JU OSC Sqr Lev"
00007FF91DFF4716  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF471A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF471E  48 8D 87 E0 2F 01 00        lea     rax, [rdi+12FE0h]
00007FF91DFF4725  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF472C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4730  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4734  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4739  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4740  E8 BB 72 01 00              call    sub_7FF91E00BA00
00007FF91DFF4745  66 0F 6F 05 E3 78 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF474D  48 8D 05 5C 6B 5F 00        lea     rax, aJuOscSubLev; "JU OSC Sub Lev"
00007FF91DFF4754  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4758  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF475C  48 8D 87 F0 2F 01 00        lea     rax, [rdi+12FF0h]
00007FF91DFF4763  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF476A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF476E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4772  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4777  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF477E  E8 7D 72 01 00              call    sub_7FF91E00BA00
00007FF91DFF4783  48 8D 05 36 6B 5F 00        lea     rax, aDutyTune; "Duty Tune"
00007FF91DFF478A  66 0F 6F 05 9E 78 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4792  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4796  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF479A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF479E  48 8D 87 00 35 01 00        lea     rax, [rdi+13500h]
00007FF91DFF47A5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF47AC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF47B0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF47B5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF47BC  E8 3F 72 01 00              call    sub_7FF91E00BA00
00007FF91DFF47C1  66 0F 6F 05 67 78 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF47C9  48 8D 05 00 6B 5F 00        lea     rax, aOsc1Mute; "Osc1 Mute"
00007FF91DFF47D0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF47D4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF47D8  48 8D 87 A0 38 01 00        lea     rax, [rdi+138A0h]
00007FF91DFF47DF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF47E6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF47EA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF47EE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF47F3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF47FA  E8 01 72 01 00              call    sub_7FF91E00BA00
00007FF91DFF47FF  66 0F 6F 05 29 78 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4807  48 8D 05 D2 6A 5F 00        lea     rax, aOsc1Level; "Osc1 Level"
00007FF91DFF480E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4812  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4816  48 8D 87 E0 38 01 00        lea     rax, [rdi+138E0h]
00007FF91DFF481D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4824  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4828  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF482C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4831  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4838  E8 C3 71 01 00              call    sub_7FF91E00BA00
00007FF91DFF483D  66 0F 6F 05 EB 77 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4845  48 8D 05 A4 6A 5F 00        lea     rax, aOscNoiseLevel; "Osc Noise Level"
00007FF91DFF484C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4850  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4854  48 8D 87 F0 38 01 00        lea     rax, [rdi+138F0h]
00007FF91DFF485B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4862  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4866  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF486A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF486F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4876  E8 85 71 01 00              call    sub_7FF91E00BA00
00007FF91DFF487B  48 8D 05 7E 6A 5F 00        lea     rax, aGrifferSw; "Griffer SW"
00007FF91DFF4882  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4889  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF488D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4891  48 8D 87 B0 39 01 00        lea     rax, [rdi+139B0h]
00007FF91DFF4898  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF489F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF48A2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF48A6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF48AA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF48AF  E8 4C 71 01 00              call    sub_7FF91E00BA00
00007FF91DFF48B4  66 0F 6F 05 74 77 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF48BC  48 8D 05 4D 6A 5F 00        lea     rax, aLpfCutoff; "LPF Cutoff"
00007FF91DFF48C3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF48C7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF48CB  48 8D 87 C0 39 01 00        lea     rax, [rdi+139C0h]
00007FF91DFF48D2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF48D9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF48DD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF48E1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF48E6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF48ED  E8 0E 71 01 00              call    sub_7FF91E00BA00
00007FF91DFF48F2  66 0F 6F 05 36 77 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF48FA  48 8D 05 1F 6A 5F 00        lea     rax, aLpfResonance; "LPF Resonance"
00007FF91DFF4901  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4905  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4909  48 8D 87 20 3A 01 00        lea     rax, [rdi+13A20h]
00007FF91DFF4910  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4917  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF491B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF491F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4924  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF492B  E8 D0 70 01 00              call    sub_7FF91E00BA00
00007FF91DFF4930  48 8D 05 F9 69 5F 00        lea     rax, aVelocity; "Velocity"
00007FF91DFF4937  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF493E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4941  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4945  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF494A  48 8D 87 40 3A 01 00        lea     rax, [rdi+13A40h]
00007FF91DFF4951  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4958  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF495C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4960  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4964  E8 97 70 01 00              call    sub_7FF91E00BA00
00007FF91DFF4969  48 8D 05 CC 69 5F 00        lea     rax, aEnv12; "Env1/2"
00007FF91DFF4970  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4977  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF497B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF497F  48 8D 87 D0 3A 01 00        lea     rax, [rdi+13AD0h]
00007FF91DFF4986  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF498D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4990  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4994  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4998  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF499D  E8 5E 70 01 00              call    sub_7FF91E00BA00
00007FF91DFF49A2  48 8D 05 9F 69 5F 00        lea     rax, aIntEnv; "Int/Env"
00007FF91DFF49A9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF49B0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF49B4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF49B8  48 8D 87 E0 3A 01 00        lea     rax, [rdi+13AE0h]
00007FF91DFF49BF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF49C6  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF49C9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF49CD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF49D1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF49D6  E8 25 70 01 00              call    sub_7FF91E00BA00
00007FF91DFF49DB  48 8D 05 2E 68 5F 00        lea     rax, aLfoGain; "LFO Gain"
00007FF91DFF49E2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF49E9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF49ED  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF49F1  48 8D 87 F0 3B 01 00        lea     rax, [rdi+13BF0h]
00007FF91DFF49F8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF49FF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4A02  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4A06  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4A0A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4A0F  E8 EC 6F 01 00              call    sub_7FF91E00BA00
00007FF91DFF4A14  48 8D 05 35 69 5F 00        lea     rax, aExtLfoSw; "Ext LFO Sw"
00007FF91DFF4A1B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4A22  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4A26  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4A2A  48 8D 87 00 3C 01 00        lea     rax, [rdi+13C00h]
00007FF91DFF4A31  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4A38  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4A3B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4A3F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4A43  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4A48  E8 B3 6F 01 00              call    sub_7FF91E00BA00
00007FF91DFF4A4D  48 8D 05 0C 69 5F 00        lea     rax, aGrfBnedSw; "GRF Bned SW"
00007FF91DFF4A54  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4A5B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4A5F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4A63  48 8D 87 10 3C 01 00        lea     rax, [rdi+13C10h]
00007FF91DFF4A6A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4A71  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4A74  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4A78  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4A7C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4A81  E8 7A 6F 01 00              call    sub_7FF91E00BA00
00007FF91DFF4A86  66 0F 6F 05 A2 75 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4A8E  48 8D 05 8B 67 5F 00        lea     rax, aLfoLevel; "LFO Level"
00007FF91DFF4A95  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4A99  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4A9D  48 8D 87 20 3C 01 00        lea     rax, [rdi+13C20h]
00007FF91DFF4AA4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4AAB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4AAF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4AB3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4AB8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4ABF  E8 3C 6F 01 00              call    sub_7FF91E00BA00
00007FF91DFF4AC4  66 0F 6F 05 64 75 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4ACC  48 8D 05 9D 68 5F 00        lea     rax, aModSens_0; "MOD Sens"
00007FF91DFF4AD3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4AD7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4ADB  48 8D 87 30 3C 01 00        lea     rax, [rdi+13C30h]
00007FF91DFF4AE2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4AE9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4AED  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4AF2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4AF9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4AFD  E8 FE 6E 01 00              call    sub_7FF91E00BA00
00007FF91DFF4B02  66 0F 6F 05 26 75 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4B0A  48 8D 05 6B 68 5F 00        lea     rax, aModSw_0; "MOD SW"
00007FF91DFF4B11  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4B15  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4B19  48 8D 87 40 3C 01 00        lea     rax, [rdi+13C40h]
00007FF91DFF4B20  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4B27  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4B2B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4B2F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4B34  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4B3B  E8 C0 6E 01 00              call    sub_7FF91E00BA00
00007FF91DFF4B40  66 0F 6F 05 E8 74 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4B48  48 8D 05 39 68 5F 00        lea     rax, aEnvLevel; "ENV Level"
00007FF91DFF4B4F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4B53  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4B57  48 8D 87 50 3C 01 00        lea     rax, [rdi+13C50h]
00007FF91DFF4B5E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4B65  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4B69  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4B6D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4B72  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4B79  E8 82 6E 01 00              call    sub_7FF91E00BA00
00007FF91DFF4B7E  66 0F 6F 05 AA 74 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4B86  48 8D 05 0B 68 5F 00        lea     rax, aKcvLevel; "KCV Level"
00007FF91DFF4B8D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4B91  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4B95  48 8D 87 60 3C 01 00        lea     rax, [rdi+13C60h]
00007FF91DFF4B9C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4BA3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4BA7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4BAB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4BB0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4BB7  E8 44 6E 01 00              call    sub_7FF91E00BA00
00007FF91DFF4BBC  66 0F 6F 05 6C 74 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4BC4  48 8D 05 DD 67 5F 00        lea     rax, aVelocitySens; "Velocity Sens"
00007FF91DFF4BCB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4BCF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4BD3  48 8D 87 70 3C 01 00        lea     rax, [rdi+13C70h]
00007FF91DFF4BDA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4BE1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4BE5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4BE9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4BEE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4BF5  E8 06 6E 01 00              call    sub_7FF91E00BA00
00007FF91DFF4BFA  66 0F 6F 05 2E 74 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4C02  48 8D 05 AF 67 5F 00        lea     rax, aVelocityOffset; "Velocity Offset"
00007FF91DFF4C09  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4C0D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4C11  48 8D 87 80 3C 01 00        lea     rax, [rdi+13C80h]
00007FF91DFF4C18  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4C1F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4C23  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4C27  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4C2C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4C33  E8 C8 6D 01 00              call    sub_7FF91E00BA00
00007FF91DFF4C38  66 0F 6F 05 F0 73 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4C40  48 8D 05 19 66 5F 00        lea     rax, aBendLevel; "Bend Level"
00007FF91DFF4C47  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4C4B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4C4F  48 8D 87 90 3C 01 00        lea     rax, [rdi+13C90h]
00007FF91DFF4C56  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4C5D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4C61  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4C65  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4C6A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4C71  E8 8A 6D 01 00              call    sub_7FF91E00BA00
00007FF91DFF4C76  66 0F 6F 05 B2 73 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4C7E  48 8D 05 EB 65 5F 00        lea     rax, aBendRange; "Bend Range"
00007FF91DFF4C85  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4C89  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4C8D  48 8D 87 A0 3C 01 00        lea     rax, [rdi+13CA0h]
00007FF91DFF4C94  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4C9B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4C9F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4CA3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4CA8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4CAF  E8 4C 6D 01 00              call    sub_7FF91E00BA00
00007FF91DFF4CB4  48 8D 05 0D 67 5F 00        lea     rax, aCutoffTune; "Cutoff Tune"
00007FF91DFF4CBB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4CBF  66 0F 6F 05 69 73 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4CC7  48 8D 87 20 3D 01 00        lea     rax, [rdi+13D20h]
00007FF91DFF4CCE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4CD2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4CD6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4CDA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4CE1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4CE6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4CED  E8 0E 6D 01 00              call    sub_7FF91E00BA00
00007FF91DFF4CF2  66 0F 6F 05 36 73 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4CFA  48 8D 05 D7 66 5F 00        lea     rax, aResonanceTune; "Resonance Tune"
00007FF91DFF4D01  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4D05  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4D09  48 8D 87 30 3D 01 00        lea     rax, [rdi+13D30h]
00007FF91DFF4D10  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4D17  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4D1B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4D1F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4D24  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4D2B  E8 D0 6C 01 00              call    sub_7FF91E00BA00
00007FF91DFF4D30  48 8D 05 B1 66 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFF4D37  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFF4D3E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4D42  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4D46  48 8D 87 40 3D 01 00        lea     rax, [rdi+13D40h]
00007FF91DFF4D4D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4D54  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4D57  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4D5B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4D5F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4D64  E8 97 6C 01 00              call    sub_7FF91E00BA00
00007FF91DFF4D69  48 8D 05 78 66 5F 00        lea     rax, aPluginSw; "PlugIn Sw"
00007FF91DFF4D70  C7 45 8F 00 00 80 3F        mov     [rbp+57h+var_C8], 3F800000h
00007FF91DFF4D77  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4D7B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4D7F  48 8D 87 D0 42 01 00        lea     rax, [rdi+142D0h]
00007FF91DFF4D86  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4D8D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4D90  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4D94  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4D98  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4D9D  E8 5E 6C 01 00              call    sub_7FF91E00BA00
00007FF91DFF4DA2  66 0F 6F 05 86 72 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4DAA  48 8D 05 47 66 5F 00        lea     rax, a12dbOctTap; "-12dB/oct Tap"
00007FF91DFF4DB1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4DB5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4DB9  48 8D 87 E0 42 01 00        lea     rax, [rdi+142E0h]
00007FF91DFF4DC0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4DC7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4DCB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4DCF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4DD4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4DDB  E8 20 6C 01 00              call    sub_7FF91E00BA00
00007FF91DFF4DE0  66 0F 6F 05 48 72 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4DE8  48 8D 05 19 66 5F 00        lea     rax, a18dbOctTap; "-18dB/oct Tap"
00007FF91DFF4DEF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4DF3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4DF7  48 8D 87 F0 42 01 00        lea     rax, [rdi+142F0h]
00007FF91DFF4DFE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4E05  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4E09  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4E0D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4E12  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4E19  E8 E2 6B 01 00              call    sub_7FF91E00BA00
00007FF91DFF4E1E  66 0F 6F 05 0A 72 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4E26  48 8D 05 EB 65 5F 00        lea     rax, a24dbOctTap; "-24dB/oct Tap"
00007FF91DFF4E2D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4E31  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4E35  48 8D 87 00 43 01 00        lea     rax, [rdi+14300h]
00007FF91DFF4E3C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4E43  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4E47  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4E4B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4E50  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4E57  E8 A4 6B 01 00              call    sub_7FF91E00BA00
00007FF91DFF4E5C  66 0F 6F 05 CC 71 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4E64  48 8D 05 BD 65 5F 00        lea     rax, aAmpTone; "AMP TONE"
00007FF91DFF4E6B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4E6F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4E74  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4E7B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4E82  48 8D 87 E0 44 01 00        lea     rax, [rdi+144E0h]
00007FF91DFF4E89  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4E8D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4E91  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4E95  E8 66 6B 01 00              call    sub_7FF91E00BA00
00007FF91DFF4E9A  66 0F 6F 05 8E 71 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4EA2  48 8D 05 8F 65 5F 00        lea     rax, aAmpVelocitySen; "AMP VELOCITY SENS"
00007FF91DFF4EA9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4EAD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4EB1  48 8D 87 F0 44 01 00        lea     rax, [rdi+144F0h]
00007FF91DFF4EB8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4EBF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4EC3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4EC7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4ECC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4ED3  E8 28 6B 01 00              call    sub_7FF91E00BA00
00007FF91DFF4ED8  66 0F 6F 05 50 71 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF4EE0  48 8D 05 69 65 5F 00        lea     rax, aAmpFixVelocity; "AMP FIX VELOCITY LEVEL"
00007FF91DFF4EE7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4EEB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4EEF  48 8D 87 00 45 01 00        lea     rax, [rdi+14500h]
00007FF91DFF4EF6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4EFD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4F01  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4F05  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4F0A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4F11  E8 EA 6A 01 00              call    sub_7FF91E00BA00
00007FF91DFF4F16  48 8D 05 13 64 5F 00        lea     rax, aVelocity; "Velocity"
00007FF91DFF4F1D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4F24  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4F28  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4F2C  48 8D 87 40 45 01 00        lea     rax, [rdi+14540h]
00007FF91DFF4F33  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4F3A  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4F3D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4F41  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4F45  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4F4A  E8 B1 6A 01 00              call    sub_7FF91E00BA00
00007FF91DFF4F4F  48 8D 05 12 65 5F 00        lea     rax, aMute; "Mute"
00007FF91DFF4F56  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4F5D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4F61  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4F65  48 8D 87 D0 45 01 00        lea     rax, [rdi+145D0h]
00007FF91DFF4F6C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4F73  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4F76  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4F7A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4F7E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4F83  E8 78 6A 01 00              call    sub_7FF91E00BA00
00007FF91DFF4F88  48 8D 05 E1 64 5F 00        lea     rax, aGateSw; "Gate SW"
00007FF91DFF4F8F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4F96  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4F9A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4F9E  48 8D 87 30 47 01 00        lea     rax, [rdi+14730h]
00007FF91DFF4FA5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4FAC  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4FAF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4FB3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4FB7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4FBC  E8 3F 6A 01 00              call    sub_7FF91E00BA00
00007FF91DFF4FC1  48 8D 05 B0 64 5F 00        lea     rax, aEnv1Sw; "ENV1 SW"
00007FF91DFF4FC8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF4FCF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF4FD3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF4FD7  48 8D 87 40 47 01 00        lea     rax, [rdi+14740h]
00007FF91DFF4FDE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF4FE5  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF4FE8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF4FEC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF4FF0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF4FF5  E8 06 6A 01 00              call    sub_7FF91E00BA00
00007FF91DFF4FFA  48 8D 05 7F 64 5F 00        lea     rax, aEnv2Sw; "ENV2 SW"
00007FF91DFF5001  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5008  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF500C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5010  48 8D 87 50 47 01 00        lea     rax, [rdi+14750h]
00007FF91DFF5017  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF501E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5021  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5025  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF502A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF502E  E8 CD 69 01 00              call    sub_7FF91E00BA00
00007FF91DFF5033  48 8D 05 4E 64 5F 00        lea     rax, aExtEnvSw; "Ext ENV SW"
00007FF91DFF503A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5041  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5045  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5049  48 8D 87 60 47 01 00        lea     rax, [rdi+14760h]
00007FF91DFF5050  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5057  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF505A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF505E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5062  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5067  E8 94 69 01 00              call    sub_7FF91E00BA00
00007FF91DFF506C  66 0F 6F 05 BC 6F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5074  48 8D 05 1D 64 5F 00        lea     rax, aHpfCutoff; "HPF Cutoff"
00007FF91DFF507B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF507F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5083  48 8D 87 70 47 01 00        lea     rax, [rdi+14770h]
00007FF91DFF508A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5091  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5095  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5099  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF509E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF50A5  E8 56 69 01 00              call    sub_7FF91E00BA00
00007FF91DFF50AA  66 0F 6F 05 7E 6F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF50B2  48 8D 05 EF 63 5F 00        lea     rax, aHpfSwitch; "HPF Switch"
00007FF91DFF50B9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF50BD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF50C1  48 8D 87 80 47 01 00        lea     rax, [rdi+14780h]
00007FF91DFF50C8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF50CF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF50D3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF50D7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF50DC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF50E3  E8 18 69 01 00              call    sub_7FF91E00BA00
00007FF91DFF50E8  66 0F 6F 05 40 6F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF50F0  48 8D 05 C1 63 5F 00        lea     rax, aBoostLpfLevel; "Boost LPF Level"
00007FF91DFF50F7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF50FB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF50FF  48 8D 87 90 47 01 00        lea     rax, [rdi+14790h]
00007FF91DFF5106  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF510D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5111  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5115  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF511A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5121  E8 DA 68 01 00              call    sub_7FF91E00BA00
00007FF91DFF5126  66 0F 6F 05 02 6F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF512E  48 8D 05 93 63 5F 00        lea     rax, aBoostThruLevel; "Boost Thru Level"
00007FF91DFF5135  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5139  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF513D  48 8D 87 A0 47 01 00        lea     rax, [rdi+147A0h]
00007FF91DFF5144  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF514B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF514F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5153  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5158  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF515F  E8 9C 68 01 00              call    sub_7FF91E00BA00
00007FF91DFF5164  66 0F 6F 05 C4 6E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF516C  48 8D 05 6D 63 5F 00        lea     rax, aEnvLevel_0; "ENV LEVEL"
00007FF91DFF5173  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5177  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF517B  48 8D 87 B0 47 01 00        lea     rax, [rdi+147B0h]
00007FF91DFF5182  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5189  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF518D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5191  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5196  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF519D  E8 5E 68 01 00              call    sub_7FF91E00BA00
00007FF91DFF51A2  66 0F 6F 05 86 6E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF51AA  48 8D 05 3F 63 5F 00        lea     rax, aAmpLevel; "AMP LEVEL"
00007FF91DFF51B1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF51B5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF51B9  48 8D 87 C0 47 01 00        lea     rax, [rdi+147C0h]
00007FF91DFF51C0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF51C7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF51CB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF51CF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF51D4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF51DB  E8 20 68 01 00              call    sub_7FF91E00BA00
00007FF91DFF51E0  48 8D 05 19 63 5F 00        lea     rax, aExtNoiseSw; "Ext Noise Sw"
00007FF91DFF51E7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF51EE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF51F2  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF51F5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF51FC  48 8D 87 50 49 01 00        lea     rax, [rdi+14950h]
00007FF91DFF5203  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5207  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF520B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF520F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5214  E8 E7 67 01 00              call    sub_7FF91E00BA00
00007FF91DFF5219  66 0F 6F 05 0F 6E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5221  48 8D 05 E8 62 5F 00        lea     rax, aVoice01OutputO; "Voice01 Output On/Off"
00007FF91DFF5228  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF522C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5230  48 8D 87 E0 49 01 00        lea     rax, [rdi+149E0h]
00007FF91DFF5237  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF523E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5242  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5246  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF524B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5252  E8 A9 67 01 00              call    sub_7FF91E00BA00
00007FF91DFF5257  66 0F 6F 05 D1 6D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF525F  48 8D 05 C2 62 5F 00        lea     rax, aVoice23OutputO; "Voice23 Output On/Off"
00007FF91DFF5266  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF526A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF526E  48 8D 87 F0 49 01 00        lea     rax, [rdi+149F0h]
00007FF91DFF5275  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF527C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5280  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5284  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5289  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5290  E8 6B 67 01 00              call    sub_7FF91E00BA00
00007FF91DFF5295  66 0F 6F 05 93 6D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF529D  48 8D 05 9C 62 5F 00        lea     rax, aVoice45OutputO; "Voice45 Output On/Off"
00007FF91DFF52A4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF52A8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF52AC  48 8D 87 00 4A 01 00        lea     rax, [rdi+14A00h]
00007FF91DFF52B3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF52BA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF52BE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF52C2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF52C7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF52CE  E8 2D 67 01 00              call    sub_7FF91E00BA00
00007FF91DFF52D3  66 0F 6F 05 55 6D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF52DB  48 8D 05 76 62 5F 00        lea     rax, aVoice67OutputO; "Voice67 Output On/Off"
00007FF91DFF52E2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF52E6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF52EA  48 8D 87 10 4A 01 00        lea     rax, [rdi+14A10h]
00007FF91DFF52F1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF52F8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF52FC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5300  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5305  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF530C  E8 EF 66 01 00              call    sub_7FF91E00BA00
00007FF91DFF5311  66 0F 6F 05 17 6D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5319  48 8D 05 50 62 5F 00        lea     rax, aEffectSw; "Effect SW"
00007FF91DFF5320  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5324  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5328  48 8D 87 40 4A 01 00        lea     rax, [rdi+14A40h]
00007FF91DFF532F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5336  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF533A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF533E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5343  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF534A  E8 B1 66 01 00              call    sub_7FF91E00BA00
00007FF91DFF534F  66 0F 6F 05 D9 6C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5357  48 8D 05 22 62 5F 00        lea     rax, aMuteSw; "Mute SW"
00007FF91DFF535E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5362  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5366  48 8D 87 50 4A 01 00        lea     rax, [rdi+14A50h]
00007FF91DFF536D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5374  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5378  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF537C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5381  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5388  E8 73 66 01 00              call    sub_7FF91E00BA00
00007FF91DFF538D  66 0F 6F 05 9B 6C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5395  48 8D 05 EC 61 5F 00        lea     rax, aDsDrive; "DS Drive"
00007FF91DFF539C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF53A0  48 8D 87 90 4C 01 00        lea     rax, [rdi+14C90h]
00007FF91DFF53A7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF53AE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF53B3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF53BA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF53BE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF53C2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF53C6  E8 35 66 01 00              call    sub_7FF91E00BA00
00007FF91DFF53CB  66 0F 6F 05 5D 6C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF53D3  48 8D 05 BE 61 5F 00        lea     rax, aDsLevel; "DS Level"
00007FF91DFF53DA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF53DE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF53E2  48 8D 87 A0 4C 01 00        lea     rax, [rdi+14CA0h]
00007FF91DFF53E9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF53F0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF53F4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF53F8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF53FD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5404  E8 F7 65 01 00              call    sub_7FF91E00BA00
00007FF91DFF5409  66 0F 6F 05 1F 6C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5411  48 8D 05 90 61 5F 00        lea     rax, aDsMute; "DS Mute"
00007FF91DFF5418  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF541C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5420  48 8D 87 B0 4C 01 00        lea     rax, [rdi+14CB0h]
00007FF91DFF5427  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF542E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5432  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5436  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF543B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5442  E8 B9 65 01 00              call    sub_7FF91E00BA00
00007FF91DFF5447  66 0F 6F 05 E1 6B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF544F  48 8D 05 5A 61 5F 00        lea     rax, aDsBiasmute; "DS BiasMute"
00007FF91DFF5456  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF545A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF545E  48 8D 87 C0 4C 01 00        lea     rax, [rdi+14CC0h]
00007FF91DFF5465  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF546C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5470  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5474  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5479  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5480  E8 7B 65 01 00              call    sub_7FF91E00BA00
00007FF91DFF5485  66 0F 6F 05 A3 6B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF548D  48 8D 05 2C 61 5F 00        lea     rax, aOdTone; "OD TONE"
00007FF91DFF5494  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5498  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF549C  48 8D 87 E0 4F 01 00        lea     rax, [rdi+14FE0h]
00007FF91DFF54A3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF54AA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF54AE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF54B2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF54B7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF54BE  E8 3D 65 01 00              call    sub_7FF91E00BA00
00007FF91DFF54C3  66 0F 6F 05 65 6B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF54CB  48 8D 05 B6 60 5F 00        lea     rax, aDsDrive; "DS Drive"
00007FF91DFF54D2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF54D6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF54DA  48 8D 87 10 51 01 00        lea     rax, [rdi+15110h]
00007FF91DFF54E1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF54E8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF54EC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF54F0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF54F5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF54FC  E8 FF 64 01 00              call    sub_7FF91E00BA00
00007FF91DFF5501  66 0F 6F 05 27 6B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5509  48 8D 05 88 60 5F 00        lea     rax, aDsLevel; "DS Level"
00007FF91DFF5510  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5514  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5518  48 8D 87 20 51 01 00        lea     rax, [rdi+15120h]
00007FF91DFF551F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5526  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF552A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF552E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5533  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF553A  E8 C1 64 01 00              call    sub_7FF91E00BA00
00007FF91DFF553F  66 0F 6F 05 E9 6A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5547  48 8D 05 5A 60 5F 00        lea     rax, aDsMute; "DS Mute"
00007FF91DFF554E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5552  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5556  48 8D 87 30 51 01 00        lea     rax, [rdi+15130h]
00007FF91DFF555D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5564  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5568  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF556C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5571  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5578  E8 83 64 01 00              call    sub_7FF91E00BA00
00007FF91DFF557D  66 0F 6F 05 AB 6A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5585  48 8D 05 24 60 5F 00        lea     rax, aDsBiasmute; "DS BiasMute"
00007FF91DFF558C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5590  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5594  48 8D 87 40 51 01 00        lea     rax, [rdi+15140h]
00007FF91DFF559B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF55A2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF55A6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF55AA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF55AF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF55B6  E8 45 64 01 00              call    sub_7FF91E00BA00
00007FF91DFF55BB  66 0F 6F 05 6D 6A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF55C3  48 8D 05 FE 5F 5F 00        lea     rax, aDsTone; "DS TONE"
00007FF91DFF55CA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF55CE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF55D2  48 8D 87 10 54 01 00        lea     rax, [rdi+15410h]
00007FF91DFF55D9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF55E0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF55E4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF55E8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF55ED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF55F4  E8 07 64 01 00              call    sub_7FF91E00BA00
00007FF91DFF55F9  66 0F 6F 05 2F 6A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5601  48 8D 05 80 5F 5F 00        lea     rax, aDsDrive; "DS Drive"
00007FF91DFF5608  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF560C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5610  48 8D 87 40 56 01 00        lea     rax, [rdi+15640h]
00007FF91DFF5617  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF561E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5622  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5626  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF562B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5632  E8 C9 63 01 00              call    sub_7FF91E00BA00
00007FF91DFF5637  66 0F 6F 05 F1 69 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF563F  48 8D 05 52 5F 5F 00        lea     rax, aDsLevel; "DS Level"
00007FF91DFF5646  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF564A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF564E  48 8D 87 50 56 01 00        lea     rax, [rdi+15650h]
00007FF91DFF5655  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF565C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5660  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5664  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5669  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5670  E8 8B 63 01 00              call    sub_7FF91E00BA00
00007FF91DFF5675  66 0F 6F 05 B3 69 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF567D  48 8D 05 24 5F 5F 00        lea     rax, aDsMute; "DS Mute"
00007FF91DFF5684  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5688  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF568C  48 8D 87 60 56 01 00        lea     rax, [rdi+15660h]
00007FF91DFF5693  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF569A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF569E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF56A2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF56A7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF56AE  E8 4D 63 01 00              call    sub_7FF91E00BA00
00007FF91DFF56B3  66 0F 6F 05 75 69 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF56BB  48 8D 05 0E 5F 5F 00        lea     rax, aMtTone; "MT TONE"
00007FF91DFF56C2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF56C6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF56CA  48 8D 87 90 5B 01 00        lea     rax, [rdi+15B90h]
00007FF91DFF56D1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF56D8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF56DC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF56E0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF56E5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF56EC  E8 0F 63 01 00              call    sub_7FF91E00BA00
00007FF91DFF56F1  66 0F 6F 05 37 69 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF56F9  48 8D 05 88 5E 5F 00        lea     rax, aDsDrive; "DS Drive"
00007FF91DFF5700  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5704  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5708  48 8D 87 E0 5C 01 00        lea     rax, [rdi+15CE0h]
00007FF91DFF570F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5716  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF571A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF571E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5723  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF572A  E8 D1 62 01 00              call    sub_7FF91E00BA00
00007FF91DFF572F  66 0F 6F 05 F9 68 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5737  48 8D 05 5A 5E 5F 00        lea     rax, aDsLevel; "DS Level"
00007FF91DFF573E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5742  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5749  48 8D 87 F0 5C 01 00        lea     rax, [rdi+15CF0h]
00007FF91DFF5750  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5757  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF575B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF575F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5763  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5768  E8 93 62 01 00              call    sub_7FF91E00BA00
00007FF91DFF576D  66 0F 6F 05 BB 68 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5775  48 8D 05 2C 5E 5F 00        lea     rax, aDsMute; "DS Mute"
00007FF91DFF577C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5780  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5784  48 8D 87 00 5D 01 00        lea     rax, [rdi+15D00h]
00007FF91DFF578B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5792  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5796  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF579A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF579F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF57A6  E8 55 62 01 00              call    sub_7FF91E00BA00
00007FF91DFF57AB  66 0F 6F 05 7D 68 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF57B3  48 8D 05 F6 5D 5F 00        lea     rax, aDsBiasmute; "DS BiasMute"
00007FF91DFF57BA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF57BE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF57C2  48 8D 87 10 5D 01 00        lea     rax, [rdi+15D10h]
00007FF91DFF57C9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF57D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF57D4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF57D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF57DD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF57E4  E8 17 62 01 00              call    sub_7FF91E00BA00
00007FF91DFF57E9  66 0F 6F 05 3F 68 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF57F1  48 8D 05 E0 5D 5F 00        lea     rax, aFzTone; "FZ TONE"
00007FF91DFF57F8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF57FC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5800  48 8D 87 90 60 01 00        lea     rax, [rdi+16090h]
00007FF91DFF5807  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF580E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5812  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5816  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF581B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5822  E8 D9 61 01 00              call    sub_7FF91E00BA00
00007FF91DFF5827  48 8D 05 B2 5D 5F 00        lea     rax, aDelayTime; "Delay Time"
00007FF91DFF582E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5835  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5839  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF583D  48 8D 87 F0 63 01 00        lea     rax, [rdi+163F0h]
00007FF91DFF5844  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF584B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF584E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5852  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5856  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF585B  E8 A0 61 01 00              call    sub_7FF91E00BA00
00007FF91DFF5860  48 8D 05 89 5D 5F 00        lea     rax, aErrorDepth; "Error Depth"
00007FF91DFF5867  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF586E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5872  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5876  48 8D 87 00 64 01 00        lea     rax, [rdi+16400h]
00007FF91DFF587D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5884  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5887  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF588B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF588F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5894  E8 67 61 01 00              call    sub_7FF91E00BA00
00007FF91DFF5899  66 0F 6F 05 8F 67 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF58A1  48 8D 05 30 57 5F 00        lea     rax, aLfoRate; "LFO Rate"
00007FF91DFF58A8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF58AC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF58B0  48 8D 87 10 64 01 00        lea     rax, [rdi+16410h]
00007FF91DFF58B7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF58BE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF58C2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF58C6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF58CB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF58D2  E8 29 61 01 00              call    sub_7FF91E00BA00
00007FF91DFF58D7  66 0F 6F 05 51 67 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF58DF  48 8D 05 1A 5D 5F 00        lea     rax, aLfoPhase; "LFO Phase"
00007FF91DFF58E6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF58EA  48 8D 87 20 64 01 00        lea     rax, [rdi+16420h]
00007FF91DFF58F1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF58F5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF58FC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5901  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5908  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF590C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5910  E8 EB 60 01 00              call    sub_7FF91E00BA00
00007FF91DFF5915  66 0F 6F 05 13 67 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF591D  48 8D 05 EC 5C 5F 00        lea     rax, aLfoDepth; "LFO Depth"
00007FF91DFF5924  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5928  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF592C  48 8D 87 30 64 01 00        lea     rax, [rdi+16430h]
00007FF91DFF5933  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF593A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF593E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5942  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5947  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF594E  E8 AD 60 01 00              call    sub_7FF91E00BA00
00007FF91DFF5953  66 0F 6F 05 D5 66 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF595B  48 8D 05 BE 5C 5F 00        lea     rax, aNoiseLevel; "Noise Level"
00007FF91DFF5962  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5966  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF596A  48 8D 87 40 64 01 00        lea     rax, [rdi+16440h]
00007FF91DFF5971  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5978  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF597C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5980  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5985  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF598C  E8 6F 60 01 00              call    sub_7FF91E00BA00
00007FF91DFF5991  66 0F 6F 05 97 66 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5999  48 8D 05 90 5C 5F 00        lea     rax, aDryLevel; "Dry Level"
00007FF91DFF59A0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF59A4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF59A8  48 8D 87 50 64 01 00        lea     rax, [rdi+16450h]
00007FF91DFF59AF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF59B6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF59BA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF59BE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF59C3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF59CA  E8 31 60 01 00              call    sub_7FF91E00BA00
00007FF91DFF59CF  66 0F 6F 05 59 66 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF59D7  48 8D 05 62 5C 5F 00        lea     rax, aWetLevel; "Wet Level"
00007FF91DFF59DE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF59E2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF59E6  48 8D 87 60 64 01 00        lea     rax, [rdi+16460h]
00007FF91DFF59ED  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF59F4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF59F8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF59FC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5A01  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5A08  E8 F3 5F 01 00              call    sub_7FF91E00BA00
00007FF91DFF5A0D  66 0F 6F 05 1B 66 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5A15  48 8D 05 30 5C 5F 00        lea     rax, aIpFc; "Ip Fc"
00007FF91DFF5A1C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5A20  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5A24  48 8D 87 70 64 01 00        lea     rax, [rdi+16470h]
00007FF91DFF5A2B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5A32  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5A36  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5A3A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5A3F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5A46  E8 B5 5F 01 00              call    sub_7FF91E00BA00
00007FF91DFF5A4B  66 0F 6F 05 DD 65 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5A53  48 8D 05 FA 5B 5F 00        lea     rax, aOnOff; "On/Off"
00007FF91DFF5A5A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5A5E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5A62  48 8D 87 80 64 01 00        lea     rax, [rdi+16480h]
00007FF91DFF5A69  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5A70  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5A74  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5A78  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5A7D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5A84  E8 77 5F 01 00              call    sub_7FF91E00BA00
00007FF91DFF5A89  66 0F 6F 05 9F 65 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5A91  48 8D 05 D0 59 5F 00        lea     rax, aMute; "Mute"
00007FF91DFF5A98  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5A9C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5AA0  48 8D 87 90 64 01 00        lea     rax, [rdi+16490h]
00007FF91DFF5AA7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5AAE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5AB2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5AB6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5ABB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5AC2  E8 39 5F 01 00              call    sub_7FF91E00BA00
00007FF91DFF5AC7  48 8D 05 12 5B 5F 00        lea     rax, aDelayTime; "Delay Time"
00007FF91DFF5ACE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5AD2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5AD6  48 8D 87 50 78 01 00        lea     rax, [rdi+17850h]
00007FF91DFF5ADD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5AE4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5AE7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5AEB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5AEF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5AF6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5AFB  E8 00 5F 01 00              call    sub_7FF91E00BA00
00007FF91DFF5B00  66 0F 6F 05 28 65 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5B08  48 8D 05 C9 54 5F 00        lea     rax, aLfoRate; "LFO Rate"
00007FF91DFF5B0F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5B13  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5B17  48 8D 87 60 78 01 00        lea     rax, [rdi+17860h]
00007FF91DFF5B1E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5B25  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5B29  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5B2D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5B32  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5B39  E8 C2 5E 01 00              call    sub_7FF91E00BA00
00007FF91DFF5B3E  66 0F 6F 05 EA 64 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5B46  48 8D 05 C3 5A 5F 00        lea     rax, aLfoDepth; "LFO Depth"
00007FF91DFF5B4D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5B51  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5B55  48 8D 87 70 78 01 00        lea     rax, [rdi+17870h]
00007FF91DFF5B5C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5B63  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5B67  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5B6B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5B70  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5B77  E8 84 5E 01 00              call    sub_7FF91E00BA00
00007FF91DFF5B7C  66 0F 6F 05 AC 64 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5B84  48 8D 05 C1 5A 5F 00        lea     rax, aIpFc; "Ip Fc"
00007FF91DFF5B8B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5B8F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5B93  48 8D 87 80 78 01 00        lea     rax, [rdi+17880h]
00007FF91DFF5B9A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5BA1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5BA5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5BA9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5BAE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5BB5  E8 46 5E 01 00              call    sub_7FF91E00BA00
00007FF91DFF5BBA  66 0F 6F 05 6E 64 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5BC2  48 8D 05 8B 5A 5F 00        lea     rax, aOnOff; "On/Off"
00007FF91DFF5BC9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5BCD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5BD1  48 8D 87 90 78 01 00        lea     rax, [rdi+17890h]
00007FF91DFF5BD8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5BDF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5BE3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5BE7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5BEC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5BF3  E8 08 5E 01 00              call    sub_7FF91E00BA00
00007FF91DFF5BF8  66 0F 6F 05 30 64 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5C00  48 8D 05 61 58 5F 00        lea     rax, aMute; "Mute"
00007FF91DFF5C07  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5C0B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5C0F  48 8D 87 A0 78 01 00        lea     rax, [rdi+178A0h]
00007FF91DFF5C16  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5C1D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5C21  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5C25  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5C2A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5C31  E8 CA 5D 01 00              call    sub_7FF91E00BA00
00007FF91DFF5C36  66 0F 6F 05 F2 63 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5C3E  48 8D 05 1B 5A 5F 00        lea     rax, aPatchLevel; "Patch Level"
00007FF91DFF5C45  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5C49  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5C4D  48 8D 87 D0 8A 01 00        lea     rax, [rdi+18AD0h]
00007FF91DFF5C54  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5C5B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5C5F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5C63  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5C68  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5C6F  E8 8C 5D 01 00              call    sub_7FF91E00BA00
00007FF91DFF5C74  66 0F 6F 05 B4 63 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5C7C  48 8D 05 ED 59 5F 00        lea     rax, aExpression; "Expression"
00007FF91DFF5C83  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5C87  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5C8C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5C93  48 8D 87 10 8B 01 00        lea     rax, [rdi+18B10h]
00007FF91DFF5C9A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5CA1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5CA5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5CA9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5CAD  E8 4E 5D 01 00              call    sub_7FF91E00BA00
00007FF91DFF5CB2  66 0F 6F 05 76 63 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF5CBA  48 8D 05 BB 59 5F 00        lea     rax, aVolume; "Volume"
00007FF91DFF5CC1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5CC5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5CC9  48 8D 87 20 8B 01 00        lea     rax, [rdi+18B20h]
00007FF91DFF5CD0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5CD7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5CDB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5CDF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5CE4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5CEB  E8 10 5D 01 00              call    sub_7FF91E00BA00
00007FF91DFF5CF0  48 8D 05 91 59 5F 00        lea     rax, aVoice0GateNoti; "Voice0 Gate Notify"
00007FF91DFF5CF7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5CFE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5D02  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5D06  48 8D 87 70 8C 01 00        lea     rax, [rdi+18C70h]
00007FF91DFF5D0D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5D14  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5D17  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5D1B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5D1F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5D24  E8 D7 5C 01 00              call    sub_7FF91E00BA00
00007FF91DFF5D29  48 8D 05 70 59 5F 00        lea     rax, aVoice0NoteOffN; "Voice0 Note Off Notify"
00007FF91DFF5D30  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5D37  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5D3B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5D3F  48 8D 87 80 8C 01 00        lea     rax, [rdi+18C80h]
00007FF91DFF5D46  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5D4D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5D50  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5D54  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5D58  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5D5D  E8 9E 5C 01 00              call    sub_7FF91E00BA00
00007FF91DFF5D62  48 8D 05 4F 59 5F 00        lea     rax, aVoice1GateNoti; "Voice1 Gate Notify"
00007FF91DFF5D69  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5D70  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5D74  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5D78  48 8D 87 90 8C 01 00        lea     rax, [rdi+18C90h]
00007FF91DFF5D7F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5D86  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5D89  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5D8D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5D91  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5D96  E8 65 5C 01 00              call    sub_7FF91E00BA00
00007FF91DFF5D9B  48 8D 05 2E 59 5F 00        lea     rax, aVoice1NoteOffN; "Voice1 Note Off Notify"
00007FF91DFF5DA2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5DA9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5DAD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5DB1  48 8D 87 A0 8C 01 00        lea     rax, [rdi+18CA0h]
00007FF91DFF5DB8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5DBF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5DC2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5DC6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5DCA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5DCF  E8 2C 5C 01 00              call    sub_7FF91E00BA00
00007FF91DFF5DD4  48 8D 05 0D 59 5F 00        lea     rax, aVoice2GateNoti; "Voice2 Gate Notify"
00007FF91DFF5DDB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5DE2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5DE6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5DEA  48 8D 87 B0 8C 01 00        lea     rax, [rdi+18CB0h]
00007FF91DFF5DF1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5DF8  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5DFB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5DFF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5E03  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5E08  E8 F3 5B 01 00              call    sub_7FF91E00BA00
00007FF91DFF5E0D  48 8D 05 EC 58 5F 00        lea     rax, aVoice2NoteOffN; "Voice2 Note Off Notify"
00007FF91DFF5E14  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5E1B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5E1F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5E23  48 8D 87 C0 8C 01 00        lea     rax, [rdi+18CC0h]
00007FF91DFF5E2A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5E31  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5E34  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5E38  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5E3D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5E41  E8 BA 5B 01 00              call    sub_7FF91E00BA00
00007FF91DFF5E46  48 8D 05 CB 58 5F 00        lea     rax, aVoice3GateNoti; "Voice3 Gate Notify"
00007FF91DFF5E4D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5E54  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5E58  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5E5C  48 8D 87 D0 8C 01 00        lea     rax, [rdi+18CD0h]
00007FF91DFF5E63  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5E6A  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5E6D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5E71  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5E75  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5E7A  E8 81 5B 01 00              call    sub_7FF91E00BA00
00007FF91DFF5E7F  48 8D 05 AA 58 5F 00        lea     rax, aVoice3NoteOffN; "Voice3 Note Off Notify"
00007FF91DFF5E86  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5E8D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5E91  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5E95  48 8D 87 E0 8C 01 00        lea     rax, [rdi+18CE0h]
00007FF91DFF5E9C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5EA3  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5EA6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5EAA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5EAE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5EB3  E8 48 5B 01 00              call    sub_7FF91E00BA00
00007FF91DFF5EB8  48 8D 05 89 58 5F 00        lea     rax, aVoice4GateNoti; "Voice4 Gate Notify"
00007FF91DFF5EBF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5EC6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5ECA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5ECE  48 8D 87 F0 8C 01 00        lea     rax, [rdi+18CF0h]
00007FF91DFF5ED5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5EDC  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5EDF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5EE3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5EE7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5EEC  E8 0F 5B 01 00              call    sub_7FF91E00BA00
00007FF91DFF5EF1  48 8D 05 68 58 5F 00        lea     rax, aVoice4NoteOffN; "Voice4 Note Off Notify"
00007FF91DFF5EF8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5EFF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5F03  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5F07  48 8D 87 00 8D 01 00        lea     rax, [rdi+18D00h]
00007FF91DFF5F0E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5F15  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5F18  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5F1C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5F20  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5F25  E8 D6 5A 01 00              call    sub_7FF91E00BA00
00007FF91DFF5F2A  48 8D 05 47 58 5F 00        lea     rax, aVoice5GateNoti; "Voice5 Gate Notify"
00007FF91DFF5F31  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5F38  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5F3C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5F40  48 8D 87 10 8D 01 00        lea     rax, [rdi+18D10h]
00007FF91DFF5F47  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5F4E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5F51  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5F55  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5F59  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5F5E  E8 9D 5A 01 00              call    sub_7FF91E00BA00
00007FF91DFF5F63  48 8D 05 26 58 5F 00        lea     rax, aVoice5NoteOffN; "Voice5 Note Off Notify"
00007FF91DFF5F6A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5F71  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5F75  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5F79  48 8D 87 20 8D 01 00        lea     rax, [rdi+18D20h]
00007FF91DFF5F80  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5F87  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5F8A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5F8E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5F92  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5F97  E8 64 5A 01 00              call    sub_7FF91E00BA00
00007FF91DFF5F9C  48 8D 05 05 58 5F 00        lea     rax, aVoice6GateNoti; "Voice6 Gate Notify"
00007FF91DFF5FA3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5FAA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5FAE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5FB2  48 8D 87 30 8D 01 00        lea     rax, [rdi+18D30h]
00007FF91DFF5FB9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5FC0  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5FC3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF5FC7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF5FCB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF5FD0  E8 2B 5A 01 00              call    sub_7FF91E00BA00
00007FF91DFF5FD5  48 8D 05 E4 57 5F 00        lea     rax, aVoice6NoteOffN; "Voice6 Note Off Notify"
00007FF91DFF5FDC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF5FE0  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF5FE3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF5FEA  48 8D 87 40 8D 01 00        lea     rax, [rdi+18D40h]
00007FF91DFF5FF1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF5FF8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF5FFC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6000  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6004  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6009  E8 F2 59 01 00              call    sub_7FF91E00BA00
00007FF91DFF600E  48 8D 05 C3 57 5F 00        lea     rax, aVoice7GateNoti; "Voice7 Gate Notify"
00007FF91DFF6015  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF601C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6020  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6024  48 8D 87 50 8D 01 00        lea     rax, [rdi+18D50h]
00007FF91DFF602B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6032  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF6035  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6039  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF603D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6042  E8 B9 59 01 00              call    sub_7FF91E00BA00
00007FF91DFF6047  48 8D 05 A2 57 5F 00        lea     rax, aVoice7NoteOffN; "Voice7 Note Off Notify"
00007FF91DFF604E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6055  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6059  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF605D  48 8D 87 60 8D 01 00        lea     rax, [rdi+18D60h]
00007FF91DFF6064  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF606B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF606E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6072  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6076  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF607B  E8 80 59 01 00              call    sub_7FF91E00BA00
00007FF91DFF6080  66 0F 6F 05 A8 5F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6088  48 8D 05 79 57 5F 00        lea     rax, aDlyMute; "DLY Mute"
00007FF91DFF608F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6093  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6097  48 8D 87 70 8D 01 00        lea     rax, [rdi+18D70h]
00007FF91DFF609E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF60A5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF60A9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF60AD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF60B2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF60B9  E8 42 59 01 00              call    sub_7FF91E00BA00
00007FF91DFF60BE  48 8D 05 1B 55 5F 00        lea     rax, aDelayTime; "Delay Time"
00007FF91DFF60C5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF60CC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF60D0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF60D4  48 8D 87 D0 8F 01 00        lea     rax, [rdi+18FD0h]
00007FF91DFF60DB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF60E2  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF60E5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF60E9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF60ED  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF60F2  E8 09 59 01 00              call    sub_7FF91E00BA00
00007FF91DFF60F7  66 0F 6F 05 31 5F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF60FF  48 8D 05 12 57 5F 00        lea     rax, aHighCutC0; "High Cut C0"
00007FF91DFF6106  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF610A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF610E  48 8D 87 E0 8F 01 00        lea     rax, [rdi+18FE0h]
00007FF91DFF6115  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF611C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6120  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6124  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6129  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6130  E8 CB 58 01 00              call    sub_7FF91E00BA00
00007FF91DFF6135  66 0F 6F 05 F3 5E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF613D  48 8D 05 E4 56 5F 00        lea     rax, aHighCutA0; "High Cut A0"
00007FF91DFF6144  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6148  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF614C  48 8D 87 F0 8F 01 00        lea     rax, [rdi+18FF0h]
00007FF91DFF6153  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF615A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF615E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6162  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6167  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF616E  E8 8D 58 01 00              call    sub_7FF91E00BA00
00007FF91DFF6173  66 0F 6F 05 B5 5E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF617B  48 8D 05 B6 56 5F 00        lea     rax, aHighCutA1; "High Cut A1"
00007FF91DFF6182  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6186  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF618B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6192  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6199  48 8D 87 00 90 01 00        lea     rax, [rdi+19000h]
00007FF91DFF61A0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF61A4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF61A8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF61AC  E8 4F 58 01 00              call    sub_7FF91E00BA00
00007FF91DFF61B1  66 0F 6F 05 77 5E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF61B9  48 8D 05 88 56 5F 00        lea     rax, aHighCutB0; "High Cut B0"
00007FF91DFF61C0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF61C4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF61C8  48 8D 87 10 90 01 00        lea     rax, [rdi+19010h]
00007FF91DFF61CF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF61D6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF61DA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF61DE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF61E3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF61EA  E8 11 58 01 00              call    sub_7FF91E00BA00
00007FF91DFF61EF  66 0F 6F 05 39 5E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF61F7  48 8D 05 5A 56 5F 00        lea     rax, aHighCutB2; "High Cut B2"
00007FF91DFF61FE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6202  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6206  48 8D 87 20 90 01 00        lea     rax, [rdi+19020h]
00007FF91DFF620D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6214  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6218  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF621C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6221  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6228  E8 D3 57 01 00              call    sub_7FF91E00BA00
00007FF91DFF622D  66 0F 6F 05 FB 5D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6235  48 8D 05 2C 56 5F 00        lea     rax, aUseIirHighCutF; "Use IIR High Cut Filter"
00007FF91DFF623C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6240  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6244  48 8D 87 30 90 01 00        lea     rax, [rdi+19030h]
00007FF91DFF624B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6252  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6256  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF625A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF625F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6266  E8 95 57 01 00              call    sub_7FF91E00BA00
00007FF91DFF626B  66 0F 6F 05 BD 5D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6273  48 8D 05 06 56 5F 00        lea     rax, aHighCutFc; "High Cut Fc"
00007FF91DFF627A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF627E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6282  48 8D 87 40 90 01 00        lea     rax, [rdi+19040h]
00007FF91DFF6289  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6290  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6294  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6298  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF629D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF62A4  E8 57 57 01 00              call    sub_7FF91E00BA00
00007FF91DFF62A9  66 0F 6F 05 7F 5D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF62B1  48 8D 05 D8 55 5F 00        lea     rax, aHighCutQc; "High Cut Qc"
00007FF91DFF62B8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF62BC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF62C0  48 8D 87 50 90 01 00        lea     rax, [rdi+19050h]
00007FF91DFF62C7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF62CE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF62D2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF62D6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF62DB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF62E2  E8 19 57 01 00              call    sub_7FF91E00BA00
00007FF91DFF62E7  66 0F 6F 05 41 5D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF62EF  48 8D 05 AA 55 5F 00        lea     rax, aHighCutSw; "High Cut Sw"
00007FF91DFF62F6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF62FA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF62FE  48 8D 87 60 90 01 00        lea     rax, [rdi+19060h]
00007FF91DFF6305  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF630C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6310  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6314  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6319  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6320  E8 DB 56 01 00              call    sub_7FF91E00BA00
00007FF91DFF6325  66 0F 6F 05 03 5D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF632D  48 8D 05 FC 52 5F 00        lea     rax, aDryLevel; "Dry Level"
00007FF91DFF6334  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6338  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF633C  48 8D 87 70 90 01 00        lea     rax, [rdi+19070h]
00007FF91DFF6343  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF634A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF634E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6352  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6357  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF635E  E8 9D 56 01 00              call    sub_7FF91E00BA00
00007FF91DFF6363  66 0F 6F 05 C5 5C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF636B  48 8D 05 CE 52 5F 00        lea     rax, aWetLevel; "Wet Level"
00007FF91DFF6372  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6376  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF637A  48 8D 87 80 90 01 00        lea     rax, [rdi+19080h]
00007FF91DFF6381  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6388  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF638C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6390  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6395  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF639C  E8 5F 56 01 00              call    sub_7FF91E00BA00
00007FF91DFF63A1  66 0F 6F 05 87 5C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF63A9  48 8D 05 9C 52 5F 00        lea     rax, aIpFc; "Ip Fc"
00007FF91DFF63B0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF63B4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF63B8  48 8D 87 90 90 01 00        lea     rax, [rdi+19090h]
00007FF91DFF63BF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF63C6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF63CA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF63CE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF63D3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF63DA  E8 21 56 01 00              call    sub_7FF91E00BA00
00007FF91DFF63DF  66 0F 6F 05 49 5C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF63E7  48 8D 05 C2 54 5F 00        lea     rax, aFeedback_0; "Feedback"
00007FF91DFF63EE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF63F2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF63F6  48 8D 87 A0 90 01 00        lea     rax, [rdi+190A0h]
00007FF91DFF63FD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6404  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6408  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF640C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6411  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6418  E8 E3 55 01 00              call    sub_7FF91E00BA00
00007FF91DFF641D  66 0F 6F 05 0B 5C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6425  48 8D 05 28 52 5F 00        lea     rax, aOnOff; "On/Off"
00007FF91DFF642C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6430  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6434  48 8D 87 B0 90 01 00        lea     rax, [rdi+190B0h]
00007FF91DFF643B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6442  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6446  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF644A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF644F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6456  E8 A5 55 01 00              call    sub_7FF91E00BA00
00007FF91DFF645B  66 0F 6F 05 CD 5B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6463  48 8D 05 FE 4F 5F 00        lea     rax, aMute; "Mute"
00007FF91DFF646A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF646E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6472  48 8D 87 C0 90 01 00        lea     rax, [rdi+190C0h]
00007FF91DFF6479  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6480  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6484  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6488  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF648D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6494  E8 67 55 01 00              call    sub_7FF91E00BA00
00007FF91DFF6499  66 0F 6F 05 8F 5B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF64A1  48 8D 05 18 54 5F 00        lea     rax, aLfDampFc; "LF Damp Fc"
00007FF91DFF64A8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF64AC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF64B0  48 8D 87 D0 90 01 00        lea     rax, [rdi+190D0h]
00007FF91DFF64B7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF64BE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF64C2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF64C6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF64CB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF64D2  E8 29 55 01 00              call    sub_7FF91E00BA00
00007FF91DFF64D7  66 0F 6F 05 51 5B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF64DF  48 8D 05 EA 53 5F 00        lea     rax, aLfDampHp; "LF Damp Hp"
00007FF91DFF64E6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF64EA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF64EE  48 8D 87 E0 90 01 00        lea     rax, [rdi+190E0h]
00007FF91DFF64F5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF64FC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6500  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6504  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6509  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6510  E8 EB 54 01 00              call    sub_7FF91E00BA00
00007FF91DFF6515  48 8D 05 C4 53 5F 00        lea     rax, aLfDampLp; "LF Damp Lp"
00007FF91DFF651C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6523  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6527  66 0F 6F 05 01 5B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF652F  48 8D 87 F0 90 01 00        lea     rax, [rdi+190F0h]
00007FF91DFF6536  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF653A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF653E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6542  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6549  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF654E  E8 AD 54 01 00              call    sub_7FF91E00BA00
00007FF91DFF6553  66 0F 6F 05 D5 5A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF655B  48 8D 05 8E 53 5F 00        lea     rax, aHfDampFc; "HF Damp Fc"
00007FF91DFF6562  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6566  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF656A  48 8D 87 00 91 01 00        lea     rax, [rdi+19100h]
00007FF91DFF6571  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6578  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF657C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6580  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6585  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF658C  E8 6F 54 01 00              call    sub_7FF91E00BA00
00007FF91DFF6591  66 0F 6F 05 97 5A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6599  48 8D 05 60 53 5F 00        lea     rax, aHfDampHp; "HF Damp Hp"
00007FF91DFF65A0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF65A4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF65A8  48 8D 87 10 91 01 00        lea     rax, [rdi+19110h]
00007FF91DFF65AF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF65B6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF65BA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF65BE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF65C3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF65CA  E8 31 54 01 00              call    sub_7FF91E00BA00
00007FF91DFF65CF  66 0F 6F 05 59 5A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF65D7  48 8D 05 32 53 5F 00        lea     rax, aHfDampLp; "HF Damp Lp"
00007FF91DFF65DE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF65E2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF65E6  48 8D 87 20 91 01 00        lea     rax, [rdi+19120h]
00007FF91DFF65ED  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF65F4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF65F8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF65FC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6601  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6608  E8 F3 53 01 00              call    sub_7FF91E00BA00
00007FF91DFF660D  48 8D 05 CC 4F 5F 00        lea     rax, aDelayTime; "Delay Time"
00007FF91DFF6614  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF661B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF661F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6623  48 8D 87 70 93 41 00        lea     rax, [rdi+419370h]
00007FF91DFF662A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6631  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF6634  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6638  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF663C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6641  E8 BA 53 01 00              call    sub_7FF91E00BA00
00007FF91DFF6646  66 0F 6F 05 E2 59 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF664E  48 8D 05 C3 51 5F 00        lea     rax, aHighCutC0; "High Cut C0"
00007FF91DFF6655  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6659  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF665D  48 8D 87 80 93 41 00        lea     rax, [rdi+419380h]
00007FF91DFF6664  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF666B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF666F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6673  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6678  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF667F  E8 7C 53 01 00              call    sub_7FF91E00BA00
00007FF91DFF6684  66 0F 6F 05 A4 59 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF668C  48 8D 05 95 51 5F 00        lea     rax, aHighCutA0; "High Cut A0"
00007FF91DFF6693  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6697  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF669B  48 8D 87 90 93 41 00        lea     rax, [rdi+419390h]
00007FF91DFF66A2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF66A9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF66AD  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF66B1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF66B6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF66BD  E8 3E 53 01 00              call    sub_7FF91E00BA00
00007FF91DFF66C2  66 0F 6F 05 66 59 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF66CA  48 8D 05 67 51 5F 00        lea     rax, aHighCutA1; "High Cut A1"
00007FF91DFF66D1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF66D5  48 8D 87 A0 93 41 00        lea     rax, [rdi+4193A0h]
00007FF91DFF66DC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF66E3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF66E8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF66EF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF66F3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF66F7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF66FB  E8 00 53 01 00              call    sub_7FF91E00BA00
00007FF91DFF6700  66 0F 6F 05 28 59 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6708  48 8D 05 39 51 5F 00        lea     rax, aHighCutB0; "High Cut B0"
00007FF91DFF670F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6713  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6717  48 8D 87 B0 93 41 00        lea     rax, [rdi+4193B0h]
00007FF91DFF671E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6725  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6729  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF672D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6732  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6739  E8 C2 52 01 00              call    sub_7FF91E00BA00
00007FF91DFF673E  66 0F 6F 05 EA 58 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6746  48 8D 05 0B 51 5F 00        lea     rax, aHighCutB2; "High Cut B2"
00007FF91DFF674D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6751  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6755  48 8D 87 C0 93 41 00        lea     rax, [rdi+4193C0h]
00007FF91DFF675C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6763  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6767  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF676B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6770  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6777  E8 84 52 01 00              call    sub_7FF91E00BA00
00007FF91DFF677C  66 0F 6F 05 AC 58 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6784  48 8D 05 DD 50 5F 00        lea     rax, aUseIirHighCutF; "Use IIR High Cut Filter"
00007FF91DFF678B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF678F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6793  48 8D 87 D0 93 41 00        lea     rax, [rdi+4193D0h]
00007FF91DFF679A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF67A1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF67A5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF67A9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF67AE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF67B5  E8 46 52 01 00              call    sub_7FF91E00BA00
00007FF91DFF67BA  66 0F 6F 05 6E 58 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF67C2  48 8D 05 B7 50 5F 00        lea     rax, aHighCutFc; "High Cut Fc"
00007FF91DFF67C9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF67CD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF67D1  48 8D 87 E0 93 41 00        lea     rax, [rdi+4193E0h]
00007FF91DFF67D8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF67DF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF67E3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF67E7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF67EC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF67F3  E8 08 52 01 00              call    sub_7FF91E00BA00
00007FF91DFF67F8  66 0F 6F 05 30 58 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6800  48 8D 05 89 50 5F 00        lea     rax, aHighCutQc; "High Cut Qc"
00007FF91DFF6807  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF680B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF680F  48 8D 87 F0 93 41 00        lea     rax, [rdi+4193F0h]
00007FF91DFF6816  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF681D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6821  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6825  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF682A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6831  E8 CA 51 01 00              call    sub_7FF91E00BA00
00007FF91DFF6836  66 0F 6F 05 F2 57 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF683E  48 8D 05 5B 50 5F 00        lea     rax, aHighCutSw; "High Cut Sw"
00007FF91DFF6845  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6849  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF684D  48 8D 87 00 94 41 00        lea     rax, [rdi+419400h]
00007FF91DFF6854  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF685B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF685F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6863  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6868  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF686F  E8 8C 51 01 00              call    sub_7FF91E00BA00
00007FF91DFF6874  66 0F 6F 05 B4 57 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF687C  48 8D 05 AD 4D 5F 00        lea     rax, aDryLevel; "Dry Level"
00007FF91DFF6883  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6887  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF688B  48 8D 87 10 94 41 00        lea     rax, [rdi+419410h]
00007FF91DFF6892  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6899  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF689D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF68A1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF68A6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF68AD  E8 4E 51 01 00              call    sub_7FF91E00BA00
00007FF91DFF68B2  66 0F 6F 05 76 57 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF68BA  48 8D 05 7F 4D 5F 00        lea     rax, aWetLevel; "Wet Level"
00007FF91DFF68C1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF68C5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF68C9  48 8D 87 20 94 41 00        lea     rax, [rdi+419420h]
00007FF91DFF68D0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF68D7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF68DB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF68DF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF68E4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF68EB  E8 10 51 01 00              call    sub_7FF91E00BA00
00007FF91DFF68F0  66 0F 6F 05 38 57 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF68F8  48 8D 05 4D 4D 5F 00        lea     rax, aIpFc; "Ip Fc"
00007FF91DFF68FF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6903  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6907  48 8D 87 30 94 41 00        lea     rax, [rdi+419430h]
00007FF91DFF690E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6915  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6919  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF691D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6922  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6929  E8 D2 50 01 00              call    sub_7FF91E00BA00
00007FF91DFF692E  66 0F 6F 05 FA 56 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6936  48 8D 05 E3 4F 5F 00        lea     rax, aTapTime; "Tap Time"
00007FF91DFF693D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6941  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6945  48 8D 87 40 94 41 00        lea     rax, [rdi+419440h]
00007FF91DFF694C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6953  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6957  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF695B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6960  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6967  E8 94 50 01 00              call    sub_7FF91E00BA00
00007FF91DFF696C  66 0F 6F 05 BC 56 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6974  48 8D 05 35 4F 5F 00        lea     rax, aFeedback_0; "Feedback"
00007FF91DFF697B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF697F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6983  48 8D 87 50 94 41 00        lea     rax, [rdi+419450h]
00007FF91DFF698A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6991  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6995  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6999  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF699E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF69A5  E8 56 50 01 00              call    sub_7FF91E00BA00
00007FF91DFF69AA  66 0F 6F 05 7E 56 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF69B2  48 8D 05 9B 4C 5F 00        lea     rax, aOnOff; "On/Off"
00007FF91DFF69B9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF69BD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF69C1  48 8D 87 60 94 41 00        lea     rax, [rdi+419460h]
00007FF91DFF69C8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF69CF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF69D3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF69D7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF69DC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF69E3  E8 18 50 01 00              call    sub_7FF91E00BA00
00007FF91DFF69E8  66 0F 6F 05 40 56 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF69F0  48 8D 05 71 4A 5F 00        lea     rax, aMute; "Mute"
00007FF91DFF69F7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF69FB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF69FF  48 8D 87 70 94 41 00        lea     rax, [rdi+419470h]
00007FF91DFF6A06  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6A0D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6A11  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6A15  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6A1A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6A21  E8 DA 4F 01 00              call    sub_7FF91E00BA00
00007FF91DFF6A26  66 0F 6F 05 02 56 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6A2E  48 8D 05 F7 4E 5F 00        lea     rax, aTapSw; "Tap Sw"
00007FF91DFF6A35  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6A39  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6A3D  48 8D 87 80 94 41 00        lea     rax, [rdi+419480h]
00007FF91DFF6A44  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6A4B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6A4F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6A53  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6A58  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6A5F  E8 9C 4F 01 00              call    sub_7FF91E00BA00
00007FF91DFF6A64  66 0F 6F 05 C4 55 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6A6C  48 8D 05 C5 4E 5F 00        lea     rax, aStereoSw; "Stereo Sw"
00007FF91DFF6A73  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6A77  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6A7E  48 8D 87 90 94 41 00        lea     rax, [rdi+419490h]
00007FF91DFF6A85  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6A8C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6A90  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6A94  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6A98  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6A9D  E8 5E 4F 01 00              call    sub_7FF91E00BA00
00007FF91DFF6AA2  66 0F 6F 05 86 55 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6AAA  48 8D 05 97 4E 5F 00        lea     rax, aWetGain; "Wet Gain"
00007FF91DFF6AB1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6AB5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6AB9  48 8D 87 A0 94 41 00        lea     rax, [rdi+4194A0h]
00007FF91DFF6AC0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6AC7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6ACB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6ACF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6AD4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6ADB  E8 20 4F 01 00              call    sub_7FF91E00BA00
00007FF91DFF6AE0  66 0F 6F 05 48 55 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6AE8  48 8D 05 D1 4D 5F 00        lea     rax, aLfDampFc; "LF Damp Fc"
00007FF91DFF6AEF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6AF3  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6AF7  48 8D 87 B0 94 41 00        lea     rax, [rdi+4194B0h]
00007FF91DFF6AFE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6B05  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6B09  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6B0D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6B12  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6B19  E8 E2 4E 01 00              call    sub_7FF91E00BA00
00007FF91DFF6B1E  66 0F 6F 05 0A 55 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6B26  48 8D 05 A3 4D 5F 00        lea     rax, aLfDampHp; "LF Damp Hp"
00007FF91DFF6B2D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6B31  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6B35  48 8D 87 C0 94 41 00        lea     rax, [rdi+4194C0h]
00007FF91DFF6B3C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6B43  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6B47  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6B4B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6B50  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6B57  E8 A4 4E 01 00              call    sub_7FF91E00BA00
00007FF91DFF6B5C  66 0F 6F 05 CC 54 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6B64  48 8D 05 75 4D 5F 00        lea     rax, aLfDampLp; "LF Damp Lp"
00007FF91DFF6B6B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6B6F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6B73  48 8D 87 D0 94 41 00        lea     rax, [rdi+4194D0h]
00007FF91DFF6B7A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6B81  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6B85  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6B89  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6B8E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6B95  E8 66 4E 01 00              call    sub_7FF91E00BA00
00007FF91DFF6B9A  66 0F 6F 05 8E 54 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6BA2  48 8D 05 47 4D 5F 00        lea     rax, aHfDampFc; "HF Damp Fc"
00007FF91DFF6BA9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6BAD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6BB1  48 8D 87 E0 94 41 00        lea     rax, [rdi+4194E0h]
00007FF91DFF6BB8  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6BBF  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6BC3  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6BC7  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6BCC  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6BD3  E8 28 4E 01 00              call    sub_7FF91E00BA00
00007FF91DFF6BD8  66 0F 6F 05 50 54 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6BE0  48 8D 05 19 4D 5F 00        lea     rax, aHfDampHp; "HF Damp Hp"
00007FF91DFF6BE7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6BEB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6BEF  48 8D 87 F0 94 41 00        lea     rax, [rdi+4194F0h]
00007FF91DFF6BF6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6BFD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6C01  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6C05  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6C0A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6C11  E8 EA 4D 01 00              call    sub_7FF91E00BA00
00007FF91DFF6C16  66 0F 6F 05 12 54 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6C1E  48 8D 05 EB 4C 5F 00        lea     rax, aHfDampLp; "HF Damp Lp"
00007FF91DFF6C25  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6C29  48 8D 87 00 95 41 00        lea     rax, [rdi+419500h]
00007FF91DFF6C30  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6C34  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6C3B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6C40  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6C47  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6C4B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6C4F  E8 AC 4D 01 00              call    sub_7FF91E00BA00
00007FF91DFF6C54  66 0F 6F 05 D4 53 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6C5C  48 8D 05 F5 4C 5F 00        lea     rax, aChorusCv; "Chorus CV"
00007FF91DFF6C63  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6C67  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6C6B  48 8D 87 B0 95 61 00        lea     rax, [rdi+6195B0h]
00007FF91DFF6C72  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6C79  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6C7D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6C81  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6C86  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6C8D  E8 6E 4D 01 00              call    sub_7FF91E00BA00
00007FF91DFF6C92  66 0F 6F 05 96 53 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6C9A  48 8D 05 C7 4C 5F 00        lea     rax, aChrusLfoSync; "Chrus LFO Sync"
00007FF91DFF6CA1  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6CA5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6CA9  48 8D 87 C0 95 61 00        lea     rax, [rdi+6195C0h]
00007FF91DFF6CB0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6CB7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6CBB  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6CBF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6CC4  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6CCB  E8 30 4D 01 00              call    sub_7FF91E00BA00
00007FF91DFF6CD0  48 8D 05 09 49 5F 00        lea     rax, aDelayTime; "Delay Time"
00007FF91DFF6CD7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6CDE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6CE2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6CE6  48 8D 87 E0 98 61 00        lea     rax, [rdi+6198E0h]
00007FF91DFF6CED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6CF4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF6CF7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6CFB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6CFF  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6D04  E8 F7 4C 01 00              call    sub_7FF91E00BA00
00007FF91DFF6D09  66 0F 6F 05 1F 53 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6D11  48 8D 05 60 4C 5F 00        lea     rax, aLfoCurve; "LFO Curve"
00007FF91DFF6D18  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6D1C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6D20  48 8D 87 F0 98 61 00        lea     rax, [rdi+6198F0h]
00007FF91DFF6D27  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6D2E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6D32  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6D36  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6D3B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6D42  E8 B9 4C 01 00              call    sub_7FF91E00BA00
00007FF91DFF6D47  66 0F 6F 05 E1 52 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6D4F  48 8D 05 32 4C 5F 00        lea     rax, aLfoManual; "LFO Manual"
00007FF91DFF6D56  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6D5A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6D5E  48 8D 87 00 99 61 00        lea     rax, [rdi+619900h]
00007FF91DFF6D65  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6D6C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6D70  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6D74  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6D79  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6D80  E8 7B 4C 01 00              call    sub_7FF91E00BA00
00007FF91DFF6D85  66 0F 6F 05 A3 52 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6D8D  48 8D 05 7C 48 5F 00        lea     rax, aLfoDepth; "LFO Depth"
00007FF91DFF6D94  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6D98  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6D9C  48 8D 87 10 99 61 00        lea     rax, [rdi+619910h]
00007FF91DFF6DA3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6DAA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6DAE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6DB2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6DB7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6DBE  E8 3D 4C 01 00              call    sub_7FF91E00BA00
00007FF91DFF6DC3  66 0F 6F 05 65 52 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6DCB  48 8D 05 46 4A 5F 00        lea     rax, aHighCutC0; "High Cut C0"
00007FF91DFF6DD2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6DD6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6DDA  48 8D 87 20 99 61 00        lea     rax, [rdi+619920h]
00007FF91DFF6DE1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6DE8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6DEC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6DF0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6DF5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6DFC  E8 FF 4B 01 00              call    sub_7FF91E00BA00
00007FF91DFF6E01  48 8D 05 20 4A 5F 00        lea     rax, aHighCutA0; "High Cut A0"
00007FF91DFF6E08  66 0F 6F 05 20 52 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6E10  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6E14  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6E18  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6E1C  48 8D 87 30 99 61 00        lea     rax, [rdi+619930h]
00007FF91DFF6E23  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6E2A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6E2E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6E33  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6E3A  E8 C1 4B 01 00              call    sub_7FF91E00BA00
00007FF91DFF6E3F  66 0F 6F 05 E9 51 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6E47  48 8D 05 EA 49 5F 00        lea     rax, aHighCutA1; "High Cut A1"
00007FF91DFF6E4E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6E52  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6E56  48 8D 87 40 99 61 00        lea     rax, [rdi+619940h]
00007FF91DFF6E5D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6E64  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6E68  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6E6C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6E71  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6E78  E8 83 4B 01 00              call    sub_7FF91E00BA00
00007FF91DFF6E7D  66 0F 6F 05 AB 51 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6E85  48 8D 05 BC 49 5F 00        lea     rax, aHighCutB0; "High Cut B0"
00007FF91DFF6E8C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6E90  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6E94  48 8D 87 50 99 61 00        lea     rax, [rdi+619950h]
00007FF91DFF6E9B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6EA2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6EA6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6EAA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6EAF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6EB6  E8 45 4B 01 00              call    sub_7FF91E00BA00
00007FF91DFF6EBB  66 0F 6F 05 6D 51 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6EC3  48 8D 05 8E 49 5F 00        lea     rax, aHighCutB2; "High Cut B2"
00007FF91DFF6ECA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6ECE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6ED2  48 8D 87 60 99 61 00        lea     rax, [rdi+619960h]
00007FF91DFF6ED9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6EE0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6EE4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6EE8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6EED  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6EF4  E8 07 4B 01 00              call    sub_7FF91E00BA00
00007FF91DFF6EF9  66 0F 6F 05 2F 51 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6F01  48 8D 05 60 49 5F 00        lea     rax, aUseIirHighCutF; "Use IIR High Cut Filter"
00007FF91DFF6F08  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6F0C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6F10  48 8D 87 70 99 61 00        lea     rax, [rdi+619970h]
00007FF91DFF6F17  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6F1E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6F22  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6F26  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6F2B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6F32  E8 C9 4A 01 00              call    sub_7FF91E00BA00
00007FF91DFF6F37  66 0F 6F 05 F1 50 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6F3F  48 8D 05 3A 49 5F 00        lea     rax, aHighCutFc; "High Cut Fc"
00007FF91DFF6F46  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6F4A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6F4E  48 8D 87 80 99 61 00        lea     rax, [rdi+619980h]
00007FF91DFF6F55  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6F5C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6F60  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6F64  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6F69  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6F70  E8 8B 4A 01 00              call    sub_7FF91E00BA00
00007FF91DFF6F75  66 0F 6F 05 B3 50 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6F7D  48 8D 05 0C 49 5F 00        lea     rax, aHighCutQc; "High Cut Qc"
00007FF91DFF6F84  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6F88  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6F8C  48 8D 87 90 99 61 00        lea     rax, [rdi+619990h]
00007FF91DFF6F93  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6F9A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6F9E  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6FA2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6FA7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6FAE  E8 4D 4A 01 00              call    sub_7FF91E00BA00
00007FF91DFF6FB3  66 0F 6F 05 75 50 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6FBB  48 8D 05 DE 48 5F 00        lea     rax, aHighCutSw; "High Cut Sw"
00007FF91DFF6FC2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF6FC6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF6FCB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF6FD2  48 8D 87 A0 99 61 00        lea     rax, [rdi+6199A0h]
00007FF91DFF6FD9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF6FE0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF6FE4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF6FE8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF6FEC  E8 0F 4A 01 00              call    sub_7FF91E00BA00
00007FF91DFF6FF1  66 0F 6F 05 37 50 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF6FF9  48 8D 05 98 49 5F 00        lea     rax, aLowCutFc; "Low Cut Fc"
00007FF91DFF7000  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7004  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7008  48 8D 87 B0 99 61 00        lea     rax, [rdi+6199B0h]
00007FF91DFF700F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7016  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF701A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF701E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7023  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF702A  E8 D1 49 01 00              call    sub_7FF91E00BA00
00007FF91DFF702F  66 0F 6F 05 F9 4F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7037  48 8D 05 6A 49 5F 00        lea     rax, aLowCutSw; "Low Cut Sw"
00007FF91DFF703E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7042  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7046  48 8D 87 C0 99 61 00        lea     rax, [rdi+6199C0h]
00007FF91DFF704D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7054  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7058  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF705C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7061  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7068  E8 93 49 01 00              call    sub_7FF91E00BA00
00007FF91DFF706D  66 0F 6F 05 BB 4F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7075  48 8D 05 B4 45 5F 00        lea     rax, aDryLevel; "Dry Level"
00007FF91DFF707C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7080  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7084  48 8D 87 D0 99 61 00        lea     rax, [rdi+6199D0h]
00007FF91DFF708B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7092  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7096  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF709A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF709F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF70A6  E8 55 49 01 00              call    sub_7FF91E00BA00
00007FF91DFF70AB  66 0F 6F 05 7D 4F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF70B3  48 8D 05 86 45 5F 00        lea     rax, aWetLevel; "Wet Level"
00007FF91DFF70BA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF70BE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF70C2  48 8D 87 E0 99 61 00        lea     rax, [rdi+6199E0h]
00007FF91DFF70C9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF70D0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF70D4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF70D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF70DD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF70E4  E8 17 49 01 00              call    sub_7FF91E00BA00
00007FF91DFF70E9  66 0F 6F 05 3F 4F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF70F1  48 8D 05 54 45 5F 00        lea     rax, aIpFc; "Ip Fc"
00007FF91DFF70F8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF70FC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7100  48 8D 87 F0 99 61 00        lea     rax, [rdi+6199F0h]
00007FF91DFF7107  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF710E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7112  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7116  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF711B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7122  E8 D9 48 01 00              call    sub_7FF91E00BA00
00007FF91DFF7127  66 0F 6F 05 01 4F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF712F  48 8D 05 7A 47 5F 00        lea     rax, aFeedback_0; "Feedback"
00007FF91DFF7136  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF713A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF713E  48 8D 87 00 9A 61 00        lea     rax, [rdi+619A00h]
00007FF91DFF7145  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF714C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7150  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7154  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7159  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7160  E8 9B 48 01 00              call    sub_7FF91E00BA00
00007FF91DFF7165  66 0F 6F 05 C3 4E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF716D  48 8D 05 E0 44 5F 00        lea     rax, aOnOff; "On/Off"
00007FF91DFF7174  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7178  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF717C  48 8D 87 10 9A 61 00        lea     rax, [rdi+619A10h]
00007FF91DFF7183  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF718A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF718E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7193  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF719A  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF719E  E8 5D 48 01 00              call    sub_7FF91E00BA00
00007FF91DFF71A3  66 0F 6F 05 85 4E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF71AB  48 8D 05 B6 42 5F 00        lea     rax, aMute; "Mute"
00007FF91DFF71B2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF71B6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF71BA  48 8D 87 20 9A 61 00        lea     rax, [rdi+619A20h]
00007FF91DFF71C1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF71C8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF71CC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF71D0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF71D5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF71DC  E8 1F 48 01 00              call    sub_7FF91E00BA00
00007FF91DFF71E1  66 0F 6F 05 47 4E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF71E9  48 8D 05 3C 47 5F 00        lea     rax, aTapSw; "Tap Sw"
00007FF91DFF71F0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF71F4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF71F8  48 8D 87 30 9A 61 00        lea     rax, [rdi+619A30h]
00007FF91DFF71FF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7206  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF720A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF720E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7213  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF721A  E8 E1 47 01 00              call    sub_7FF91E00BA00
00007FF91DFF721F  66 0F 6F 05 09 4E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7227  48 8D 05 0A 47 5F 00        lea     rax, aStereoSw; "Stereo Sw"
00007FF91DFF722E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7232  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7236  48 8D 87 40 9A 61 00        lea     rax, [rdi+619A40h]
00007FF91DFF723D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7244  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7248  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF724C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7251  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7258  E8 A3 47 01 00              call    sub_7FF91E00BA00
00007FF91DFF725D  66 0F 6F 05 CB 4D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7265  48 8D 05 4C 47 5F 00        lea     rax, aDryGain; "Dry Gain"
00007FF91DFF726C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7270  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7274  48 8D 87 50 9A 61 00        lea     rax, [rdi+619A50h]
00007FF91DFF727B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7282  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7286  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF728A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF728F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7296  E8 65 47 01 00              call    sub_7FF91E00BA00
00007FF91DFF729B  66 0F 6F 05 8D 4D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF72A3  48 8D 05 9E 46 5F 00        lea     rax, aWetGain; "Wet Gain"
00007FF91DFF72AA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF72AE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF72B2  48 8D 87 60 9A 61 00        lea     rax, [rdi+619A60h]
00007FF91DFF72B9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF72C0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF72C4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF72C8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF72CD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF72D4  E8 27 47 01 00              call    sub_7FF91E00BA00
00007FF91DFF72D9  66 0F 6F 05 4F 4D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF72E1  48 8D 05 E0 46 5F 00        lea     rax, aFlangerCv; "Flanger CV"
00007FF91DFF72E8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF72EC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF72F0  48 8D 87 20 1B 62 00        lea     rax, [rdi+621B20h]
00007FF91DFF72F7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF72FE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7302  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7306  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF730B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7312  E8 E9 46 01 00              call    sub_7FF91E00BA00
00007FF91DFF7317  66 0F 6F 05 11 4D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF731F  48 8D 05 B2 46 5F 00        lea     rax, aFlangerLfoSync; "Flanger LFO Sync"
00007FF91DFF7326  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF732A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF732E  48 8D 87 30 1B 62 00        lea     rax, [rdi+621B30h]
00007FF91DFF7335  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF733C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7340  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7344  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7349  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7350  E8 AB 46 01 00              call    sub_7FF91E00BA00
00007FF91DFF7355  48 8D 05 84 42 5F 00        lea     rax, aDelayTime; "Delay Time"
00007FF91DFF735C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7360  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF7363  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF736A  48 8D 87 00 1F 62 00        lea     rax, [rdi+621F00h]
00007FF91DFF7371  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7378  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF737C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7380  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7384  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7389  E8 72 46 01 00              call    sub_7FF91E00BA00
00007FF91DFF738E  66 0F 6F 05 9A 4C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7396  48 8D 05 DB 45 5F 00        lea     rax, aLfoCurve; "LFO Curve"
00007FF91DFF739D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF73A1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF73A5  48 8D 87 10 1F 62 00        lea     rax, [rdi+621F10h]
00007FF91DFF73AC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF73B3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF73B7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF73BB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF73C0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF73C7  E8 34 46 01 00              call    sub_7FF91E00BA00
00007FF91DFF73CC  66 0F 6F 05 5C 4C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF73D4  48 8D 05 AD 45 5F 00        lea     rax, aLfoManual; "LFO Manual"
00007FF91DFF73DB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF73DF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF73E3  48 8D 87 20 1F 62 00        lea     rax, [rdi+621F20h]
00007FF91DFF73EA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF73F1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF73F5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF73F9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF73FE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7405  E8 F6 45 01 00              call    sub_7FF91E00BA00
00007FF91DFF740A  66 0F 6F 05 1E 4C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7412  48 8D 05 F7 41 5F 00        lea     rax, aLfoDepth; "LFO Depth"
00007FF91DFF7419  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF741D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7421  48 8D 87 30 1F 62 00        lea     rax, [rdi+621F30h]
00007FF91DFF7428  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF742F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7433  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7437  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF743C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7443  E8 B8 45 01 00              call    sub_7FF91E00BA00
00007FF91DFF7448  66 0F 6F 05 E0 4B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7450  48 8D 05 C1 43 5F 00        lea     rax, aHighCutC0; "High Cut C0"
00007FF91DFF7457  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF745B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF745F  48 8D 87 40 1F 62 00        lea     rax, [rdi+621F40h]
00007FF91DFF7466  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF746D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7471  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7475  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF747A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7481  E8 7A 45 01 00              call    sub_7FF91E00BA00
00007FF91DFF7486  66 0F 6F 05 A2 4B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF748E  48 8D 05 93 43 5F 00        lea     rax, aHighCutA0; "High Cut A0"
00007FF91DFF7495  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7499  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF749D  48 8D 87 50 1F 62 00        lea     rax, [rdi+621F50h]
00007FF91DFF74A4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF74AB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF74AF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF74B3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF74B8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF74BF  E8 3C 45 01 00              call    sub_7FF91E00BA00
00007FF91DFF74C4  66 0F 6F 05 64 4B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF74CC  48 8D 05 65 43 5F 00        lea     rax, aHighCutA1; "High Cut A1"
00007FF91DFF74D3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF74D7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF74DB  48 8D 87 60 1F 62 00        lea     rax, [rdi+621F60h]
00007FF91DFF74E2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF74E9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF74ED  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF74F1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF74F6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF74FD  E8 FE 44 01 00              call    sub_7FF91E00BA00
00007FF91DFF7502  66 0F 6F 05 26 4B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF750A  48 8D 05 37 43 5F 00        lea     rax, aHighCutB0; "High Cut B0"
00007FF91DFF7511  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7515  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF751A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7521  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7528  48 8D 87 70 1F 62 00        lea     rax, [rdi+621F70h]
00007FF91DFF752F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7533  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7537  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF753B  E8 C0 44 01 00              call    sub_7FF91E00BA00
00007FF91DFF7540  66 0F 6F 05 E8 4A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7548  48 8D 05 09 43 5F 00        lea     rax, aHighCutB2; "High Cut B2"
00007FF91DFF754F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7553  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7557  48 8D 87 80 1F 62 00        lea     rax, [rdi+621F80h]
00007FF91DFF755E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7565  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7569  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF756D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7572  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7579  E8 82 44 01 00              call    sub_7FF91E00BA00
00007FF91DFF757E  66 0F 6F 05 AA 4A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7586  48 8D 05 DB 42 5F 00        lea     rax, aUseIirHighCutF; "Use IIR High Cut Filter"
00007FF91DFF758D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7591  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7595  48 8D 87 90 1F 62 00        lea     rax, [rdi+621F90h]
00007FF91DFF759C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF75A3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF75A7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF75AB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF75B0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF75B7  E8 44 44 01 00              call    sub_7FF91E00BA00
00007FF91DFF75BC  66 0F 6F 05 6C 4A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF75C4  48 8D 05 B5 42 5F 00        lea     rax, aHighCutFc; "High Cut Fc"
00007FF91DFF75CB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF75CF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF75D3  48 8D 87 A0 1F 62 00        lea     rax, [rdi+621FA0h]
00007FF91DFF75DA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF75E1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF75E5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF75E9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF75EE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF75F5  E8 06 44 01 00              call    sub_7FF91E00BA00
00007FF91DFF75FA  66 0F 6F 05 2E 4A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7602  48 8D 05 87 42 5F 00        lea     rax, aHighCutQc; "High Cut Qc"
00007FF91DFF7609  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF760D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7611  48 8D 87 B0 1F 62 00        lea     rax, [rdi+621FB0h]
00007FF91DFF7618  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF761F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7623  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7627  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF762C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7633  E8 C8 43 01 00              call    sub_7FF91E00BA00
00007FF91DFF7638  66 0F 6F 05 F0 49 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7640  48 8D 05 59 42 5F 00        lea     rax, aHighCutSw; "High Cut Sw"
00007FF91DFF7647  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF764B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF764F  48 8D 87 C0 1F 62 00        lea     rax, [rdi+621FC0h]
00007FF91DFF7656  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF765D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7661  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7665  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF766A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7671  E8 8A 43 01 00              call    sub_7FF91E00BA00
00007FF91DFF7676  66 0F 6F 05 B2 49 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF767E  48 8D 05 13 43 5F 00        lea     rax, aLowCutFc; "Low Cut Fc"
00007FF91DFF7685  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7689  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF768D  48 8D 87 D0 1F 62 00        lea     rax, [rdi+621FD0h]
00007FF91DFF7694  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF769B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF769F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF76A3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF76A8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF76AF  E8 4C 43 01 00              call    sub_7FF91E00BA00
00007FF91DFF76B4  66 0F 6F 05 74 49 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF76BC  48 8D 05 E5 42 5F 00        lea     rax, aLowCutSw; "Low Cut Sw"
00007FF91DFF76C3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF76C7  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF76CB  48 8D 87 E0 1F 62 00        lea     rax, [rdi+621FE0h]
00007FF91DFF76D2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF76D9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF76DD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF76E1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF76E6  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF76ED  E8 0E 43 01 00              call    sub_7FF91E00BA00
00007FF91DFF76F2  66 0F 6F 05 36 49 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF76FA  48 8D 05 2F 3F 5F 00        lea     rax, aDryLevel; "Dry Level"
00007FF91DFF7701  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7705  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7709  48 8D 87 F0 1F 62 00        lea     rax, [rdi+621FF0h]
00007FF91DFF7710  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7717  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF771B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF771F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7724  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF772B  E8 D0 42 01 00              call    sub_7FF91E00BA00
00007FF91DFF7730  66 0F 6F 05 F8 48 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7738  48 8D 05 01 3F 5F 00        lea     rax, aWetLevel; "Wet Level"
00007FF91DFF773F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7743  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7747  48 8D 87 00 20 62 00        lea     rax, [rdi+622000h]
00007FF91DFF774E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7755  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7759  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF775D  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7762  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7769  E8 92 42 01 00              call    sub_7FF91E00BA00
00007FF91DFF776E  66 0F 6F 05 BA 48 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7776  48 8D 05 CF 3E 5F 00        lea     rax, aIpFc; "Ip Fc"
00007FF91DFF777D  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7781  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7785  48 8D 87 10 20 62 00        lea     rax, [rdi+622010h]
00007FF91DFF778C  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7793  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7797  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF779B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF77A0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF77A7  E8 54 42 01 00              call    sub_7FF91E00BA00
00007FF91DFF77AC  66 0F 6F 05 7C 48 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF77B4  48 8D 05 F5 40 5F 00        lea     rax, aFeedback_0; "Feedback"
00007FF91DFF77BB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF77BF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF77C3  48 8D 87 20 20 62 00        lea     rax, [rdi+622020h]
00007FF91DFF77CA  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF77D1  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF77D5  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF77D9  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF77DE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF77E5  E8 16 42 01 00              call    sub_7FF91E00BA00
00007FF91DFF77EA  66 0F 6F 05 3E 48 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF77F2  48 8D 05 5B 3E 5F 00        lea     rax, aOnOff; "On/Off"
00007FF91DFF77F9  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF77FD  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7801  48 8D 87 30 20 62 00        lea     rax, [rdi+622030h]
00007FF91DFF7808  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF780F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7813  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7817  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF781C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7823  E8 D8 41 01 00              call    sub_7FF91E00BA00
00007FF91DFF7828  66 0F 6F 05 00 48 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7830  48 8D 05 31 3C 5F 00        lea     rax, aMute; "Mute"
00007FF91DFF7837  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF783B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF783F  48 8D 87 40 20 62 00        lea     rax, [rdi+622040h]
00007FF91DFF7846  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF784D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7851  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7855  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF785A  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7861  E8 9A 41 01 00              call    sub_7FF91E00BA00
00007FF91DFF7866  66 0F 6F 05 C2 47 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF786E  48 8D 05 7B 41 5F 00        lea     rax, aLfoStPhase; "LFO St.Phase"
00007FF91DFF7875  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7879  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF787D  48 8D 87 50 20 62 00        lea     rax, [rdi+622050h]
00007FF91DFF7884  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF788B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF788F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7893  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7898  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF789F  E8 5C 41 01 00              call    sub_7FF91E00BA00
00007FF91DFF78A4  48 8D 05 55 41 5F 00        lea     rax, aLfoStOfst; "LFO St.Ofst"
00007FF91DFF78AB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF78B2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF78B6  66 0F 6F 05 72 47 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF78BE  48 8D 87 60 20 62 00        lea     rax, [rdi+622060h]
00007FF91DFF78C5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF78C9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF78CD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF78D1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF78D8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF78DD  E8 1E 41 01 00              call    sub_7FF91E00BA00
00007FF91DFF78E2  48 8D 05 F7 3C 5F 00        lea     rax, aDelayTime; "Delay Time"
00007FF91DFF78E9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF78F0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF78F4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF78F8  48 8D 87 90 23 63 00        lea     rax, [rdi+632390h]
00007FF91DFF78FF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7906  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF7909  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF790D  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7911  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7916  E8 E5 40 01 00              call    sub_7FF91E00BA00
00007FF91DFF791B  66 0F 6F 05 0D 47 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7923  48 8D 05 EE 3E 5F 00        lea     rax, aHighCutC0; "High Cut C0"
00007FF91DFF792A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF792E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7932  48 8D 87 A0 23 63 00        lea     rax, [rdi+6323A0h]
00007FF91DFF7939  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7940  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7944  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7948  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF794D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7954  E8 A7 40 01 00              call    sub_7FF91E00BA00
00007FF91DFF7959  66 0F 6F 05 CF 46 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7961  48 8D 05 C0 3E 5F 00        lea     rax, aHighCutA0; "High Cut A0"
00007FF91DFF7968  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF796C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7970  48 8D 87 B0 23 63 00        lea     rax, [rdi+6323B0h]
00007FF91DFF7977  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF797E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7982  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7986  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF798B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7992  E8 69 40 01 00              call    sub_7FF91E00BA00
00007FF91DFF7997  66 0F 6F 05 91 46 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF799F  48 8D 05 92 3E 5F 00        lea     rax, aHighCutA1; "High Cut A1"
00007FF91DFF79A6  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF79AA  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF79AE  48 8D 87 C0 23 63 00        lea     rax, [rdi+6323C0h]
00007FF91DFF79B5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF79BC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF79C0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF79C4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF79C9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF79D0  E8 2B 40 01 00              call    sub_7FF91E00BA00
00007FF91DFF79D5  66 0F 6F 05 53 46 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF79DD  48 8D 05 64 3E 5F 00        lea     rax, aHighCutB0; "High Cut B0"
00007FF91DFF79E4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF79E8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF79EC  48 8D 87 D0 23 63 00        lea     rax, [rdi+6323D0h]
00007FF91DFF79F3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF79FA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF79FE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7A02  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7A07  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7A0E  E8 ED 3F 01 00              call    sub_7FF91E00BA00
00007FF91DFF7A13  66 0F 6F 05 15 46 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7A1B  48 8D 05 36 3E 5F 00        lea     rax, aHighCutB2; "High Cut B2"
00007FF91DFF7A22  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7A26  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7A2A  48 8D 87 E0 23 63 00        lea     rax, [rdi+6323E0h]
00007FF91DFF7A31  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7A38  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7A3C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7A40  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7A45  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7A4C  E8 AF 3F 01 00              call    sub_7FF91E00BA00
00007FF91DFF7A51  66 0F 6F 05 D7 45 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7A59  48 8D 05 08 3E 5F 00        lea     rax, aUseIirHighCutF; "Use IIR High Cut Filter"
00007FF91DFF7A60  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7A64  48 8D 87 F0 23 63 00        lea     rax, [rdi+6323F0h]
00007FF91DFF7A6B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7A72  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7A77  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7A7E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7A82  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7A86  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7A8A  E8 71 3F 01 00              call    sub_7FF91E00BA00
00007FF91DFF7A8F  66 0F 6F 05 99 45 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7A97  48 8D 05 E2 3D 5F 00        lea     rax, aHighCutFc; "High Cut Fc"
00007FF91DFF7A9E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7AA2  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7AA6  48 8D 87 00 24 63 00        lea     rax, [rdi+632400h]
00007FF91DFF7AAD  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7AB4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7AB8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7ABC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7AC1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7AC8  E8 33 3F 01 00              call    sub_7FF91E00BA00
00007FF91DFF7ACD  66 0F 6F 05 5B 45 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7AD5  48 8D 05 B4 3D 5F 00        lea     rax, aHighCutQc; "High Cut Qc"
00007FF91DFF7ADC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7AE0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7AE4  48 8D 87 10 24 63 00        lea     rax, [rdi+632410h]
00007FF91DFF7AEB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7AF2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7AF6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7AFA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7AFF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7B06  E8 F5 3E 01 00              call    sub_7FF91E00BA00
00007FF91DFF7B0B  66 0F 6F 05 1D 45 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7B13  48 8D 05 86 3D 5F 00        lea     rax, aHighCutSw; "High Cut Sw"
00007FF91DFF7B1A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7B1E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7B22  48 8D 87 20 24 63 00        lea     rax, [rdi+632420h]
00007FF91DFF7B29  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7B30  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7B34  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7B38  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7B3D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7B44  E8 B7 3E 01 00              call    sub_7FF91E00BA00
00007FF91DFF7B49  66 0F 6F 05 DF 44 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7B51  48 8D 05 D8 3A 5F 00        lea     rax, aDryLevel; "Dry Level"
00007FF91DFF7B58  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7B5C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7B60  48 8D 87 30 24 63 00        lea     rax, [rdi+632430h]
00007FF91DFF7B67  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7B6E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7B72  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7B76  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7B7B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7B82  E8 79 3E 01 00              call    sub_7FF91E00BA00
00007FF91DFF7B87  66 0F 6F 05 A1 44 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7B8F  48 8D 05 AA 3A 5F 00        lea     rax, aWetLevel; "Wet Level"
00007FF91DFF7B96  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7B9A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7B9E  48 8D 87 40 24 63 00        lea     rax, [rdi+632440h]
00007FF91DFF7BA5  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7BAC  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7BB0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7BB4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7BB9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7BC0  E8 3B 3E 01 00              call    sub_7FF91E00BA00
00007FF91DFF7BC5  66 0F 6F 05 63 44 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7BCD  48 8D 05 78 3A 5F 00        lea     rax, aIpFc; "Ip Fc"
00007FF91DFF7BD4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7BD8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7BDC  48 8D 87 50 24 63 00        lea     rax, [rdi+632450h]
00007FF91DFF7BE3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7BEA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7BEE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7BF2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7BF7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7BFE  E8 FD 3D 01 00              call    sub_7FF91E00BA00
00007FF91DFF7C03  66 0F 6F 05 25 44 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7C0B  48 8D 05 9E 3C 5F 00        lea     rax, aFeedback_0; "Feedback"
00007FF91DFF7C12  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7C16  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7C1A  48 8D 87 60 24 63 00        lea     rax, [rdi+632460h]
00007FF91DFF7C21  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7C28  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7C2C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7C30  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7C35  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7C3C  E8 BF 3D 01 00              call    sub_7FF91E00BA00
00007FF91DFF7C41  66 0F 6F 05 E7 43 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7C49  48 8D 05 04 3A 5F 00        lea     rax, aOnOff; "On/Off"
00007FF91DFF7C50  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7C54  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7C58  48 8D 87 70 24 63 00        lea     rax, [rdi+632470h]
00007FF91DFF7C5F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7C66  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7C6A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7C6E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7C73  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7C7A  E8 81 3D 01 00              call    sub_7FF91E00BA00
00007FF91DFF7C7F  66 0F 6F 05 A9 43 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7C87  48 8D 05 DA 37 5F 00        lea     rax, aMute; "Mute"
00007FF91DFF7C8E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7C92  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7C96  48 8D 87 80 24 63 00        lea     rax, [rdi+632480h]
00007FF91DFF7C9D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7CA4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7CA8  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7CAC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7CB1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7CB8  E8 43 3D 01 00              call    sub_7FF91E00BA00
00007FF91DFF7CBD  66 0F 6F 05 6B 43 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7CC5  48 8D 05 F4 3B 5F 00        lea     rax, aLfDampFc; "LF Damp Fc"
00007FF91DFF7CCC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7CD0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7CD4  48 8D 87 90 24 63 00        lea     rax, [rdi+632490h]
00007FF91DFF7CDB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7CE2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7CE6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7CEA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7CEF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7CF6  E8 05 3D 01 00              call    sub_7FF91E00BA00
00007FF91DFF7CFB  66 0F 6F 05 2D 43 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7D03  48 8D 05 C6 3B 5F 00        lea     rax, aLfDampHp; "LF Damp Hp"
00007FF91DFF7D0A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7D0E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7D12  48 8D 87 A0 24 63 00        lea     rax, [rdi+6324A0h]
00007FF91DFF7D19  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7D20  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7D24  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7D28  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7D2D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7D34  E8 C7 3C 01 00              call    sub_7FF91E00BA00
00007FF91DFF7D39  66 0F 6F 05 EF 42 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7D41  48 8D 05 98 3B 5F 00        lea     rax, aLfDampLp; "LF Damp Lp"
00007FF91DFF7D48  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7D4C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7D50  48 8D 87 B0 24 63 00        lea     rax, [rdi+6324B0h]
00007FF91DFF7D57  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7D5E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7D62  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7D66  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7D6B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7D72  E8 89 3C 01 00              call    sub_7FF91E00BA00
00007FF91DFF7D77  66 0F 6F 05 B1 42 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7D7F  48 8D 05 6A 3B 5F 00        lea     rax, aHfDampFc; "HF Damp Fc"
00007FF91DFF7D86  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7D8A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7D8E  48 8D 87 C0 24 63 00        lea     rax, [rdi+6324C0h]
00007FF91DFF7D95  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7D9C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7DA0  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7DA4  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7DA9  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7DB0  E8 4B 3C 01 00              call    sub_7FF91E00BA00
00007FF91DFF7DB5  66 0F 6F 05 73 42 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7DBD  48 8D 05 3C 3B 5F 00        lea     rax, aHfDampHp; "HF Damp Hp"
00007FF91DFF7DC4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7DC8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7DCC  48 8D 87 D0 24 63 00        lea     rax, [rdi+6324D0h]
00007FF91DFF7DD3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7DDA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7DDE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7DE2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7DE7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7DEE  E8 0D 3C 01 00              call    sub_7FF91E00BA00
00007FF91DFF7DF3  66 0F 6F 05 35 42 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7DFB  48 8D 05 0E 3B 5F 00        lea     rax, aHfDampLp; "HF Damp Lp"
00007FF91DFF7E02  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7E06  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7E0D  48 8D 87 E0 24 63 00        lea     rax, [rdi+6324E0h]
00007FF91DFF7E14  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7E1B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7E1F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7E23  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7E27  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7E2C  E8 CF 3B 01 00              call    sub_7FF91E00BA00
00007FF91DFF7E31  66 0F 6F 05 F7 41 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7E39  48 8D 05 18 3B 5F 00        lea     rax, aChorusCv; "Chorus CV"
00007FF91DFF7E40  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7E44  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7E48  48 8D 87 B0 25 A3 00        lea     rax, [rdi+0A325B0h]
00007FF91DFF7E4F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7E56  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7E5A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7E5E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7E63  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7E6A  E8 91 3B 01 00              call    sub_7FF91E00BA00
00007FF91DFF7E6F  66 0F 6F 05 B9 41 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7E77  48 8D 05 EA 3A 5F 00        lea     rax, aChrusLfoSync; "Chrus LFO Sync"
00007FF91DFF7E7E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7E82  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7E86  48 8D 87 C0 25 A3 00        lea     rax, [rdi+0A325C0h]
00007FF91DFF7E8D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7E94  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7E98  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7E9C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7EA1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7EA8  E8 53 3B 01 00              call    sub_7FF91E00BA00
00007FF91DFF7EAD  48 8D 05 2C 37 5F 00        lea     rax, aDelayTime; "Delay Time"
00007FF91DFF7EB4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7EBB  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7EBF  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7EC3  48 8D 87 90 29 A3 00        lea     rax, [rdi+0A32990h]
00007FF91DFF7ECA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7ED1  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF7ED4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7ED8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7EDC  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7EE1  E8 1A 3B 01 00              call    sub_7FF91E00BA00
00007FF91DFF7EE6  66 0F 6F 05 42 41 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7EEE  48 8D 05 83 3A 5F 00        lea     rax, aLfoCurve; "LFO Curve"
00007FF91DFF7EF5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7EF9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7EFD  48 8D 87 A0 29 A3 00        lea     rax, [rdi+0A329A0h]
00007FF91DFF7F04  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7F0B  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7F0F  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7F13  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7F18  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7F1F  E8 DC 3A 01 00              call    sub_7FF91E00BA00
00007FF91DFF7F24  66 0F 6F 05 04 41 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7F2C  48 8D 05 55 3A 5F 00        lea     rax, aLfoManual; "LFO Manual"
00007FF91DFF7F33  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7F37  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7F3B  48 8D 87 B0 29 A3 00        lea     rax, [rdi+0A329B0h]
00007FF91DFF7F42  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7F49  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7F4D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7F51  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7F56  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7F5D  E8 9E 3A 01 00              call    sub_7FF91E00BA00
00007FF91DFF7F62  66 0F 6F 05 C6 40 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7F6A  48 8D 05 9F 36 5F 00        lea     rax, aLfoDepth; "LFO Depth"
00007FF91DFF7F71  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7F75  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7F79  48 8D 87 C0 29 A3 00        lea     rax, [rdi+0A329C0h]
00007FF91DFF7F80  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7F87  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7F8B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7F8F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7F94  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7F9B  E8 60 3A 01 00              call    sub_7FF91E00BA00
00007FF91DFF7FA0  66 0F 6F 05 88 40 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7FA8  48 8D 05 69 38 5F 00        lea     rax, aHighCutC0; "High Cut C0"
00007FF91DFF7FAF  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7FB3  48 8D 87 D0 29 A3 00        lea     rax, [rdi+0A329D0h]
00007FF91DFF7FBA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF7FBE  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF7FC5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF7FCA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF7FD1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7FD5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF7FD9  E8 22 3A 01 00              call    sub_7FF91E00BA00
00007FF91DFF7FDE  66 0F 6F 05 4A 40 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF7FE6  48 8D 05 3B 38 5F 00        lea     rax, aHighCutA0; "High Cut A0"
00007FF91DFF7FED  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF7FF1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF7FF5  48 8D 87 E0 29 A3 00        lea     rax, [rdi+0A329E0h]
00007FF91DFF7FFC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8003  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8007  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF800B  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8010  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8017  E8 E4 39 01 00              call    sub_7FF91E00BA00
00007FF91DFF801C  66 0F 6F 05 0C 40 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8024  48 8D 05 0D 38 5F 00        lea     rax, aHighCutA1; "High Cut A1"
00007FF91DFF802B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF802F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8033  48 8D 87 F0 29 A3 00        lea     rax, [rdi+0A329F0h]
00007FF91DFF803A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8041  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8045  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8049  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF804E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8055  E8 A6 39 01 00              call    sub_7FF91E00BA00
00007FF91DFF805A  66 0F 6F 05 CE 3F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8062  48 8D 05 DF 37 5F 00        lea     rax, aHighCutB0; "High Cut B0"
00007FF91DFF8069  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF806D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8071  48 8D 87 00 2A A3 00        lea     rax, [rdi+0A32A00h]
00007FF91DFF8078  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF807F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8083  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8087  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF808C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8093  E8 68 39 01 00              call    sub_7FF91E00BA00
00007FF91DFF8098  66 0F 6F 05 90 3F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF80A0  48 8D 05 B1 37 5F 00        lea     rax, aHighCutB2; "High Cut B2"
00007FF91DFF80A7  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF80AB  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF80AF  48 8D 87 10 2A A3 00        lea     rax, [rdi+0A32A10h]
00007FF91DFF80B6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF80BD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF80C1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF80C5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF80CA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF80D1  E8 2A 39 01 00              call    sub_7FF91E00BA00
00007FF91DFF80D6  66 0F 6F 05 52 3F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF80DE  48 8D 05 83 37 5F 00        lea     rax, aUseIirHighCutF; "Use IIR High Cut Filter"
00007FF91DFF80E5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF80E9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF80ED  48 8D 87 20 2A A3 00        lea     rax, [rdi+0A32A20h]
00007FF91DFF80F4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF80FB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF80FF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8103  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8108  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF810F  E8 EC 38 01 00              call    sub_7FF91E00BA00
00007FF91DFF8114  66 0F 6F 05 14 3F 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF811C  48 8D 05 5D 37 5F 00        lea     rax, aHighCutFc; "High Cut Fc"
00007FF91DFF8123  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8127  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF812B  48 8D 87 30 2A A3 00        lea     rax, [rdi+0A32A30h]
00007FF91DFF8132  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8139  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF813D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8141  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8146  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF814D  E8 AE 38 01 00              call    sub_7FF91E00BA00
00007FF91DFF8152  66 0F 6F 05 D6 3E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF815A  48 8D 05 2F 37 5F 00        lea     rax, aHighCutQc; "High Cut Qc"
00007FF91DFF8161  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8165  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8169  48 8D 87 40 2A A3 00        lea     rax, [rdi+0A32A40h]
00007FF91DFF8170  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8177  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF817B  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF817F  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8184  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF818B  E8 70 38 01 00              call    sub_7FF91E00BA00
00007FF91DFF8190  48 8D 05 09 37 5F 00        lea     rax, aHighCutSw; "High Cut Sw"
00007FF91DFF8197  66 0F 6F 05 91 3E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF819F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF81A3  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF81A7  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF81AB  48 8D 87 50 2A A3 00        lea     rax, [rdi+0A32A50h]
00007FF91DFF81B2  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF81B9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF81BD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF81C2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF81C9  E8 32 38 01 00              call    sub_7FF91E00BA00
00007FF91DFF81CE  66 0F 6F 05 5A 3E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF81D6  48 8D 05 BB 37 5F 00        lea     rax, aLowCutFc; "Low Cut Fc"
00007FF91DFF81DD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF81E1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF81E5  48 8D 87 60 2A A3 00        lea     rax, [rdi+0A32A60h]
00007FF91DFF81EC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF81F3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF81F7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF81FB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8200  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8207  E8 F4 37 01 00              call    sub_7FF91E00BA00
00007FF91DFF820C  66 0F 6F 05 1C 3E 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8214  48 8D 05 8D 37 5F 00        lea     rax, aLowCutSw; "Low Cut Sw"
00007FF91DFF821B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF821F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8223  48 8D 87 70 2A A3 00        lea     rax, [rdi+0A32A70h]
00007FF91DFF822A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8231  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8235  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8239  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF823E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8245  E8 B6 37 01 00              call    sub_7FF91E00BA00
00007FF91DFF824A  66 0F 6F 05 DE 3D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8252  48 8D 05 D7 33 5F 00        lea     rax, aDryLevel; "Dry Level"
00007FF91DFF8259  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF825D  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8261  48 8D 87 80 2A A3 00        lea     rax, [rdi+0A32A80h]
00007FF91DFF8268  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF826F  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8273  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8277  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF827C  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8283  E8 78 37 01 00              call    sub_7FF91E00BA00
00007FF91DFF8288  66 0F 6F 05 A0 3D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8290  48 8D 05 A9 33 5F 00        lea     rax, aWetLevel; "Wet Level"
00007FF91DFF8297  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF829B  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF829F  48 8D 87 90 2A A3 00        lea     rax, [rdi+0A32A90h]
00007FF91DFF82A6  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF82AD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF82B1  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF82B5  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF82BA  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF82C1  E8 3A 37 01 00              call    sub_7FF91E00BA00
00007FF91DFF82C6  66 0F 6F 05 62 3D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF82CE  48 8D 05 77 33 5F 00        lea     rax, aIpFc; "Ip Fc"
00007FF91DFF82D5  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF82D9  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF82DD  48 8D 87 A0 2A A3 00        lea     rax, [rdi+0A32AA0h]
00007FF91DFF82E4  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF82EB  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF82EF  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF82F3  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF82F8  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF82FF  E8 FC 36 01 00              call    sub_7FF91E00BA00
00007FF91DFF8304  66 0F 6F 05 24 3D 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF830C  48 8D 05 9D 35 5F 00        lea     rax, aFeedback_0; "Feedback"
00007FF91DFF8313  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8317  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF831B  48 8D 87 B0 2A A3 00        lea     rax, [rdi+0A32AB0h]
00007FF91DFF8322  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8329  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF832D  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8331  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8336  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF833D  E8 BE 36 01 00              call    sub_7FF91E00BA00
00007FF91DFF8342  66 0F 6F 05 E6 3C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF834A  48 8D 05 03 33 5F 00        lea     rax, aOnOff; "On/Off"
00007FF91DFF8351  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8355  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF835A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8361  48 8D 87 C0 2A A3 00        lea     rax, [rdi+0A32AC0h]
00007FF91DFF8368  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF836F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8373  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8377  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF837B  E8 80 36 01 00              call    sub_7FF91E00BA00
00007FF91DFF8380  66 0F 6F 05 A8 3C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8388  48 8D 05 D9 30 5F 00        lea     rax, aMute; "Mute"
00007FF91DFF838F  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8393  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8397  48 8D 87 D0 2A A3 00        lea     rax, [rdi+0A32AD0h]
00007FF91DFF839E  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF83A5  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF83A9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF83AD  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF83B2  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF83B9  E8 42 36 01 00              call    sub_7FF91E00BA00
00007FF91DFF83BE  66 0F 6F 05 6A 3C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF83C6  48 8D 05 23 36 5F 00        lea     rax, aLfoStPhase; "LFO St.Phase"
00007FF91DFF83CD  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF83D1  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF83D5  48 8D 87 E0 2A A3 00        lea     rax, [rdi+0A32AE0h]
00007FF91DFF83DC  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF83E3  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF83E7  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF83EB  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF83F0  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF83F7  E8 04 36 01 00              call    sub_7FF91E00BA00
00007FF91DFF83FC  66 0F 6F 05 2C 3C 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8404  48 8D 05 F5 35 5F 00        lea     rax, aLfoStOfst; "LFO St.Ofst"
00007FF91DFF840B  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF840F  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8413  48 8D 87 F0 2A A3 00        lea     rax, [rdi+0A32AF0h]
00007FF91DFF841A  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8421  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8425  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8429  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF842E  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8435  E8 C6 35 01 00              call    sub_7FF91E00BA00
00007FF91DFF843A  48 8D 05 CF 35 5F 00        lea     rax, aRevDpmPredly; "Rev Dpm PreDly"
00007FF91DFF8441  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8448  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF844C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8450  48 8D 87 C0 2C A4 00        lea     rax, [rdi+0A42CC0h]
00007FF91DFF8457  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF845E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFF8461  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8465  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8469  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF846E  E8 CD 35 01 00              call    sub_7FF91E00BA40
00007FF91DFF8473  66 0F 6F 05 B5 3B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF847B  48 8D 05 9E 35 5F 00        lea     rax, aRevEcfOn; "Rev Ecf On"
00007FF91DFF8482  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8486  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF848A  48 8D 87 D0 2C A4 00        lea     rax, [rdi+0A42CD0h]
00007FF91DFF8491  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8498  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF849C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF84A0  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF84A5  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF84AC  E8 8F 35 01 00              call    sub_7FF91E00BA40
00007FF91DFF84B1  66 0F 6F 05 77 3B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF84B9  48 8D 05 70 35 5F 00        lea     rax, aRevEcfDensity; "Rev Ecf Density"
00007FF91DFF84C0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF84C4  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF84C8  48 8D 87 E0 2C A4 00        lea     rax, [rdi+0A42CE0h]
00007FF91DFF84CF  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF84D6  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF84DA  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF84DE  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF84E3  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF84EA  E8 51 35 01 00              call    sub_7FF91E00BA40
00007FF91DFF84EF  66 0F 6F 05 39 3B 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF84F7  48 8D 05 42 35 5F 00        lea     rax, aRevEcfLevel; "Rev Ecf Level"
00007FF91DFF84FE  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8502  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8506  48 8D 87 F0 2C A4 00        lea     rax, [rdi+0A42CF0h]
00007FF91DFF850D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8514  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8518  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF851D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8524  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8528  E8 13 35 01 00              call    sub_7FF91E00BA40
00007FF91DFF852D  66 0F 6F 05 FB 3A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8535  48 8D 05 14 35 5F 00        lea     rax, aRevEcfDirLev; "Rev Ecf Dir Lev"
00007FF91DFF853C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8540  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8544  48 8D 87 00 2D A4 00        lea     rax, [rdi+0A42D00h]
00007FF91DFF854B  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8552  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8556  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF855A  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF855F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8566  E8 D5 34 01 00              call    sub_7FF91E00BA40
00007FF91DFF856B  66 0F 6F 05 BD 3A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8573  48 8D 05 E6 34 5F 00        lea     rax, aRevEcfGlbLev; "Rev Ecf Glb Lev"
00007FF91DFF857A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF857E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8582  48 8D 87 10 2D A4 00        lea     rax, [rdi+0A42D10h]
00007FF91DFF8589  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8590  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8594  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8598  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF859D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF85A4  E8 97 34 01 00              call    sub_7FF91E00BA40
00007FF91DFF85A9  66 0F 6F 05 7F 3A 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF85B1  48 8D 05 B8 34 5F 00        lea     rax, aRevEcfMute; "Rev Ecf Mute"
00007FF91DFF85B8  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF85BC  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF85C0  48 8D 87 20 2D A4 00        lea     rax, [rdi+0A42D20h]
00007FF91DFF85C7  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF85CE  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF85D2  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF85D6  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF85DB  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF85E2  E8 59 34 01 00              call    sub_7FF91E00BA40
00007FF91DFF85E7  F3 0F 10 05 89 26 5F 00     movss   xmm0, cs:dword_7FF91E5EAC78
00007FF91DFF85EF  48 8D 05 8A 34 5F 00        lea     rax, aRevEcfInAtt; "Rev Ecf In Att "
00007FF91DFF85F6  66 0F 6F 0D 32 3A 5F 00     movdqa  xmm1, cs:xmmword_7FF91E5EC030
00007FF91DFF85FE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8602  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8606  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF860A  48 8D 87 30 2D A4 00        lea     rax, [rdi+0A42D30h]
00007FF91DFF8611  F3 0F 11 45 8F              movss   [rbp+57h+var_C8], xmm0
00007FF91DFF8616  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF861A  F3 0F 7F 4D 93              movdqu  [rbp+57h+var_C4], xmm1
00007FF91DFF861F  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8626  E8 15 34 01 00              call    sub_7FF91E00BA40
00007FF91DFF862B  66 0F 6F 05 FD 39 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8633  48 8D 05 56 34 5F 00        lea     rax, aRevEcfDepth; "Rev Ecf Depth"
00007FF91DFF863A  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF863E  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8642  48 8D 87 40 2D A4 00        lea     rax, [rdi+0A42D40h]
00007FF91DFF8649  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8650  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8654  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8658  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF865D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8664  E8 D7 33 01 00              call    sub_7FF91E00BA40
00007FF91DFF8669  F3 0F 10 05 F3 35 5F 00     movss   xmm0, cs:dword_7FF91E5EBC64
00007FF91DFF8671  48 8D 05 28 34 5F 00        lea     rax, aRevEcfRate; "Rev Ecf Rate"
00007FF91DFF8678  66 0F 6F 0D B0 39 5F 00     movdqa  xmm1, cs:xmmword_7FF91E5EC030
00007FF91DFF8680  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8684  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8688  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF868C  48 8D 87 50 2D A4 00        lea     rax, [rdi+0A42D50h]
00007FF91DFF8693  F3 0F 11 45 8F              movss   [rbp+57h+var_C8], xmm0
00007FF91DFF8698  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF869C  F3 0F 7F 4D 93              movdqu  [rbp+57h+var_C4], xmm1
00007FF91DFF86A1  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF86A8  E8 93 33 01 00              call    sub_7FF91E00BA40
00007FF91DFF86AD  66 0F 6F 05 7B 39 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF86B5  48 8D 05 F4 33 5F 00        lea     rax, aRevEcfHpfC0; "Rev Ecf HPF C0"
00007FF91DFF86BC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF86C0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF86C4  48 8D 87 60 2D A4 00        lea     rax, [rdi+0A42D60h]
00007FF91DFF86CB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF86D2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF86D6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF86DA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF86DF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF86E6  E8 55 33 01 00              call    sub_7FF91E00BA40
00007FF91DFF86EB  66 0F 6F 05 3D 39 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF86F3  48 8D 05 C6 33 5F 00        lea     rax, aRevEcfHpfA0; "Rev Ecf HPF A0"
00007FF91DFF86FA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF86FE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8702  48 8D 87 70 2D A4 00        lea     rax, [rdi+0A42D70h]
00007FF91DFF8709  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8710  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8714  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8718  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF871D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8724  E8 17 33 01 00              call    sub_7FF91E00BA40
00007FF91DFF8729  66 0F 6F 05 FF 38 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8731  48 8D 05 98 33 5F 00        lea     rax, aRevEcfHpfB0; "Rev Ecf HPF B0"
00007FF91DFF8738  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF873C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8740  48 8D 87 80 2D A4 00        lea     rax, [rdi+0A42D80h]
00007FF91DFF8747  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF874E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8752  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8756  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF875B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8762  E8 D9 32 01 00              call    sub_7FF91E00BA40
00007FF91DFF8767  66 0F 6F 05 C1 38 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF876F  48 8D 05 6A 33 5F 00        lea     rax, aRevEcfLpfC0; "Rev Ecf LPF C0"
00007FF91DFF8776  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF877A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF877E  48 8D 87 90 2D A4 00        lea     rax, [rdi+0A42D90h]
00007FF91DFF8785  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF878C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8790  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8794  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8799  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF87A0  E8 9B 32 01 00              call    sub_7FF91E00BA40
00007FF91DFF87A5  66 0F 6F 05 83 38 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF87AD  48 8D 05 3C 33 5F 00        lea     rax, aRevEcfLpfA0; "Rev Ecf LPF A0"
00007FF91DFF87B4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF87B8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF87BC  48 8D 87 A0 2D A4 00        lea     rax, [rdi+0A42DA0h]
00007FF91DFF87C3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF87CA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF87CE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF87D2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF87D7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF87DE  E8 5D 32 01 00              call    sub_7FF91E00BA40
00007FF91DFF87E3  66 0F 6F 05 45 38 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF87EB  48 8D 05 0E 33 5F 00        lea     rax, aRevEcfLpfA1; "Rev Ecf LPF A1"
00007FF91DFF87F2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF87F6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF87FA  48 8D 87 B0 2D A4 00        lea     rax, [rdi+0A42DB0h]
00007FF91DFF8801  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8808  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF880C  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8810  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8815  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF881C  E8 1F 32 01 00              call    sub_7FF91E00BA40
00007FF91DFF8821  66 0F 6F 05 07 38 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8829  48 8D 05 E0 32 5F 00        lea     rax, aRevEcfLpfB0; "Rev Ecf LPF B0"
00007FF91DFF8830  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8834  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8838  48 8D 87 C0 2D A4 00        lea     rax, [rdi+0A42DC0h]
00007FF91DFF883F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8846  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF884A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF884E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8853  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF885A  E8 E1 31 01 00              call    sub_7FF91E00BA40
00007FF91DFF885F  66 0F 6F 05 C9 37 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8867  48 8D 05 B2 32 5F 00        lea     rax, aRevEcfLpfB1; "Rev Ecf LPF B1"
00007FF91DFF886E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8872  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8876  48 8D 87 D0 2D A4 00        lea     rax, [rdi+0A42DD0h]
00007FF91DFF887D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8884  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8888  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF888C  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8891  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8898  E8 A3 31 01 00              call    sub_7FF91E00BA40
00007FF91DFF889D  66 0F 6F 05 8B 37 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF88A5  48 8D 05 84 32 5F 00        lea     rax, aRevEcfDpf0Fc; "Rev Ecf DPF0 Fc"
00007FF91DFF88AC  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF88B0  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF88B7  48 8D 87 E0 2D A4 00        lea     rax, [rdi+0A42DE0h]
00007FF91DFF88BE  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF88C5  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF88C9  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF88CD  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF88D1  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF88D6  E8 65 31 01 00              call    sub_7FF91E00BA40
00007FF91DFF88DB  66 0F 6F 05 4D 37 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF88E3  48 8D 05 56 32 5F 00        lea     rax, aRevEcfDpf0Hp; "Rev Ecf DPF0 Hp"
00007FF91DFF88EA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF88EE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF88F2  48 8D 87 F0 2D A4 00        lea     rax, [rdi+0A42DF0h]
00007FF91DFF88F9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8900  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8904  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8908  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF890D  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8914  E8 27 31 01 00              call    sub_7FF91E00BA40
00007FF91DFF8919  66 0F 6F 05 0F 37 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8921  48 8D 05 28 32 5F 00        lea     rax, aRevEcfDpf0Lp; "Rev Ecf DPF0 Lp"
00007FF91DFF8928  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF892C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8930  48 8D 87 00 2E A4 00        lea     rax, [rdi+0A42E00h]
00007FF91DFF8937  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF893E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8942  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8946  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF894B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8952  E8 E9 30 01 00              call    sub_7FF91E00BA40
00007FF91DFF8957  66 0F 6F 05 D1 36 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF895F  48 8D 05 FA 31 5F 00        lea     rax, aRevEcfDpf1Fc; "Rev Ecf DPF1 Fc"
00007FF91DFF8966  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF896A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF896E  48 8D 87 10 2E A4 00        lea     rax, [rdi+0A42E10h]
00007FF91DFF8975  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF897C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8980  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8984  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8989  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8990  E8 AB 30 01 00              call    sub_7FF91E00BA40
00007FF91DFF8995  66 0F 6F 05 93 36 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF899D  48 8D 05 CC 31 5F 00        lea     rax, aRevEcfDpf1Hp; "Rev Ecf DPF1 Hp"
00007FF91DFF89A4  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF89A8  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF89AC  48 8D 87 20 2E A4 00        lea     rax, [rdi+0A42E20h]
00007FF91DFF89B3  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF89BA  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF89BE  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF89C2  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF89C7  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF89CE  E8 6D 30 01 00              call    sub_7FF91E00BA40
00007FF91DFF89D3  66 0F 6F 05 55 36 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF89DB  48 8D 05 9E 31 5F 00        lea     rax, aRevEcfDpf1Lp; "Rev Ecf DPF1 Lp"
00007FF91DFF89E2  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF89E6  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF89EA  48 8D 87 30 2E A4 00        lea     rax, [rdi+0A42E30h]
00007FF91DFF89F1  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF89F8  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF89FC  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8A00  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8A05  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8A0C  E8 2F 30 01 00              call    sub_7FF91E00BA40
00007FF91DFF8A11  66 0F 6F 05 17 36 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8A19  48 8D 05 70 31 5F 00        lea     rax, aRevEcfDpf2Fc; "Rev Ecf DPF2 Fc"
00007FF91DFF8A20  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8A24  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8A28  48 8D 87 40 2E A4 00        lea     rax, [rdi+0A42E40h]
00007FF91DFF8A2F  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8A36  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8A3A  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8A3E  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8A43  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8A4A  E8 F1 2F 01 00              call    sub_7FF91E00BA40
00007FF91DFF8A4F  66 0F 6F 05 D9 35 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8A57  48 8D 05 42 31 5F 00        lea     rax, aRevEcfDpf2Hp; "Rev Ecf DPF2 Hp"
00007FF91DFF8A5E  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8A62  48 8D 87 50 2E A4 00        lea     rax, [rdi+0A42E50h]
00007FF91DFF8A69  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8A6D  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8A74  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8A79  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8A80  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8A84  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8A88  E8 B3 2F 01 00              call    sub_7FF91E00BA40
00007FF91DFF8A8D  66 0F 6F 05 9B 35 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8A95  48 8D 05 14 31 5F 00        lea     rax, aRevEcfDpf2Lp; "Rev Ecf DPF2 Lp"
00007FF91DFF8A9C  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8AA0  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8AA4  48 8D 87 60 2E A4 00        lea     rax, [rdi+0A42E60h]
00007FF91DFF8AAB  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8AB2  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8AB6  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8ABA  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8ABF  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8AC6  E8 75 2F 01 00              call    sub_7FF91E00BA40
00007FF91DFF8ACB  66 0F 6F 05 5D 35 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8AD3  48 8D 05 E6 30 5F 00        lea     rax, aRevEcfDpf3Fc; "Rev Ecf DPF3 Fc"
00007FF91DFF8ADA  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8ADE  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8AE2  48 8D 87 70 2E A4 00        lea     rax, [rdi+0A42E70h]
00007FF91DFF8AE9  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8AF0  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8AF4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8AF8  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8AFD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8B04  E8 37 2F 01 00              call    sub_7FF91E00BA40
00007FF91DFF8B09  66 0F 6F 05 1F 35 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8B11  48 8D 05 B8 30 5F 00        lea     rax, aRevEcfDpf3Hp; "Rev Ecf DPF3 Hp"
00007FF91DFF8B18  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8B1C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8B20  48 8D 87 80 2E A4 00        lea     rax, [rdi+0A42E80h]
00007FF91DFF8B27  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8B2E  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8B32  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8B36  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8B3B  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8B42  E8 F9 2E 01 00              call    sub_7FF91E00BA40
00007FF91DFF8B47  66 0F 6F 05 E1 34 5F 00     movdqa  xmm0, cs:xmmword_7FF91E5EC030
00007FF91DFF8B4F  48 8D 05 8A 30 5F 00        lea     rax, aRevEcfDpf3Lp; "Rev Ecf DPF3 Lp"
00007FF91DFF8B56  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8B5A  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8B5E  48 8D 87 90 2E A4 00        lea     rax, [rdi+0A42E90h]
00007FF91DFF8B65  C7 45 8F 00 00 00 00        mov     [rbp+57h+var_C8], 0
00007FF91DFF8B6C  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8B70  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8B74  F3 0F 7F 45 93              movdqu  [rbp+57h+var_C4], xmm0
00007FF91DFF8B79  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8B80  E8 BB 2E 01 00              call    sub_7FF91E00BA40
00007FF91DFF8B85  F3 0F 10 05 8F 32 5F 00     movss   xmm0, cs:dword_7FF91E5EBE1C
00007FF91DFF8B8D  48 8D 05 5C 30 5F 00        lea     rax, aRevEcfDlymute; "Rev Ecf DlyMute"
00007FF91DFF8B94  66 0F 6F 0D 94 34 5F 00     movdqa  xmm1, cs:xmmword_7FF91E5EC030
00007FF91DFF8B9C  48 8D 55 87                 lea     rdx, [rbp+57h+var_D0]
00007FF91DFF8BA0  48 89 45 87                 mov     [rbp+57h+var_D0], rax
00007FF91DFF8BA4  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8BA8  48 8D 87 A0 2E A4 00        lea     rax, [rdi+0A42EA0h]
00007FF91DFF8BAF  F3 0F 11 45 8F              movss   [rbp+57h+var_C8], xmm0
00007FF91DFF8BB4  48 89 45 A7                 mov     [rbp+57h+var_B0], rax
00007FF91DFF8BB8  F3 0F 7F 4D 93              movdqu  [rbp+57h+var_C4], xmm1
00007FF91DFF8BBD  C7 45 A3 01 00 00 00        mov     [rbp+57h+var_B4], 1
00007FF91DFF8BC4  E8 77 2E 01 00              call    sub_7FF91E00BA40
00007FF91DFF8BC9  48 8D 4F 38                 lea     rcx, [rdi+38h]
00007FF91DFF8BCD  E8 AE 2E 01 00              call    sub_7FF91E00BA80
00007FF91DFF8BD2  4C 8D 9C 24 F0 00 00 00     lea     r11, [rsp+0F0h+var_s0]
00007FF91DFF8BDA  89 47 50                    mov     [rdi+50h], eax
00007FF91DFF8BDD  49 8B 5B 20                 mov     rbx, [r11+20h]
00007FF91DFF8BE1  49 8B 7B 28                 mov     rdi, [r11+28h]
00007FF91DFF8BE5  49 8B E3                    mov     rsp, r11
00007FF91DFF8BE8  5D                          pop     rbp
00007FF91DFF8BE9  C3                          retn
