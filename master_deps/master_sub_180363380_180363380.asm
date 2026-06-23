; sub_180363380 @ 0x180363380 (RVA 0x363380)

0000000180363380  48 8B C4                    mov     rax, rsp
0000000180363383  48 89 58 10                 mov     [rax+10h], rbx
0000000180363387  57                          push    rdi
0000000180363388  48 81 EC C0 00 00 00        sub     rsp, 0C0h
000000018036338F  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
0000000180363393  49 8B F8                    mov     rdi, r8
0000000180363396  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
000000018036339A  48 8B D9                    mov     rbx, rcx
000000018036339D  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
00000001803633A2  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
00000001803633A7  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
00000001803633AC  F3 44 0F 10 91 10 4A 01 00  movss   xmm10, dword ptr [rcx+14A10h]
00000001803633B5  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
00000001803633BA  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
00000001803633BF  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
00000001803633C5  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
00000001803633CB  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
00000001803633D1  48 89 70 08                 mov     [rax+8], rsi
00000001803633D5  33 F6                       xor     esi, esi
00000001803633D7  48 8B 02                    mov     rax, [rdx]
00000001803633DA  F3 0F 10 20                 movss   xmm4, dword ptr [rax]
00000001803633DE  F3 0F 11 A1 B0 29 00 00     movss   dword ptr [rcx+29B0h], xmm4
00000001803633E6  48 8B 42 10                 mov     rax, [rdx+10h]
00000001803633EA  F3 0F 10 28                 movss   xmm5, dword ptr [rax]
00000001803633EE  F3 0F 11 A9 C0 52 00 00     movss   dword ptr [rcx+52C0h], xmm5
00000001803633F6  F3 0F 58 EC                 addss   xmm5, xmm4
00000001803633FA  48 8B 42 20                 mov     rax, [rdx+20h]
00000001803633FE  F3 0F 10 A1 40 4A 01 00     movss   xmm4, dword ptr [rcx+14A40h]
0000000180363406  F3 0F 10 00                 movss   xmm0, dword ptr [rax]
000000018036340A  F3 0F 59 A9 E0 49 01 00     mulss   xmm5, dword ptr [rcx+149E0h]
0000000180363412  F3 0F 11 81 D0 7B 00 00     movss   dword ptr [rcx+7BD0h], xmm0
000000018036341A  48 8B 42 30                 mov     rax, [rdx+30h]
000000018036341E  F3 0F 10 38                 movss   xmm7, dword ptr [rax]
0000000180363422  F3 0F 11 B9 E0 A4 00 00     movss   dword ptr [rcx+0A4E0h], xmm7
000000018036342A  F3 0F 58 F8                 addss   xmm7, xmm0
000000018036342E  48 8B 42 40                 mov     rax, [rdx+40h]
0000000180363432  F3 0F 10 81 50 4A 01 00     movss   xmm0, dword ptr [rcx+14A50h]
000000018036343A  F3 0F 10 18                 movss   xmm3, dword ptr [rax]
000000018036343E  F3 0F 59 B9 F0 49 01 00     mulss   xmm7, dword ptr [rcx+149F0h]
0000000180363446  F3 0F 11 99 F0 CD 00 00     movss   dword ptr [rcx+0CDF0h], xmm3
000000018036344E  48 8B 42 50                 mov     rax, [rdx+50h]
0000000180363452  F3 0F 58 FD                 addss   xmm7, xmm5
0000000180363456  F3 0F 10 30                 movss   xmm6, dword ptr [rax]
000000018036345A  F3 0F 11 B1 00 F7 00 00     movss   dword ptr [rcx+0F700h], xmm6
0000000180363462  F3 0F 58 F3                 addss   xmm6, xmm3
0000000180363466  48 8B 42 60                 mov     rax, [rdx+60h]
000000018036346A  F3 0F 10 99 E0 4A 01 00     movss   xmm3, dword ptr [rcx+14AE0h]
0000000180363472  F3 0F 10 08                 movss   xmm1, dword ptr [rax]
0000000180363476  F3 0F 59 B1 00 4A 01 00     mulss   xmm6, dword ptr [rcx+14A00h]
000000018036347E  F3 0F 11 89 10 20 01 00     movss   dword ptr [rcx+12010h], xmm1
0000000180363486  48 8B 42 70                 mov     rax, [rdx+70h]
000000018036348A  F3 0F 10 10                 movss   xmm2, dword ptr [rax]
000000018036348E  8B 81 60 4B 01 00           mov     eax, [rcx+14B60h]
0000000180363494  F3 0F 11 91 20 49 01 00     movss   dword ptr [rcx+14920h], xmm2
000000018036349C  F3 0F 58 D1                 addss   xmm2, xmm1
00000001803634A0  F3 0F 10 89 20 4B 01 00     movss   xmm1, dword ptr [rcx+14B20h]
00000001803634A8  F3 0F 11 89 30 4B 01 00     movss   dword ptr [rcx+14B30h], xmm1
00000001803634B0  F3 0F 59 89 50 4B 01 00     mulss   xmm1, dword ptr [rcx+14B50h]
00000001803634B8  89 B1 80 4A 01 00           mov     [rcx+14A80h], esi
00000001803634BE  F3 41 0F 59 D2              mulss   xmm2, xmm10
00000001803634C3  89 81 70 4B 01 00           mov     [rcx+14B70h], eax
00000001803634C9  F3 0F 11 81 70 4A 01 00     movss   dword ptr [rcx+14A70h], xmm0
00000001803634D1  F3 0F 11 99 F0 4A 01 00     movss   dword ptr [rcx+14AF0h], xmm3
00000001803634D9  F3 0F 58 F2                 addss   xmm6, xmm2
00000001803634DD  F3 0F 59 D8                 mulss   xmm3, xmm0
00000001803634E1  F3 0F 10 91 C0 4A 01 00     movss   xmm2, dword ptr [rcx+14AC0h]
00000001803634E9  F3 0F 11 91 D0 4A 01 00     movss   dword ptr [rcx+14AD0h], xmm2
00000001803634F1  F3 0F 59 D0                 mulss   xmm2, xmm0
00000001803634F5  0F 28 C4                    movaps  xmm0, xmm4
00000001803634F8  F3 0F 58 FE                 addss   xmm7, xmm6
00000001803634FC  F3 0F 11 A1 60 4A 01 00     movss   dword ptr [rcx+14A60h], xmm4
0000000180363504  F3 0F 11 99 10 4B 01 00     movss   dword ptr [rcx+14B10h], xmm3
000000018036350C  F3 0F 11 91 00 4B 01 00     movss   dword ptr [rcx+14B00h], xmm2
0000000180363514  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180363518  F3 0F 59 B9 20 4A 01 00     mulss   xmm7, dword ptr [rcx+14A20h]
0000000180363520  F3 0F 11 B9 30 4A 01 00     movss   dword ptr [rcx+14A30h], xmm7
0000000180363528  F3 0F 59 B9 A0 4A 01 00     mulss   xmm7, dword ptr [rcx+14AA0h]
0000000180363530  F3 0F 58 B9 B0 4A 01 00     addss   xmm7, dword ptr [rcx+14AB0h]
0000000180363538  F3 0F 11 B9 90 4A 01 00     movss   dword ptr [rcx+14A90h], xmm7
0000000180363540  F3 0F 11 B9 20 4B 01 00     movss   dword ptr [rcx+14B20h], xmm7
0000000180363548  F3 0F 59 B9 40 4B 01 00     mulss   xmm7, dword ptr [rcx+14B40h]
0000000180363550  F3 0F 58 CF                 addss   xmm1, xmm7
0000000180363554  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180363558  F3 0F 11 89 60 4B 01 00     movss   dword ptr [rcx+14B60h], xmm1
0000000180363560  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180363564  F3 44 0F 10 81 D0 8A 01 00  movss   xmm8, dword ptr [rcx+18AD0h]
000000018036356D  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180363571  F3 44 0F 10 1D 6E 1C 78 00  movss   xmm11, cs:flt_180AE51E8
000000018036357A  45 0F 28 C8                 movaps  xmm9, xmm8
000000018036357E  F3 44 0F 10 3D 85 1A 78 00  movss   xmm15, cs:dword_180AE500C
0000000180363587  F3 44 0F 10 25 00 22 78 00  movss   xmm12, dword ptr cs:xmmword_180AE5790
0000000180363590  F3 44 0F 11 81 E0 8A 01 00  movss   dword ptr [rcx+18AE0h], xmm8
0000000180363599  F3 0F 11 91 80 4B 01 00     movss   dword ptr [rcx+14B80h], xmm2
00000001803635A1  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803635A5  F3 44 0F 59 CA              mulss   xmm9, xmm2
00000001803635AA  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803635AE  F3 44 0F 11 89 F0 8A 01 00  movss   dword ptr [rcx+18AF0h], xmm9
00000001803635B7  F3 0F 58 D9                 addss   xmm3, xmm1
00000001803635BB  F3 0F 11 99 90 4B 01 00     movss   dword ptr [rcx+14B90h], xmm3
00000001803635C3  F3 44 0F 59 C3              mulss   xmm8, xmm3
00000001803635C8  F3 44 0F 11 81 00 8B 01 00  movss   dword ptr [rcx+18B00h], xmm8
00000001803635D1  48 8B 81 88 00 00 00        mov     rax, [rcx+88h]
00000001803635D8  48 8B 88 88 00 00 00        mov     rcx, [rax+88h]
00000001803635DF  8B 01                       mov     eax, [rcx]
00000001803635E1  83 F8 01                    cmp     eax, 1
00000001803635E4  0F 84 DF 2A 00 00           jz      loc_1803660C9
00000001803635EA  0F 8E AA 22 00 00           jle     loc_18036589A
00000001803635F0  83 F8 03                    cmp     eax, 3
00000001803635F3  0F 8E F0 1A 00 00           jle     loc_1803650E9
00000001803635F9  83 F8 04                    cmp     eax, 4
00000001803635FC  0F 84 92 11 00 00           jz      loc_180364794
0000000180363602  83 F8 05                    cmp     eax, 5
0000000180363605  0F 85 8F 22 00 00           jnz     loc_18036589A
000000018036360B  39 83 0C 30 A8 00           cmp     [rbx+0A8300Ch], eax
0000000180363611  74 24                       jz      short loc_180363637
0000000180363613  89 B3 40 23 63 00           mov     [rbx+632340h], esi
0000000180363619  89 B3 50 23 63 00           mov     [rbx+632350h], esi
000000018036361F  89 B3 60 23 63 00           mov     [rbx+632360h], esi
0000000180363625  89 B3 00 29 A3 00           mov     [rbx+0A32900h], esi
000000018036362B  89 B3 10 29 A3 00           mov     [rbx+0A32910h], esi
0000000180363631  89 B3 20 29 A3 00           mov     [rbx+0A32920h], esi
0000000180363637  C7 83 0C 30 A8 00 05 00 00 00  mov     dword ptr [rbx+0A8300Ch], 5
0000000180363641  41 0F 28 E1                 movaps  xmm4, xmm9
0000000180363645  8B 83 C0 21 63 00           mov     eax, [rbx+6321C0h]
000000018036364B  89 83 D0 21 63 00           mov     [rbx+6321D0h], eax
0000000180363651  8B 83 B0 21 63 00           mov     eax, [rbx+6321B0h]
0000000180363657  89 83 C0 21 63 00           mov     [rbx+6321C0h], eax
000000018036365D  8B 83 A0 21 63 00           mov     eax, [rbx+6321A0h]
0000000180363663  89 83 B0 21 63 00           mov     [rbx+6321B0h], eax
0000000180363669  8B 83 90 21 63 00           mov     eax, [rbx+632190h]
000000018036366F  89 83 A0 21 63 00           mov     [rbx+6321A0h], eax
0000000180363675  8B 83 80 21 63 00           mov     eax, [rbx+632180h]
000000018036367B  89 83 90 21 63 00           mov     [rbx+632190h], eax
0000000180363681  8B 83 70 21 63 00           mov     eax, [rbx+632170h]
0000000180363687  89 83 80 21 63 00           mov     [rbx+632180h], eax
000000018036368D  8B 83 60 21 63 00           mov     eax, [rbx+632160h]
0000000180363693  89 83 70 21 63 00           mov     [rbx+632170h], eax
0000000180363699  8B 83 40 22 63 00           mov     eax, [rbx+632240h]
000000018036369F  89 83 50 22 63 00           mov     [rbx+632250h], eax
00000001803636A5  8B 83 30 22 63 00           mov     eax, [rbx+632230h]
00000001803636AB  89 83 40 22 63 00           mov     [rbx+632240h], eax
00000001803636B1  8B 83 20 22 63 00           mov     eax, [rbx+632220h]
00000001803636B7  89 83 30 22 63 00           mov     [rbx+632230h], eax
00000001803636BD  8B 83 10 22 63 00           mov     eax, [rbx+632210h]
00000001803636C3  89 83 20 22 63 00           mov     [rbx+632220h], eax
00000001803636C9  8B 83 00 22 63 00           mov     eax, [rbx+632200h]
00000001803636CF  89 83 10 22 63 00           mov     [rbx+632210h], eax
00000001803636D5  8B 83 F0 21 63 00           mov     eax, [rbx+6321F0h]
00000001803636DB  89 83 00 22 63 00           mov     [rbx+632200h], eax
00000001803636E1  8B 83 E0 21 63 00           mov     eax, [rbx+6321E0h]
00000001803636E7  89 83 F0 21 63 00           mov     [rbx+6321F0h], eax
00000001803636ED  8B 83 90 22 63 00           mov     eax, [rbx+632290h]
00000001803636F3  89 83 A0 22 63 00           mov     [rbx+6322A0h], eax
00000001803636F9  8B 83 80 22 63 00           mov     eax, [rbx+632280h]
00000001803636FF  89 83 90 22 63 00           mov     [rbx+632290h], eax
0000000180363705  8B 83 70 22 63 00           mov     eax, [rbx+632270h]
000000018036370B  89 83 80 22 63 00           mov     [rbx+632280h], eax
0000000180363711  8B 83 60 22 63 00           mov     eax, [rbx+632260h]
0000000180363717  89 83 70 22 63 00           mov     [rbx+632270h], eax
000000018036371D  8B 83 E0 22 63 00           mov     eax, [rbx+6322E0h]
0000000180363723  89 83 F0 22 63 00           mov     [rbx+6322F0h], eax
0000000180363729  8B 83 D0 22 63 00           mov     eax, [rbx+6322D0h]
000000018036372F  89 83 E0 22 63 00           mov     [rbx+6322E0h], eax
0000000180363735  8B 83 C0 22 63 00           mov     eax, [rbx+6322C0h]
000000018036373B  89 83 D0 22 63 00           mov     [rbx+6322D0h], eax
0000000180363741  8B 83 B0 22 63 00           mov     eax, [rbx+6322B0h]
0000000180363747  89 83 C0 22 63 00           mov     [rbx+6322C0h], eax
000000018036374D  8B 83 50 23 63 00           mov     eax, [rbx+632350h]
0000000180363753  89 83 60 23 63 00           mov     [rbx+632360h], eax
0000000180363759  8B 83 40 23 63 00           mov     eax, [rbx+632340h]
000000018036375F  89 83 50 23 63 00           mov     [rbx+632350h], eax
0000000180363765  8B 83 20 23 63 00           mov     eax, [rbx+632320h]
000000018036376B  89 83 30 23 63 00           mov     [rbx+632330h], eax
0000000180363771  8B 83 10 23 63 00           mov     eax, [rbx+632310h]
0000000180363777  89 83 20 23 63 00           mov     [rbx+632320h], eax
000000018036377D  8B 83 00 23 63 00           mov     eax, [rbx+632300h]
0000000180363783  89 83 10 23 63 00           mov     [rbx+632310h], eax
0000000180363789  F3 44 0F 11 8B 40 21 63 00  movss   dword ptr [rbx+632140h], xmm9
0000000180363792  F3 44 0F 11 83 50 21 63 00  movss   dword ptr [rbx+632150h], xmm8
000000018036379B  F3 44 0F 11 8B 60 22 63 00  movss   dword ptr [rbx+632260h], xmm9
00000001803637A4  F3 0F 59 A3 A0 23 63 00     mulss   xmm4, dword ptr [rbx+6323A0h]
00000001803637AC  F3 0F 10 83 B0 23 63 00     movss   xmm0, dword ptr [rbx+6323B0h]
00000001803637B4  F3 0F 59 83 70 22 63 00     mulss   xmm0, dword ptr [rbx+632270h]
00000001803637BC  F3 0F 10 8B 80 22 63 00     movss   xmm1, dword ptr [rbx+632280h]
00000001803637C4  F3 0F 59 8B C0 23 63 00     mulss   xmm1, dword ptr [rbx+6323C0h]
00000001803637CC  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803637D0  F3 0F 10 83 D0 23 63 00     movss   xmm0, dword ptr [rbx+6323D0h]
00000001803637D8  F3 0F 59 83 90 22 63 00     mulss   xmm0, dword ptr [rbx+632290h]
00000001803637E0  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803637E4  F3 0F 10 8B E0 23 63 00     movss   xmm1, dword ptr [rbx+6323E0h]
00000001803637EC  F3 0F 59 8B A0 22 63 00     mulss   xmm1, dword ptr [rbx+6322A0h]
00000001803637F4  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803637F8  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803637FC  41 0F 28 C9                 movaps  xmm1, xmm9
0000000180363800  F3 0F 11 A3 80 22 63 00     movss   dword ptr [rbx+632280h], xmm4
0000000180363808  F3 0F 10 93 70 21 63 00     movss   xmm2, dword ptr [rbx+632170h]
0000000180363810  0F 28 C2                    movaps  xmm0, xmm2
0000000180363813  F3 0F 59 83 10 24 63 00     mulss   xmm0, dword ptr [rbx+632410h]
000000018036381B  F3 0F 5C C8                 subss   xmm1, xmm0
000000018036381F  F3 0F 5C 8B 80 21 63 00     subss   xmm1, dword ptr [rbx+632180h]
0000000180363827  F3 0F 59 8B 00 24 63 00     mulss   xmm1, dword ptr [rbx+632400h]
000000018036382F  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180363833  F3 0F 11 8B 60 21 63 00     movss   dword ptr [rbx+632160h], xmm1
000000018036383B  45 0F 57 ED                 xorps   xmm13, xmm13
000000018036383F  F3 0F 10 9B 00 24 63 00     movss   xmm3, dword ptr [rbx+632400h]
0000000180363847  F3 0F 59 9B 70 21 63 00     mulss   xmm3, dword ptr [rbx+632170h]
000000018036384F  F3 44 0F 10 35 5C 18 78 00  movss   xmm14, cs:dword_180AE50B4
0000000180363858  41 0F 28 D6                 movaps  xmm2, xmm14
000000018036385C  F3 0F 58 9B 80 21 63 00     addss   xmm3, dword ptr [rbx+632180h]
0000000180363864  F3 0F 11 9B 70 21 63 00     movss   dword ptr [rbx+632170h], xmm3
000000018036386C  F3 0F 10 83 F0 23 63 00     movss   xmm0, dword ptr [rbx+6323F0h]
0000000180363874  F3 0F 10 8B 20 24 63 00     movss   xmm1, dword ptr [rbx+632420h]
000000018036387C  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180363880  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180363884  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180363888  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036388C  41 0F 28 C6                 movaps  xmm0, xmm14
0000000180363890  F3 0F 5C C1                 subss   xmm0, xmm1
0000000180363894  F3 0F 59 D1                 mulss   xmm2, xmm1
0000000180363898  F3 41 0F 59 C1              mulss   xmm0, xmm9
000000018036389D  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803638A1  F3 0F 10 83 60 24 63 00     movss   xmm0, dword ptr [rbx+632460h]
00000001803638A9  F3 0F 59 83 C0 21 63 00     mulss   xmm0, dword ptr [rbx+6321C0h]
00000001803638B1  F3 0F 59 93 70 24 63 00     mulss   xmm2, dword ptr [rbx+632470h]
00000001803638B9  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803638BD  F3 0F 59 93 80 24 63 00     mulss   xmm2, dword ptr [rbx+632480h]
00000001803638C5  F3 0F 11 93 70 25 A3 00     movss   dword ptr [rbx+0A32570h], xmm2
00000001803638CD  F3 0F 10 AB 50 21 63 00     movss   xmm5, dword ptr [rbx+632150h]
00000001803638D5  F3 0F 11 AB B0 22 63 00     movss   dword ptr [rbx+6322B0h], xmm5
00000001803638DD  0F 28 E5                    movaps  xmm4, xmm5
00000001803638E0  F3 0F 59 A3 A0 23 63 00     mulss   xmm4, dword ptr [rbx+6323A0h]
00000001803638E8  F3 0F 10 83 B0 23 63 00     movss   xmm0, dword ptr [rbx+6323B0h]
00000001803638F0  F3 0F 59 83 C0 22 63 00     mulss   xmm0, dword ptr [rbx+6322C0h]
00000001803638F8  F3 0F 10 8B C0 23 63 00     movss   xmm1, dword ptr [rbx+6323C0h]
0000000180363900  F3 0F 59 8B D0 22 63 00     mulss   xmm1, dword ptr [rbx+6322D0h]
0000000180363908  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036390C  F3 0F 10 83 E0 22 63 00     movss   xmm0, dword ptr [rbx+6322E0h]
0000000180363914  F3 0F 59 83 D0 23 63 00     mulss   xmm0, dword ptr [rbx+6323D0h]
000000018036391C  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180363920  F3 0F 10 8B E0 23 63 00     movss   xmm1, dword ptr [rbx+6323E0h]
0000000180363928  F3 0F 59 8B F0 22 63 00     mulss   xmm1, dword ptr [rbx+6322F0h]
0000000180363930  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180363934  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180363938  0F 28 CD                    movaps  xmm1, xmm5
000000018036393B  F3 0F 11 A3 D0 22 63 00     movss   dword ptr [rbx+6322D0h], xmm4
0000000180363943  F3 0F 10 93 F0 21 63 00     movss   xmm2, dword ptr [rbx+6321F0h]
000000018036394B  0F 28 C2                    movaps  xmm0, xmm2
000000018036394E  F3 0F 59 83 10 24 63 00     mulss   xmm0, dword ptr [rbx+632410h]
0000000180363956  F3 0F 5C C8                 subss   xmm1, xmm0
000000018036395A  F3 0F 5C 8B 00 22 63 00     subss   xmm1, dword ptr [rbx+632200h]
0000000180363962  F3 0F 59 8B 00 24 63 00     mulss   xmm1, dword ptr [rbx+632400h]
000000018036396A  F3 0F 58 CA                 addss   xmm1, xmm2
000000018036396E  41 0F 28 D6                 movaps  xmm2, xmm14
0000000180363972  F3 0F 11 8B E0 21 63 00     movss   dword ptr [rbx+6321E0h], xmm1
000000018036397A  F3 0F 10 9B F0 21 63 00     movss   xmm3, dword ptr [rbx+6321F0h]
0000000180363982  F3 0F 59 9B 00 24 63 00     mulss   xmm3, dword ptr [rbx+632400h]
000000018036398A  F3 0F 58 9B 00 22 63 00     addss   xmm3, dword ptr [rbx+632200h]
0000000180363992  F3 0F 11 9B F0 21 63 00     movss   dword ptr [rbx+6321F0h], xmm3
000000018036399A  F3 0F 10 83 F0 23 63 00     movss   xmm0, dword ptr [rbx+6323F0h]
00000001803639A2  F3 0F 10 8B 20 24 63 00     movss   xmm1, dword ptr [rbx+632420h]
00000001803639AA  F3 0F 5C D0                 subss   xmm2, xmm0
00000001803639AE  F3 0F 59 C4                 mulss   xmm0, xmm4
00000001803639B2  F3 0F 59 D3                 mulss   xmm2, xmm3
00000001803639B6  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803639BA  41 0F 28 C6                 movaps  xmm0, xmm14
00000001803639BE  F3 0F 5C C1                 subss   xmm0, xmm1
00000001803639C2  F3 0F 59 D1                 mulss   xmm2, xmm1
00000001803639C6  F3 0F 59 C5                 mulss   xmm0, xmm5
00000001803639CA  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803639CE  F3 0F 10 83 60 24 63 00     movss   xmm0, dword ptr [rbx+632460h]
00000001803639D6  F3 0F 59 83 40 22 63 00     mulss   xmm0, dword ptr [rbx+632240h]
00000001803639DE  F3 0F 59 93 70 24 63 00     mulss   xmm2, dword ptr [rbx+632470h]
00000001803639E6  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803639EA  F3 0F 59 93 80 24 63 00     mulss   xmm2, dword ptr [rbx+632480h]
00000001803639F2  F3 0F 11 93 90 25 A3 00     movss   dword ptr [rbx+0A32590h], xmm2
00000001803639FA  F3 0F 10 8B 00 25 63 00     movss   xmm1, dword ptr [rbx+632500h]
0000000180363A02  F3 0F 58 8B 50 23 63 00     addss   xmm1, dword ptr [rbx+632350h]
0000000180363A0A  F3 41 0F 59 CA              mulss   xmm1, xmm10
0000000180363A0F  F3 0F 11 8B 40 23 63 00     movss   dword ptr [rbx+632340h], xmm1
0000000180363A17  F3 0F 5C 8B 30 23 63 00     subss   xmm1, dword ptr [rbx+632330h]
0000000180363A1F  F3 0F 10 B3 60 23 63 00     movss   xmm6, dword ptr [rbx+632360h]
0000000180363A27  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180363A2B  73 0A                       jnb     short loc_180363A37
0000000180363A2D  F3 0F 10 83 30 25 63 00     movss   xmm0, dword ptr [rbx+632530h]
0000000180363A35  EB 08                       jmp     short loc_180363A3F
0000000180363A37  F3 0F 10 83 20 25 63 00     movss   xmm0, dword ptr [rbx+632520h]
0000000180363A3F  F3 0F 10 AB 90 23 63 00     movss   xmm5, dword ptr [rbx+632390h]
0000000180363A47  F3 0F 58 F0                 addss   xmm6, xmm0
0000000180363A4B  F3 0F 11 AB 00 23 63 00     movss   dword ptr [rbx+632300h], xmm5
0000000180363A53  0F 28 C5                    movaps  xmm0, xmm5
0000000180363A56  F3 0F 5C 83 10 23 63 00     subss   xmm0, dword ptr [rbx+632310h]
0000000180363A5E  F3 0F 10 93 30 23 63 00     movss   xmm2, dword ptr [rbx+632330h]
0000000180363A66  0F 28 E5                    movaps  xmm4, xmm5
0000000180363A69  F3 0F 10 9B 20 23 63 00     movss   xmm3, dword ptr [rbx+632320h]
0000000180363A71  F3 0F 5C E2                 subss   xmm4, xmm2
0000000180363A75  F3 0F 10 BB 40 25 63 00     movss   xmm7, dword ptr [rbx+632540h]
0000000180363A7D  41 0F 2E C5                 ucomiss xmm0, xmm13
0000000180363A81  74 03                       jz      short loc_180363A86
0000000180363A83  0F 28 DC                    movaps  xmm3, xmm4
0000000180363A86  41 0F 2F E5                 comiss  xmm4, xmm13
0000000180363A8A  0F 28 C2                    movaps  xmm0, xmm2
0000000180363A8D  F3 0F 11 9B 10 23 63 00     movss   dword ptr [rbx+632310h], xmm3
0000000180363A95  41 0F 54 DC                 andps   xmm3, xmm12
0000000180363A99  F3 0F 59 DF                 mulss   xmm3, xmm7
0000000180363A9D  F3 0F 5C D3                 subss   xmm2, xmm3
0000000180363AA1  F3 0F 58 C3                 addss   xmm0, xmm3
0000000180363AA5  F3 0F 5F D5                 maxss   xmm2, xmm5
0000000180363AA9  76 07                       jbe     short loc_180363AB2
0000000180363AAB  0F 28 D0                    movaps  xmm2, xmm0
0000000180363AAE  F3 0F 5D D5                 minss   xmm2, xmm5
0000000180363AB2  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180363AB6  F3 0F 11 93 20 23 63 00     movss   dword ptr [rbx+632320h], xmm2
0000000180363ABE  45 0F 57 FF                 xorps   xmm15, xmm15
0000000180363AC2  76 05                       jbe     short loc_180363AC9
0000000180363AC4  0F 5A C6                    cvtps2pd xmm0, xmm6
0000000180363AC7  EB 03                       jmp     short loc_180363ACC
0000000180363AC9  0F 57 C0                    xorps   xmm0, xmm0
0000000180363ACC  F3 44 0F 10 25 0F 1A 78 00  movss   xmm12, cs:dword_180AE54E4
0000000180363AD5  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180363AD9  41 0F 2F C4                 comiss  xmm0, xmm12
0000000180363ADD  73 06                       jnb     short loc_180363AE5
0000000180363ADF  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180363AE3  EB 05                       jmp     short loc_180363AEA
0000000180363AE5  F3 41 0F 5D C6              minss   xmm0, xmm14
0000000180363AEA  F3 0F 59 83 80 24 63 00     mulss   xmm0, dword ptr [rbx+632480h]
0000000180363AF2  F3 44 0F 10 1D BD 71 62 00  movss   xmm11, cs:dword_18098ACB8
0000000180363AFB  F3 44 0F 10 0D 9C 71 62 00  movss   xmm9, cs:dword_18098ACA0
0000000180363B04  F3 0F 11 83 50 23 63 00     movss   dword ptr [rbx+632350h], xmm0
0000000180363B0C  0F 28 C2                    movaps  xmm0, xmm2
0000000180363B0F  8B 83 50 25 83 00           mov     eax, [rbx+832550h]
0000000180363B15  F3 41 0F 59 C3              mulss   xmm0, xmm11
0000000180363B1A  F3 41 0F 59 D1              mulss   xmm2, xmm9
0000000180363B1F  F3 0F 2C D0                 cvttss2si edx, xmm0
0000000180363B23  0F 5A CA                    cvtps2pd xmm1, xmm2
0000000180363B26  2B C2                       sub     eax, edx
0000000180363B28  48 63 C8                    movsxd  rcx, eax
0000000180363B2B  48 63 83 54 25 83 00        movsxd  rax, dword ptr [rbx+832554h]
0000000180363B32  48 FF C1                    inc     rcx
0000000180363B35  48 FF C8                    dec     rax
0000000180363B38  48 23 C8                    and     rcx, rax
0000000180363B3B  8B 84 8B 50 25 63 00        mov     eax, [rbx+rcx*4+632550h]
0000000180363B42  89 83 80 25 A3 00           mov     [rbx+0A32580h], eax
0000000180363B48  8B 83 50 25 83 00           mov     eax, [rbx+832550h]
0000000180363B4E  2B C2                       sub     eax, edx
0000000180363B50  48 63 C8                    movsxd  rcx, eax
0000000180363B53  48 63 83 54 25 83 00        movsxd  rax, dword ptr [rbx+832554h]
0000000180363B5A  48 83 C1 02                 add     rcx, 2
0000000180363B5E  48 FF C8                    dec     rax
0000000180363B61  48 23 C8                    and     rcx, rax
0000000180363B64  8B 84 8B 50 25 63 00        mov     eax, [rbx+rcx*4+632550h]
0000000180363B6B  89 83 84 25 A3 00           mov     [rbx+0A32584h], eax
0000000180363B71  F3 0F 2C C2                 cvttss2si eax, xmm2
0000000180363B75  66 0F 6E C0                 movd    xmm0, eax
0000000180363B79  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
0000000180363B7D  F2 0F 5C C8                 subsd   xmm1, xmm0
0000000180363B81  66 44 0F 5A C1              cvtpd2ps xmm8, xmm1
0000000180363B86  F3 44 0F 11 83 88 25 A3 00  movss   dword ptr [rbx+0A32588h], xmm8
0000000180363B8F  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180363B93  F3 0F 10 8B 80 25 A3 00     movss   xmm1, dword ptr [rbx+0A32580h]
0000000180363B9B  41 0F 28 C0                 movaps  xmm0, xmm8
0000000180363B9F  8B 83 60 25 A3 00           mov     eax, [rbx+0A32560h]
0000000180363BA5  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180363BA9  2B C2                       sub     eax, edx
0000000180363BAB  48 63 C8                    movsxd  rcx, eax
0000000180363BAE  48 63 83 64 25 A3 00        movsxd  rax, dword ptr [rbx+0A32564h]
0000000180363BB5  48 FF C1                    inc     rcx
0000000180363BB8  48 FF C8                    dec     rax
0000000180363BBB  48 23 C8                    and     rcx, rax
0000000180363BBE  8B 84 8B 60 25 83 00        mov     eax, [rbx+rcx*4+832560h]
0000000180363BC5  89 83 A0 25 A3 00           mov     [rbx+0A325A0h], eax
0000000180363BCB  8B 83 60 25 A3 00           mov     eax, [rbx+0A32560h]
0000000180363BD1  2B C2                       sub     eax, edx
0000000180363BD3  48 63 C8                    movsxd  rcx, eax
0000000180363BD6  48 63 83 64 25 A3 00        movsxd  rax, dword ptr [rbx+0A32564h]
0000000180363BDD  48 83 C1 02                 add     rcx, 2
0000000180363BE1  48 FF C8                    dec     rax
0000000180363BE4  48 23 C8                    and     rcx, rax
0000000180363BE7  8B 84 8B 60 25 83 00        mov     eax, [rbx+rcx*4+832560h]
0000000180363BEE  89 83 A4 25 A3 00           mov     [rbx+0A325A4h], eax
0000000180363BF4  F3 44 0F 11 83 A8 25 A3 00  movss   dword ptr [rbx+0A325A8h], xmm8
0000000180363BFD  F3 0F 59 9B 84 25 A3 00     mulss   xmm3, dword ptr [rbx+0A32584h]
0000000180363C05  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180363C09  F3 0F 10 83 A0 21 63 00     movss   xmm0, dword ptr [rbx+6321A0h]
0000000180363C11  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180363C15  F3 0F 59 9B 60 23 63 00     mulss   xmm3, dword ptr [rbx+632360h]
0000000180363C1D  F3 0F 11 9B 80 21 63 00     movss   dword ptr [rbx+632180h], xmm3
0000000180363C25  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180363C29  F3 0F 10 93 B0 21 63 00     movss   xmm2, dword ptr [rbx+6321B0h]
0000000180363C31  F3 0F 10 A3 A0 24 63 00     movss   xmm4, dword ptr [rbx+6324A0h]
0000000180363C39  F3 0F 10 BB A0 25 A3 00     movss   xmm7, dword ptr [rbx+0A325A0h]
0000000180363C41  F3 0F 59 E3                 mulss   xmm4, xmm3
0000000180363C45  0F 28 CB                    movaps  xmm1, xmm3
0000000180363C48  F3 0F 59 8B 90 24 63 00     mulss   xmm1, dword ptr [rbx+632490h]
0000000180363C50  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180363C54  F3 0F 10 83 B0 24 63 00     movss   xmm0, dword ptr [rbx+6324B0h]
0000000180363C5C  F3 0F 11 8B 90 21 63 00     movss   dword ptr [rbx+632190h], xmm1
0000000180363C64  F3 0F 10 9B D0 21 63 00     movss   xmm3, dword ptr [rbx+6321D0h]
0000000180363C6C  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180363C70  F3 0F 5C E0                 subss   xmm4, xmm0
0000000180363C74  F3 0F 10 83 D0 24 63 00     movss   xmm0, dword ptr [rbx+6324D0h]
0000000180363C7C  F3 0F 5C E2                 subss   xmm4, xmm2
0000000180363C80  0F 28 CC                    movaps  xmm1, xmm4
0000000180363C83  F3 0F 59 8B C0 24 63 00     mulss   xmm1, dword ptr [rbx+6324C0h]
0000000180363C8B  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180363C8F  F3 0F 10 93 E0 24 63 00     movss   xmm2, dword ptr [rbx+6324E0h]
0000000180363C97  F3 0F 11 8B A0 21 63 00     movss   dword ptr [rbx+6321A0h], xmm1
0000000180363C9F  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180363CA3  F3 0F 59 D1                 mulss   xmm2, xmm1
0000000180363CA7  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180363CAB  F3 44 0F 59 C7              mulss   xmm8, xmm7
0000000180363CB0  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180363CB4  F3 0F 5C D3                 subss   xmm2, xmm3
0000000180363CB8  F3 0F 11 93 B0 21 63 00     movss   dword ptr [rbx+6321B0h], xmm2
0000000180363CC0  F3 0F 59 93 F0 24 63 00     mulss   xmm2, dword ptr [rbx+6324F0h]
0000000180363CC8  F3 0F 58 D3                 addss   xmm2, xmm3
0000000180363CCC  F3 0F 11 93 C0 21 63 00     movss   dword ptr [rbx+6321C0h], xmm2
0000000180363CD4  F3 0F 59 AB A4 25 A3 00     mulss   xmm5, dword ptr [rbx+0A325A4h]
0000000180363CDC  F3 0F 10 83 20 22 63 00     movss   xmm0, dword ptr [rbx+632220h]
0000000180363CE4  F3 41 0F 5C E8              subss   xmm5, xmm8
0000000180363CE9  F3 0F 58 EF                 addss   xmm5, xmm7
0000000180363CED  F3 0F 59 AB 60 23 63 00     mulss   xmm5, dword ptr [rbx+632360h]
0000000180363CF5  F3 0F 11 AB 00 22 63 00     movss   dword ptr [rbx+632200h], xmm5
0000000180363CFD  F3 0F 5C E8                 subss   xmm5, xmm0
0000000180363D01  F3 0F 10 A3 A0 24 63 00     movss   xmm4, dword ptr [rbx+6324A0h]
0000000180363D09  F3 0F 10 93 30 22 63 00     movss   xmm2, dword ptr [rbx+632230h]
0000000180363D11  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180363D15  0F 28 CD                    movaps  xmm1, xmm5
0000000180363D18  F3 0F 59 8B 90 24 63 00     mulss   xmm1, dword ptr [rbx+632490h]
0000000180363D20  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180363D24  F3 0F 10 83 B0 24 63 00     movss   xmm0, dword ptr [rbx+6324B0h]
0000000180363D2C  F3 0F 11 8B 10 22 63 00     movss   dword ptr [rbx+632210h], xmm1
0000000180363D34  F3 0F 10 9B 50 22 63 00     movss   xmm3, dword ptr [rbx+632250h]
0000000180363D3C  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180363D40  F3 0F 5C E0                 subss   xmm4, xmm0
0000000180363D44  F3 0F 10 83 D0 24 63 00     movss   xmm0, dword ptr [rbx+6324D0h]
0000000180363D4C  F3 0F 5C E2                 subss   xmm4, xmm2
0000000180363D50  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180363D54  0F 28 CC                    movaps  xmm1, xmm4
0000000180363D57  F3 0F 59 8B C0 24 63 00     mulss   xmm1, dword ptr [rbx+6324C0h]
0000000180363D5F  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180363D63  F3 0F 10 93 E0 24 63 00     movss   xmm2, dword ptr [rbx+6324E0h]
0000000180363D6B  F3 0F 11 8B 20 22 63 00     movss   dword ptr [rbx+632220h], xmm1
0000000180363D73  F3 0F 59 D1                 mulss   xmm2, xmm1
0000000180363D77  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180363D7B  F3 0F 5C D3                 subss   xmm2, xmm3
0000000180363D7F  F3 0F 11 93 30 22 63 00     movss   dword ptr [rbx+632230h], xmm2
0000000180363D87  F3 0F 10 83 40 24 63 00     movss   xmm0, dword ptr [rbx+632440h]
0000000180363D8F  F3 0F 59 93 F0 24 63 00     mulss   xmm2, dword ptr [rbx+6324F0h]
0000000180363D97  F3 0F 10 BB 80 21 63 00     movss   xmm7, dword ptr [rbx+632180h]
0000000180363D9F  F3 44 0F 10 83 00 22 63 00  movss   xmm8, dword ptr [rbx+632200h]
0000000180363DA8  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180363DAC  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180363DB0  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180363DB5  F3 0F 11 9B 40 22 63 00     movss   dword ptr [rbx+632240h], xmm3
0000000180363DBD  41 0F 28 DE                 movaps  xmm3, xmm14
0000000180363DC1  F3 0F 10 AB 70 24 63 00     movss   xmm5, dword ptr [rbx+632470h]
0000000180363DC9  F3 0F 10 A3 30 24 63 00     movss   xmm4, dword ptr [rbx+632430h]
0000000180363DD1  F3 0F 5C DD                 subss   xmm3, xmm5
0000000180363DD5  F3 0F 10 93 40 21 63 00     movss   xmm2, dword ptr [rbx+632140h]
0000000180363DDD  0F 28 CD                    movaps  xmm1, xmm5
0000000180363DE0  F3 0F 10 B3 50 21 63 00     movss   xmm6, dword ptr [rbx+632150h]
0000000180363DE8  0F 28 C4                    movaps  xmm0, xmm4
0000000180363DEB  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180363DEF  F3 0F 59 E6                 mulss   xmm4, xmm6
0000000180363DF3  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180363DF7  0F 28 C3                    movaps  xmm0, xmm3
0000000180363DFA  F3 0F 59 EC                 mulss   xmm5, xmm4
0000000180363DFE  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180363E02  F3 0F 59 DE                 mulss   xmm3, xmm6
0000000180363E06  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180363E0A  F3 0F 58 EB                 addss   xmm5, xmm3
0000000180363E0E  F3 0F 58 CF                 addss   xmm1, xmm7
0000000180363E12  F3 41 0F 58 E8              addss   xmm5, xmm8
0000000180363E17  F3 0F 11 8B 70 23 63 00     movss   dword ptr [rbx+632370h], xmm1
0000000180363E1F  F3 0F 11 AB 80 23 63 00     movss   dword ptr [rbx+632380h], xmm5
0000000180363E27  8B 8B 54 25 83 00           mov     ecx, [rbx+832554h]
0000000180363E2D  8B 83 50 25 83 00           mov     eax, [rbx+832550h]
0000000180363E33  FF C9                       dec     ecx
0000000180363E35  FF C8                       dec     eax
0000000180363E37  23 C8                       and     ecx, eax
0000000180363E39  89 8B 50 25 83 00           mov     [rbx+832550h], ecx
0000000180363E3F  8B 83 70 25 A3 00           mov     eax, [rbx+0A32570h]
0000000180363E45  48 63 C9                    movsxd  rcx, ecx
0000000180363E48  89 84 8B 50 25 63 00        mov     [rbx+rcx*4+632550h], eax
0000000180363E4F  8B 8B 64 25 A3 00           mov     ecx, [rbx+0A32564h]
0000000180363E55  FF C9                       dec     ecx
0000000180363E57  8B 83 60 25 A3 00           mov     eax, [rbx+0A32560h]
0000000180363E5D  FF C8                       dec     eax
0000000180363E5F  23 C8                       and     ecx, eax
0000000180363E61  89 8B 60 25 A3 00           mov     [rbx+0A32560h], ecx
0000000180363E67  8B 83 90 25 A3 00           mov     eax, [rbx+0A32590h]
0000000180363E6D  48 63 C9                    movsxd  rcx, ecx
0000000180363E70  89 84 8B 60 25 83 00        mov     [rbx+rcx*4+832560h], eax
0000000180363E77  F3 0F 10 8B B0 25 A3 00     movss   xmm1, dword ptr [rbx+0A325B0h]
0000000180363E7F  F3 0F 10 83 C0 25 A3 00     movss   xmm0, dword ptr [rbx+0A325C0h]
0000000180363E87  F3 0F 11 8B D0 25 A3 00     movss   dword ptr [rbx+0A325D0h], xmm1
0000000180363E8F  F3 0F 11 83 E0 25 A3 00     movss   dword ptr [rbx+0A325E0h], xmm0
0000000180363E97  F3 0F 58 8B 10 26 A3 00     addss   xmm1, dword ptr [rbx+0A32610h]
0000000180363E9F  0F 5A C1                    cvtps2pd xmm0, xmm1
0000000180363EA2  E8 19 4F 00 00              call    sub_180368DC0
0000000180363EA7  F3 44 0F 10 15 38 13 78 00  movss   xmm10, cs:flt_180AE51E8
0000000180363EB0  0F 57 C9                    xorps   xmm1, xmm1
0000000180363EB3  F2 0F 5A C8                 cvtsd2ss xmm1, xmm0
0000000180363EB7  F3 0F 5D 0D D9 6D 62 00     minss   xmm1, cs:dword_18098AC98
0000000180363EBF  F3 0F 5F 0D E9 6D 62 00     maxss   xmm1, cs:dword_18098ACB0
0000000180363EC7  F3 0F 11 8B F0 25 A3 00     movss   dword ptr [rbx+0A325F0h], xmm1
0000000180363ECF  F3 0F 10 83 D0 26 A3 00     movss   xmm0, dword ptr [rbx+0A326D0h]
0000000180363ED7  F3 0F 10 BB E0 25 A3 00     movss   xmm7, dword ptr [rbx+0A325E0h]
0000000180363EDF  F3 0F 11 83 E0 26 A3 00     movss   dword ptr [rbx+0A326E0h], xmm0
0000000180363EE7  F3 0F 59 8B 00 27 A3 00     mulss   xmm1, dword ptr [rbx+0A32700h]
0000000180363EEF  0F 2F 0D DA 13 78 00        comiss  xmm1, cs:dword_180AE52D0
0000000180363EF6  72 0A                       jb      short loc_180363F02
0000000180363EF8  F3 0F 58 0D 10 16 78 00     addss   xmm1, cs:dword_180AE5510
0000000180363F00  EB 0E                       jmp     short loc_180363F10
0000000180363F02  41 0F 2F CA                 comiss  xmm1, xmm10
0000000180363F06  72 08                       jb      short loc_180363F10
0000000180363F08  F3 0F 58 0D E8 15 78 00     addss   xmm1, cs:dword_180AE54F8
0000000180363F10  41 0F 2E CD                 ucomiss xmm1, xmm13
0000000180363F14  75 08                       jnz     short loc_180363F1E
0000000180363F16  F3 0F 10 8B 10 27 A3 00     movss   xmm1, dword ptr [rbx+0A32710h]
0000000180363F1E  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180363F22  E8 69 50 00 00              call    sub_180368F90
0000000180363F27  0F 28 F0                    movaps  xmm6, xmm0
0000000180363F2A  E8 91 50 00 00              call    sub_180368FC0
0000000180363F2F  0F 28 E8                    movaps  xmm5, xmm0
0000000180363F32  F3 0F 59 F7                 mulss   xmm6, xmm7
0000000180363F36  F3 0F 11 AB F0 26 A3 00     movss   dword ptr [rbx+0A326F0h], xmm5
0000000180363F3E  F3 41 0F 5C FE              subss   xmm7, xmm14
0000000180363F43  F3 0F 58 F7                 addss   xmm6, xmm7
0000000180363F47  F3 0F 11 B3 D0 26 A3 00     movss   dword ptr [rbx+0A326D0h], xmm6
0000000180363F4F  F3 0F 59 AB 30 27 A3 00     mulss   xmm5, dword ptr [rbx+0A32730h]
0000000180363F57  F3 0F 58 AB 40 27 A3 00     addss   xmm5, dword ptr [rbx+0A32740h]
0000000180363F5F  F3 0F 11 AB 20 27 A3 00     movss   dword ptr [rbx+0A32720h], xmm5
0000000180363F67  0F 28 E5                    movaps  xmm4, xmm5
0000000180363F6A  F3 0F 10 8B 80 23 63 00     movss   xmm1, dword ptr [rbx+632380h]
0000000180363F72  0F 28 D5                    movaps  xmm2, xmm5
0000000180363F75  8B 83 C0 27 A3 00           mov     eax, [rbx+0A327C0h]
0000000180363F7B  F3 0F 10 B3 70 23 63 00     movss   xmm6, dword ptr [rbx+632370h]
0000000180363F83  89 83 D0 27 A3 00           mov     [rbx+0A327D0h], eax
0000000180363F89  8B 83 B0 27 A3 00           mov     eax, [rbx+0A327B0h]
0000000180363F8F  89 83 C0 27 A3 00           mov     [rbx+0A327C0h], eax
0000000180363F95  8B 83 A0 27 A3 00           mov     eax, [rbx+0A327A0h]
0000000180363F9B  89 83 B0 27 A3 00           mov     [rbx+0A327B0h], eax
0000000180363FA1  8B 83 90 27 A3 00           mov     eax, [rbx+0A32790h]
0000000180363FA7  89 83 A0 27 A3 00           mov     [rbx+0A327A0h], eax
0000000180363FAD  8B 83 80 27 A3 00           mov     eax, [rbx+0A32780h]
0000000180363FB3  89 83 90 27 A3 00           mov     [rbx+0A32790h], eax
0000000180363FB9  8B 83 20 28 A3 00           mov     eax, [rbx+0A32820h]
0000000180363FBF  89 83 30 28 A3 00           mov     [rbx+0A32830h], eax
0000000180363FC5  8B 83 10 28 A3 00           mov     eax, [rbx+0A32810h]
0000000180363FCB  89 83 20 28 A3 00           mov     [rbx+0A32820h], eax
0000000180363FD1  8B 83 00 28 A3 00           mov     eax, [rbx+0A32800h]
0000000180363FD7  F3 0F 59 15 2D 10 78 00     mulss   xmm2, cs:dword_180AE500C
0000000180363FDF  89 83 10 28 A3 00           mov     [rbx+0A32810h], eax
0000000180363FE5  8B 83 F0 27 A3 00           mov     eax, [rbx+0A327F0h]
0000000180363FEB  89 83 00 28 A3 00           mov     [rbx+0A32800h], eax
0000000180363FF1  8B 83 E0 27 A3 00           mov     eax, [rbx+0A327E0h]
0000000180363FF7  89 83 F0 27 A3 00           mov     [rbx+0A327F0h], eax
0000000180363FFD  8B 83 70 28 A3 00           mov     eax, [rbx+0A32870h]
0000000180364003  89 83 80 28 A3 00           mov     [rbx+0A32880h], eax
0000000180364009  8B 83 60 28 A3 00           mov     eax, [rbx+0A32860h]
000000018036400F  89 83 70 28 A3 00           mov     [rbx+0A32870h], eax
0000000180364015  8B 83 50 28 A3 00           mov     eax, [rbx+0A32850h]
000000018036401B  89 83 60 28 A3 00           mov     [rbx+0A32860h], eax
0000000180364021  8B 83 40 28 A3 00           mov     eax, [rbx+0A32840h]
0000000180364027  89 83 50 28 A3 00           mov     [rbx+0A32850h], eax
000000018036402D  8B 83 C0 28 A3 00           mov     eax, [rbx+0A328C0h]
0000000180364033  89 83 D0 28 A3 00           mov     [rbx+0A328D0h], eax
0000000180364039  8B 83 B0 28 A3 00           mov     eax, [rbx+0A328B0h]
000000018036403F  89 83 C0 28 A3 00           mov     [rbx+0A328C0h], eax
0000000180364045  8B 83 A0 28 A3 00           mov     eax, [rbx+0A328A0h]
000000018036404B  89 83 B0 28 A3 00           mov     [rbx+0A328B0h], eax
0000000180364051  8B 83 90 28 A3 00           mov     eax, [rbx+0A32890h]
0000000180364057  89 83 A0 28 A3 00           mov     [rbx+0A328A0h], eax
000000018036405D  8B 83 E0 28 A3 00           mov     eax, [rbx+0A328E0h]
0000000180364063  89 83 F0 28 A3 00           mov     [rbx+0A328F0h], eax
0000000180364069  8B 83 10 29 A3 00           mov     eax, [rbx+0A32910h]
000000018036406F  89 83 20 29 A3 00           mov     [rbx+0A32920h], eax
0000000180364075  8B 83 00 29 A3 00           mov     eax, [rbx+0A32900h]
000000018036407B  89 83 10 29 A3 00           mov     [rbx+0A32910h], eax
0000000180364081  F3 0F 11 AB 70 27 A3 00     movss   dword ptr [rbx+0A32770h], xmm5
0000000180364089  F3 0F 10 83 B0 29 A3 00     movss   xmm0, dword ptr [rbx+0A329B0h]
0000000180364091  F3 0F 59 A3 E0 2A A3 00     mulss   xmm4, dword ptr [rbx+0A32AE0h]
0000000180364099  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036409D  F3 0F 58 A3 F0 2A A3 00     addss   xmm4, dword ptr [rbx+0A32AF0h]
00000001803640A5  F3 0F 11 B3 50 27 A3 00     movss   dword ptr [rbx+0A32750h], xmm6
00000001803640AD  F3 0F 11 8B 60 27 A3 00     movss   dword ptr [rbx+0A32760h], xmm1
00000001803640B5  F3 0F 10 8B A0 29 A3 00     movss   xmm1, dword ptr [rbx+0A329A0h]
00000001803640BD  F3 0F 59 D2                 mulss   xmm2, xmm2
00000001803640C1  0F 28 DC                    movaps  xmm3, xmm4
00000001803640C4  F3 0F 59 1D 40 0F 78 00     mulss   xmm3, cs:dword_180AE500C
00000001803640CC  F3 0F 59 D1                 mulss   xmm2, xmm1
00000001803640D0  F3 0F 58 D8                 addss   xmm3, xmm0
00000001803640D4  0F 28 C1                    movaps  xmm0, xmm1
00000001803640D7  F3 0F 59 C5                 mulss   xmm0, xmm5
00000001803640DB  F3 0F 59 DB                 mulss   xmm3, xmm3
00000001803640DF  F3 0F 5C D0                 subss   xmm2, xmm0
00000001803640E3  F3 0F 59 D9                 mulss   xmm3, xmm1
00000001803640E7  F3 0F 59 CC                 mulss   xmm1, xmm4
00000001803640EB  F3 0F 58 EA                 addss   xmm5, xmm2
00000001803640EF  F3 0F 5C D9                 subss   xmm3, xmm1
00000001803640F3  F3 0F 10 8B 00 2B A3 00     movss   xmm1, dword ptr [rbx+0A32B00h]
00000001803640FB  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803640FF  F3 0F 10 9B C0 29 A3 00     movss   xmm3, dword ptr [rbx+0A329C0h]
0000000180364107  F3 0F 10 93 10 2B A3 00     movss   xmm2, dword ptr [rbx+0A32B10h]
000000018036410F  0F 28 C3                    movaps  xmm0, xmm3
0000000180364112  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180364116  41 0F 28 EE                 movaps  xmm5, xmm14
000000018036411A  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018036411E  0F 28 E6                    movaps  xmm4, xmm6
0000000180364121  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180364125  F3 0F 59 D9                 mulss   xmm3, xmm1
0000000180364129  F3 0F 58 C2                 addss   xmm0, xmm2
000000018036412D  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180364131  F3 0F 11 83 30 29 A3 00     movss   dword ptr [rbx+0A32930h], xmm0
0000000180364139  F3 0F 11 9B 40 29 A3 00     movss   dword ptr [rbx+0A32940h], xmm3
0000000180364141  F3 0F 11 B3 40 28 A3 00     movss   dword ptr [rbx+0A32840h], xmm6
0000000180364149  F3 0F 59 A3 D0 29 A3 00     mulss   xmm4, dword ptr [rbx+0A329D0h]
0000000180364151  F3 0F 10 83 E0 29 A3 00     movss   xmm0, dword ptr [rbx+0A329E0h]
0000000180364159  F3 0F 59 83 50 28 A3 00     mulss   xmm0, dword ptr [rbx+0A32850h]
0000000180364161  F3 0F 10 8B F0 29 A3 00     movss   xmm1, dword ptr [rbx+0A329F0h]
0000000180364169  F3 0F 59 8B 60 28 A3 00     mulss   xmm1, dword ptr [rbx+0A32860h]
0000000180364171  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180364175  F3 0F 10 83 00 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A00h]
000000018036417D  F3 0F 59 83 70 28 A3 00     mulss   xmm0, dword ptr [rbx+0A32870h]
0000000180364185  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180364189  F3 0F 10 8B 80 28 A3 00     movss   xmm1, dword ptr [rbx+0A32880h]
0000000180364191  F3 0F 59 8B 10 2A A3 00     mulss   xmm1, dword ptr [rbx+0A32A10h]
0000000180364199  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036419D  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803641A1  0F 28 CE                    movaps  xmm1, xmm6
00000001803641A4  F3 0F 11 A3 60 28 A3 00     movss   dword ptr [rbx+0A32860h], xmm4
00000001803641AC  F3 0F 10 93 90 27 A3 00     movss   xmm2, dword ptr [rbx+0A32790h]
00000001803641B4  0F 28 C2                    movaps  xmm0, xmm2
00000001803641B7  F3 0F 59 83 40 2A A3 00     mulss   xmm0, dword ptr [rbx+0A32A40h]
00000001803641BF  F3 0F 5C C8                 subss   xmm1, xmm0
00000001803641C3  F3 0F 5C 8B A0 27 A3 00     subss   xmm1, dword ptr [rbx+0A327A0h]
00000001803641CB  F3 0F 59 8B 30 2A A3 00     mulss   xmm1, dword ptr [rbx+0A32A30h]
00000001803641D3  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803641D7  F3 0F 11 8B 80 27 A3 00     movss   dword ptr [rbx+0A32780h], xmm1
00000001803641DF  F3 0F 10 9B 90 27 A3 00     movss   xmm3, dword ptr [rbx+0A32790h]
00000001803641E7  F3 0F 59 9B 30 2A A3 00     mulss   xmm3, dword ptr [rbx+0A32A30h]
00000001803641EF  F3 0F 58 9B A0 27 A3 00     addss   xmm3, dword ptr [rbx+0A327A0h]
00000001803641F7  F3 0F 11 9B 90 27 A3 00     movss   dword ptr [rbx+0A32790h], xmm3
00000001803641FF  F3 0F 10 83 20 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A20h]
0000000180364207  F3 0F 10 8B 50 2A A3 00     movss   xmm1, dword ptr [rbx+0A32A50h]
000000018036420F  F3 0F 5C E8                 subss   xmm5, xmm0
0000000180364213  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180364217  F3 0F 59 EB                 mulss   xmm5, xmm3
000000018036421B  F3 0F 10 9B B0 27 A3 00     movss   xmm3, dword ptr [rbx+0A327B0h]
0000000180364223  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180364227  41 0F 28 C6                 movaps  xmm0, xmm14
000000018036422B  F3 0F 5C C1                 subss   xmm0, xmm1
000000018036422F  F3 0F 59 E9                 mulss   xmm5, xmm1
0000000180364233  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180364237  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036423B  F3 0F 10 83 70 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A70h]
0000000180364243  0F 28 C8                    movaps  xmm1, xmm0
0000000180364246  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018036424A  0F 28 E5                    movaps  xmm4, xmm5
000000018036424D  F3 0F 5C E3                 subss   xmm4, xmm3
0000000180364251  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180364255  F3 0F 59 A3 60 2A A3 00     mulss   xmm4, dword ptr [rbx+0A32A60h]
000000018036425D  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180364261  F3 0F 10 83 C0 2A A3 00     movss   xmm0, dword ptr [rbx+0A32AC0h]
0000000180364269  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036426D  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180364271  F3 0F 10 8B B0 2A A3 00     movss   xmm1, dword ptr [rbx+0A32AB0h]
0000000180364279  F3 0F 11 A3 A0 27 A3 00     movss   dword ptr [rbx+0A327A0h], xmm4
0000000180364281  F3 0F 59 8B C0 27 A3 00     mulss   xmm1, dword ptr [rbx+0A327C0h]
0000000180364289  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018036428D  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180364291  F3 0F 59 8B D0 2A A3 00     mulss   xmm1, dword ptr [rbx+0A32AD0h]
0000000180364299  F3 0F 11 8B 90 2B A4 00     movss   dword ptr [rbx+0A42B90h], xmm1
00000001803642A1  F3 0F 10 AB 60 27 A3 00     movss   xmm5, dword ptr [rbx+0A32760h]
00000001803642A9  F3 0F 11 AB 90 28 A3 00     movss   dword ptr [rbx+0A32890h], xmm5
00000001803642B1  0F 28 E5                    movaps  xmm4, xmm5
00000001803642B4  F3 0F 10 83 A0 28 A3 00     movss   xmm0, dword ptr [rbx+0A328A0h]
00000001803642BC  F3 0F 59 83 E0 29 A3 00     mulss   xmm0, dword ptr [rbx+0A329E0h]
00000001803642C4  F3 0F 59 A3 D0 29 A3 00     mulss   xmm4, dword ptr [rbx+0A329D0h]
00000001803642CC  F3 0F 10 8B B0 28 A3 00     movss   xmm1, dword ptr [rbx+0A328B0h]
00000001803642D4  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803642D8  F3 0F 59 8B F0 29 A3 00     mulss   xmm1, dword ptr [rbx+0A329F0h]
00000001803642E0  41 0F 28 F6                 movaps  xmm6, xmm14
00000001803642E4  F3 0F 10 83 00 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A00h]
00000001803642EC  F3 0F 59 83 C0 28 A3 00     mulss   xmm0, dword ptr [rbx+0A328C0h]
00000001803642F4  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803642F8  F3 0F 10 8B D0 28 A3 00     movss   xmm1, dword ptr [rbx+0A328D0h]
0000000180364300  F3 0F 59 8B 10 2A A3 00     mulss   xmm1, dword ptr [rbx+0A32A10h]
0000000180364308  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036430C  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180364310  0F 28 CD                    movaps  xmm1, xmm5
0000000180364313  F3 0F 11 A3 B0 28 A3 00     movss   dword ptr [rbx+0A328B0h], xmm4
000000018036431B  F3 0F 10 93 F0 27 A3 00     movss   xmm2, dword ptr [rbx+0A327F0h]
0000000180364323  0F 28 C2                    movaps  xmm0, xmm2
0000000180364326  F3 0F 59 83 40 2A A3 00     mulss   xmm0, dword ptr [rbx+0A32A40h]
000000018036432E  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180364332  F3 0F 5C 8B 00 28 A3 00     subss   xmm1, dword ptr [rbx+0A32800h]
000000018036433A  F3 0F 59 8B 30 2A A3 00     mulss   xmm1, dword ptr [rbx+0A32A30h]
0000000180364342  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180364346  F3 0F 11 8B E0 27 A3 00     movss   dword ptr [rbx+0A327E0h], xmm1
000000018036434E  F3 0F 10 9B F0 27 A3 00     movss   xmm3, dword ptr [rbx+0A327F0h]
0000000180364356  F3 0F 59 9B 30 2A A3 00     mulss   xmm3, dword ptr [rbx+0A32A30h]
000000018036435E  F3 0F 58 9B 00 28 A3 00     addss   xmm3, dword ptr [rbx+0A32800h]
0000000180364366  F3 0F 11 9B F0 27 A3 00     movss   dword ptr [rbx+0A327F0h], xmm3
000000018036436E  F3 0F 10 83 20 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A20h]
0000000180364376  F3 0F 10 8B 50 2A A3 00     movss   xmm1, dword ptr [rbx+0A32A50h]
000000018036437E  F3 0F 5C F0                 subss   xmm6, xmm0
0000000180364382  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180364386  F3 0F 59 F3                 mulss   xmm6, xmm3
000000018036438A  F3 0F 10 9B 10 28 A3 00     movss   xmm3, dword ptr [rbx+0A32810h]
0000000180364392  F3 0F 58 F0                 addss   xmm6, xmm0
0000000180364396  41 0F 28 C6                 movaps  xmm0, xmm14
000000018036439A  F3 0F 5C C1                 subss   xmm0, xmm1
000000018036439E  F3 0F 59 F1                 mulss   xmm6, xmm1
00000001803643A2  F3 0F 59 C5                 mulss   xmm0, xmm5
00000001803643A6  F3 0F 10 AB B0 2A A3 00     movss   xmm5, dword ptr [rbx+0A32AB0h]
00000001803643AE  F3 0F 58 F0                 addss   xmm6, xmm0
00000001803643B2  F3 0F 10 83 70 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A70h]
00000001803643BA  0F 28 C8                    movaps  xmm1, xmm0
00000001803643BD  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803643C1  0F 28 E6                    movaps  xmm4, xmm6
00000001803643C4  F3 0F 5C E3                 subss   xmm4, xmm3
00000001803643C8  F3 0F 59 CC                 mulss   xmm1, xmm4
00000001803643CC  F3 0F 59 A3 60 2A A3 00     mulss   xmm4, dword ptr [rbx+0A32A60h]
00000001803643D4  F3 0F 5C C8                 subss   xmm1, xmm0
00000001803643D8  F3 0F 10 83 C0 2A A3 00     movss   xmm0, dword ptr [rbx+0A32AC0h]
00000001803643E0  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803643E4  F3 0F 58 F1                 addss   xmm6, xmm1
00000001803643E8  F3 0F 11 A3 00 28 A3 00     movss   dword ptr [rbx+0A32800h], xmm4
00000001803643F0  F3 0F 10 93 D0 2A A3 00     movss   xmm2, dword ptr [rbx+0A32AD0h]
00000001803643F8  F3 0F 59 AB 20 28 A3 00     mulss   xmm5, dword ptr [rbx+0A32820h]
0000000180364400  F3 0F 10 8B 30 2B A3 00     movss   xmm1, dword ptr [rbx+0A32B30h]
0000000180364408  F3 0F 58 8B 10 29 A3 00     addss   xmm1, dword ptr [rbx+0A32910h]
0000000180364410  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180364414  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180364418  0F 28 C2                    movaps  xmm0, xmm2
000000018036441B  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018036441F  F3 0F 11 83 B0 2B A4 00     movss   dword ptr [rbx+0A42BB0h], xmm0
0000000180364427  F3 0F 10 9B 40 2B A3 00     movss   xmm3, dword ptr [rbx+0A32B40h]
000000018036442F  F3 0F 5D D9                 minss   xmm3, xmm1
0000000180364433  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180364437  F3 0F 11 9B 00 29 A3 00     movss   dword ptr [rbx+0A32900h], xmm3
000000018036443F  F3 0F 5C 9B F0 28 A3 00     subss   xmm3, dword ptr [rbx+0A328F0h]
0000000180364447  F3 0F 10 93 20 29 A3 00     movss   xmm2, dword ptr [rbx+0A32920h]
000000018036444F  41 0F 2F DD                 comiss  xmm3, xmm13
0000000180364453  73 0A                       jnb     short loc_18036445F
0000000180364455  F3 0F 58 93 60 2B A3 00     addss   xmm2, dword ptr [rbx+0A32B60h]
000000018036445D  EB 08                       jmp     short loc_180364467
000000018036445F  F3 0F 58 93 50 2B A3 00     addss   xmm2, dword ptr [rbx+0A32B50h]
0000000180364467  41 0F 2F D5                 comiss  xmm2, xmm13
000000018036446B  F3 0F 10 9B 90 29 A3 00     movss   xmm3, dword ptr [rbx+0A32990h]
0000000180364473  F3 0F 10 A3 F0 28 A3 00     movss   xmm4, dword ptr [rbx+0A328F0h]
000000018036447B  0F 28 CB                    movaps  xmm1, xmm3
000000018036447E  F3 0F 5C CC                 subss   xmm1, xmm4
0000000180364482  76 05                       jbe     short loc_180364489
0000000180364484  0F 5A C2                    cvtps2pd xmm0, xmm2
0000000180364487  EB 03                       jmp     short loc_18036448C
0000000180364489  0F 57 C0                    xorps   xmm0, xmm0
000000018036448C  F3 0F 59 8B A0 2A A3 00     mulss   xmm1, dword ptr [rbx+0A32AA0h]
0000000180364494  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180364498  F3 0F 58 CC                 addss   xmm1, xmm4
000000018036449C  41 0F 2F C4                 comiss  xmm0, xmm12
00000001803644A0  73 06                       jnb     short loc_1803644A8
00000001803644A2  41 0F 28 C4                 movaps  xmm0, xmm12
00000001803644A6  EB 05                       jmp     short loc_1803644AD
00000001803644A8  F3 41 0F 5D C6              minss   xmm0, xmm14
00000001803644AD  F3 0F 59 83 D0 2A A3 00     mulss   xmm0, dword ptr [rbx+0A32AD0h]
00000001803644B5  F3 0F 11 83 10 29 A3 00     movss   dword ptr [rbx+0A32910h], xmm0
00000001803644BD  0F 28 C1                    movaps  xmm0, xmm1
00000001803644C0  F3 0F 5C C4                 subss   xmm0, xmm4
00000001803644C4  41 0F 2E C5                 ucomiss xmm0, xmm13
00000001803644C8  74 03                       jz      short loc_1803644CD
00000001803644CA  0F 28 D9                    movaps  xmm3, xmm1
00000001803644CD  F3 0F 11 9B E0 28 A3 00     movss   dword ptr [rbx+0A328E0h], xmm3
00000001803644D5  0F 28 E3                    movaps  xmm4, xmm3
00000001803644D8  F3 0F 58 9B 30 29 A3 00     addss   xmm3, dword ptr [rbx+0A32930h]
00000001803644E0  8B 83 70 AB A3 00           mov     eax, [rbx+0A3AB70h]
00000001803644E6  0F 28 C3                    movaps  xmm0, xmm3
00000001803644E9  F3 41 0F 59 D9              mulss   xmm3, xmm9
00000001803644EE  F3 41 0F 59 C3              mulss   xmm0, xmm11
00000001803644F3  0F 5A CB                    cvtps2pd xmm1, xmm3
00000001803644F6  F3 0F 2C D0                 cvttss2si edx, xmm0
00000001803644FA  2B C2                       sub     eax, edx
00000001803644FC  48 63 C8                    movsxd  rcx, eax
00000001803644FF  48 63 83 74 AB A3 00        movsxd  rax, dword ptr [rbx+0A3AB74h]
0000000180364506  48 FF C1                    inc     rcx
0000000180364509  48 FF C8                    dec     rax
000000018036450C  48 23 C8                    and     rcx, rax
000000018036450F  8B 84 8B 70 2B A3 00        mov     eax, [rbx+rcx*4+0A32B70h]
0000000180364516  89 83 A0 2B A4 00           mov     [rbx+0A42BA0h], eax
000000018036451C  8B 83 70 AB A3 00           mov     eax, [rbx+0A3AB70h]
0000000180364522  2B C2                       sub     eax, edx
0000000180364524  48 63 C8                    movsxd  rcx, eax
0000000180364527  48 63 83 74 AB A3 00        movsxd  rax, dword ptr [rbx+0A3AB74h]
000000018036452E  48 83 C1 02                 add     rcx, 2
0000000180364532  48 FF C8                    dec     rax
0000000180364535  48 23 C8                    and     rcx, rax
0000000180364538  8B 84 8B 70 2B A3 00        mov     eax, [rbx+rcx*4+0A32B70h]
000000018036453F  89 83 A4 2B A4 00           mov     [rbx+0A42BA4h], eax
0000000180364545  F3 0F 2C C3                 cvttss2si eax, xmm3
0000000180364549  66 0F 6E C0                 movd    xmm0, eax
000000018036454D  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
0000000180364551  F2 0F 5C C8                 subsd   xmm1, xmm0
0000000180364555  66 0F 5A E9                 cvtpd2ps xmm5, xmm1
0000000180364559  F3 0F 11 AB A8 2B A4 00     movss   dword ptr [rbx+0A42BA8h], xmm5
0000000180364561  0F 28 FD                    movaps  xmm7, xmm5
0000000180364564  F3 0F 58 A3 40 29 A3 00     addss   xmm4, dword ptr [rbx+0A32940h]
000000018036456C  F3 0F 10 9B A0 2B A4 00     movss   xmm3, dword ptr [rbx+0A42BA0h]
0000000180364574  8B 83 80 2B A4 00           mov     eax, [rbx+0A42B80h]
000000018036457A  F3 0F 10 B3 20 29 A3 00     movss   xmm6, dword ptr [rbx+0A32920h]
0000000180364582  F3 0F 59 EB                 mulss   xmm5, xmm3
0000000180364586  0F 28 C4                    movaps  xmm0, xmm4
0000000180364589  F3 41 0F 59 E1              mulss   xmm4, xmm9
000000018036458E  F3 41 0F 59 C3              mulss   xmm0, xmm11
0000000180364593  0F 5A CC                    cvtps2pd xmm1, xmm4
0000000180364596  F3 0F 2C D0                 cvttss2si edx, xmm0
000000018036459A  2B C2                       sub     eax, edx
000000018036459C  48 63 C8                    movsxd  rcx, eax
000000018036459F  48 63 83 84 2B A4 00        movsxd  rax, dword ptr [rbx+0A42B84h]
00000001803645A6  48 FF C1                    inc     rcx
00000001803645A9  48 FF C8                    dec     rax
00000001803645AC  48 23 C8                    and     rcx, rax
00000001803645AF  8B 84 8B 80 AB A3 00        mov     eax, [rbx+rcx*4+0A3AB80h]
00000001803645B6  89 83 C0 2B A4 00           mov     [rbx+0A42BC0h], eax
00000001803645BC  8B 83 80 2B A4 00           mov     eax, [rbx+0A42B80h]
00000001803645C2  2B C2                       sub     eax, edx
00000001803645C4  48 63 C8                    movsxd  rcx, eax
00000001803645C7  48 63 83 84 2B A4 00        movsxd  rax, dword ptr [rbx+0A42B84h]
00000001803645CE  48 83 C1 02                 add     rcx, 2
00000001803645D2  48 FF C8                    dec     rax
00000001803645D5  48 23 C8                    and     rcx, rax
00000001803645D8  8B 84 8B 80 AB A3 00        mov     eax, [rbx+rcx*4+0A3AB80h]
00000001803645DF  89 83 C4 2B A4 00           mov     [rbx+0A42BC4h], eax
00000001803645E5  F3 0F 2C C4                 cvttss2si eax, xmm4
00000001803645E9  66 0F 6E C0                 movd    xmm0, eax
00000001803645ED  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00000001803645F1  F2 0F 5C C8                 subsd   xmm1, xmm0
00000001803645F5  66 0F 5A E1                 cvtpd2ps xmm4, xmm1
00000001803645F9  F3 0F 11 A3 C8 2B A4 00     movss   dword ptr [rbx+0A42BC8h], xmm4
0000000180364601  44 0F 28 C4                 movaps  xmm8, xmm4
0000000180364605  F3 0F 59 BB A4 2B A4 00     mulss   xmm7, dword ptr [rbx+0A42BA4h]
000000018036460D  F3 0F 10 83 D0 27 A3 00     movss   xmm0, dword ptr [rbx+0A327D0h]
0000000180364615  F3 0F 5C FD                 subss   xmm7, xmm5
0000000180364619  F3 0F 58 FB                 addss   xmm7, xmm3
000000018036461D  F3 0F 10 9B C0 2B A4 00     movss   xmm3, dword ptr [rbx+0A42BC0h]
0000000180364625  F3 0F 59 E3                 mulss   xmm4, xmm3
0000000180364629  F3 0F 59 FE                 mulss   xmm7, xmm6
000000018036462D  0F 28 CF                    movaps  xmm1, xmm7
0000000180364630  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180364634  F3 0F 11 8B B0 27 A3 00     movss   dword ptr [rbx+0A327B0h], xmm1
000000018036463C  F3 0F 59 8B 20 2B A3 00     mulss   xmm1, dword ptr [rbx+0A32B20h]
0000000180364644  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180364648  F3 0F 11 8B C0 27 A3 00     movss   dword ptr [rbx+0A327C0h], xmm1
0000000180364650  F3 44 0F 59 83 C4 2B A4 00  mulss   xmm8, dword ptr [rbx+0A42BC4h]
0000000180364659  F3 0F 10 8B 30 28 A3 00     movss   xmm1, dword ptr [rbx+0A32830h]
0000000180364661  F3 44 0F 5C C4              subss   xmm8, xmm4
0000000180364666  F3 44 0F 58 C3              addss   xmm8, xmm3
000000018036466B  F3 44 0F 59 C6              mulss   xmm8, xmm6
0000000180364670  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180364674  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180364678  F3 0F 11 93 10 28 A3 00     movss   dword ptr [rbx+0A32810h], xmm2
0000000180364680  F3 0F 59 93 20 2B A3 00     mulss   xmm2, dword ptr [rbx+0A32B20h]
0000000180364688  F3 0F 10 83 90 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A90h]
0000000180364690  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180364694  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180364698  F3 44 0F 59 C0              mulss   xmm8, xmm0
000000018036469D  F3 0F 11 93 20 28 A3 00     movss   dword ptr [rbx+0A32820h], xmm2
00000001803646A5  41 0F 28 D6                 movaps  xmm2, xmm14
00000001803646A9  F3 0F 10 B3 60 27 A3 00     movss   xmm6, dword ptr [rbx+0A32760h]
00000001803646B1  F3 0F 10 9B 50 27 A3 00     movss   xmm3, dword ptr [rbx+0A32750h]
00000001803646B9  F3 0F 10 AB 80 2A A3 00     movss   xmm5, dword ptr [rbx+0A32A80h]
00000001803646C1  F3 0F 11 BB 50 29 A3 00     movss   dword ptr [rbx+0A32950h], xmm7
00000001803646C9  0F 28 C5                    movaps  xmm0, xmm5
00000001803646CC  F3 44 0F 11 83 60 29 A3 00  movss   dword ptr [rbx+0A32960h], xmm8
00000001803646D5  F3 0F 10 A3 C0 2A A3 00     movss   xmm4, dword ptr [rbx+0A32AC0h]
00000001803646DD  F3 0F 5C D4                 subss   xmm2, xmm4
00000001803646E1  F3 0F 59 C3                 mulss   xmm0, xmm3
00000001803646E5  0F 28 CC                    movaps  xmm1, xmm4
00000001803646E8  F3 0F 59 EE                 mulss   xmm5, xmm6
00000001803646EC  F3 0F 59 C8                 mulss   xmm1, xmm0
00000001803646F0  0F 28 C2                    movaps  xmm0, xmm2
00000001803646F3  F3 0F 59 D6                 mulss   xmm2, xmm6
00000001803646F7  F3 0F 59 E5                 mulss   xmm4, xmm5
00000001803646FB  F3 0F 59 C3                 mulss   xmm0, xmm3
00000001803646FF  F3 0F 58 E2                 addss   xmm4, xmm2
0000000180364703  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180364707  F3 41 0F 58 E0              addss   xmm4, xmm8
000000018036470C  F3 0F 58 8B 50 29 A3 00     addss   xmm1, dword ptr [rbx+0A32950h]
0000000180364714  F3 0F 11 8B 70 29 A3 00     movss   dword ptr [rbx+0A32970h], xmm1
000000018036471C  F3 0F 11 A3 80 29 A3 00     movss   dword ptr [rbx+0A32980h], xmm4
0000000180364724  8B 8B 74 AB A3 00           mov     ecx, [rbx+0A3AB74h]
000000018036472A  8B 83 70 AB A3 00           mov     eax, [rbx+0A3AB70h]
0000000180364730  FF C9                       dec     ecx
0000000180364732  FF C8                       dec     eax
0000000180364734  23 C8                       and     ecx, eax
0000000180364736  89 8B 70 AB A3 00           mov     [rbx+0A3AB70h], ecx
000000018036473C  8B 83 90 2B A4 00           mov     eax, [rbx+0A42B90h]
0000000180364742  48 63 C9                    movsxd  rcx, ecx
0000000180364745  89 84 8B 70 2B A3 00        mov     [rbx+rcx*4+0A32B70h], eax
000000018036474C  8B 8B 80 2B A4 00           mov     ecx, [rbx+0A42B80h]
0000000180364752  8B 83 84 2B A4 00           mov     eax, [rbx+0A42B84h]
0000000180364758  FF C9                       dec     ecx
000000018036475A  FF C8                       dec     eax
000000018036475C  23 C8                       and     ecx, eax
000000018036475E  89 8B 80 2B A4 00           mov     [rbx+0A42B80h], ecx
0000000180364764  8B 83 B0 2B A4 00           mov     eax, [rbx+0A42BB0h]
000000018036476A  48 63 C9                    movsxd  rcx, ecx
000000018036476D  89 84 8B 80 AB A3 00        mov     [rbx+rcx*4+0A3AB80h], eax
0000000180364774  F3 0F 10 B3 70 8D 01 00     movss   xmm6, dword ptr [rbx+18D70h]
000000018036477C  0F 28 FE                    movaps  xmm7, xmm6
000000018036477F  F3 0F 59 B3 80 29 A3 00     mulss   xmm6, dword ptr [rbx+0A32980h]
0000000180364787  F3 0F 59 BB 70 29 A3 00     mulss   xmm7, dword ptr [rbx+0A32970h]
000000018036478F  E9 E6 1F 00 00              jmp     loc_18036677A
0000000180364794  83 BB 0C 30 A8 00 04        cmp     dword ptr [rbx+0A8300Ch], 4
000000018036479B  74 12                       jz      short loc_1803647AF
000000018036479D  89 B3 70 1E 62 00           mov     [rbx+621E70h], esi
00000001803647A3  89 B3 80 1E 62 00           mov     [rbx+621E80h], esi
00000001803647A9  89 B3 90 1E 62 00           mov     [rbx+621E90h], esi
00000001803647AF  C7 83 0C 30 A8 00 04 00 00 00  mov     dword ptr [rbx+0A8300Ch], 4
00000001803647B9  F3 0F 10 8B 20 1B 62 00     movss   xmm1, dword ptr [rbx+621B20h]
00000001803647C1  F3 0F 10 83 30 1B 62 00     movss   xmm0, dword ptr [rbx+621B30h]
00000001803647C9  F3 0F 11 8B 40 1B 62 00     movss   dword ptr [rbx+621B40h], xmm1
00000001803647D1  F3 0F 11 83 50 1B 62 00     movss   dword ptr [rbx+621B50h], xmm0
00000001803647D9  F3 0F 58 8B 80 1B 62 00     addss   xmm1, dword ptr [rbx+621B80h]
00000001803647E1  0F 5A C1                    cvtps2pd xmm0, xmm1
00000001803647E4  E8 D7 45 00 00              call    sub_180368DC0
00000001803647E9  0F 57 C9                    xorps   xmm1, xmm1
00000001803647EC  F2 0F 5A C8                 cvtsd2ss xmm1, xmm0
00000001803647F0  F3 0F 5D 0D A0 64 62 00     minss   xmm1, cs:dword_18098AC98
00000001803647F8  F3 0F 5F 0D B0 64 62 00     maxss   xmm1, cs:dword_18098ACB0
0000000180364800  F3 0F 11 8B 60 1B 62 00     movss   dword ptr [rbx+621B60h], xmm1
0000000180364808  F3 0F 10 83 40 1C 62 00     movss   xmm0, dword ptr [rbx+621C40h]
0000000180364810  F3 0F 10 BB 50 1B 62 00     movss   xmm7, dword ptr [rbx+621B50h]
0000000180364818  F3 0F 11 83 50 1C 62 00     movss   dword ptr [rbx+621C50h], xmm0
0000000180364820  F3 0F 59 8B 70 1C 62 00     mulss   xmm1, dword ptr [rbx+621C70h]
0000000180364828  0F 2F 0D A1 0A 78 00        comiss  xmm1, cs:dword_180AE52D0
000000018036482F  72 0A                       jb      short loc_18036483B
0000000180364831  F3 0F 58 0D D7 0C 78 00     addss   xmm1, cs:dword_180AE5510
0000000180364839  EB 0E                       jmp     short loc_180364849
000000018036483B  41 0F 2F CB                 comiss  xmm1, xmm11
000000018036483F  72 08                       jb      short loc_180364849
0000000180364841  F3 0F 58 0D AF 0C 78 00     addss   xmm1, cs:dword_180AE54F8
0000000180364849  45 0F 57 ED                 xorps   xmm13, xmm13
000000018036484D  41 0F 2E CD                 ucomiss xmm1, xmm13
0000000180364851  75 08                       jnz     short loc_18036485B
0000000180364853  F3 0F 10 8B 80 1C 62 00     movss   xmm1, dword ptr [rbx+621C80h]
000000018036485B  F3 0F 58 C1                 addss   xmm0, xmm1
000000018036485F  E8 2C 47 00 00              call    sub_180368F90
0000000180364864  0F 28 F0                    movaps  xmm6, xmm0
0000000180364867  E8 54 47 00 00              call    sub_180368FC0
000000018036486C  F3 44 0F 10 35 3F 08 78 00  movss   xmm14, cs:dword_180AE50B4
0000000180364875  0F 28 E8                    movaps  xmm5, xmm0
0000000180364878  F3 0F 11 AB 60 1C 62 00     movss   dword ptr [rbx+621C60h], xmm5
0000000180364880  F3 0F 59 F7                 mulss   xmm6, xmm7
0000000180364884  F3 41 0F 5C FE              subss   xmm7, xmm14
0000000180364889  F3 0F 58 F7                 addss   xmm6, xmm7
000000018036488D  F3 0F 11 B3 40 1C 62 00     movss   dword ptr [rbx+621C40h], xmm6
0000000180364895  F3 0F 59 AB A0 1C 62 00     mulss   xmm5, dword ptr [rbx+621CA0h]
000000018036489D  F3 0F 58 AB B0 1C 62 00     addss   xmm5, dword ptr [rbx+621CB0h]
00000001803648A5  F3 0F 11 AB 90 1C 62 00     movss   dword ptr [rbx+621C90h], xmm5
00000001803648AD  0F 28 E5                    movaps  xmm4, xmm5
00000001803648B0  8B 83 30 1D 62 00           mov     eax, [rbx+621D30h]
00000001803648B6  0F 28 D5                    movaps  xmm2, xmm5
00000001803648B9  89 83 40 1D 62 00           mov     [rbx+621D40h], eax
00000001803648BF  8B 83 20 1D 62 00           mov     eax, [rbx+621D20h]
00000001803648C5  89 83 30 1D 62 00           mov     [rbx+621D30h], eax
00000001803648CB  8B 83 10 1D 62 00           mov     eax, [rbx+621D10h]
00000001803648D1  89 83 20 1D 62 00           mov     [rbx+621D20h], eax
00000001803648D7  8B 83 00 1D 62 00           mov     eax, [rbx+621D00h]
00000001803648DD  89 83 10 1D 62 00           mov     [rbx+621D10h], eax
00000001803648E3  8B 83 F0 1C 62 00           mov     eax, [rbx+621CF0h]
00000001803648E9  89 83 00 1D 62 00           mov     [rbx+621D00h], eax
00000001803648EF  8B 83 90 1D 62 00           mov     eax, [rbx+621D90h]
00000001803648F5  89 83 A0 1D 62 00           mov     [rbx+621DA0h], eax
00000001803648FB  8B 83 80 1D 62 00           mov     eax, [rbx+621D80h]
0000000180364901  89 83 90 1D 62 00           mov     [rbx+621D90h], eax
0000000180364907  8B 83 70 1D 62 00           mov     eax, [rbx+621D70h]
000000018036490D  89 83 80 1D 62 00           mov     [rbx+621D80h], eax
0000000180364913  8B 83 60 1D 62 00           mov     eax, [rbx+621D60h]
0000000180364919  89 83 70 1D 62 00           mov     [rbx+621D70h], eax
000000018036491F  8B 83 50 1D 62 00           mov     eax, [rbx+621D50h]
0000000180364925  89 83 60 1D 62 00           mov     [rbx+621D60h], eax
000000018036492B  8B 83 E0 1D 62 00           mov     eax, [rbx+621DE0h]
0000000180364931  89 83 F0 1D 62 00           mov     [rbx+621DF0h], eax
0000000180364937  8B 83 D0 1D 62 00           mov     eax, [rbx+621DD0h]
000000018036493D  89 83 E0 1D 62 00           mov     [rbx+621DE0h], eax
0000000180364943  8B 83 C0 1D 62 00           mov     eax, [rbx+621DC0h]
0000000180364949  89 83 D0 1D 62 00           mov     [rbx+621DD0h], eax
000000018036494F  8B 83 B0 1D 62 00           mov     eax, [rbx+621DB0h]
0000000180364955  89 83 C0 1D 62 00           mov     [rbx+621DC0h], eax
000000018036495B  8B 83 30 1E 62 00           mov     eax, [rbx+621E30h]
0000000180364961  89 83 40 1E 62 00           mov     [rbx+621E40h], eax
0000000180364967  8B 83 20 1E 62 00           mov     eax, [rbx+621E20h]
000000018036496D  89 83 30 1E 62 00           mov     [rbx+621E30h], eax
0000000180364973  8B 83 10 1E 62 00           mov     eax, [rbx+621E10h]
0000000180364979  89 83 20 1E 62 00           mov     [rbx+621E20h], eax
000000018036497F  8B 83 00 1E 62 00           mov     eax, [rbx+621E00h]
0000000180364985  89 83 10 1E 62 00           mov     [rbx+621E10h], eax
000000018036498B  8B 83 50 1E 62 00           mov     eax, [rbx+621E50h]
0000000180364991  89 83 60 1E 62 00           mov     [rbx+621E60h], eax
0000000180364997  8B 83 80 1E 62 00           mov     eax, [rbx+621E80h]
000000018036499D  89 83 90 1E 62 00           mov     [rbx+621E90h], eax
00000001803649A3  8B 83 70 1E 62 00           mov     eax, [rbx+621E70h]
00000001803649A9  89 83 80 1E 62 00           mov     [rbx+621E80h], eax
00000001803649AF  F3 0F 11 AB E0 1C 62 00     movss   dword ptr [rbx+621CE0h], xmm5
00000001803649B7  F3 0F 59 A3 50 20 62 00     mulss   xmm4, dword ptr [rbx+622050h]
00000001803649BF  F3 0F 10 83 20 1F 62 00     movss   xmm0, dword ptr [rbx+621F20h]
00000001803649C7  F3 41 0F 59 D7              mulss   xmm2, xmm15
00000001803649CC  F3 0F 58 A3 60 20 62 00     addss   xmm4, dword ptr [rbx+622060h]
00000001803649D4  F3 44 0F 11 8B C0 1C 62 00  movss   dword ptr [rbx+621CC0h], xmm9
00000001803649DD  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803649E1  F3 44 0F 11 83 D0 1C 62 00  movss   dword ptr [rbx+621CD0h], xmm8
00000001803649EA  F3 0F 10 8B 10 1F 62 00     movss   xmm1, dword ptr [rbx+621F10h]
00000001803649F2  0F 28 DC                    movaps  xmm3, xmm4
00000001803649F5  F3 41 0F 59 DF              mulss   xmm3, xmm15
00000001803649FA  F3 0F 59 D2                 mulss   xmm2, xmm2
00000001803649FE  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180364A02  0F 28 C1                    movaps  xmm0, xmm1
0000000180364A05  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180364A09  F3 0F 59 D1                 mulss   xmm2, xmm1
0000000180364A0D  F3 0F 59 DB                 mulss   xmm3, xmm3
0000000180364A11  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180364A15  F3 0F 59 D9                 mulss   xmm3, xmm1
0000000180364A19  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180364A1D  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180364A21  F3 0F 5C D9                 subss   xmm3, xmm1
0000000180364A25  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180364A29  F3 0F 10 9B 30 1F 62 00     movss   xmm3, dword ptr [rbx+621F30h]
0000000180364A31  F3 0F 10 8B 70 20 62 00     movss   xmm1, dword ptr [rbx+622070h]
0000000180364A39  0F 28 C3                    movaps  xmm0, xmm3
0000000180364A3C  F3 0F 10 93 80 20 62 00     movss   xmm2, dword ptr [rbx+622080h]
0000000180364A44  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180364A48  41 0F 28 EE                 movaps  xmm5, xmm14
0000000180364A4C  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180364A50  41 0F 28 E1                 movaps  xmm4, xmm9
0000000180364A54  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180364A58  F3 0F 59 D9                 mulss   xmm3, xmm1
0000000180364A5C  F3 0F 58 C2                 addss   xmm0, xmm2
0000000180364A60  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180364A64  F3 0F 11 83 A0 1E 62 00     movss   dword ptr [rbx+621EA0h], xmm0
0000000180364A6C  F3 0F 11 9B B0 1E 62 00     movss   dword ptr [rbx+621EB0h], xmm3
0000000180364A74  F3 44 0F 11 8B B0 1D 62 00  movss   dword ptr [rbx+621DB0h], xmm9
0000000180364A7D  F3 0F 59 A3 40 1F 62 00     mulss   xmm4, dword ptr [rbx+621F40h]
0000000180364A85  F3 0F 10 83 50 1F 62 00     movss   xmm0, dword ptr [rbx+621F50h]
0000000180364A8D  F3 0F 59 83 C0 1D 62 00     mulss   xmm0, dword ptr [rbx+621DC0h]
0000000180364A95  F3 0F 10 8B 60 1F 62 00     movss   xmm1, dword ptr [rbx+621F60h]
0000000180364A9D  F3 0F 59 8B D0 1D 62 00     mulss   xmm1, dword ptr [rbx+621DD0h]
0000000180364AA5  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180364AA9  F3 0F 10 83 E0 1D 62 00     movss   xmm0, dword ptr [rbx+621DE0h]
0000000180364AB1  F3 0F 59 83 70 1F 62 00     mulss   xmm0, dword ptr [rbx+621F70h]
0000000180364AB9  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180364ABD  F3 0F 10 8B 80 1F 62 00     movss   xmm1, dword ptr [rbx+621F80h]
0000000180364AC5  F3 0F 59 8B F0 1D 62 00     mulss   xmm1, dword ptr [rbx+621DF0h]
0000000180364ACD  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180364AD1  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180364AD5  41 0F 28 C9                 movaps  xmm1, xmm9
0000000180364AD9  F3 0F 11 A3 D0 1D 62 00     movss   dword ptr [rbx+621DD0h], xmm4
0000000180364AE1  F3 0F 10 93 00 1D 62 00     movss   xmm2, dword ptr [rbx+621D00h]
0000000180364AE9  0F 28 C2                    movaps  xmm0, xmm2
0000000180364AEC  F3 0F 59 83 B0 1F 62 00     mulss   xmm0, dword ptr [rbx+621FB0h]
0000000180364AF4  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180364AF8  F3 0F 5C 8B 10 1D 62 00     subss   xmm1, dword ptr [rbx+621D10h]
0000000180364B00  F3 0F 59 8B A0 1F 62 00     mulss   xmm1, dword ptr [rbx+621FA0h]
0000000180364B08  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180364B0C  F3 0F 11 8B F0 1C 62 00     movss   dword ptr [rbx+621CF0h], xmm1
0000000180364B14  F3 0F 10 9B 00 1D 62 00     movss   xmm3, dword ptr [rbx+621D00h]
0000000180364B1C  F3 0F 59 9B A0 1F 62 00     mulss   xmm3, dword ptr [rbx+621FA0h]
0000000180364B24  F3 0F 58 9B 10 1D 62 00     addss   xmm3, dword ptr [rbx+621D10h]
0000000180364B2C  F3 0F 11 9B 00 1D 62 00     movss   dword ptr [rbx+621D00h], xmm3
0000000180364B34  F3 0F 10 83 90 1F 62 00     movss   xmm0, dword ptr [rbx+621F90h]
0000000180364B3C  F3 0F 10 8B C0 1F 62 00     movss   xmm1, dword ptr [rbx+621FC0h]
0000000180364B44  F3 0F 5C E8                 subss   xmm5, xmm0
0000000180364B48  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180364B4C  F3 0F 59 EB                 mulss   xmm5, xmm3
0000000180364B50  F3 0F 10 9B 20 1D 62 00     movss   xmm3, dword ptr [rbx+621D20h]
0000000180364B58  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180364B5C  41 0F 28 C6                 movaps  xmm0, xmm14
0000000180364B60  F3 0F 5C C1                 subss   xmm0, xmm1
0000000180364B64  F3 0F 59 E9                 mulss   xmm5, xmm1
0000000180364B68  F3 41 0F 59 C1              mulss   xmm0, xmm9
0000000180364B6D  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180364B71  F3 0F 10 83 E0 1F 62 00     movss   xmm0, dword ptr [rbx+621FE0h]
0000000180364B79  0F 28 C8                    movaps  xmm1, xmm0
0000000180364B7C  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180364B80  0F 28 E5                    movaps  xmm4, xmm5
0000000180364B83  F3 0F 5C E3                 subss   xmm4, xmm3
0000000180364B87  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180364B8B  F3 0F 59 A3 D0 1F 62 00     mulss   xmm4, dword ptr [rbx+621FD0h]
0000000180364B93  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180364B97  F3 0F 10 83 30 20 62 00     movss   xmm0, dword ptr [rbx+622030h]
0000000180364B9F  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180364BA3  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180364BA7  F3 0F 10 8B 20 20 62 00     movss   xmm1, dword ptr [rbx+622020h]
0000000180364BAF  F3 0F 11 A3 10 1D 62 00     movss   dword ptr [rbx+621D10h], xmm4
0000000180364BB7  F3 0F 59 8B 30 1D 62 00     mulss   xmm1, dword ptr [rbx+621D30h]
0000000180364BBF  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180364BC3  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180364BC7  F3 0F 59 8B 40 20 62 00     mulss   xmm1, dword ptr [rbx+622040h]
0000000180364BCF  F3 0F 11 8B 00 21 63 00     movss   dword ptr [rbx+632100h], xmm1
0000000180364BD7  F3 0F 10 AB D0 1C 62 00     movss   xmm5, dword ptr [rbx+621CD0h]
0000000180364BDF  F3 0F 11 AB 00 1E 62 00     movss   dword ptr [rbx+621E00h], xmm5
0000000180364BE7  0F 28 C5                    movaps  xmm0, xmm5
0000000180364BEA  F3 0F 10 A3 10 1E 62 00     movss   xmm4, dword ptr [rbx+621E10h]
0000000180364BF2  F3 0F 59 A3 50 1F 62 00     mulss   xmm4, dword ptr [rbx+621F50h]
0000000180364BFA  F3 0F 59 83 40 1F 62 00     mulss   xmm0, dword ptr [rbx+621F40h]
0000000180364C02  F3 0F 10 8B 60 1F 62 00     movss   xmm1, dword ptr [rbx+621F60h]
0000000180364C0A  F3 0F 59 8B 20 1E 62 00     mulss   xmm1, dword ptr [rbx+621E20h]
0000000180364C12  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180364C16  F3 0F 10 83 30 1E 62 00     movss   xmm0, dword ptr [rbx+621E30h]
0000000180364C1E  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180364C22  F3 0F 59 83 70 1F 62 00     mulss   xmm0, dword ptr [rbx+621F70h]
0000000180364C2A  41 0F 28 F6                 movaps  xmm6, xmm14
0000000180364C2E  F3 0F 10 8B 40 1E 62 00     movss   xmm1, dword ptr [rbx+621E40h]
0000000180364C36  F3 0F 59 8B 80 1F 62 00     mulss   xmm1, dword ptr [rbx+621F80h]
0000000180364C3E  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180364C42  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180364C46  0F 28 CD                    movaps  xmm1, xmm5
0000000180364C49  F3 0F 11 A3 20 1E 62 00     movss   dword ptr [rbx+621E20h], xmm4
0000000180364C51  F3 0F 10 93 60 1D 62 00     movss   xmm2, dword ptr [rbx+621D60h]
0000000180364C59  0F 28 C2                    movaps  xmm0, xmm2
0000000180364C5C  F3 0F 59 83 B0 1F 62 00     mulss   xmm0, dword ptr [rbx+621FB0h]
0000000180364C64  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180364C68  F3 0F 5C 8B 70 1D 62 00     subss   xmm1, dword ptr [rbx+621D70h]
0000000180364C70  F3 0F 59 8B A0 1F 62 00     mulss   xmm1, dword ptr [rbx+621FA0h]
0000000180364C78  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180364C7C  F3 0F 11 8B 50 1D 62 00     movss   dword ptr [rbx+621D50h], xmm1
0000000180364C84  F3 0F 10 9B 60 1D 62 00     movss   xmm3, dword ptr [rbx+621D60h]
0000000180364C8C  F3 0F 59 9B A0 1F 62 00     mulss   xmm3, dword ptr [rbx+621FA0h]
0000000180364C94  F3 0F 58 9B 70 1D 62 00     addss   xmm3, dword ptr [rbx+621D70h]
0000000180364C9C  F3 0F 11 9B 60 1D 62 00     movss   dword ptr [rbx+621D60h], xmm3
0000000180364CA4  F3 0F 10 83 90 1F 62 00     movss   xmm0, dword ptr [rbx+621F90h]
0000000180364CAC  F3 0F 10 8B C0 1F 62 00     movss   xmm1, dword ptr [rbx+621FC0h]
0000000180364CB4  F3 0F 5C F0                 subss   xmm6, xmm0
0000000180364CB8  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180364CBC  F3 0F 59 F3                 mulss   xmm6, xmm3
0000000180364CC0  F3 0F 10 9B 80 1D 62 00     movss   xmm3, dword ptr [rbx+621D80h]
0000000180364CC8  F3 0F 58 F0                 addss   xmm6, xmm0
0000000180364CCC  41 0F 28 C6                 movaps  xmm0, xmm14
0000000180364CD0  F3 0F 5C C1                 subss   xmm0, xmm1
0000000180364CD4  F3 0F 59 F1                 mulss   xmm6, xmm1
0000000180364CD8  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180364CDC  F3 0F 10 AB 20 20 62 00     movss   xmm5, dword ptr [rbx+622020h]
0000000180364CE4  F3 0F 58 F0                 addss   xmm6, xmm0
0000000180364CE8  F3 0F 10 83 E0 1F 62 00     movss   xmm0, dword ptr [rbx+621FE0h]
0000000180364CF0  0F 28 C8                    movaps  xmm1, xmm0
0000000180364CF3  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180364CF7  0F 28 E6                    movaps  xmm4, xmm6
0000000180364CFA  F3 0F 5C E3                 subss   xmm4, xmm3
0000000180364CFE  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180364D02  F3 0F 59 A3 D0 1F 62 00     mulss   xmm4, dword ptr [rbx+621FD0h]
0000000180364D0A  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180364D0E  F3 0F 10 83 30 20 62 00     movss   xmm0, dword ptr [rbx+622030h]
0000000180364D16  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180364D1A  F3 0F 58 F1                 addss   xmm6, xmm1
0000000180364D1E  F3 0F 11 A3 70 1D 62 00     movss   dword ptr [rbx+621D70h], xmm4
0000000180364D26  F3 0F 10 93 40 20 62 00     movss   xmm2, dword ptr [rbx+622040h]
0000000180364D2E  F3 0F 59 AB 90 1D 62 00     mulss   xmm5, dword ptr [rbx+621D90h]
0000000180364D36  F3 0F 10 8B A0 20 62 00     movss   xmm1, dword ptr [rbx+6220A0h]
0000000180364D3E  F3 0F 58 8B 80 1E 62 00     addss   xmm1, dword ptr [rbx+621E80h]
0000000180364D46  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180364D4A  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180364D4E  0F 28 C2                    movaps  xmm0, xmm2
0000000180364D51  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180364D55  F3 0F 11 83 20 21 63 00     movss   dword ptr [rbx+632120h], xmm0
0000000180364D5D  F3 0F 10 9B B0 20 62 00     movss   xmm3, dword ptr [rbx+6220B0h]
0000000180364D65  F3 0F 5D D9                 minss   xmm3, xmm1
0000000180364D69  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180364D6D  F3 0F 11 9B 70 1E 62 00     movss   dword ptr [rbx+621E70h], xmm3
0000000180364D75  F3 0F 5C 9B 60 1E 62 00     subss   xmm3, dword ptr [rbx+621E60h]
0000000180364D7D  F3 0F 10 93 90 1E 62 00     movss   xmm2, dword ptr [rbx+621E90h]
0000000180364D85  41 0F 2F DD                 comiss  xmm3, xmm13
0000000180364D89  73 0A                       jnb     short loc_180364D95
0000000180364D8B  F3 0F 58 93 D0 20 62 00     addss   xmm2, dword ptr [rbx+6220D0h]
0000000180364D93  EB 08                       jmp     short loc_180364D9D
0000000180364D95  F3 0F 58 93 C0 20 62 00     addss   xmm2, dword ptr [rbx+6220C0h]
0000000180364D9D  41 0F 2F D5                 comiss  xmm2, xmm13
0000000180364DA1  F3 0F 10 9B 00 1F 62 00     movss   xmm3, dword ptr [rbx+621F00h]
0000000180364DA9  45 0F 57 FF                 xorps   xmm15, xmm15
0000000180364DAD  F3 0F 10 A3 60 1E 62 00     movss   xmm4, dword ptr [rbx+621E60h]
0000000180364DB5  0F 28 CB                    movaps  xmm1, xmm3
0000000180364DB8  F3 0F 5C CC                 subss   xmm1, xmm4
0000000180364DBC  76 05                       jbe     short loc_180364DC3
0000000180364DBE  0F 5A C2                    cvtps2pd xmm0, xmm2
0000000180364DC1  EB 03                       jmp     short loc_180364DC6
0000000180364DC3  0F 57 C0                    xorps   xmm0, xmm0
0000000180364DC6  F3 0F 59 8B 10 20 62 00     mulss   xmm1, dword ptr [rbx+622010h]
0000000180364DCE  F3 44 0F 10 25 0D 07 78 00  movss   xmm12, cs:dword_180AE54E4
0000000180364DD7  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180364DDB  F3 0F 58 CC                 addss   xmm1, xmm4
0000000180364DDF  41 0F 2F C4                 comiss  xmm0, xmm12
0000000180364DE3  73 06                       jnb     short loc_180364DEB
0000000180364DE5  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180364DE9  EB 05                       jmp     short loc_180364DF0
0000000180364DEB  F3 41 0F 5D C6              minss   xmm0, xmm14
0000000180364DF0  F3 0F 59 83 40 20 62 00     mulss   xmm0, dword ptr [rbx+622040h]
0000000180364DF8  F3 0F 11 83 80 1E 62 00     movss   dword ptr [rbx+621E80h], xmm0
0000000180364E00  0F 28 C1                    movaps  xmm0, xmm1
0000000180364E03  F3 0F 5C C4                 subss   xmm0, xmm4
0000000180364E07  41 0F 2E C5                 ucomiss xmm0, xmm13
0000000180364E0B  74 03                       jz      short loc_180364E10
0000000180364E0D  0F 28 D9                    movaps  xmm3, xmm1
0000000180364E10  F3 44 0F 10 1D 9F 5E 62 00  movss   xmm11, cs:dword_18098ACB8
0000000180364E19  0F 28 E3                    movaps  xmm4, xmm3
0000000180364E1C  F3 44 0F 10 0D 7B 5E 62 00  movss   xmm9, cs:dword_18098ACA0
0000000180364E25  F3 0F 11 9B 50 1E 62 00     movss   dword ptr [rbx+621E50h], xmm3
0000000180364E2D  F3 0F 58 9B A0 1E 62 00     addss   xmm3, dword ptr [rbx+621EA0h]
0000000180364E35  8B 83 E0 A0 62 00           mov     eax, [rbx+62A0E0h]
0000000180364E3B  0F 28 C3                    movaps  xmm0, xmm3
0000000180364E3E  F3 41 0F 59 D9              mulss   xmm3, xmm9
0000000180364E43  F3 41 0F 59 C3              mulss   xmm0, xmm11
0000000180364E48  0F 5A CB                    cvtps2pd xmm1, xmm3
0000000180364E4B  F3 0F 2C D0                 cvttss2si edx, xmm0
0000000180364E4F  2B C2                       sub     eax, edx
0000000180364E51  48 63 C8                    movsxd  rcx, eax
0000000180364E54  48 63 83 E4 A0 62 00        movsxd  rax, dword ptr [rbx+62A0E4h]
0000000180364E5B  48 FF C1                    inc     rcx
0000000180364E5E  48 FF C8                    dec     rax
0000000180364E61  48 23 C8                    and     rcx, rax
0000000180364E64  8B 84 8B E0 20 62 00        mov     eax, [rbx+rcx*4+6220E0h]
0000000180364E6B  89 83 10 21 63 00           mov     [rbx+632110h], eax
0000000180364E71  8B 83 E0 A0 62 00           mov     eax, [rbx+62A0E0h]
0000000180364E77  2B C2                       sub     eax, edx
0000000180364E79  48 63 C8                    movsxd  rcx, eax
0000000180364E7C  48 63 83 E4 A0 62 00        movsxd  rax, dword ptr [rbx+62A0E4h]
0000000180364E83  48 83 C1 02                 add     rcx, 2
0000000180364E87  48 FF C8                    dec     rax
0000000180364E8A  48 23 C8                    and     rcx, rax
0000000180364E8D  8B 84 8B E0 20 62 00        mov     eax, [rbx+rcx*4+6220E0h]
0000000180364E94  89 83 14 21 63 00           mov     [rbx+632114h], eax
0000000180364E9A  F3 0F 2C C3                 cvttss2si eax, xmm3
0000000180364E9E  66 0F 6E C0                 movd    xmm0, eax
0000000180364EA2  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
0000000180364EA6  F2 0F 5C C8                 subsd   xmm1, xmm0
0000000180364EAA  66 0F 5A E9                 cvtpd2ps xmm5, xmm1
0000000180364EAE  F3 0F 11 AB 18 21 63 00     movss   dword ptr [rbx+632118h], xmm5
0000000180364EB6  0F 28 FD                    movaps  xmm7, xmm5
0000000180364EB9  F3 0F 58 A3 B0 1E 62 00     addss   xmm4, dword ptr [rbx+621EB0h]
0000000180364EC1  F3 0F 10 9B 10 21 63 00     movss   xmm3, dword ptr [rbx+632110h]
0000000180364EC9  8B 83 F0 20 63 00           mov     eax, [rbx+6320F0h]
0000000180364ECF  F3 0F 10 B3 90 1E 62 00     movss   xmm6, dword ptr [rbx+621E90h]
0000000180364ED7  F3 0F 59 EB                 mulss   xmm5, xmm3
0000000180364EDB  0F 28 C4                    movaps  xmm0, xmm4
0000000180364EDE  F3 41 0F 59 E1              mulss   xmm4, xmm9
0000000180364EE3  F3 41 0F 59 C3              mulss   xmm0, xmm11
0000000180364EE8  0F 5A CC                    cvtps2pd xmm1, xmm4
0000000180364EEB  F3 0F 2C D0                 cvttss2si edx, xmm0
0000000180364EEF  2B C2                       sub     eax, edx
0000000180364EF1  48 63 C8                    movsxd  rcx, eax
0000000180364EF4  48 63 83 F4 20 63 00        movsxd  rax, dword ptr [rbx+6320F4h]
0000000180364EFB  48 FF C1                    inc     rcx
0000000180364EFE  48 FF C8                    dec     rax
0000000180364F01  48 23 C8                    and     rcx, rax
0000000180364F04  8B 84 8B F0 A0 62 00        mov     eax, [rbx+rcx*4+62A0F0h]
0000000180364F0B  89 83 30 21 63 00           mov     [rbx+632130h], eax
0000000180364F11  8B 83 F0 20 63 00           mov     eax, [rbx+6320F0h]
0000000180364F17  2B C2                       sub     eax, edx
0000000180364F19  48 63 C8                    movsxd  rcx, eax
0000000180364F1C  48 63 83 F4 20 63 00        movsxd  rax, dword ptr [rbx+6320F4h]
0000000180364F23  48 83 C1 02                 add     rcx, 2
0000000180364F27  48 FF C8                    dec     rax
0000000180364F2A  48 23 C8                    and     rcx, rax
0000000180364F2D  8B 84 8B F0 A0 62 00        mov     eax, [rbx+rcx*4+62A0F0h]
0000000180364F34  89 83 34 21 63 00           mov     [rbx+632134h], eax
0000000180364F3A  F3 0F 2C C4                 cvttss2si eax, xmm4
0000000180364F3E  66 0F 6E C0                 movd    xmm0, eax
0000000180364F42  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
0000000180364F46  F2 0F 5C C8                 subsd   xmm1, xmm0
0000000180364F4A  66 0F 5A E1                 cvtpd2ps xmm4, xmm1
0000000180364F4E  F3 0F 11 A3 38 21 63 00     movss   dword ptr [rbx+632138h], xmm4
0000000180364F56  44 0F 28 C4                 movaps  xmm8, xmm4
0000000180364F5A  F3 0F 59 BB 14 21 63 00     mulss   xmm7, dword ptr [rbx+632114h]
0000000180364F62  F3 0F 10 83 40 1D 62 00     movss   xmm0, dword ptr [rbx+621D40h]
0000000180364F6A  F3 0F 5C FD                 subss   xmm7, xmm5
0000000180364F6E  F3 0F 58 FB                 addss   xmm7, xmm3
0000000180364F72  F3 0F 10 9B 30 21 63 00     movss   xmm3, dword ptr [rbx+632130h]
0000000180364F7A  F3 0F 59 FE                 mulss   xmm7, xmm6
0000000180364F7E  0F 28 CF                    movaps  xmm1, xmm7
0000000180364F81  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180364F85  F3 0F 11 8B 20 1D 62 00     movss   dword ptr [rbx+621D20h], xmm1
0000000180364F8D  F3 0F 59 8B 90 20 62 00     mulss   xmm1, dword ptr [rbx+622090h]
0000000180364F95  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180364F99  F3 0F 11 8B 30 1D 62 00     movss   dword ptr [rbx+621D30h], xmm1
0000000180364FA1  F3 44 0F 59 83 34 21 63 00  mulss   xmm8, dword ptr [rbx+632134h]
0000000180364FAA  F3 0F 10 8B A0 1D 62 00     movss   xmm1, dword ptr [rbx+621DA0h]
0000000180364FB2  F3 0F 59 E3                 mulss   xmm4, xmm3
0000000180364FB6  F3 44 0F 5C C4              subss   xmm8, xmm4
0000000180364FBB  F3 44 0F 58 C3              addss   xmm8, xmm3
0000000180364FC0  F3 44 0F 59 C6              mulss   xmm8, xmm6
0000000180364FC5  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180364FC9  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180364FCD  F3 0F 11 93 80 1D 62 00     movss   dword ptr [rbx+621D80h], xmm2
0000000180364FD5  F3 0F 59 93 90 20 62 00     mulss   xmm2, dword ptr [rbx+622090h]
0000000180364FDD  F3 0F 10 83 00 20 62 00     movss   xmm0, dword ptr [rbx+622000h]
0000000180364FE5  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180364FE9  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180364FED  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180364FF2  F3 0F 11 93 90 1D 62 00     movss   dword ptr [rbx+621D90h], xmm2
0000000180364FFA  41 0F 28 D6                 movaps  xmm2, xmm14
0000000180364FFE  F3 0F 10 B3 D0 1C 62 00     movss   xmm6, dword ptr [rbx+621CD0h]
0000000180365006  F3 0F 10 9B C0 1C 62 00     movss   xmm3, dword ptr [rbx+621CC0h]
000000018036500E  F3 0F 10 AB F0 1F 62 00     movss   xmm5, dword ptr [rbx+621FF0h]
0000000180365016  F3 0F 11 BB C0 1E 62 00     movss   dword ptr [rbx+621EC0h], xmm7
000000018036501E  0F 28 C5                    movaps  xmm0, xmm5
0000000180365021  F3 44 0F 11 83 D0 1E 62 00  movss   dword ptr [rbx+621ED0h], xmm8
000000018036502A  F3 0F 10 A3 30 20 62 00     movss   xmm4, dword ptr [rbx+622030h]
0000000180365032  F3 0F 5C D4                 subss   xmm2, xmm4
0000000180365036  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018036503A  0F 28 CC                    movaps  xmm1, xmm4
000000018036503D  F3 0F 59 EE                 mulss   xmm5, xmm6
0000000180365041  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180365045  0F 28 C2                    movaps  xmm0, xmm2
0000000180365048  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018036504C  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180365050  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180365054  F3 0F 58 E2                 addss   xmm4, xmm2
0000000180365058  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036505C  F3 41 0F 58 E0              addss   xmm4, xmm8
0000000180365061  F3 0F 58 8B C0 1E 62 00     addss   xmm1, dword ptr [rbx+621EC0h]
0000000180365069  F3 0F 11 8B E0 1E 62 00     movss   dword ptr [rbx+621EE0h], xmm1
0000000180365071  F3 0F 11 A3 F0 1E 62 00     movss   dword ptr [rbx+621EF0h], xmm4
0000000180365079  8B 8B E4 A0 62 00           mov     ecx, [rbx+62A0E4h]
000000018036507F  8B 83 E0 A0 62 00           mov     eax, [rbx+62A0E0h]
0000000180365085  FF C9                       dec     ecx
0000000180365087  FF C8                       dec     eax
0000000180365089  23 C8                       and     ecx, eax
000000018036508B  89 8B E0 A0 62 00           mov     [rbx+62A0E0h], ecx
0000000180365091  8B 83 00 21 63 00           mov     eax, [rbx+632100h]
0000000180365097  48 63 C9                    movsxd  rcx, ecx
000000018036509A  89 84 8B E0 20 62 00        mov     [rbx+rcx*4+6220E0h], eax
00000001803650A1  8B 8B F4 20 63 00           mov     ecx, [rbx+6320F4h]
00000001803650A7  8B 83 F0 20 63 00           mov     eax, [rbx+6320F0h]
00000001803650AD  FF C9                       dec     ecx
00000001803650AF  FF C8                       dec     eax
00000001803650B1  23 C8                       and     ecx, eax
00000001803650B3  89 8B F0 20 63 00           mov     [rbx+6320F0h], ecx
00000001803650B9  8B 83 20 21 63 00           mov     eax, [rbx+632120h]
00000001803650BF  48 63 C9                    movsxd  rcx, ecx
00000001803650C2  89 84 8B F0 A0 62 00        mov     [rbx+rcx*4+62A0F0h], eax
00000001803650C9  F3 0F 10 B3 70 8D 01 00     movss   xmm6, dword ptr [rbx+18D70h]
00000001803650D1  0F 28 FE                    movaps  xmm7, xmm6
00000001803650D4  F3 0F 59 B3 F0 1E 62 00     mulss   xmm6, dword ptr [rbx+621EF0h]
00000001803650DC  F3 0F 59 BB E0 1E 62 00     mulss   xmm7, dword ptr [rbx+621EE0h]
00000001803650E4  E9 88 16 00 00              jmp     loc_180366771
00000001803650E9  83 BB 0C 30 A8 00 02        cmp     dword ptr [rbx+0A8300Ch], 2
00000001803650F0  74 12                       jz      short loc_180365104
00000001803650F2  89 B3 50 98 61 00           mov     [rbx+619850h], esi
00000001803650F8  89 B3 60 98 61 00           mov     [rbx+619860h], esi
00000001803650FE  89 B3 70 98 61 00           mov     [rbx+619870h], esi
0000000180365104  C7 83 0C 30 A8 00 02 00 00 00  mov     dword ptr [rbx+0A8300Ch], 2
000000018036510E  F3 0F 10 8B B0 95 61 00     movss   xmm1, dword ptr [rbx+6195B0h]
0000000180365116  F3 0F 10 83 C0 95 61 00     movss   xmm0, dword ptr [rbx+6195C0h]
000000018036511E  F3 0F 11 8B D0 95 61 00     movss   dword ptr [rbx+6195D0h], xmm1
0000000180365126  F3 0F 11 83 E0 95 61 00     movss   dword ptr [rbx+6195E0h], xmm0
000000018036512E  F3 0F 58 8B 10 96 61 00     addss   xmm1, dword ptr [rbx+619610h]
0000000180365136  0F 5A C1                    cvtps2pd xmm0, xmm1
0000000180365139  E8 82 3C 00 00              call    sub_180368DC0
000000018036513E  0F 57 C9                    xorps   xmm1, xmm1
0000000180365141  F2 0F 5A C8                 cvtsd2ss xmm1, xmm0
0000000180365145  F3 0F 5D 0D 4B 5B 62 00     minss   xmm1, cs:dword_18098AC98
000000018036514D  F3 0F 5F 0D 5B 5B 62 00     maxss   xmm1, cs:dword_18098ACB0
0000000180365155  F3 0F 11 8B F0 95 61 00     movss   dword ptr [rbx+6195F0h], xmm1
000000018036515D  F3 0F 10 B3 D0 96 61 00     movss   xmm6, dword ptr [rbx+6196D0h]
0000000180365165  F3 44 0F 10 93 E0 95 61 00  movss   xmm10, dword ptr [rbx+6195E0h]
000000018036516E  F3 0F 11 B3 E0 96 61 00     movss   dword ptr [rbx+6196E0h], xmm6
0000000180365176  F3 0F 59 8B 00 97 61 00     mulss   xmm1, dword ptr [rbx+619700h]
000000018036517E  0F 2F 0D 4B 01 78 00        comiss  xmm1, cs:dword_180AE52D0
0000000180365185  72 0A                       jb      short loc_180365191
0000000180365187  F3 0F 58 0D 81 03 78 00     addss   xmm1, cs:dword_180AE5510
000000018036518F  EB 0E                       jmp     short loc_18036519F
0000000180365191  41 0F 2F CB                 comiss  xmm1, xmm11
0000000180365195  72 08                       jb      short loc_18036519F
0000000180365197  F3 0F 58 0D 59 03 78 00     addss   xmm1, cs:dword_180AE54F8
000000018036519F  45 0F 57 ED                 xorps   xmm13, xmm13
00000001803651A3  41 0F 2E CD                 ucomiss xmm1, xmm13
00000001803651A7  75 08                       jnz     short loc_1803651B1
00000001803651A9  F3 0F 10 8B 10 97 61 00     movss   xmm1, dword ptr [rbx+619710h]
00000001803651B1  F3 44 0F 10 35 FA FE 77 00  movss   xmm14, cs:dword_180AE50B4
00000001803651BA  F3 0F 58 F1                 addss   xmm6, xmm1
00000001803651BE  41 0F 28 FA                 movaps  xmm7, xmm10
00000001803651C2  F3 41 0F 5C FE              subss   xmm7, xmm14
00000001803651C7  41 0F 2F F6                 comiss  xmm6, xmm14
00000001803651CB  76 19                       jbe     short loc_1803651E6
00000001803651CD  F3 41 0F 58 F6              addss   xmm6, xmm14
00000001803651D2  41 0F 28 CB                 movaps  xmm1, xmm11; Y
00000001803651D6  0F 28 C6                    movaps  xmm0, xmm6; X
00000001803651D9  E8 FA A2 38 00              call    fmodf
00000001803651DE  0F 28 F0                    movaps  xmm6, xmm0
00000001803651E1  F3 41 0F 5C F6              subss   xmm6, xmm14
00000001803651E6  0F 28 C6                    movaps  xmm0, xmm6
00000001803651E9  E8 D2 3D 00 00              call    sub_180368FC0
00000001803651EE  0F 28 E8                    movaps  xmm5, xmm0
00000001803651F1  F3 41 0F 59 F2              mulss   xmm6, xmm10
00000001803651F6  F3 0F 11 AB F0 96 61 00     movss   dword ptr [rbx+6196F0h], xmm5
00000001803651FE  41 0F 28 E6                 movaps  xmm4, xmm14
0000000180365202  F3 0F 58 F7                 addss   xmm6, xmm7
0000000180365206  F3 0F 11 B3 D0 96 61 00     movss   dword ptr [rbx+6196D0h], xmm6
000000018036520E  F3 0F 59 AB 30 97 61 00     mulss   xmm5, dword ptr [rbx+619730h]
0000000180365216  F3 0F 58 AB 40 97 61 00     addss   xmm5, dword ptr [rbx+619740h]
000000018036521E  F3 0F 11 AB 20 97 61 00     movss   dword ptr [rbx+619720h], xmm5
0000000180365226  F3 0F 5C E5                 subss   xmm4, xmm5
000000018036522A  8B 83 C0 97 61 00           mov     eax, [rbx+6197C0h]
0000000180365230  0F 28 D5                    movaps  xmm2, xmm5
0000000180365233  89 83 D0 97 61 00           mov     [rbx+6197D0h], eax
0000000180365239  8B 83 B0 97 61 00           mov     eax, [rbx+6197B0h]
000000018036523F  89 83 C0 97 61 00           mov     [rbx+6197C0h], eax
0000000180365245  8B 83 A0 97 61 00           mov     eax, [rbx+6197A0h]
000000018036524B  0F 28 DC                    movaps  xmm3, xmm4
000000018036524E  89 83 B0 97 61 00           mov     [rbx+6197B0h], eax
0000000180365254  8B 83 90 97 61 00           mov     eax, [rbx+619790h]
000000018036525A  89 83 A0 97 61 00           mov     [rbx+6197A0h], eax
0000000180365260  8B 83 80 97 61 00           mov     eax, [rbx+619780h]
0000000180365266  89 83 90 97 61 00           mov     [rbx+619790h], eax
000000018036526C  8B 83 10 98 61 00           mov     eax, [rbx+619810h]
0000000180365272  89 83 20 98 61 00           mov     [rbx+619820h], eax
0000000180365278  8B 83 00 98 61 00           mov     eax, [rbx+619800h]
000000018036527E  89 83 10 98 61 00           mov     [rbx+619810h], eax
0000000180365284  8B 83 F0 97 61 00           mov     eax, [rbx+6197F0h]
000000018036528A  89 83 00 98 61 00           mov     [rbx+619800h], eax
0000000180365290  8B 83 E0 97 61 00           mov     eax, [rbx+6197E0h]
0000000180365296  89 83 F0 97 61 00           mov     [rbx+6197F0h], eax
000000018036529C  8B 83 30 98 61 00           mov     eax, [rbx+619830h]
00000001803652A2  89 83 40 98 61 00           mov     [rbx+619840h], eax
00000001803652A8  8B 83 60 98 61 00           mov     eax, [rbx+619860h]
00000001803652AE  89 83 70 98 61 00           mov     [rbx+619870h], eax
00000001803652B4  8B 83 50 98 61 00           mov     eax, [rbx+619850h]
00000001803652BA  89 83 60 98 61 00           mov     [rbx+619860h], eax
00000001803652C0  F3 0F 11 AB 70 97 61 00     movss   dword ptr [rbx+619770h], xmm5
00000001803652C8  F3 0F 10 83 00 99 61 00     movss   xmm0, dword ptr [rbx+619900h]
00000001803652D0  F3 44 0F 11 8B 50 97 61 00  movss   dword ptr [rbx+619750h], xmm9
00000001803652D9  F3 44 0F 11 83 60 97 61 00  movss   dword ptr [rbx+619760h], xmm8
00000001803652E2  F3 45 0F 58 C1              addss   xmm8, xmm9
00000001803652E7  F3 0F 10 8B F0 98 61 00     movss   xmm1, dword ptr [rbx+6198F0h]
00000001803652EF  F3 41 0F 59 DF              mulss   xmm3, xmm15
00000001803652F4  F3 41 0F 59 D7              mulss   xmm2, xmm15
00000001803652F9  F3 0F 58 D8                 addss   xmm3, xmm0
00000001803652FD  F3 45 0F 59 C7              mulss   xmm8, xmm15
0000000180365302  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180365306  0F 28 C1                    movaps  xmm0, xmm1
0000000180365309  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018036530D  F3 0F 59 DB                 mulss   xmm3, xmm3
0000000180365311  F3 0F 59 D2                 mulss   xmm2, xmm2
0000000180365315  F3 0F 59 D9                 mulss   xmm3, xmm1
0000000180365319  F3 0F 59 D1                 mulss   xmm2, xmm1
000000018036531D  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180365321  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180365325  F3 0F 5C D9                 subss   xmm3, xmm1
0000000180365329  F3 0F 10 8B 70 9A 61 00     movss   xmm1, dword ptr [rbx+619A70h]
0000000180365331  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180365335  F3 0F 10 93 80 9A 61 00     movss   xmm2, dword ptr [rbx+619A80h]
000000018036533D  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180365341  F3 0F 10 9B 10 99 61 00     movss   xmm3, dword ptr [rbx+619910h]
0000000180365349  0F 28 C3                    movaps  xmm0, xmm3
000000018036534C  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180365350  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180365354  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180365358  F3 0F 59 D9                 mulss   xmm3, xmm1
000000018036535C  F3 0F 58 C2                 addss   xmm0, xmm2
0000000180365360  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180365364  F3 0F 11 83 80 98 61 00     movss   dword ptr [rbx+619880h], xmm0
000000018036536C  41 0F 28 C0                 movaps  xmm0, xmm8
0000000180365370  F3 0F 11 9B 90 98 61 00     movss   dword ptr [rbx+619890h], xmm3
0000000180365378  F3 44 0F 11 83 E0 97 61 00  movss   dword ptr [rbx+6197E0h], xmm8
0000000180365381  F3 0F 10 A3 30 99 61 00     movss   xmm4, dword ptr [rbx+619930h]
0000000180365389  F3 0F 59 A3 F0 97 61 00     mulss   xmm4, dword ptr [rbx+6197F0h]
0000000180365391  F3 0F 59 83 20 99 61 00     mulss   xmm0, dword ptr [rbx+619920h]
0000000180365399  F3 0F 10 8B 40 99 61 00     movss   xmm1, dword ptr [rbx+619940h]
00000001803653A1  F3 0F 59 8B 00 98 61 00     mulss   xmm1, dword ptr [rbx+619800h]
00000001803653A9  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803653AD  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803653B1  F3 0F 10 83 50 99 61 00     movss   xmm0, dword ptr [rbx+619950h]
00000001803653B9  41 0F 28 F6                 movaps  xmm6, xmm14
00000001803653BD  F3 0F 59 83 10 98 61 00     mulss   xmm0, dword ptr [rbx+619810h]
00000001803653C5  F3 0F 10 8B 60 99 61 00     movss   xmm1, dword ptr [rbx+619960h]
00000001803653CD  F3 0F 59 8B 20 98 61 00     mulss   xmm1, dword ptr [rbx+619820h]
00000001803653D5  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803653D9  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803653DD  41 0F 28 C8                 movaps  xmm1, xmm8
00000001803653E1  F3 0F 11 A3 00 98 61 00     movss   dword ptr [rbx+619800h], xmm4
00000001803653E9  F3 0F 10 93 90 97 61 00     movss   xmm2, dword ptr [rbx+619790h]
00000001803653F1  0F 28 C2                    movaps  xmm0, xmm2
00000001803653F4  F3 0F 59 83 90 99 61 00     mulss   xmm0, dword ptr [rbx+619990h]
00000001803653FC  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180365400  F3 0F 5C 8B A0 97 61 00     subss   xmm1, dword ptr [rbx+6197A0h]
0000000180365408  F3 0F 59 8B 80 99 61 00     mulss   xmm1, dword ptr [rbx+619980h]
0000000180365410  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180365414  F3 0F 11 8B 80 97 61 00     movss   dword ptr [rbx+619780h], xmm1
000000018036541C  F3 0F 10 9B 90 97 61 00     movss   xmm3, dword ptr [rbx+619790h]
0000000180365424  F3 0F 59 9B 80 99 61 00     mulss   xmm3, dword ptr [rbx+619980h]
000000018036542C  F3 0F 58 9B A0 97 61 00     addss   xmm3, dword ptr [rbx+6197A0h]
0000000180365434  F3 0F 11 9B 90 97 61 00     movss   dword ptr [rbx+619790h], xmm3
000000018036543C  F3 0F 10 83 70 99 61 00     movss   xmm0, dword ptr [rbx+619970h]
0000000180365444  F3 0F 10 8B A0 99 61 00     movss   xmm1, dword ptr [rbx+6199A0h]
000000018036544C  F3 0F 5C F0                 subss   xmm6, xmm0
0000000180365450  F3 0F 10 AB 00 9A 61 00     movss   xmm5, dword ptr [rbx+619A00h]
0000000180365458  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018036545C  F3 0F 59 F3                 mulss   xmm6, xmm3
0000000180365460  F3 0F 10 9B B0 97 61 00     movss   xmm3, dword ptr [rbx+6197B0h]
0000000180365468  F3 0F 58 F0                 addss   xmm6, xmm0
000000018036546C  41 0F 28 C6                 movaps  xmm0, xmm14
0000000180365470  F3 0F 5C C1                 subss   xmm0, xmm1
0000000180365474  F3 0F 59 F1                 mulss   xmm6, xmm1
0000000180365478  F3 41 0F 59 C0              mulss   xmm0, xmm8
000000018036547D  F3 0F 58 F0                 addss   xmm6, xmm0
0000000180365481  F3 0F 10 83 C0 99 61 00     movss   xmm0, dword ptr [rbx+6199C0h]
0000000180365489  0F 28 C8                    movaps  xmm1, xmm0
000000018036548C  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180365490  0F 28 E6                    movaps  xmm4, xmm6
0000000180365493  F3 0F 5C E3                 subss   xmm4, xmm3
0000000180365497  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018036549B  F3 0F 59 A3 B0 99 61 00     mulss   xmm4, dword ptr [rbx+6199B0h]
00000001803654A3  F3 0F 5C C8                 subss   xmm1, xmm0
00000001803654A7  F3 0F 10 83 10 9A 61 00     movss   xmm0, dword ptr [rbx+619A10h]
00000001803654AF  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803654B3  F3 0F 58 F1                 addss   xmm6, xmm1
00000001803654B7  F3 0F 11 A3 A0 97 61 00     movss   dword ptr [rbx+6197A0h], xmm4
00000001803654BF  F3 0F 10 93 20 9A 61 00     movss   xmm2, dword ptr [rbx+619A20h]
00000001803654C7  F3 0F 59 AB C0 97 61 00     mulss   xmm5, dword ptr [rbx+6197C0h]
00000001803654CF  F3 0F 10 8B A0 9A 61 00     movss   xmm1, dword ptr [rbx+619AA0h]
00000001803654D7  F3 0F 58 8B 60 98 61 00     addss   xmm1, dword ptr [rbx+619860h]
00000001803654DF  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803654E3  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803654E7  0F 28 C2                    movaps  xmm0, xmm2
00000001803654EA  F3 0F 59 C5                 mulss   xmm0, xmm5
00000001803654EE  F3 0F 11 83 F0 1A 62 00     movss   dword ptr [rbx+621AF0h], xmm0
00000001803654F6  F3 0F 10 9B B0 9A 61 00     movss   xmm3, dword ptr [rbx+619AB0h]
00000001803654FE  F3 0F 5D D9                 minss   xmm3, xmm1
0000000180365502  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180365506  F3 0F 11 9B 50 98 61 00     movss   dword ptr [rbx+619850h], xmm3
000000018036550E  F3 0F 5C 9B 40 98 61 00     subss   xmm3, dword ptr [rbx+619840h]
0000000180365516  41 0F 2F DD                 comiss  xmm3, xmm13
000000018036551A  73 0A                       jnb     short loc_180365526
000000018036551C  F3 0F 10 83 D0 9A 61 00     movss   xmm0, dword ptr [rbx+619AD0h]
0000000180365524  EB 08                       jmp     short loc_18036552E
0000000180365526  F3 0F 10 83 C0 9A 61 00     movss   xmm0, dword ptr [rbx+619AC0h]
000000018036552E  F3 0F 58 83 70 98 61 00     addss   xmm0, dword ptr [rbx+619870h]
0000000180365536  F3 0F 10 9B E0 98 61 00     movss   xmm3, dword ptr [rbx+6198E0h]
000000018036553E  45 0F 57 FF                 xorps   xmm15, xmm15
0000000180365542  F3 0F 10 93 40 98 61 00     movss   xmm2, dword ptr [rbx+619840h]
000000018036554A  0F 28 CB                    movaps  xmm1, xmm3
000000018036554D  F3 0F 5C CA                 subss   xmm1, xmm2
0000000180365551  41 0F 2F C5                 comiss  xmm0, xmm13
0000000180365555  76 05                       jbe     short loc_18036555C
0000000180365557  0F 5A E0                    cvtps2pd xmm4, xmm0
000000018036555A  EB 03                       jmp     short loc_18036555F
000000018036555C  0F 57 E4                    xorps   xmm4, xmm4
000000018036555F  F3 0F 59 8B F0 99 61 00     mulss   xmm1, dword ptr [rbx+6199F0h]
0000000180365567  F3 44 0F 10 25 74 FF 77 00  movss   xmm12, cs:dword_180AE54E4
0000000180365570  66 0F 5A C4                 cvtpd2ps xmm0, xmm4
0000000180365574  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180365578  41 0F 2F C4                 comiss  xmm0, xmm12
000000018036557C  73 06                       jnb     short loc_180365584
000000018036557E  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180365582  EB 05                       jmp     short loc_180365589
0000000180365584  F3 41 0F 5D C6              minss   xmm0, xmm14
0000000180365589  F3 0F 59 83 20 9A 61 00     mulss   xmm0, dword ptr [rbx+619A20h]
0000000180365591  F3 0F 11 83 60 98 61 00     movss   dword ptr [rbx+619860h], xmm0
0000000180365599  0F 28 C1                    movaps  xmm0, xmm1
000000018036559C  F3 0F 5C C2                 subss   xmm0, xmm2
00000001803655A0  41 0F 2E C5                 ucomiss xmm0, xmm13
00000001803655A4  74 03                       jz      short loc_1803655A9
00000001803655A6  0F 28 D9                    movaps  xmm3, xmm1
00000001803655A9  F3 44 0F 10 1D 06 57 62 00  movss   xmm11, cs:dword_18098ACB8
00000001803655B2  0F 28 EB                    movaps  xmm5, xmm3
00000001803655B5  F3 0F 11 9B 30 98 61 00     movss   dword ptr [rbx+619830h], xmm3
00000001803655BD  F3 0F 58 9B 80 98 61 00     addss   xmm3, dword ptr [rbx+619880h]
00000001803655C5  8B 83 E0 1A 62 00           mov     eax, [rbx+621AE0h]
00000001803655CB  0F 28 C3                    movaps  xmm0, xmm3
00000001803655CE  F3 0F 59 1D CA 56 62 00     mulss   xmm3, cs:dword_18098ACA0
00000001803655D6  F3 41 0F 59 C3              mulss   xmm0, xmm11
00000001803655DB  0F 5A CB                    cvtps2pd xmm1, xmm3
00000001803655DE  F3 0F 2C D0                 cvttss2si edx, xmm0
00000001803655E2  2B C2                       sub     eax, edx
00000001803655E4  48 63 C8                    movsxd  rcx, eax
00000001803655E7  48 63 83 E4 1A 62 00        movsxd  rax, dword ptr [rbx+621AE4h]
00000001803655EE  48 FF C1                    inc     rcx
00000001803655F1  48 FF C8                    dec     rax
00000001803655F4  48 23 C8                    and     rcx, rax
00000001803655F7  8B 84 8B E0 9A 61 00        mov     eax, [rbx+rcx*4+619AE0h]
00000001803655FE  89 83 00 1B 62 00           mov     [rbx+621B00h], eax
0000000180365604  8B 83 E0 1A 62 00           mov     eax, [rbx+621AE0h]
000000018036560A  2B C2                       sub     eax, edx
000000018036560C  48 63 C8                    movsxd  rcx, eax
000000018036560F  48 63 83 E4 1A 62 00        movsxd  rax, dword ptr [rbx+621AE4h]
0000000180365616  48 83 C1 02                 add     rcx, 2
000000018036561A  48 FF C8                    dec     rax
000000018036561D  48 23 C8                    and     rcx, rax
0000000180365620  8B 84 8B E0 9A 61 00        mov     eax, [rbx+rcx*4+619AE0h]
0000000180365627  89 83 04 1B 62 00           mov     [rbx+621B04h], eax
000000018036562D  F3 0F 2C C3                 cvttss2si eax, xmm3
0000000180365631  66 0F 6E C0                 movd    xmm0, eax
0000000180365635  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
0000000180365639  F2 0F 5C C8                 subsd   xmm1, xmm0
000000018036563D  66 0F 5A E1                 cvtpd2ps xmm4, xmm1
0000000180365641  F3 0F 11 A3 08 1B 62 00     movss   dword ptr [rbx+621B08h], xmm4
0000000180365649  44 0F 28 D4                 movaps  xmm10, xmm4
000000018036564D  F3 0F 58 AB 90 98 61 00     addss   xmm5, dword ptr [rbx+619890h]
0000000180365655  F3 0F 10 9B 00 1B 62 00     movss   xmm3, dword ptr [rbx+621B00h]
000000018036565D  8B 83 E0 1A 62 00           mov     eax, [rbx+621AE0h]
0000000180365663  F3 0F 10 B3 70 98 61 00     movss   xmm6, dword ptr [rbx+619870h]
000000018036566B  F3 0F 59 E3                 mulss   xmm4, xmm3
000000018036566F  0F 28 C5                    movaps  xmm0, xmm5
0000000180365672  F3 0F 59 2D 26 56 62 00     mulss   xmm5, cs:dword_18098ACA0
000000018036567A  F3 41 0F 59 C3              mulss   xmm0, xmm11
000000018036567F  0F 5A CD                    cvtps2pd xmm1, xmm5
0000000180365682  F3 0F 2C D0                 cvttss2si edx, xmm0
0000000180365686  2B C2                       sub     eax, edx
0000000180365688  48 63 C8                    movsxd  rcx, eax
000000018036568B  48 63 83 E4 1A 62 00        movsxd  rax, dword ptr [rbx+621AE4h]
0000000180365692  48 FF C1                    inc     rcx
0000000180365695  48 FF C8                    dec     rax
0000000180365698  48 23 C8                    and     rcx, rax
000000018036569B  8B 84 8B E0 9A 61 00        mov     eax, [rbx+rcx*4+619AE0h]
00000001803656A2  89 83 10 1B 62 00           mov     [rbx+621B10h], eax
00000001803656A8  8B 83 E0 1A 62 00           mov     eax, [rbx+621AE0h]
00000001803656AE  2B C2                       sub     eax, edx
00000001803656B0  48 63 C8                    movsxd  rcx, eax
00000001803656B3  48 63 83 E4 1A 62 00        movsxd  rax, dword ptr [rbx+621AE4h]
00000001803656BA  48 83 C1 02                 add     rcx, 2
00000001803656BE  48 FF C8                    dec     rax
00000001803656C1  48 23 C8                    and     rcx, rax
00000001803656C4  8B 84 8B E0 9A 61 00        mov     eax, [rbx+rcx*4+619AE0h]
00000001803656CB  89 83 14 1B 62 00           mov     [rbx+621B14h], eax
00000001803656D1  F3 0F 2C C5                 cvttss2si eax, xmm5
00000001803656D5  66 0F 6E C0                 movd    xmm0, eax
00000001803656D9  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00000001803656DD  F2 0F 5C C8                 subsd   xmm1, xmm0
00000001803656E1  66 0F 5A E9                 cvtpd2ps xmm5, xmm1
00000001803656E5  F3 0F 11 AB 18 1B 62 00     movss   dword ptr [rbx+621B18h], xmm5
00000001803656ED  F3 44 0F 59 93 04 1B 62 00  mulss   xmm10, dword ptr [rbx+621B04h]
00000001803656F6  F3 0F 10 83 D0 97 61 00     movss   xmm0, dword ptr [rbx+6197D0h]
00000001803656FE  F3 44 0F 5C D4              subss   xmm10, xmm4
0000000180365703  0F 28 E5                    movaps  xmm4, xmm5
0000000180365706  F3 44 0F 58 D3              addss   xmm10, xmm3
000000018036570B  F3 0F 10 9B 10 1B 62 00     movss   xmm3, dword ptr [rbx+621B10h]
0000000180365713  F3 44 0F 59 D6              mulss   xmm10, xmm6
0000000180365718  41 0F 28 CA                 movaps  xmm1, xmm10
000000018036571C  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180365720  F3 0F 11 8B B0 97 61 00     movss   dword ptr [rbx+6197B0h], xmm1
0000000180365728  F3 0F 59 8B 90 9A 61 00     mulss   xmm1, dword ptr [rbx+619A90h]
0000000180365730  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180365734  F3 0F 11 8B C0 97 61 00     movss   dword ptr [rbx+6197C0h], xmm1
000000018036573C  F3 0F 59 A3 14 1B 62 00     mulss   xmm4, dword ptr [rbx+621B14h]
0000000180365744  F3 0F 10 BB 40 9A 61 00     movss   xmm7, dword ptr [rbx+619A40h]
000000018036574C  41 0F 28 CE                 movaps  xmm1, xmm14
0000000180365750  F3 0F 10 93 30 9A 61 00     movss   xmm2, dword ptr [rbx+619A30h]
0000000180365758  0F 28 C7                    movaps  xmm0, xmm7
000000018036575B  F3 44 0F 10 83 60 97 61 00  movss   xmm8, dword ptr [rbx+619760h]
0000000180365764  F3 0F 5C CA                 subss   xmm1, xmm2
0000000180365768  F3 44 0F 10 8B 60 9A 61 00  movss   xmm9, dword ptr [rbx+619A60h]
0000000180365771  F3 0F 59 EB                 mulss   xmm5, xmm3
0000000180365775  F3 41 0F 59 CA              mulss   xmm1, xmm10
000000018036577A  F3 0F 5C E5                 subss   xmm4, xmm5
000000018036577E  41 0F 28 EE                 movaps  xmm5, xmm14
0000000180365782  F3 0F 5C EF                 subss   xmm5, xmm7
0000000180365786  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036578A  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036578E  0F 28 DF                    movaps  xmm3, xmm7
0000000180365791  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180365796  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018036579B  F3 0F 59 E6                 mulss   xmm4, xmm6
000000018036579F  F3 0F 10 B3 50 97 61 00     movss   xmm6, dword ptr [rbx+619750h]
00000001803657A7  F3 0F 58 DE                 addss   xmm3, xmm6
00000001803657AB  F3 0F 59 D4                 mulss   xmm2, xmm4
00000001803657AF  F3 0F 5C D0                 subss   xmm2, xmm0
00000001803657B3  F3 0F 10 83 E0 99 61 00     movss   xmm0, dword ptr [rbx+6199E0h]
00000001803657BB  F3 44 0F 59 D0              mulss   xmm10, xmm0
00000001803657C0  F3 0F 58 D1                 addss   xmm2, xmm1
00000001803657C4  F3 0F 59 D0                 mulss   xmm2, xmm0
00000001803657C8  41 0F 28 C1                 movaps  xmm0, xmm9
00000001803657CC  F3 45 0F 59 CA              mulss   xmm9, xmm10
00000001803657D1  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803657D5  41 0F 28 D6                 movaps  xmm2, xmm14
00000001803657D9  F3 0F 11 83 A0 98 61 00     movss   dword ptr [rbx+6198A0h], xmm0
00000001803657E1  F3 44 0F 11 8B B0 98 61 00  movss   dword ptr [rbx+6198B0h], xmm9
00000001803657EA  F3 0F 10 83 D0 99 61 00     movss   xmm0, dword ptr [rbx+6199D0h]
00000001803657F2  F3 0F 10 A3 10 9A 61 00     movss   xmm4, dword ptr [rbx+619A10h]
00000001803657FA  F3 0F 5C D4                 subss   xmm2, xmm4
00000001803657FE  F3 0F 59 D8                 mulss   xmm3, xmm0
0000000180365802  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180365806  0F 28 CC                    movaps  xmm1, xmm4
0000000180365809  F3 0F 10 83 50 9A 61 00     movss   xmm0, dword ptr [rbx+619A50h]
0000000180365811  F3 0F 59 D8                 mulss   xmm3, xmm0
0000000180365815  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180365819  0F 28 C2                    movaps  xmm0, xmm2
000000018036581C  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180365820  F3 0F 59 CB                 mulss   xmm1, xmm3
0000000180365824  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180365828  F3 41 0F 59 D0              mulss   xmm2, xmm8
000000018036582D  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180365831  F3 0F 58 E2                 addss   xmm4, xmm2
0000000180365835  F3 0F 58 8B A0 98 61 00     addss   xmm1, dword ptr [rbx+6198A0h]
000000018036583D  F3 41 0F 58 E1              addss   xmm4, xmm9
0000000180365842  F3 0F 11 8B C0 98 61 00     movss   dword ptr [rbx+6198C0h], xmm1
000000018036584A  F3 0F 11 A3 D0 98 61 00     movss   dword ptr [rbx+6198D0h], xmm4
0000000180365852  8B 8B E4 1A 62 00           mov     ecx, [rbx+621AE4h]
0000000180365858  8B 83 E0 1A 62 00           mov     eax, [rbx+621AE0h]
000000018036585E  FF C9                       dec     ecx
0000000180365860  FF C8                       dec     eax
0000000180365862  23 C8                       and     ecx, eax
0000000180365864  89 8B E0 1A 62 00           mov     [rbx+621AE0h], ecx
000000018036586A  8B 83 F0 1A 62 00           mov     eax, [rbx+621AF0h]
0000000180365870  48 63 C9                    movsxd  rcx, ecx
0000000180365873  89 84 8B E0 9A 61 00        mov     [rbx+rcx*4+619AE0h], eax
000000018036587A  F3 0F 10 B3 70 8D 01 00     movss   xmm6, dword ptr [rbx+18D70h]
0000000180365882  0F 28 FE                    movaps  xmm7, xmm6
0000000180365885  F3 0F 59 B3 D0 98 61 00     mulss   xmm6, dword ptr [rbx+6198D0h]
000000018036588D  F3 0F 59 BB C0 98 61 00     mulss   xmm7, dword ptr [rbx+6198C0h]
0000000180365895  E9 CE 0E 00 00              jmp     loc_180366768
000000018036589A  45 0F 57 ED                 xorps   xmm13, xmm13
000000018036589E  39 B3 0C 30 A8 00           cmp     [rbx+0A8300Ch], esi
00000001803658A4  74 09                       jz      short loc_1803658AF
00000001803658A6  0F 57 C0                    xorps   xmm0, xmm0
00000001803658A9  45 0F 57 DB                 xorps   xmm11, xmm11
00000001803658AD  EB 11                       jmp     short loc_1803658C0
00000001803658AF  F3 0F 10 83 90 8F 01 00     movss   xmm0, dword ptr [rbx+18F90h]
00000001803658B7  F3 44 0F 10 9B 80 8F 01 00  movss   xmm11, dword ptr [rbx+18F80h]
00000001803658C0  F3 0F 10 AB A0 8D 01 00     movss   xmm5, dword ptr [rbx+18DA0h]
00000001803658C8  F3 0F 10 93 C0 8E 01 00     movss   xmm2, dword ptr [rbx+18EC0h]
00000001803658D0  F3 0F 10 9B D0 8E 01 00     movss   xmm3, dword ptr [rbx+18ED0h]
00000001803658D8  F3 0F 10 B3 B0 8D 01 00     movss   xmm6, dword ptr [rbx+18DB0h]
00000001803658E0  F3 0F 10 A3 A0 8E 01 00     movss   xmm4, dword ptr [rbx+18EA0h]
00000001803658E8  F3 0F 10 8B B0 8E 01 00     movss   xmm1, dword ptr [rbx+18EB0h]
00000001803658F0  F3 0F 59 8B 00 90 01 00     mulss   xmm1, dword ptr [rbx+19000h]
00000001803658F8  8B 83 00 8E 01 00           mov     eax, [rbx+18E00h]
00000001803658FE  F3 0F 10 BB F0 8D 01 00     movss   xmm7, dword ptr [rbx+18DF0h]
0000000180365906  F3 44 0F 10 35 A5 F7 77 00  movss   xmm14, cs:dword_180AE50B4
000000018036590F  89 83 10 8E 01 00           mov     [rbx+18E10h], eax
0000000180365915  8B 83 E0 8D 01 00           mov     eax, [rbx+18DE0h]
000000018036591B  89 83 F0 8D 01 00           mov     [rbx+18DF0h], eax
0000000180365921  8B 83 D0 8D 01 00           mov     eax, [rbx+18DD0h]
0000000180365927  89 83 E0 8D 01 00           mov     [rbx+18DE0h], eax
000000018036592D  8B 83 C0 8D 01 00           mov     eax, [rbx+18DC0h]
0000000180365933  89 83 D0 8D 01 00           mov     [rbx+18DD0h], eax
0000000180365939  8B 83 80 8E 01 00           mov     eax, [rbx+18E80h]
000000018036593F  89 83 90 8E 01 00           mov     [rbx+18E90h], eax
0000000180365945  8B 83 70 8E 01 00           mov     eax, [rbx+18E70h]
000000018036594B  89 83 80 8E 01 00           mov     [rbx+18E80h], eax
0000000180365951  8B 83 60 8E 01 00           mov     eax, [rbx+18E60h]
0000000180365957  89 83 70 8E 01 00           mov     [rbx+18E70h], eax
000000018036595D  8B 83 50 8E 01 00           mov     eax, [rbx+18E50h]
0000000180365963  89 83 60 8E 01 00           mov     [rbx+18E60h], eax
0000000180365969  8B 83 40 8E 01 00           mov     eax, [rbx+18E40h]
000000018036596F  89 83 50 8E 01 00           mov     [rbx+18E50h], eax
0000000180365975  8B 83 30 8E 01 00           mov     eax, [rbx+18E30h]
000000018036597B  89 83 40 8E 01 00           mov     [rbx+18E40h], eax
0000000180365981  8B 83 20 8E 01 00           mov     eax, [rbx+18E20h]
0000000180365987  89 83 30 8E 01 00           mov     [rbx+18E30h], eax
000000018036598D  8B 83 20 8F 01 00           mov     eax, [rbx+18F20h]
0000000180365993  89 83 30 8F 01 00           mov     [rbx+18F30h], eax
0000000180365999  8B 83 10 8F 01 00           mov     eax, [rbx+18F10h]
000000018036599F  F3 0F 11 83 A0 8F 01 00     movss   dword ptr [rbx+18FA0h], xmm0
00000001803659A7  41 0F 28 C1                 movaps  xmm0, xmm9
00000001803659AB  F3 0F 59 83 E0 8F 01 00     mulss   xmm0, dword ptr [rbx+18FE0h]
00000001803659B3  89 83 20 8F 01 00           mov     [rbx+18F20h], eax
00000001803659B9  8B 83 00 8F 01 00           mov     eax, [rbx+18F00h]
00000001803659BF  F3 0F 11 A3 B0 8E 01 00     movss   dword ptr [rbx+18EB0h], xmm4
00000001803659C7  F3 0F 59 A3 F0 8F 01 00     mulss   xmm4, dword ptr [rbx+18FF0h]
00000001803659CF  89 83 10 8F 01 00           mov     [rbx+18F10h], eax
00000001803659D5  8B 83 F0 8E 01 00           mov     eax, [rbx+18EF0h]
00000001803659DB  F3 0F 11 9B E0 8E 01 00     movss   dword ptr [rbx+18EE0h], xmm3
00000001803659E3  F3 0F 59 9B 20 90 01 00     mulss   xmm3, dword ptr [rbx+19020h]
00000001803659EB  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803659EF  89 83 00 8F 01 00           mov     [rbx+18F00h], eax
00000001803659F5  8B 83 60 8F 01 00           mov     eax, [rbx+18F60h]
00000001803659FB  0F 28 C5                    movaps  xmm0, xmm5
00000001803659FE  F3 0F 59 83 50 90 01 00     mulss   xmm0, dword ptr [rbx+19050h]
0000000180365A06  89 83 70 8F 01 00           mov     [rbx+18F70h], eax
0000000180365A0C  8B 83 50 8F 01 00           mov     eax, [rbx+18F50h]
0000000180365A12  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180365A16  F3 0F 11 93 D0 8E 01 00     movss   dword ptr [rbx+18ED0h], xmm2
0000000180365A1E  41 0F 28 C9                 movaps  xmm1, xmm9
0000000180365A22  F3 0F 59 93 10 90 01 00     mulss   xmm2, dword ptr [rbx+19010h]
0000000180365A2A  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180365A2E  89 83 60 8F 01 00           mov     [rbx+18F60h], eax
0000000180365A34  8B 83 40 8F 01 00           mov     eax, [rbx+18F40h]
0000000180365A3A  F3 0F 10 83 30 90 01 00     movss   xmm0, dword ptr [rbx+19030h]
0000000180365A42  F3 0F 58 E2                 addss   xmm4, xmm2
0000000180365A46  F3 0F 11 BB 00 8E 01 00     movss   dword ptr [rbx+18E00h], xmm7
0000000180365A4E  F3 0F 5C CE                 subss   xmm1, xmm6
0000000180365A52  F3 0F 11 B3 C0 8D 01 00     movss   dword ptr [rbx+18DC0h], xmm6
0000000180365A5A  F3 44 0F 11 9B 90 8F 01 00  movss   dword ptr [rbx+18F90h], xmm11
0000000180365A63  41 0F 28 D6                 movaps  xmm2, xmm14
0000000180365A67  F3 44 0F 11 8B 80 8D 01 00  movss   dword ptr [rbx+18D80h], xmm9
0000000180365A70  F3 44 0F 11 83 90 8D 01 00  movss   dword ptr [rbx+18D90h], xmm8
0000000180365A79  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180365A7D  F3 44 0F 11 8B A0 8E 01 00  movss   dword ptr [rbx+18EA0h], xmm9
0000000180365A86  F3 0F 10 9B 40 90 01 00     movss   xmm3, dword ptr [rbx+19040h]
0000000180365A8E  F3 0F 59 CB                 mulss   xmm1, xmm3
0000000180365A92  89 B3 0C 30 A8 00           mov     [rbx+0A8300Ch], esi
0000000180365A98  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180365A9C  89 83 50 8F 01 00           mov     [rbx+18F50h], eax
0000000180365AA2  F3 0F 58 CD                 addss   xmm1, xmm5
0000000180365AA6  F3 0F 11 A3 C0 8E 01 00     movss   dword ptr [rbx+18EC0h], xmm4
0000000180365AAE  F3 0F 58 DE                 addss   xmm3, xmm6
0000000180365AB2  F3 0F 11 8B A0 8D 01 00     movss   dword ptr [rbx+18DA0h], xmm1
0000000180365ABA  F3 0F 10 8B 60 90 01 00     movss   xmm1, dword ptr [rbx+19060h]
0000000180365AC2  F3 0F 11 9B B0 8D 01 00     movss   dword ptr [rbx+18DB0h], xmm3
0000000180365ACA  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180365ACE  F3 0F 59 BB A0 90 01 00     mulss   xmm7, dword ptr [rbx+190A0h]
0000000180365AD6  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180365ADA  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180365ADE  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180365AE2  41 0F 28 C6                 movaps  xmm0, xmm14
0000000180365AE6  F3 0F 5C C1                 subss   xmm0, xmm1
0000000180365AEA  F3 0F 59 D1                 mulss   xmm2, xmm1
0000000180365AEE  F3 41 0F 59 C1              mulss   xmm0, xmm9
0000000180365AF3  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180365AF7  F3 0F 59 93 B0 90 01 00     mulss   xmm2, dword ptr [rbx+190B0h]
0000000180365AFF  F3 0F 58 D7                 addss   xmm2, xmm7
0000000180365B03  F3 0F 59 93 C0 90 01 00     mulss   xmm2, dword ptr [rbx+190C0h]
0000000180365B0B  F3 0F 11 93 B0 91 41 00     movss   dword ptr [rbx+4191B0h], xmm2
0000000180365B13  F3 0F 10 93 30 8E 01 00     movss   xmm2, dword ptr [rbx+18E30h]
0000000180365B1B  F3 0F 10 B3 90 8D 01 00     movss   xmm6, dword ptr [rbx+18D90h]
0000000180365B23  F3 0F 10 8B 10 8F 01 00     movss   xmm1, dword ptr [rbx+18F10h]
0000000180365B2B  0F 28 C6                    movaps  xmm0, xmm6
0000000180365B2E  F3 0F 59 83 E0 8F 01 00     mulss   xmm0, dword ptr [rbx+18FE0h]
0000000180365B36  F3 0F 59 8B 00 90 01 00     mulss   xmm1, dword ptr [rbx+19000h]
0000000180365B3E  F3 0F 10 AB 00 8F 01 00     movss   xmm5, dword ptr [rbx+18F00h]
0000000180365B46  F3 0F 59 AB F0 8F 01 00     mulss   xmm5, dword ptr [rbx+18FF0h]
0000000180365B4E  F3 0F 10 9B 40 8E 01 00     movss   xmm3, dword ptr [rbx+18E40h]
0000000180365B56  F3 0F 10 A3 40 90 01 00     movss   xmm4, dword ptr [rbx+19040h]
0000000180365B5E  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180365B62  F3 0F 11 B3 F0 8E 01 00     movss   dword ptr [rbx+18EF0h], xmm6
0000000180365B6A  F3 0F 10 83 10 90 01 00     movss   xmm0, dword ptr [rbx+19010h]
0000000180365B72  F3 0F 59 83 20 8F 01 00     mulss   xmm0, dword ptr [rbx+18F20h]
0000000180365B7A  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180365B7E  F3 0F 10 8B 20 90 01 00     movss   xmm1, dword ptr [rbx+19020h]
0000000180365B86  F3 0F 59 8B 30 8F 01 00     mulss   xmm1, dword ptr [rbx+18F30h]
0000000180365B8E  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180365B92  0F 28 C2                    movaps  xmm0, xmm2
0000000180365B95  F3 0F 59 83 50 90 01 00     mulss   xmm0, dword ptr [rbx+19050h]
0000000180365B9D  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180365BA1  0F 28 CE                    movaps  xmm1, xmm6
0000000180365BA4  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180365BA8  F3 0F 10 83 30 90 01 00     movss   xmm0, dword ptr [rbx+19030h]
0000000180365BB0  F3 0F 11 AB 10 8F 01 00     movss   dword ptr [rbx+18F10h], xmm5
0000000180365BB8  F3 0F 5C CB                 subss   xmm1, xmm3
0000000180365BBC  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180365BC0  F3 0F 59 E2                 mulss   xmm4, xmm2
0000000180365BC4  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180365BC8  41 0F 28 D6                 movaps  xmm2, xmm14
0000000180365BCC  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180365BD0  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180365BD4  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180365BD8  F3 0F 11 8B 20 8E 01 00     movss   dword ptr [rbx+18E20h], xmm1
0000000180365BE0  F3 0F 10 8B 60 90 01 00     movss   xmm1, dword ptr [rbx+19060h]
0000000180365BE8  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180365BEC  F3 0F 11 A3 30 8E 01 00     movss   dword ptr [rbx+18E30h], xmm4
0000000180365BF4  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180365BF8  41 0F 28 C6                 movaps  xmm0, xmm14
0000000180365BFC  F3 0F 5C C1                 subss   xmm0, xmm1
0000000180365C00  F3 0F 59 D1                 mulss   xmm2, xmm1
0000000180365C04  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180365C08  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180365C0C  F3 0F 10 83 A0 90 01 00     movss   xmm0, dword ptr [rbx+190A0h]
0000000180365C14  F3 0F 59 83 80 8E 01 00     mulss   xmm0, dword ptr [rbx+18E80h]
0000000180365C1C  F3 0F 59 93 B0 90 01 00     mulss   xmm2, dword ptr [rbx+190B0h]
0000000180365C24  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180365C28  F3 0F 59 93 C0 90 01 00     mulss   xmm2, dword ptr [rbx+190C0h]
0000000180365C30  F3 0F 11 93 D0 91 41 00     movss   dword ptr [rbx+4191D0h], xmm2
0000000180365C38  F3 0F 10 83 40 91 01 00     movss   xmm0, dword ptr [rbx+19140h]
0000000180365C40  F3 0F 58 83 90 8F 01 00     addss   xmm0, dword ptr [rbx+18F90h]
0000000180365C48  F3 0F 10 93 70 8F 01 00     movss   xmm2, dword ptr [rbx+18F70h]
0000000180365C50  F3 0F 10 AB A0 8F 01 00     movss   xmm5, dword ptr [rbx+18FA0h]
0000000180365C58  F3 41 0F 59 C2              mulss   xmm0, xmm10
0000000180365C5D  F3 0F 11 83 80 8F 01 00     movss   dword ptr [rbx+18F80h], xmm0
0000000180365C65  F3 0F 5C C2                 subss   xmm0, xmm2
0000000180365C69  41 0F 2F C5                 comiss  xmm0, xmm13
0000000180365C6D  73 0A                       jnb     short loc_180365C79
0000000180365C6F  F3 0F 10 83 70 91 01 00     movss   xmm0, dword ptr [rbx+19170h]
0000000180365C77  EB 08                       jmp     short loc_180365C81
0000000180365C79  F3 0F 10 83 60 91 01 00     movss   xmm0, dword ptr [rbx+19160h]
0000000180365C81  F3 0F 10 A3 D0 8F 01 00     movss   xmm4, dword ptr [rbx+18FD0h]
0000000180365C89  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180365C8D  F3 0F 10 8B 60 8F 01 00     movss   xmm1, dword ptr [rbx+18F60h]
0000000180365C95  0F 28 C4                    movaps  xmm0, xmm4
0000000180365C98  F3 0F 5C 83 50 8F 01 00     subss   xmm0, dword ptr [rbx+18F50h]
0000000180365CA0  0F 28 DC                    movaps  xmm3, xmm4
0000000180365CA3  F3 0F 11 A3 40 8F 01 00     movss   dword ptr [rbx+18F40h], xmm4
0000000180365CAB  F3 0F 5C DA                 subss   xmm3, xmm2
0000000180365CAF  41 0F 2E C5                 ucomiss xmm0, xmm13
0000000180365CB3  74 03                       jz      short loc_180365CB8
0000000180365CB5  0F 28 CB                    movaps  xmm1, xmm3
0000000180365CB8  41 0F 2F DD                 comiss  xmm3, xmm13
0000000180365CBC  0F 28 C2                    movaps  xmm0, xmm2
0000000180365CBF  F3 0F 11 8B 50 8F 01 00     movss   dword ptr [rbx+18F50h], xmm1
0000000180365CC7  41 0F 54 CC                 andps   xmm1, xmm12
0000000180365CCB  F3 0F 59 8B 80 91 01 00     mulss   xmm1, dword ptr [rbx+19180h]
0000000180365CD3  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180365CD7  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180365CDB  F3 0F 5F D4                 maxss   xmm2, xmm4
0000000180365CDF  76 07                       jbe     short loc_180365CE8
0000000180365CE1  0F 28 D0                    movaps  xmm2, xmm0
0000000180365CE4  F3 0F 5D D4                 minss   xmm2, xmm4
0000000180365CE8  41 0F 2F ED                 comiss  xmm5, xmm13
0000000180365CEC  F3 0F 11 93 60 8F 01 00     movss   dword ptr [rbx+18F60h], xmm2
0000000180365CF4  45 0F 57 FF                 xorps   xmm15, xmm15
0000000180365CF8  76 05                       jbe     short loc_180365CFF
0000000180365CFA  0F 5A C5                    cvtps2pd xmm0, xmm5
0000000180365CFD  EB 03                       jmp     short loc_180365D02
0000000180365CFF  0F 57 C0                    xorps   xmm0, xmm0
0000000180365D02  F3 44 0F 10 25 D9 F7 77 00  movss   xmm12, cs:dword_180AE54E4
0000000180365D0B  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180365D0F  41 0F 2F C4                 comiss  xmm0, xmm12
0000000180365D13  73 06                       jnb     short loc_180365D1B
0000000180365D15  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180365D19  EB 05                       jmp     short loc_180365D20
0000000180365D1B  F3 41 0F 5D C6              minss   xmm0, xmm14
0000000180365D20  F3 0F 59 83 C0 90 01 00     mulss   xmm0, dword ptr [rbx+190C0h]
0000000180365D28  8B 83 90 91 21 00           mov     eax, [rbx+219190h]
0000000180365D2E  F3 44 0F 10 1D 81 4F 62 00  movss   xmm11, cs:dword_18098ACB8
0000000180365D37  F3 0F 11 83 90 8F 01 00     movss   dword ptr [rbx+18F90h], xmm0
0000000180365D3F  0F 28 C2                    movaps  xmm0, xmm2
0000000180365D42  F3 0F 59 15 56 4F 62 00     mulss   xmm2, cs:dword_18098ACA0
0000000180365D4A  F3 41 0F 59 C3              mulss   xmm0, xmm11
0000000180365D4F  0F 5A CA                    cvtps2pd xmm1, xmm2
0000000180365D52  F3 0F 2C D0                 cvttss2si edx, xmm0
0000000180365D56  2B C2                       sub     eax, edx
0000000180365D58  48 63 C8                    movsxd  rcx, eax
0000000180365D5B  48 63 83 94 91 21 00        movsxd  rax, dword ptr [rbx+219194h]
0000000180365D62  48 FF C1                    inc     rcx
0000000180365D65  48 FF C8                    dec     rax
0000000180365D68  48 23 C8                    and     rcx, rax
0000000180365D6B  8B 84 8B 90 91 01 00        mov     eax, [rbx+rcx*4+19190h]
0000000180365D72  89 83 C0 91 41 00           mov     [rbx+4191C0h], eax
0000000180365D78  8B 83 90 91 21 00           mov     eax, [rbx+219190h]
0000000180365D7E  2B C2                       sub     eax, edx
0000000180365D80  48 63 C8                    movsxd  rcx, eax
0000000180365D83  48 63 83 94 91 21 00        movsxd  rax, dword ptr [rbx+219194h]
0000000180365D8A  48 83 C1 02                 add     rcx, 2
0000000180365D8E  48 FF C8                    dec     rax
0000000180365D91  48 23 C8                    and     rcx, rax
0000000180365D94  8B 84 8B 90 91 01 00        mov     eax, [rbx+rcx*4+19190h]
0000000180365D9B  89 83 C4 91 41 00           mov     [rbx+4191C4h], eax
0000000180365DA1  F3 0F 2C C2                 cvttss2si eax, xmm2
0000000180365DA5  66 0F 6E C0                 movd    xmm0, eax
0000000180365DA9  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
0000000180365DAD  F2 0F 5C C8                 subsd   xmm1, xmm0
0000000180365DB1  66 44 0F 5A C9              cvtpd2ps xmm9, xmm1
0000000180365DB6  F3 44 0F 11 8B C8 91 41 00  movss   dword ptr [rbx+4191C8h], xmm9
0000000180365DBF  45 0F 28 D1                 movaps  xmm10, xmm9
0000000180365DC3  F3 0F 10 8B C0 91 41 00     movss   xmm1, dword ptr [rbx+4191C0h]
0000000180365DCB  41 0F 28 C1                 movaps  xmm0, xmm9
0000000180365DCF  8B 83 A0 91 41 00           mov     eax, [rbx+4191A0h]
0000000180365DD5  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180365DD9  2B C2                       sub     eax, edx
0000000180365DDB  48 63 C8                    movsxd  rcx, eax
0000000180365DDE  48 63 83 A4 91 41 00        movsxd  rax, dword ptr [rbx+4191A4h]
0000000180365DE5  48 FF C1                    inc     rcx
0000000180365DE8  48 FF C8                    dec     rax
0000000180365DEB  48 23 C8                    and     rcx, rax
0000000180365DEE  8B 84 8B A0 91 21 00        mov     eax, [rbx+rcx*4+2191A0h]
0000000180365DF5  89 83 E0 91 41 00           mov     [rbx+4191E0h], eax
0000000180365DFB  8B 83 A0 91 41 00           mov     eax, [rbx+4191A0h]
0000000180365E01  2B C2                       sub     eax, edx
0000000180365E03  48 63 C8                    movsxd  rcx, eax
0000000180365E06  48 63 83 A4 91 41 00        movsxd  rax, dword ptr [rbx+4191A4h]
0000000180365E0D  48 83 C1 02                 add     rcx, 2
0000000180365E11  48 FF C8                    dec     rax
0000000180365E14  48 23 C8                    and     rcx, rax
0000000180365E17  8B 84 8B A0 91 21 00        mov     eax, [rbx+rcx*4+2191A0h]
0000000180365E1E  89 83 E4 91 41 00           mov     [rbx+4191E4h], eax
0000000180365E24  F3 44 0F 11 8B E8 91 41 00  movss   dword ptr [rbx+4191E8h], xmm9
0000000180365E2D  F3 44 0F 59 93 C4 91 41 00  mulss   xmm10, dword ptr [rbx+4191C4h]
0000000180365E36  F3 0F 10 9B F0 8D 01 00     movss   xmm3, dword ptr [rbx+18DF0h]
0000000180365E3E  F3 0F 10 A3 10 8E 01 00     movss   xmm4, dword ptr [rbx+18E10h]
0000000180365E46  F3 44 0F 5C D0              subss   xmm10, xmm0
0000000180365E4B  F3 0F 10 83 E0 8D 01 00     movss   xmm0, dword ptr [rbx+18DE0h]
0000000180365E53  F3 44 0F 58 D1              addss   xmm10, xmm1
0000000180365E58  F3 44 0F 59 93 A0 8F 01 00  mulss   xmm10, dword ptr [rbx+18FA0h]
0000000180365E61  F3 44 0F 11 93 C0 8D 01 00  movss   dword ptr [rbx+18DC0h], xmm10
0000000180365E6A  41 0F 28 D2                 movaps  xmm2, xmm10
0000000180365E6E  F3 0F 10 AB E0 90 01 00     movss   xmm5, dword ptr [rbx+190E0h]
0000000180365E76  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180365E7A  F3 0F 10 BB E0 91 41 00     movss   xmm7, dword ptr [rbx+4191E0h]
0000000180365E82  F3 0F 59 EA                 mulss   xmm5, xmm2
0000000180365E86  0F 28 CA                    movaps  xmm1, xmm2
0000000180365E89  F3 0F 59 8B D0 90 01 00     mulss   xmm1, dword ptr [rbx+190D0h]
0000000180365E91  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180365E95  F3 0F 10 83 F0 90 01 00     movss   xmm0, dword ptr [rbx+190F0h]
0000000180365E9D  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180365EA1  F3 0F 11 8B D0 8D 01 00     movss   dword ptr [rbx+18DD0h], xmm1
0000000180365EA9  F3 0F 10 93 20 91 01 00     movss   xmm2, dword ptr [rbx+19120h]
0000000180365EB1  F3 0F 5C E8                 subss   xmm5, xmm0
0000000180365EB5  F3 0F 10 83 10 91 01 00     movss   xmm0, dword ptr [rbx+19110h]
0000000180365EBD  F3 0F 5C EB                 subss   xmm5, xmm3
0000000180365EC1  0F 28 CD                    movaps  xmm1, xmm5
0000000180365EC4  F3 0F 59 8B 00 91 01 00     mulss   xmm1, dword ptr [rbx+19100h]
0000000180365ECC  F3 0F 58 CB                 addss   xmm1, xmm3
0000000180365ED0  F3 0F 10 9B 70 8E 01 00     movss   xmm3, dword ptr [rbx+18E70h]
0000000180365ED8  45 0F 28 C1                 movaps  xmm8, xmm9
0000000180365EDC  F3 0F 10 B3 90 8D 01 00     movss   xmm6, dword ptr [rbx+18D90h]
0000000180365EE4  F3 0F 11 8B E0 8D 01 00     movss   dword ptr [rbx+18DE0h], xmm1
0000000180365EEC  F3 0F 59 D1                 mulss   xmm2, xmm1
0000000180365EF0  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180365EF4  F3 44 0F 59 CF              mulss   xmm9, xmm7
0000000180365EF9  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180365EFD  F3 0F 10 83 60 8E 01 00     movss   xmm0, dword ptr [rbx+18E60h]
0000000180365F05  F3 0F 5C D4                 subss   xmm2, xmm4
0000000180365F09  F3 0F 11 93 F0 8D 01 00     movss   dword ptr [rbx+18DF0h], xmm2
0000000180365F11  F3 0F 59 93 30 91 01 00     mulss   xmm2, dword ptr [rbx+19130h]
0000000180365F19  F3 0F 58 D4                 addss   xmm2, xmm4
0000000180365F1D  F3 0F 10 A3 90 8E 01 00     movss   xmm4, dword ptr [rbx+18E90h]
0000000180365F25  F3 0F 11 93 00 8E 01 00     movss   dword ptr [rbx+18E00h], xmm2
0000000180365F2D  F3 44 0F 59 83 E4 91 41 00  mulss   xmm8, dword ptr [rbx+4191E4h]
0000000180365F36  F3 45 0F 5C C1              subss   xmm8, xmm9
0000000180365F3B  F3 44 0F 58 C7              addss   xmm8, xmm7
0000000180365F40  F3 44 0F 59 83 A0 8F 01 00  mulss   xmm8, dword ptr [rbx+18FA0h]
0000000180365F49  F3 44 0F 11 83 40 8E 01 00  movss   dword ptr [rbx+18E40h], xmm8
0000000180365F52  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180365F56  F3 0F 10 AB E0 90 01 00     movss   xmm5, dword ptr [rbx+190E0h]
0000000180365F5E  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180365F62  F3 0F 59 EA                 mulss   xmm5, xmm2
0000000180365F66  0F 28 CA                    movaps  xmm1, xmm2
0000000180365F69  F3 0F 59 8B D0 90 01 00     mulss   xmm1, dword ptr [rbx+190D0h]
0000000180365F71  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180365F75  F3 0F 10 83 F0 90 01 00     movss   xmm0, dword ptr [rbx+190F0h]
0000000180365F7D  F3 0F 11 8B 50 8E 01 00     movss   dword ptr [rbx+18E50h], xmm1
0000000180365F85  F3 0F 10 93 20 91 01 00     movss   xmm2, dword ptr [rbx+19120h]
0000000180365F8D  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180365F91  F3 0F 5C E8                 subss   xmm5, xmm0
0000000180365F95  F3 0F 10 83 10 91 01 00     movss   xmm0, dword ptr [rbx+19110h]
0000000180365F9D  F3 0F 5C EB                 subss   xmm5, xmm3
0000000180365FA1  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180365FA5  0F 28 CD                    movaps  xmm1, xmm5
0000000180365FA8  F3 0F 59 8B 00 91 01 00     mulss   xmm1, dword ptr [rbx+19100h]
0000000180365FB0  F3 0F 10 AB B0 90 01 00     movss   xmm5, dword ptr [rbx+190B0h]
0000000180365FB8  F3 0F 58 CB                 addss   xmm1, xmm3
0000000180365FBC  41 0F 28 DE                 movaps  xmm3, xmm14
0000000180365FC0  F3 0F 5C DD                 subss   xmm3, xmm5
0000000180365FC4  F3 0F 11 8B 60 8E 01 00     movss   dword ptr [rbx+18E60h], xmm1
0000000180365FCC  F3 0F 59 D1                 mulss   xmm2, xmm1
0000000180365FD0  0F 28 CD                    movaps  xmm1, xmm5
0000000180365FD3  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180365FD7  F3 0F 5C D4                 subss   xmm2, xmm4
0000000180365FDB  F3 0F 11 93 70 8E 01 00     movss   dword ptr [rbx+18E70h], xmm2
0000000180365FE3  F3 0F 10 83 80 90 01 00     movss   xmm0, dword ptr [rbx+19080h]
0000000180365FEB  F3 0F 59 93 30 91 01 00     mulss   xmm2, dword ptr [rbx+19130h]
0000000180365FF3  F3 44 0F 59 D0              mulss   xmm10, xmm0
0000000180365FF8  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180365FFD  F3 0F 58 D4                 addss   xmm2, xmm4
0000000180366001  F3 0F 11 93 80 8E 01 00     movss   dword ptr [rbx+18E80h], xmm2
0000000180366009  F3 0F 10 A3 70 90 01 00     movss   xmm4, dword ptr [rbx+19070h]
0000000180366011  F3 0F 10 93 80 8D 01 00     movss   xmm2, dword ptr [rbx+18D80h]
0000000180366019  0F 28 C4                    movaps  xmm0, xmm4
000000018036601C  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180366020  F3 0F 59 E6                 mulss   xmm4, xmm6
0000000180366024  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180366028  0F 28 C3                    movaps  xmm0, xmm3
000000018036602B  F3 0F 59 EC                 mulss   xmm5, xmm4
000000018036602F  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180366033  F3 0F 59 DE                 mulss   xmm3, xmm6
0000000180366037  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036603B  F3 0F 58 EB                 addss   xmm5, xmm3
000000018036603F  F3 41 0F 58 CA              addss   xmm1, xmm10
0000000180366044  F3 41 0F 58 E8              addss   xmm5, xmm8
0000000180366049  F3 0F 11 8B B0 8F 01 00     movss   dword ptr [rbx+18FB0h], xmm1
0000000180366051  F3 0F 11 AB C0 8F 01 00     movss   dword ptr [rbx+18FC0h], xmm5
0000000180366059  8B 8B 94 91 21 00           mov     ecx, [rbx+219194h]
000000018036605F  8B 83 90 91 21 00           mov     eax, [rbx+219190h]
0000000180366065  FF C9                       dec     ecx
0000000180366067  FF C8                       dec     eax
0000000180366069  23 C8                       and     ecx, eax
000000018036606B  89 8B 90 91 21 00           mov     [rbx+219190h], ecx
0000000180366071  8B 83 B0 91 41 00           mov     eax, [rbx+4191B0h]
0000000180366077  48 63 C9                    movsxd  rcx, ecx
000000018036607A  89 84 8B 90 91 01 00        mov     [rbx+rcx*4+19190h], eax
0000000180366081  8B 8B A4 91 41 00           mov     ecx, [rbx+4191A4h]
0000000180366087  8B 83 A0 91 41 00           mov     eax, [rbx+4191A0h]
000000018036608D  FF C9                       dec     ecx
000000018036608F  FF C8                       dec     eax
0000000180366091  23 C8                       and     ecx, eax
0000000180366093  89 8B A0 91 41 00           mov     [rbx+4191A0h], ecx
0000000180366099  8B 83 D0 91 41 00           mov     eax, [rbx+4191D0h]
000000018036609F  48 63 C9                    movsxd  rcx, ecx
00000001803660A2  89 84 8B A0 91 21 00        mov     [rbx+rcx*4+2191A0h], eax
00000001803660A9  F3 0F 10 B3 70 8D 01 00     movss   xmm6, dword ptr [rbx+18D70h]
00000001803660B1  0F 28 FE                    movaps  xmm7, xmm6
00000001803660B4  F3 0F 59 B3 C0 8F 01 00     mulss   xmm6, dword ptr [rbx+18FC0h]
00000001803660BC  F3 0F 59 BB B0 8F 01 00     mulss   xmm7, dword ptr [rbx+18FB0h]
00000001803660C4  E9 9F 06 00 00              jmp     loc_180366768
00000001803660C9  83 BB 0C 30 A8 00 01        cmp     dword ptr [rbx+0A8300Ch], 1
00000001803660D0  74 12                       jz      short loc_1803660E4
00000001803660D2  89 B3 20 93 41 00           mov     [rbx+419320h], esi
00000001803660D8  89 B3 30 93 41 00           mov     [rbx+419330h], esi
00000001803660DE  89 B3 40 93 41 00           mov     [rbx+419340h], esi
00000001803660E4  C7 83 0C 30 A8 00 01 00 00 00  mov     dword ptr [rbx+0A8300Ch], 1
00000001803660EE  8B 83 70 92 41 00           mov     eax, [rbx+419270h]
00000001803660F4  89 83 80 92 41 00           mov     [rbx+419280h], eax
00000001803660FA  8B 83 60 92 41 00           mov     eax, [rbx+419260h]
0000000180366100  89 83 70 92 41 00           mov     [rbx+419270h], eax
0000000180366106  8B 83 50 92 41 00           mov     eax, [rbx+419250h]
000000018036610C  89 83 60 92 41 00           mov     [rbx+419260h], eax
0000000180366112  8B 83 40 92 41 00           mov     eax, [rbx+419240h]
0000000180366118  89 83 50 92 41 00           mov     [rbx+419250h], eax
000000018036611E  8B 83 30 92 41 00           mov     eax, [rbx+419230h]
0000000180366124  89 83 40 92 41 00           mov     [rbx+419240h], eax
000000018036612A  8B 83 20 92 41 00           mov     eax, [rbx+419220h]
0000000180366130  89 83 30 92 41 00           mov     [rbx+419230h], eax
0000000180366136  8B 83 10 92 41 00           mov     eax, [rbx+419210h]
000000018036613C  89 83 20 92 41 00           mov     [rbx+419220h], eax
0000000180366142  8B 83 C0 92 41 00           mov     eax, [rbx+4192C0h]
0000000180366148  89 83 D0 92 41 00           mov     [rbx+4192D0h], eax
000000018036614E  8B 83 B0 92 41 00           mov     eax, [rbx+4192B0h]
0000000180366154  89 83 C0 92 41 00           mov     [rbx+4192C0h], eax
000000018036615A  8B 83 A0 92 41 00           mov     eax, [rbx+4192A0h]
0000000180366160  89 83 B0 92 41 00           mov     [rbx+4192B0h], eax
0000000180366166  8B 83 90 92 41 00           mov     eax, [rbx+419290h]
000000018036616C  89 83 A0 92 41 00           mov     [rbx+4192A0h], eax
0000000180366172  8B 83 00 93 41 00           mov     eax, [rbx+419300h]
0000000180366178  89 83 10 93 41 00           mov     [rbx+419310h], eax
000000018036617E  8B 83 F0 92 41 00           mov     eax, [rbx+4192F0h]
0000000180366184  89 83 00 93 41 00           mov     [rbx+419300h], eax
000000018036618A  8B 83 E0 92 41 00           mov     eax, [rbx+4192E0h]
0000000180366190  F3 44 0F 10 35 1B EF 77 00  movss   xmm14, cs:dword_180AE50B4
0000000180366199  89 83 F0 92 41 00           mov     [rbx+4192F0h], eax
000000018036619F  8B 83 30 93 41 00           mov     eax, [rbx+419330h]
00000001803661A5  89 83 40 93 41 00           mov     [rbx+419340h], eax
00000001803661AB  8B 83 20 93 41 00           mov     eax, [rbx+419320h]
00000001803661B1  89 83 30 93 41 00           mov     [rbx+419330h], eax
00000001803661B7  F3 44 0F 11 8B F0 91 41 00  movss   dword ptr [rbx+4191F0h], xmm9
00000001803661C0  F3 44 0F 11 83 00 92 41 00  movss   dword ptr [rbx+419200h], xmm8
00000001803661C9  F3 45 0F 58 C1              addss   xmm8, xmm9
00000001803661CE  F3 45 0F 59 C7              mulss   xmm8, xmm15
00000001803661D3  F3 44 0F 11 83 90 92 41 00  movss   dword ptr [rbx+419290h], xmm8
00000001803661DC  41 0F 28 C0                 movaps  xmm0, xmm8
00000001803661E0  F3 0F 59 83 80 93 41 00     mulss   xmm0, dword ptr [rbx+419380h]
00000001803661E8  F3 0F 10 8B A0 93 41 00     movss   xmm1, dword ptr [rbx+4193A0h]
00000001803661F0  F3 0F 59 8B B0 92 41 00     mulss   xmm1, dword ptr [rbx+4192B0h]
00000001803661F8  F3 0F 10 AB 90 93 41 00     movss   xmm5, dword ptr [rbx+419390h]
0000000180366200  F3 0F 59 AB A0 92 41 00     mulss   xmm5, dword ptr [rbx+4192A0h]
0000000180366208  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036620C  F3 0F 10 83 B0 93 41 00     movss   xmm0, dword ptr [rbx+4193B0h]
0000000180366214  F3 0F 59 83 C0 92 41 00     mulss   xmm0, dword ptr [rbx+4192C0h]
000000018036621C  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180366220  F3 0F 10 8B C0 93 41 00     movss   xmm1, dword ptr [rbx+4193C0h]
0000000180366228  F3 0F 59 8B D0 92 41 00     mulss   xmm1, dword ptr [rbx+4192D0h]
0000000180366230  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180366234  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180366238  41 0F 28 C8                 movaps  xmm1, xmm8
000000018036623C  F3 0F 11 AB B0 92 41 00     movss   dword ptr [rbx+4192B0h], xmm5
0000000180366244  F3 0F 10 93 20 92 41 00     movss   xmm2, dword ptr [rbx+419220h]
000000018036624C  0F 28 C2                    movaps  xmm0, xmm2
000000018036624F  F3 0F 59 83 F0 93 41 00     mulss   xmm0, dword ptr [rbx+4193F0h]
0000000180366257  F3 0F 5C C8                 subss   xmm1, xmm0
000000018036625B  F3 0F 5C 8B 30 92 41 00     subss   xmm1, dword ptr [rbx+419230h]
0000000180366263  F3 0F 59 8B E0 93 41 00     mulss   xmm1, dword ptr [rbx+4193E0h]
000000018036626B  F3 0F 58 CA                 addss   xmm1, xmm2
000000018036626F  41 0F 28 D6                 movaps  xmm2, xmm14
0000000180366273  F3 0F 11 8B 10 92 41 00     movss   dword ptr [rbx+419210h], xmm1
000000018036627B  F3 0F 10 9B E0 93 41 00     movss   xmm3, dword ptr [rbx+4193E0h]
0000000180366283  F3 0F 59 9B 20 92 41 00     mulss   xmm3, dword ptr [rbx+419220h]
000000018036628B  F3 0F 58 9B 30 92 41 00     addss   xmm3, dword ptr [rbx+419230h]
0000000180366293  F3 0F 11 9B 20 92 41 00     movss   dword ptr [rbx+419220h], xmm3
000000018036629B  F3 0F 10 83 D0 93 41 00     movss   xmm0, dword ptr [rbx+4193D0h]
00000001803662A3  F3 0F 10 8B 00 94 41 00     movss   xmm1, dword ptr [rbx+419400h]
00000001803662AB  F3 0F 5C D0                 subss   xmm2, xmm0
00000001803662AF  F3 0F 10 A3 20 95 41 00     movss   xmm4, dword ptr [rbx+419520h]
00000001803662B7  F3 0F 58 A3 30 93 41 00     addss   xmm4, dword ptr [rbx+419330h]
00000001803662BF  F3 0F 59 C5                 mulss   xmm0, xmm5
00000001803662C3  F3 0F 59 D3                 mulss   xmm2, xmm3
00000001803662C7  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803662CB  41 0F 28 C6                 movaps  xmm0, xmm14
00000001803662CF  F3 0F 5C C1                 subss   xmm0, xmm1
00000001803662D3  F3 0F 59 D1                 mulss   xmm2, xmm1
00000001803662D7  F3 41 0F 59 C0              mulss   xmm0, xmm8
00000001803662DC  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803662E0  F3 0F 59 93 60 94 41 00     mulss   xmm2, dword ptr [rbx+419460h]
00000001803662E8  45 0F 57 ED                 xorps   xmm13, xmm13
00000001803662EC  F3 0F 10 83 50 94 41 00     movss   xmm0, dword ptr [rbx+419450h]
00000001803662F4  F3 0F 59 83 70 92 41 00     mulss   xmm0, dword ptr [rbx+419270h]
00000001803662FC  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180366300  F3 0F 59 93 70 94 41 00     mulss   xmm2, dword ptr [rbx+419470h]
0000000180366308  F3 0F 11 93 80 95 61 00     movss   dword ptr [rbx+619580h], xmm2
0000000180366310  F3 0F 10 8B 30 95 41 00     movss   xmm1, dword ptr [rbx+419530h]
0000000180366318  F3 0F 5D CC                 minss   xmm1, xmm4
000000018036631C  F3 41 0F 59 CA              mulss   xmm1, xmm10
0000000180366321  F3 0F 11 8B 20 93 41 00     movss   dword ptr [rbx+419320h], xmm1
0000000180366329  F3 0F 5C 8B 10 93 41 00     subss   xmm1, dword ptr [rbx+419310h]
0000000180366331  F3 0F 10 B3 40 93 41 00     movss   xmm6, dword ptr [rbx+419340h]
0000000180366339  41 0F 2F CD                 comiss  xmm1, xmm13
000000018036633D  73 0A                       jnb     short loc_180366349
000000018036633F  F3 0F 10 83 50 95 41 00     movss   xmm0, dword ptr [rbx+419550h]
0000000180366347  EB 08                       jmp     short loc_180366351
0000000180366349  F3 0F 10 83 40 95 41 00     movss   xmm0, dword ptr [rbx+419540h]
0000000180366351  F3 0F 10 AB 70 93 41 00     movss   xmm5, dword ptr [rbx+419370h]
0000000180366359  F3 0F 58 F0                 addss   xmm6, xmm0
000000018036635D  F3 0F 11 AB E0 92 41 00     movss   dword ptr [rbx+4192E0h], xmm5
0000000180366365  0F 28 C5                    movaps  xmm0, xmm5
0000000180366368  F3 0F 5C 83 F0 92 41 00     subss   xmm0, dword ptr [rbx+4192F0h]
0000000180366370  F3 0F 10 93 10 93 41 00     movss   xmm2, dword ptr [rbx+419310h]
0000000180366378  0F 28 E5                    movaps  xmm4, xmm5
000000018036637B  F3 0F 10 9B 00 93 41 00     movss   xmm3, dword ptr [rbx+419300h]
0000000180366383  F3 0F 5C E2                 subss   xmm4, xmm2
0000000180366387  F3 0F 10 BB 60 95 41 00     movss   xmm7, dword ptr [rbx+419560h]
000000018036638F  41 0F 2E C5                 ucomiss xmm0, xmm13
0000000180366393  74 03                       jz      short loc_180366398
0000000180366395  0F 28 DC                    movaps  xmm3, xmm4
0000000180366398  41 0F 2F E5                 comiss  xmm4, xmm13
000000018036639C  0F 28 C2                    movaps  xmm0, xmm2
000000018036639F  F3 0F 11 9B F0 92 41 00     movss   dword ptr [rbx+4192F0h], xmm3
00000001803663A7  41 0F 54 DC                 andps   xmm3, xmm12
00000001803663AB  F3 0F 59 DF                 mulss   xmm3, xmm7
00000001803663AF  F3 0F 5C D3                 subss   xmm2, xmm3
00000001803663B3  F3 0F 58 C3                 addss   xmm0, xmm3
00000001803663B7  F3 0F 5F D5                 maxss   xmm2, xmm5
00000001803663BB  76 07                       jbe     short loc_1803663C4
00000001803663BD  0F 28 D0                    movaps  xmm2, xmm0
00000001803663C0  F3 0F 5D D5                 minss   xmm2, xmm5
00000001803663C4  41 0F 2F F5                 comiss  xmm6, xmm13
00000001803663C8  F3 0F 11 93 00 93 41 00     movss   dword ptr [rbx+419300h], xmm2
00000001803663D0  45 0F 57 FF                 xorps   xmm15, xmm15
00000001803663D4  76 05                       jbe     short loc_1803663DB
00000001803663D6  0F 5A C6                    cvtps2pd xmm0, xmm6
00000001803663D9  EB 03                       jmp     short loc_1803663DE
00000001803663DB  0F 57 C0                    xorps   xmm0, xmm0
00000001803663DE  F3 44 0F 10 25 FD F0 77 00  movss   xmm12, cs:dword_180AE54E4
00000001803663E7  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00000001803663EB  41 0F 2F C4                 comiss  xmm0, xmm12
00000001803663EF  73 06                       jnb     short loc_1803663F7
00000001803663F1  41 0F 28 C4                 movaps  xmm0, xmm12
00000001803663F5  EB 05                       jmp     short loc_1803663FC
00000001803663F7  F3 41 0F 5D C6              minss   xmm0, xmm14
00000001803663FC  F3 0F 59 83 70 94 41 00     mulss   xmm0, dword ptr [rbx+419470h]
0000000180366404  0F 28 CA                    movaps  xmm1, xmm2
0000000180366407  F3 0F 11 83 30 93 41 00     movss   dword ptr [rbx+419330h], xmm0
000000018036640F  F3 0F 59 8B 40 94 41 00     mulss   xmm1, dword ptr [rbx+419440h]
0000000180366417  0F 2F 0D E6 1C 62 00        comiss  xmm1, cs:dword_180988104
000000018036641E  76 05                       jbe     short loc_180366425
0000000180366420  0F 5A D9                    cvtps2pd xmm3, xmm1
0000000180366423  EB 08                       jmp     short loc_18036642D
0000000180366425  F2 0F 10 1D 53 48 62 00     movsd   xmm3, cs:qword_18098AC80
000000018036642D  8B 83 70 95 61 00           mov     eax, [rbx+619570h]
0000000180366433  0F 28 C2                    movaps  xmm0, xmm2
0000000180366436  F3 0F 59 15 62 48 62 00     mulss   xmm2, cs:dword_18098ACA0
000000018036643E  F3 44 0F 10 1D 71 48 62 00  movss   xmm11, cs:dword_18098ACB8
0000000180366447  F3 41 0F 59 C3              mulss   xmm0, xmm11
000000018036644C  0F 5A CA                    cvtps2pd xmm1, xmm2
000000018036644F  F3 0F 2C D0                 cvttss2si edx, xmm0
0000000180366453  2B C2                       sub     eax, edx
0000000180366455  48 63 C8                    movsxd  rcx, eax
0000000180366458  48 63 83 74 95 61 00        movsxd  rax, dword ptr [rbx+619574h]
000000018036645F  48 FF C1                    inc     rcx
0000000180366462  48 FF C8                    dec     rax
0000000180366465  48 23 C8                    and     rcx, rax
0000000180366468  8B 84 8B 70 95 41 00        mov     eax, [rbx+rcx*4+419570h]
000000018036646F  89 83 90 95 61 00           mov     [rbx+619590h], eax
0000000180366475  8B 83 70 95 61 00           mov     eax, [rbx+619570h]
000000018036647B  2B C2                       sub     eax, edx
000000018036647D  48 63 C8                    movsxd  rcx, eax
0000000180366480  48 63 83 74 95 61 00        movsxd  rax, dword ptr [rbx+619574h]
0000000180366487  48 83 C1 02                 add     rcx, 2
000000018036648B  48 FF C8                    dec     rax
000000018036648E  48 23 C8                    and     rcx, rax
0000000180366491  8B 84 8B 70 95 41 00        mov     eax, [rbx+rcx*4+419570h]
0000000180366498  89 83 94 95 61 00           mov     [rbx+619594h], eax
000000018036649E  F3 0F 2C C2                 cvttss2si eax, xmm2
00000001803664A2  66 0F 5A D3                 cvtpd2ps xmm2, xmm3
00000001803664A6  66 0F 6E C0                 movd    xmm0, eax
00000001803664AA  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00000001803664AE  F2 0F 5C C8                 subsd   xmm1, xmm0
00000001803664B2  0F 28 C2                    movaps  xmm0, xmm2
00000001803664B5  F3 0F 59 15 E3 47 62 00     mulss   xmm2, cs:dword_18098ACA0
00000001803664BD  F3 41 0F 59 C3              mulss   xmm0, xmm11
00000001803664C2  66 0F 5A F9                 cvtpd2ps xmm7, xmm1
00000001803664C6  F3 0F 2C D0                 cvttss2si edx, xmm0
00000001803664CA  F3 0F 11 BB 98 95 61 00     movss   dword ptr [rbx+619598h], xmm7
00000001803664D2  0F 28 DF                    movaps  xmm3, xmm7
00000001803664D5  8B 83 70 95 61 00           mov     eax, [rbx+619570h]
00000001803664DB  F3 0F 10 AB 90 95 61 00     movss   xmm5, dword ptr [rbx+619590h]
00000001803664E3  2B C2                       sub     eax, edx
00000001803664E5  48 63 C8                    movsxd  rcx, eax
00000001803664E8  48 63 83 74 95 61 00        movsxd  rax, dword ptr [rbx+619574h]
00000001803664EF  48 FF C1                    inc     rcx
00000001803664F2  48 FF C8                    dec     rax
00000001803664F5  F3 0F 59 FD                 mulss   xmm7, xmm5
00000001803664F9  48 23 C8                    and     rcx, rax
00000001803664FC  0F 5A CA                    cvtps2pd xmm1, xmm2
00000001803664FF  8B 84 8B 70 95 41 00        mov     eax, [rbx+rcx*4+419570h]
0000000180366506  89 83 A0 95 61 00           mov     [rbx+6195A0h], eax
000000018036650C  8B 83 70 95 61 00           mov     eax, [rbx+619570h]
0000000180366512  2B C2                       sub     eax, edx
0000000180366514  48 63 C8                    movsxd  rcx, eax
0000000180366517  48 63 83 74 95 61 00        movsxd  rax, dword ptr [rbx+619574h]
000000018036651E  48 83 C1 02                 add     rcx, 2
0000000180366522  48 FF C8                    dec     rax
0000000180366525  48 23 C8                    and     rcx, rax
0000000180366528  8B 84 8B 70 95 41 00        mov     eax, [rbx+rcx*4+419570h]
000000018036652F  89 83 A4 95 61 00           mov     [rbx+6195A4h], eax
0000000180366535  F3 0F 2C C2                 cvttss2si eax, xmm2
0000000180366539  66 0F 6E C0                 movd    xmm0, eax
000000018036653D  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
0000000180366541  F2 0F 5C C8                 subsd   xmm1, xmm0
0000000180366545  66 44 0F 5A D1              cvtpd2ps xmm10, xmm1
000000018036654A  F3 44 0F 11 93 A8 95 61 00  movss   dword ptr [rbx+6195A8h], xmm10
0000000180366553  F3 0F 59 9B 94 95 61 00     mulss   xmm3, dword ptr [rbx+619594h]
000000018036655B  F3 0F 10 83 50 92 41 00     movss   xmm0, dword ptr [rbx+419250h]
0000000180366563  F3 0F 5C DF                 subss   xmm3, xmm7
0000000180366567  F3 0F 58 DD                 addss   xmm3, xmm5
000000018036656B  F3 0F 59 9B 40 93 41 00     mulss   xmm3, dword ptr [rbx+419340h]
0000000180366573  F3 0F 11 9B 30 92 41 00     movss   dword ptr [rbx+419230h], xmm3
000000018036657B  F3 0F 5C D8                 subss   xmm3, xmm0
000000018036657F  F3 0F 10 A3 C0 94 41 00     movss   xmm4, dword ptr [rbx+4194C0h]
0000000180366587  F3 0F 10 BB A0 95 61 00     movss   xmm7, dword ptr [rbx+6195A0h]
000000018036658F  F3 0F 10 93 60 92 41 00     movss   xmm2, dword ptr [rbx+419260h]
0000000180366597  0F 28 CB                    movaps  xmm1, xmm3
000000018036659A  F3 0F 59 E3                 mulss   xmm4, xmm3
000000018036659E  F3 0F 59 8B B0 94 41 00     mulss   xmm1, dword ptr [rbx+4194B0h]
00000001803665A6  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803665AA  F3 0F 10 83 D0 94 41 00     movss   xmm0, dword ptr [rbx+4194D0h]
00000001803665B2  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803665B6  F3 0F 11 8B 40 92 41 00     movss   dword ptr [rbx+419240h], xmm1
00000001803665BE  F3 0F 5C E0                 subss   xmm4, xmm0
00000001803665C2  F3 0F 10 9B 80 92 41 00     movss   xmm3, dword ptr [rbx+419280h]
00000001803665CA  F3 0F 5C E2                 subss   xmm4, xmm2
00000001803665CE  F3 0F 10 83 F0 94 41 00     movss   xmm0, dword ptr [rbx+4194F0h]
00000001803665D6  45 0F 28 CA                 movaps  xmm9, xmm10
00000001803665DA  F3 44 0F 59 D7              mulss   xmm10, xmm7
00000001803665DF  F3 0F 59 C4                 mulss   xmm0, xmm4
00000001803665E3  0F 28 CC                    movaps  xmm1, xmm4
00000001803665E6  F3 0F 59 8B E0 94 41 00     mulss   xmm1, dword ptr [rbx+4194E0h]
00000001803665EE  41 0F 28 E6                 movaps  xmm4, xmm14
00000001803665F2  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803665F6  F3 0F 10 93 00 95 41 00     movss   xmm2, dword ptr [rbx+419500h]
00000001803665FE  F3 0F 11 8B 50 92 41 00     movss   dword ptr [rbx+419250h], xmm1
0000000180366606  F3 0F 59 D1                 mulss   xmm2, xmm1
000000018036660A  41 0F 28 CE                 movaps  xmm1, xmm14
000000018036660E  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180366612  F3 0F 5C D3                 subss   xmm2, xmm3
0000000180366616  F3 0F 11 93 60 92 41 00     movss   dword ptr [rbx+419260h], xmm2
000000018036661E  F3 0F 59 93 10 95 41 00     mulss   xmm2, dword ptr [rbx+419510h]
0000000180366626  F3 0F 58 D3                 addss   xmm2, xmm3
000000018036662A  F3 0F 11 93 70 92 41 00     movss   dword ptr [rbx+419270h], xmm2
0000000180366632  41 0F 28 D6                 movaps  xmm2, xmm14
0000000180366636  F3 44 0F 59 8B A4 95 61 00  mulss   xmm9, dword ptr [rbx+6195A4h]
000000018036663F  F3 0F 10 AB 90 94 41 00     movss   xmm5, dword ptr [rbx+419490h]
0000000180366647  F3 0F 10 83 80 94 41 00     movss   xmm0, dword ptr [rbx+419480h]
000000018036664F  F3 0F 5C E5                 subss   xmm4, xmm5
0000000180366653  F3 0F 10 B3 F0 91 41 00     movss   xmm6, dword ptr [rbx+4191F0h]
000000018036665B  F3 0F 5C C8                 subss   xmm1, xmm0
000000018036665F  F3 44 0F 10 83 30 92 41 00  movss   xmm8, dword ptr [rbx+419230h]
0000000180366668  F3 45 0F 5C CA              subss   xmm9, xmm10
000000018036666D  0F 28 DD                    movaps  xmm3, xmm5
0000000180366670  F3 41 0F 59 C8              mulss   xmm1, xmm8
0000000180366675  F3 44 0F 58 CF              addss   xmm9, xmm7
000000018036667A  F3 0F 10 BB 00 92 41 00     movss   xmm7, dword ptr [rbx+419200h]
0000000180366682  F3 0F 59 DF                 mulss   xmm3, xmm7
0000000180366686  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018036668A  F3 44 0F 59 8B 40 93 41 00  mulss   xmm9, dword ptr [rbx+419340h]
0000000180366693  F3 0F 58 DE                 addss   xmm3, xmm6
0000000180366697  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018036669C  0F 28 C5                    movaps  xmm0, xmm5
000000018036669F  F3 0F 10 AB 60 94 41 00     movss   xmm5, dword ptr [rbx+419460h]
00000001803666A7  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803666AB  F3 0F 5C D5                 subss   xmm2, xmm5
00000001803666AF  F3 44 0F 5C C8              subss   xmm9, xmm0
00000001803666B4  F3 0F 10 83 20 94 41 00     movss   xmm0, dword ptr [rbx+419420h]
00000001803666BC  F3 44 0F 59 C0              mulss   xmm8, xmm0
00000001803666C1  F3 44 0F 58 C9              addss   xmm9, xmm1
00000001803666C6  F3 0F 10 8B A0 94 41 00     movss   xmm1, dword ptr [rbx+4194A0h]
00000001803666CE  F3 44 0F 59 C1              mulss   xmm8, xmm1
00000001803666D3  F3 44 0F 59 C8              mulss   xmm9, xmm0
00000001803666D8  F3 0F 10 83 10 94 41 00     movss   xmm0, dword ptr [rbx+419410h]
00000001803666E0  F3 0F 59 D8                 mulss   xmm3, xmm0
00000001803666E4  F3 44 0F 59 C9              mulss   xmm9, xmm1
00000001803666E9  0F 28 CD                    movaps  xmm1, xmm5
00000001803666EC  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803666F0  0F 28 C2                    movaps  xmm0, xmm2
00000001803666F3  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803666F7  F3 0F 59 D7                 mulss   xmm2, xmm7
00000001803666FB  F3 0F 59 CB                 mulss   xmm1, xmm3
00000001803666FF  F3 0F 59 EC                 mulss   xmm5, xmm4
0000000180366703  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180366707  F3 0F 58 EA                 addss   xmm5, xmm2
000000018036670B  F3 41 0F 58 C8              addss   xmm1, xmm8
0000000180366710  F3 41 0F 58 E9              addss   xmm5, xmm9
0000000180366715  F3 0F 11 8B 50 93 41 00     movss   dword ptr [rbx+419350h], xmm1
000000018036671D  F3 0F 11 AB 60 93 41 00     movss   dword ptr [rbx+419360h], xmm5
0000000180366725  8B 8B 74 95 61 00           mov     ecx, [rbx+619574h]
000000018036672B  8B 83 70 95 61 00           mov     eax, [rbx+619570h]
0000000180366731  FF C9                       dec     ecx
0000000180366733  FF C8                       dec     eax
0000000180366735  23 C8                       and     ecx, eax
0000000180366737  89 8B 70 95 61 00           mov     [rbx+619570h], ecx
000000018036673D  8B 83 80 95 61 00           mov     eax, [rbx+619580h]
0000000180366743  48 63 C9                    movsxd  rcx, ecx
0000000180366746  89 84 8B 70 95 41 00        mov     [rbx+rcx*4+419570h], eax
000000018036674D  F3 0F 10 B3 70 8D 01 00     movss   xmm6, dword ptr [rbx+18D70h]
0000000180366755  0F 28 FE                    movaps  xmm7, xmm6
0000000180366758  F3 0F 59 B3 60 93 41 00     mulss   xmm6, dword ptr [rbx+419360h]
0000000180366760  F3 0F 59 BB 50 93 41 00     mulss   xmm7, dword ptr [rbx+419350h]
0000000180366768  F3 44 0F 10 0D 2F 45 62 00  movss   xmm9, cs:dword_18098ACA0
0000000180366771  F3 44 0F 10 15 6E EA 77 00  movss   xmm10, cs:flt_180AE51E8
000000018036677A  8B 83 B0 2E A4 00           mov     eax, [rbx+0A42EB0h]
0000000180366780  FF C8                       dec     eax
0000000180366782  0F B7 C0                    movzx   eax, ax
0000000180366785  89 83 B0 2E A4 00           mov     [rbx+0A42EB0h], eax
000000018036678B  F3 0F 10 83 D0 2E A8 00     movss   xmm0, dword ptr [rbx+0A82ED0h]
0000000180366793  39 B3 C0 2E A4 00           cmp     [rbx+0A42EC0h], esi
0000000180366799  7E 2A                       jle     short loc_1803667C5
000000018036679B  41 0F 2E C5                 ucomiss xmm0, xmm13
000000018036679F  74 1F                       jz      short loc_1803667C0
00000001803667A1  F3 0F 5C 05 CB 44 62 00     subss   xmm0, cs:dword_18098AC74
00000001803667A9  41 0F 2F C5                 comiss  xmm0, xmm13
00000001803667AD  F3 0F 11 83 D0 2E A8 00     movss   dword ptr [rbx+0A82ED0h], xmm0
00000001803667B5  73 09                       jnb     short loc_1803667C0
00000001803667B7  89 B3 D0 2E A8 00           mov     [rbx+0A82ED0h], esi
00000001803667BD  0F 57 C0                    xorps   xmm0, xmm0
00000001803667C0  0F 28 C8                    movaps  xmm1, xmm0
00000001803667C3  EB 37                       jmp     short loc_1803667FC
00000001803667C5  41 0F 2F C6                 comiss  xmm0, xmm14
00000001803667C9  0F 28 C8                    movaps  xmm1, xmm0
00000001803667CC  73 2E                       jnb     short loc_1803667FC
00000001803667CE  44 0F 2F AB D0 2C A4 00     comiss  xmm13, dword ptr [rbx+0A42CD0h]
00000001803667D6  73 24                       jnb     short loc_1803667FC
00000001803667D8  F3 0F 58 0D 94 44 62 00     addss   xmm1, cs:dword_18098AC74
00000001803667E0  41 0F 2F CE                 comiss  xmm1, xmm14
00000001803667E4  F3 0F 11 8B D0 2E A8 00     movss   dword ptr [rbx+0A82ED0h], xmm1
00000001803667EC  76 0E                       jbe     short loc_1803667FC
00000001803667EE  C7 83 D0 2E A8 00 00 00 80 3F  mov     dword ptr [rbx+0A82ED0h], 3F800000h
00000001803667F8  41 0F 28 CE                 movaps  xmm1, xmm14
00000001803667FC  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180366800  0F 86 FB 06 00 00           jbe     loc_180366F01
0000000180366806  F3 0F 10 83 D0 2C A4 00     movss   xmm0, dword ptr [rbx+0A42CD0h]
000000018036680E  41 0F 2F C5                 comiss  xmm0, xmm13
0000000180366812  0F 86 E9 06 00 00           jbe     loc_180366F01
0000000180366818  F3 0F 10 9B 70 2D A4 00     movss   xmm3, dword ptr [rbx+0A42D70h]
0000000180366820  0F 28 D6                    movaps  xmm2, xmm6
0000000180366823  F3 0F 59 9B D0 2B A4 00     mulss   xmm3, dword ptr [rbx+0A42BD0h]
000000018036682B  F3 0F 58 D7                 addss   xmm2, xmm7
000000018036682F  F3 0F 59 15 41 44 62 00     mulss   xmm2, cs:dword_18098AC78
0000000180366837  F3 0F 59 93 F0 2C A4 00     mulss   xmm2, dword ptr [rbx+0A42CF0h]
000000018036683F  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180366843  F3 0F 59 D1                 mulss   xmm2, xmm1
0000000180366847  F3 0F 10 8B 80 2D A4 00     movss   xmm1, dword ptr [rbx+0A42D80h]
000000018036684F  F3 0F 59 8B E0 2B A4 00     mulss   xmm1, dword ptr [rbx+0A42BE0h]
0000000180366857  0F 28 C2                    movaps  xmm0, xmm2
000000018036685A  F3 0F 59 83 60 2D A4 00     mulss   xmm0, dword ptr [rbx+0A42D60h]
0000000180366862  F3 0F 11 93 D0 2B A4 00     movss   dword ptr [rbx+0A42BD0h], xmm2
000000018036686A  F3 0F 10 93 E0 2B A4 00     movss   xmm2, dword ptr [rbx+0A42BE0h]
0000000180366872  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180366876  0F 28 E2                    movaps  xmm4, xmm2
0000000180366879  F3 0F 59 A3 A0 2D A4 00     mulss   xmm4, dword ptr [rbx+0A42DA0h]
0000000180366881  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180366885  F3 0F 10 8B B0 2D A4 00     movss   xmm1, dword ptr [rbx+0A42DB0h]
000000018036688D  F3 0F 59 8B F0 2B A4 00     mulss   xmm1, dword ptr [rbx+0A42BF0h]
0000000180366895  0F 28 C3                    movaps  xmm0, xmm3
0000000180366898  F3 0F 59 83 90 2D A4 00     mulss   xmm0, dword ptr [rbx+0A42D90h]
00000001803668A0  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803668A4  F3 0F 10 83 C0 2D A4 00     movss   xmm0, dword ptr [rbx+0A42DC0h]
00000001803668AC  F3 0F 59 83 00 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42C00h]
00000001803668B4  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803668B8  F3 0F 10 8B D0 2D A4 00     movss   xmm1, dword ptr [rbx+0A42DD0h]
00000001803668C0  F3 0F 59 8B 10 2C A4 00     mulss   xmm1, dword ptr [rbx+0A42C10h]
00000001803668C8  F3 0F 11 93 F0 2B A4 00     movss   dword ptr [rbx+0A42BF0h], xmm2
00000001803668D0  F3 0F 11 9B E0 2B A4 00     movss   dword ptr [rbx+0A42BE0h], xmm3
00000001803668D8  8B 83 00 2C A4 00           mov     eax, [rbx+0A42C00h]
00000001803668DE  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803668E2  89 83 10 2C A4 00           mov     [rbx+0A42C10h], eax
00000001803668E8  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803668EC  F3 0F 11 A3 00 2C A4 00     movss   dword ptr [rbx+0A42C00h], xmm4
00000001803668F4  F3 0F 10 83 50 2D A4 00     movss   xmm0, dword ptr [rbx+0A42D50h]
00000001803668FC  F3 0F 58 83 B0 2C A4 00     addss   xmm0, dword ptr [rbx+0A42CB0h]
0000000180366904  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180366908  F3 0F 11 83 A0 2C A4 00     movss   dword ptr [rbx+0A42CA0h], xmm0
0000000180366910  76 0D                       jbe     short loc_18036691F
0000000180366912  F3 41 0F 5C C2              subss   xmm0, xmm10
0000000180366917  F3 0F 11 83 A0 2C A4 00     movss   dword ptr [rbx+0A42CA0h], xmm0
000000018036691F  41 0F 2F C5                 comiss  xmm0, xmm13
0000000180366923  0F 28 C8                    movaps  xmm1, xmm0
0000000180366926  F3 0F 59 8B 40 2D A4 00     mulss   xmm1, dword ptr [rbx+0A42D40h]
000000018036692E  72 0A                       jb      short loc_18036693A
0000000180366930  F3 0F 10 15 7C 43 62 00     movss   xmm2, cs:dword_18098ACB4
0000000180366938  EB 08                       jmp     short loc_180366942
000000018036693A  F3 0F 10 15 5A 43 62 00     movss   xmm2, cs:dword_18098AC9C
0000000180366942  F3 0F 11 83 B0 2C A4 00     movss   dword ptr [rbx+0A42CB0h], xmm0
000000018036694A  8B 83 F0 2E A8 00           mov     eax, [rbx+0A82EF0h]
0000000180366950  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
0000000180366956  0F B7 C0                    movzx   eax, ax
0000000180366959  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018036695D  F3 0F 11 A4 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm4
0000000180366966  8B 93 B0 2E A4 00           mov     edx, [rbx+0A42EB0h]
000000018036696C  8B 83 FC 2E A8 00           mov     eax, [rbx+0A82EFCh]
0000000180366972  8B 8B F4 2E A8 00           mov     ecx, [rbx+0A82EF4h]
0000000180366978  03 C2                       add     eax, edx
000000018036697A  0F B7 C0                    movzx   eax, ax
000000018036697D  F3 0F 10 A4 83 D0 2E A4 00  movss   xmm4, dword ptr [rbx+rax*4+0A42ED0h]
0000000180366986  F3 0F 2C C1                 cvttss2si eax, xmm1
000000018036698A  0F 28 C4                    movaps  xmm0, xmm4
000000018036698D  F3 0F 59 83 E0 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42CE0h]
0000000180366995  2B C8                       sub     ecx, eax
0000000180366997  03 CA                       add     ecx, edx
0000000180366999  0F B7 C1                    movzx   eax, cx
000000018036699C  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
00000001803669A5  8B 83 F8 2E A8 00           mov     eax, [rbx+0A82EF8h]
00000001803669AB  F3 0F 5C C8                 subss   xmm1, xmm0
00000001803669AF  03 C2                       add     eax, edx
00000001803669B1  0F B7 C0                    movzx   eax, ax
00000001803669B4  F3 0F 11 8C 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm1
00000001803669BD  F3 0F 10 93 E0 2C A4 00     movss   xmm2, dword ptr [rbx+0A42CE0h]
00000001803669C5  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
00000001803669CB  0F 28 DA                    movaps  xmm3, xmm2
00000001803669CE  8B 83 04 2F A8 00           mov     eax, [rbx+0A82F04h]
00000001803669D4  03 C1                       add     eax, ecx
00000001803669D6  F3 0F 59 D9                 mulss   xmm3, xmm1
00000001803669DA  0F B7 C0                    movzx   eax, ax
00000001803669DD  F3 0F 58 DC                 addss   xmm3, xmm4
00000001803669E1  F3 0F 10 84 83 D0 2E A4 00  movss   xmm0, dword ptr [rbx+rax*4+0A42ED0h]
00000001803669EA  8B 83 00 2F A8 00           mov     eax, [rbx+0A82F00h]
00000001803669F0  03 C1                       add     eax, ecx
00000001803669F2  F3 0F 59 D0                 mulss   xmm2, xmm0
00000001803669F6  0F B7 C0                    movzx   eax, ax
00000001803669F9  F3 0F 5C DA                 subss   xmm3, xmm2
00000001803669FD  F3 0F 11 9C 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm3
0000000180366A06  F3 0F 10 8B E0 2C A4 00     movss   xmm1, dword ptr [rbx+0A42CE0h]
0000000180366A0E  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
0000000180366A14  0F 28 D1                    movaps  xmm2, xmm1
0000000180366A17  8B 83 0C 2F A8 00           mov     eax, [rbx+0A82F0Ch]
0000000180366A1D  03 C1                       add     eax, ecx
0000000180366A1F  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180366A23  0F B7 C0                    movzx   eax, ax
0000000180366A26  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180366A2A  F3 0F 10 84 83 D0 2E A4 00  movss   xmm0, dword ptr [rbx+rax*4+0A42ED0h]
0000000180366A33  8B 83 08 2F A8 00           mov     eax, [rbx+0A82F08h]
0000000180366A39  03 C1                       add     eax, ecx
0000000180366A3B  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180366A3F  0F B7 C0                    movzx   eax, ax
0000000180366A42  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180366A46  F3 0F 11 94 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm2
0000000180366A4F  F3 0F 10 8B E0 2C A4 00     movss   xmm1, dword ptr [rbx+0A42CE0h]
0000000180366A57  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
0000000180366A5D  0F 28 D9                    movaps  xmm3, xmm1
0000000180366A60  8B 83 14 2F A8 00           mov     eax, [rbx+0A82F14h]
0000000180366A66  03 C1                       add     eax, ecx
0000000180366A68  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180366A6C  0F B7 C0                    movzx   eax, ax
0000000180366A6F  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180366A73  F3 0F 10 84 83 D0 2E A4 00  movss   xmm0, dword ptr [rbx+rax*4+0A42ED0h]
0000000180366A7C  8B 83 10 2F A8 00           mov     eax, [rbx+0A82F10h]
0000000180366A82  03 C1                       add     eax, ecx
0000000180366A84  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180366A88  0F B7 C0                    movzx   eax, ax
0000000180366A8B  F3 0F 5C D9                 subss   xmm3, xmm1
0000000180366A8F  F3 0F 11 9C 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm3
0000000180366A98  F3 0F 10 93 E0 2C A4 00     movss   xmm2, dword ptr [rbx+0A42CE0h]
0000000180366AA0  8B 83 1C 2F A8 00           mov     eax, [rbx+0A82F1Ch]
0000000180366AA6  0F 28 E2                    movaps  xmm4, xmm2
0000000180366AA9  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
0000000180366AAF  03 C1                       add     eax, ecx
0000000180366AB1  F3 0F 59 E3                 mulss   xmm4, xmm3
0000000180366AB5  0F B7 C0                    movzx   eax, ax
0000000180366AB8  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180366ABC  F3 0F 10 84 83 D0 2E A4 00  movss   xmm0, dword ptr [rbx+rax*4+0A42ED0h]
0000000180366AC5  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180366AC9  F3 0F 59 25 3B E5 77 00     mulss   xmm4, cs:dword_180AE500C
0000000180366AD1  0F 28 CC                    movaps  xmm1, xmm4
0000000180366AD4  8B 83 18 2F A8 00           mov     eax, [rbx+0A82F18h]
0000000180366ADA  F3 0F 5C CA                 subss   xmm1, xmm2
0000000180366ADE  03 C1                       add     eax, ecx
0000000180366AE0  0F 28 D4                    movaps  xmm2, xmm4
0000000180366AE3  0F B7 C0                    movzx   eax, ax
0000000180366AE6  F3 0F 58 8B 30 2C A4 00     addss   xmm1, dword ptr [rbx+0A42C30h]
0000000180366AEE  F3 0F 11 8C 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm1
0000000180366AF7  F3 0F 59 8B E0 2C A4 00     mulss   xmm1, dword ptr [rbx+0A42CE0h]
0000000180366AFF  8B 83 38 2F A8 00           mov     eax, [rbx+0A82F38h]
0000000180366B05  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
0000000180366B0B  0F B7 C0                    movzx   eax, ax
0000000180366B0E  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180366B12  F3 0F 11 8C 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm1
0000000180366B1B  8B 83 44 2F A8 00           mov     eax, [rbx+0A82F44h]
0000000180366B21  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
0000000180366B27  0F B7 C0                    movzx   eax, ax
0000000180366B2A  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
0000000180366B33  F3 0F 5C 8B 20 2C A4 00     subss   xmm1, dword ptr [rbx+0A42C20h]
0000000180366B3B  F3 0F 11 8B 30 2C A4 00     movss   dword ptr [rbx+0A42C30h], xmm1
0000000180366B43  F3 0F 59 8B E0 2D A4 00     mulss   xmm1, dword ptr [rbx+0A42DE0h]
0000000180366B4B  F3 0F 58 8B 20 2C A4 00     addss   xmm1, dword ptr [rbx+0A42C20h]
0000000180366B53  F3 0F 11 8B 20 2C A4 00     movss   dword ptr [rbx+0A42C20h], xmm1
0000000180366B5B  F3 0F 59 8B 00 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E00h]
0000000180366B63  F3 0F 10 83 F0 2D A4 00     movss   xmm0, dword ptr [rbx+0A42DF0h]
0000000180366B6B  F3 0F 59 83 30 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42C30h]
0000000180366B73  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180366B77  F3 0F 11 8B 30 2C A4 00     movss   dword ptr [rbx+0A42C30h], xmm1
0000000180366B7F  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
0000000180366B85  8B 83 24 2F A8 00           mov     eax, [rbx+0A82F24h]
0000000180366B8B  03 C1                       add     eax, ecx
0000000180366B8D  0F B7 C0                    movzx   eax, ax
0000000180366B90  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
0000000180366B99  8B 83 20 2F A8 00           mov     eax, [rbx+0A82F20h]
0000000180366B9F  0F 28 C1                    movaps  xmm0, xmm1
0000000180366BA2  F3 0F 59 83 E0 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42CE0h]
0000000180366BAA  03 C1                       add     eax, ecx
0000000180366BAC  0F B7 C0                    movzx   eax, ax
0000000180366BAF  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180366BB3  F3 0F 58 93 50 2C A4 00     addss   xmm2, dword ptr [rbx+0A42C50h]
0000000180366BBB  F3 0F 11 94 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm2
0000000180366BC4  F3 0F 59 93 E0 2C A4 00     mulss   xmm2, dword ptr [rbx+0A42CE0h]
0000000180366BCC  8B 83 48 2F A8 00           mov     eax, [rbx+0A82F48h]
0000000180366BD2  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
0000000180366BD8  0F B7 C0                    movzx   eax, ax
0000000180366BDB  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180366BDF  F3 0F 11 94 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm2
0000000180366BE8  0F 28 D4                    movaps  xmm2, xmm4
0000000180366BEB  8B 83 54 2F A8 00           mov     eax, [rbx+0A82F54h]
0000000180366BF1  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
0000000180366BF7  0F B7 C0                    movzx   eax, ax
0000000180366BFA  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
0000000180366C03  F3 0F 5C 8B 40 2C A4 00     subss   xmm1, dword ptr [rbx+0A42C40h]
0000000180366C0B  F3 0F 11 8B 50 2C A4 00     movss   dword ptr [rbx+0A42C50h], xmm1
0000000180366C13  F3 0F 59 8B 10 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E10h]
0000000180366C1B  F3 0F 58 8B 40 2C A4 00     addss   xmm1, dword ptr [rbx+0A42C40h]
0000000180366C23  F3 0F 11 8B 40 2C A4 00     movss   dword ptr [rbx+0A42C40h], xmm1
0000000180366C2B  F3 0F 10 83 20 2E A4 00     movss   xmm0, dword ptr [rbx+0A42E20h]
0000000180366C33  F3 0F 59 83 50 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42C50h]
0000000180366C3B  F3 0F 59 8B 30 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E30h]
0000000180366C43  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180366C47  F3 0F 11 83 50 2C A4 00     movss   dword ptr [rbx+0A42C50h], xmm0
0000000180366C4F  8B 83 2C 2F A8 00           mov     eax, [rbx+0A82F2Ch]
0000000180366C55  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
0000000180366C5B  03 C1                       add     eax, ecx
0000000180366C5D  0F B7 C0                    movzx   eax, ax
0000000180366C60  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
0000000180366C69  8B 83 28 2F A8 00           mov     eax, [rbx+0A82F28h]
0000000180366C6F  0F 28 C1                    movaps  xmm0, xmm1
0000000180366C72  F3 0F 59 83 E0 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42CE0h]
0000000180366C7A  03 C1                       add     eax, ecx
0000000180366C7C  0F B7 C0                    movzx   eax, ax
0000000180366C7F  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180366C83  F3 0F 58 93 70 2C A4 00     addss   xmm2, dword ptr [rbx+0A42C70h]
0000000180366C8B  F3 0F 11 94 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm2
0000000180366C94  8B 83 58 2F A8 00           mov     eax, [rbx+0A82F58h]
0000000180366C9A  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
0000000180366CA0  F3 0F 59 93 E0 2C A4 00     mulss   xmm2, dword ptr [rbx+0A42CE0h]
0000000180366CA8  0F B7 C0                    movzx   eax, ax
0000000180366CAB  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180366CAF  F3 0F 11 94 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm2
0000000180366CB8  8B 83 64 2F A8 00           mov     eax, [rbx+0A82F64h]
0000000180366CBE  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
0000000180366CC4  0F B7 C0                    movzx   eax, ax
0000000180366CC7  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
0000000180366CD0  F3 0F 5C 8B 60 2C A4 00     subss   xmm1, dword ptr [rbx+0A42C60h]
0000000180366CD8  F3 0F 11 8B 70 2C A4 00     movss   dword ptr [rbx+0A42C70h], xmm1
0000000180366CE0  F3 0F 59 8B 40 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E40h]
0000000180366CE8  F3 0F 58 8B 60 2C A4 00     addss   xmm1, dword ptr [rbx+0A42C60h]
0000000180366CF0  F3 0F 11 8B 60 2C A4 00     movss   dword ptr [rbx+0A42C60h], xmm1
0000000180366CF8  F3 0F 59 8B 60 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E60h]
0000000180366D00  F3 0F 10 83 50 2E A4 00     movss   xmm0, dword ptr [rbx+0A42E50h]
0000000180366D08  F3 0F 59 83 70 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42C70h]
0000000180366D10  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180366D14  F3 0F 11 83 70 2C A4 00     movss   dword ptr [rbx+0A42C70h], xmm0
0000000180366D1C  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
0000000180366D22  8B 83 34 2F A8 00           mov     eax, [rbx+0A82F34h]
0000000180366D28  03 C1                       add     eax, ecx
0000000180366D2A  0F B7 C0                    movzx   eax, ax
0000000180366D2D  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
0000000180366D36  8B 83 30 2F A8 00           mov     eax, [rbx+0A82F30h]
0000000180366D3C  0F 28 C1                    movaps  xmm0, xmm1
0000000180366D3F  F3 0F 59 83 E0 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42CE0h]
0000000180366D47  03 C1                       add     eax, ecx
0000000180366D49  0F B7 C0                    movzx   eax, ax
0000000180366D4C  F3 0F 5C E0                 subss   xmm4, xmm0
0000000180366D50  F3 0F 58 A3 90 2C A4 00     addss   xmm4, dword ptr [rbx+0A42C90h]
0000000180366D58  F3 0F 11 A4 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm4
0000000180366D61  F3 0F 59 A3 E0 2C A4 00     mulss   xmm4, dword ptr [rbx+0A42CE0h]
0000000180366D69  8B 83 68 2F A8 00           mov     eax, [rbx+0A82F68h]
0000000180366D6F  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
0000000180366D75  0F B7 C0                    movzx   eax, ax
0000000180366D78  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180366D7C  F3 0F 11 A4 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm4
0000000180366D85  8B 83 74 2F A8 00           mov     eax, [rbx+0A82F74h]
0000000180366D8B  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
0000000180366D91  0F B7 C0                    movzx   eax, ax
0000000180366D94  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
0000000180366D9D  F3 0F 5C 8B 80 2C A4 00     subss   xmm1, dword ptr [rbx+0A42C80h]
0000000180366DA5  F3 0F 11 8B 90 2C A4 00     movss   dword ptr [rbx+0A42C90h], xmm1
0000000180366DAD  F3 0F 59 8B 70 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E70h]
0000000180366DB5  F3 0F 58 8B 80 2C A4 00     addss   xmm1, dword ptr [rbx+0A42C80h]
0000000180366DBD  F3 0F 11 8B 80 2C A4 00     movss   dword ptr [rbx+0A42C80h], xmm1
0000000180366DC5  F3 0F 10 83 80 2E A4 00     movss   xmm0, dword ptr [rbx+0A42E80h]
0000000180366DCD  F3 0F 59 83 90 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42C90h]
0000000180366DD5  F3 0F 59 8B 90 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E90h]
0000000180366DDD  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180366DE1  F3 0F 11 83 90 2C A4 00     movss   dword ptr [rbx+0A42C90h], xmm0
0000000180366DE9  44 8B 83 B0 2E A4 00        mov     r8d, [rbx+0A42EB0h]
0000000180366DF0  8B 83 50 2F A8 00           mov     eax, [rbx+0A82F50h]
0000000180366DF6  F3 0F 10 93 10 2D A4 00     movss   xmm2, dword ptr [rbx+0A42D10h]
0000000180366DFE  41 03 C0                    add     eax, r8d
0000000180366E01  F3 0F 10 9B D0 2E A8 00     movss   xmm3, dword ptr [rbx+0A82ED0h]
0000000180366E09  F3 0F 10 AB 00 2D A4 00     movss   xmm5, dword ptr [rbx+0A42D00h]
0000000180366E11  F3 0F 10 A3 D0 2C A4 00     movss   xmm4, dword ptr [rbx+0A42CD0h]
0000000180366E19  0F 28 C5                    movaps  xmm0, xmm5
0000000180366E1C  0F B7 D0                    movzx   edx, ax
0000000180366E1F  8B 83 3C 2F A8 00           mov     eax, [rbx+0A82F3Ch]
0000000180366E25  41 03 C0                    add     eax, r8d
0000000180366E28  F3 0F 59 C7                 mulss   xmm0, xmm7
0000000180366E2C  0F B7 C8                    movzx   ecx, ax
0000000180366E2F  F3 44 0F 10 84 93 D0 2E A4 00  movss   xmm8, dword ptr [rbx+rdx*4+0A42ED0h]
0000000180366E39  8B 83 5C 2F A8 00           mov     eax, [rbx+0A82F5Ch]
0000000180366E3F  41 03 C0                    add     eax, r8d
0000000180366E42  F3 44 0F 58 84 8B D0 2E A4 00  addss   xmm8, dword ptr [rbx+rcx*4+0A42ED0h]
0000000180366E4C  0F B7 C8                    movzx   ecx, ax
0000000180366E4F  8B 83 70 2F A8 00           mov     eax, [rbx+0A82F70h]
0000000180366E55  41 03 C0                    add     eax, r8d
0000000180366E58  F3 44 0F 58 84 8B D0 2E A4 00  addss   xmm8, dword ptr [rbx+rcx*4+0A42ED0h]
0000000180366E62  0F B7 C8                    movzx   ecx, ax
0000000180366E65  8B 83 40 2F A8 00           mov     eax, [rbx+0A82F40h]
0000000180366E6B  41 03 C0                    add     eax, r8d
0000000180366E6E  0F B7 D0                    movzx   edx, ax
0000000180366E71  F3 44 0F 58 84 8B D0 2E A4 00  addss   xmm8, dword ptr [rbx+rcx*4+0A42ED0h]
0000000180366E7B  8B 83 4C 2F A8 00           mov     eax, [rbx+0A82F4Ch]
0000000180366E81  41 03 C0                    add     eax, r8d
0000000180366E84  F3 0F 10 BC 93 D0 2E A4 00  movss   xmm7, dword ptr [rbx+rdx*4+0A42ED0h]
0000000180366E8D  0F B7 C8                    movzx   ecx, ax
0000000180366E90  F3 44 0F 59 C2              mulss   xmm8, xmm2
0000000180366E95  F3 44 0F 59 05 FE E4 77 00  mulss   xmm8, cs:dword_180AE539C
0000000180366E9E  F3 44 0F 59 C3              mulss   xmm8, xmm3
0000000180366EA3  F3 44 0F 59 C4              mulss   xmm8, xmm4
0000000180366EA8  F3 44 0F 58 C0              addss   xmm8, xmm0
0000000180366EAD  F3 0F 58 BC 8B D0 2E A4 00  addss   xmm7, dword ptr [rbx+rcx*4+0A42ED0h]
0000000180366EB6  8B 83 60 2F A8 00           mov     eax, [rbx+0A82F60h]
0000000180366EBC  41 03 C0                    add     eax, r8d
0000000180366EBF  F3 0F 59 EE                 mulss   xmm5, xmm6
0000000180366EC3  0F B7 C8                    movzx   ecx, ax
0000000180366EC6  8B 83 6C 2F A8 00           mov     eax, [rbx+0A82F6Ch]
0000000180366ECC  41 03 C0                    add     eax, r8d
0000000180366ECF  F3 0F 58 BC 8B D0 2E A4 00  addss   xmm7, dword ptr [rbx+rcx*4+0A42ED0h]
0000000180366ED8  0F B7 C8                    movzx   ecx, ax
0000000180366EDB  F3 0F 58 BC 8B D0 2E A4 00  addss   xmm7, dword ptr [rbx+rcx*4+0A42ED0h]
0000000180366EE4  F3 0F 59 FA                 mulss   xmm7, xmm2
0000000180366EE8  F3 0F 59 3D AC E4 77 00     mulss   xmm7, cs:dword_180AE539C
0000000180366EF0  F3 0F 59 FB                 mulss   xmm7, xmm3
0000000180366EF4  F3 0F 59 FC                 mulss   xmm7, xmm4
0000000180366EF8  F3 0F 58 FD                 addss   xmm7, xmm5
0000000180366EFC  E9 D6 02 00 00              jmp     loc_1803671D7
0000000180366F01  44 0F 28 C7                 movaps  xmm8, xmm7
0000000180366F05  0F 28 FE                    movaps  xmm7, xmm6
0000000180366F08  39 B3 C0 2E A4 00           cmp     [rbx+0A42EC0h], esi
0000000180366F0E  0F 8E C3 02 00 00           jle     loc_1803671D7
0000000180366F14  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180366F18  0F 87 B9 02 00 00           ja      loc_1803671D7
0000000180366F1E  8B CE                       mov     ecx, esi
0000000180366F20  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
0000000180366F26  C1 E0 08                    shl     eax, 8
0000000180366F29  03 C1                       add     eax, ecx
0000000180366F2B  48 98                       cdqe
0000000180366F2D  89 B4 83 D0 2A A4 00        mov     [rbx+rax*4+0A42AD0h], esi
0000000180366F34  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
0000000180366F3A  C1 E0 08                    shl     eax, 8
0000000180366F3D  03 C1                       add     eax, ecx
0000000180366F3F  48 98                       cdqe
0000000180366F41  89 B4 83 D4 2A A4 00        mov     [rbx+rax*4+0A42AD4h], esi
0000000180366F48  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
0000000180366F4E  C1 E0 08                    shl     eax, 8
0000000180366F51  03 C1                       add     eax, ecx
0000000180366F53  48 98                       cdqe
0000000180366F55  89 B4 83 D8 2A A4 00        mov     [rbx+rax*4+0A42AD8h], esi
0000000180366F5C  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
0000000180366F62  C1 E0 08                    shl     eax, 8
0000000180366F65  03 C1                       add     eax, ecx
0000000180366F67  48 98                       cdqe
0000000180366F69  89 B4 83 DC 2A A4 00        mov     [rbx+rax*4+0A42ADCh], esi
0000000180366F70  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
0000000180366F76  C1 E0 08                    shl     eax, 8
0000000180366F79  03 C1                       add     eax, ecx
0000000180366F7B  48 98                       cdqe
0000000180366F7D  89 B4 83 E0 2A A4 00        mov     [rbx+rax*4+0A42AE0h], esi
0000000180366F84  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
0000000180366F8A  C1 E0 08                    shl     eax, 8
0000000180366F8D  03 C1                       add     eax, ecx
0000000180366F8F  48 98                       cdqe
0000000180366F91  89 B4 83 E4 2A A4 00        mov     [rbx+rax*4+0A42AE4h], esi
0000000180366F98  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
0000000180366F9E  C1 E0 08                    shl     eax, 8
0000000180366FA1  03 C1                       add     eax, ecx
0000000180366FA3  48 98                       cdqe
0000000180366FA5  89 B4 83 E8 2A A4 00        mov     [rbx+rax*4+0A42AE8h], esi
0000000180366FAC  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
0000000180366FB2  C1 E0 08                    shl     eax, 8
0000000180366FB5  03 C1                       add     eax, ecx
0000000180366FB7  83 C1 08                    add     ecx, 8
0000000180366FBA  48 98                       cdqe
0000000180366FBC  89 B4 83 EC 2A A4 00        mov     [rbx+rax*4+0A42AECh], esi
0000000180366FC3  81 F9 00 01 00 00           cmp     ecx, 100h
0000000180366FC9  0F 8C 51 FF FF FF           jl      loc_180366F20
0000000180366FCF  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
0000000180366FD5  FF C8                       dec     eax
0000000180366FD7  89 83 C0 2E A4 00           mov     [rbx+0A42EC0h], eax
0000000180366FDD  85 C0                       test    eax, eax
0000000180366FDF  0F 8F F2 01 00 00           jg      loc_1803671D7
0000000180366FE5  8B 83 80 2F A8 00           mov     eax, [rbx+0A82F80h]
0000000180366FEB  89 83 F0 2E A8 00           mov     [rbx+0A82EF0h], eax
0000000180366FF1  8B 83 84 2F A8 00           mov     eax, [rbx+0A82F84h]
0000000180366FF7  89 83 F4 2E A8 00           mov     [rbx+0A82EF4h], eax
0000000180366FFD  8B 83 88 2F A8 00           mov     eax, [rbx+0A82F88h]
0000000180367003  89 83 F8 2E A8 00           mov     [rbx+0A82EF8h], eax
0000000180367009  8B 83 8C 2F A8 00           mov     eax, [rbx+0A82F8Ch]
000000018036700F  89 83 FC 2E A8 00           mov     [rbx+0A82EFCh], eax
0000000180367015  8B 83 90 2F A8 00           mov     eax, [rbx+0A82F90h]
000000018036701B  89 83 00 2F A8 00           mov     [rbx+0A82F00h], eax
0000000180367021  8B 83 94 2F A8 00           mov     eax, [rbx+0A82F94h]
0000000180367027  89 83 04 2F A8 00           mov     [rbx+0A82F04h], eax
000000018036702D  8B 83 98 2F A8 00           mov     eax, [rbx+0A82F98h]
0000000180367033  89 83 08 2F A8 00           mov     [rbx+0A82F08h], eax
0000000180367039  8B 83 9C 2F A8 00           mov     eax, [rbx+0A82F9Ch]
000000018036703F  89 83 0C 2F A8 00           mov     [rbx+0A82F0Ch], eax
0000000180367045  8B 83 A0 2F A8 00           mov     eax, [rbx+0A82FA0h]
000000018036704B  89 83 10 2F A8 00           mov     [rbx+0A82F10h], eax
0000000180367051  8B 83 A4 2F A8 00           mov     eax, [rbx+0A82FA4h]
0000000180367057  89 83 14 2F A8 00           mov     [rbx+0A82F14h], eax
000000018036705D  8B 83 A8 2F A8 00           mov     eax, [rbx+0A82FA8h]
0000000180367063  89 83 18 2F A8 00           mov     [rbx+0A82F18h], eax
0000000180367069  8B 83 AC 2F A8 00           mov     eax, [rbx+0A82FACh]
000000018036706F  89 83 1C 2F A8 00           mov     [rbx+0A82F1Ch], eax
0000000180367075  8B 83 B0 2F A8 00           mov     eax, [rbx+0A82FB0h]
000000018036707B  89 83 20 2F A8 00           mov     [rbx+0A82F20h], eax
0000000180367081  8B 83 B4 2F A8 00           mov     eax, [rbx+0A82FB4h]
0000000180367087  89 83 24 2F A8 00           mov     [rbx+0A82F24h], eax
000000018036708D  8B 83 B8 2F A8 00           mov     eax, [rbx+0A82FB8h]
0000000180367093  89 83 28 2F A8 00           mov     [rbx+0A82F28h], eax
0000000180367099  8B 83 BC 2F A8 00           mov     eax, [rbx+0A82FBCh]
000000018036709F  89 83 2C 2F A8 00           mov     [rbx+0A82F2Ch], eax
00000001803670A5  8B 83 C0 2F A8 00           mov     eax, [rbx+0A82FC0h]
00000001803670AB  89 83 30 2F A8 00           mov     [rbx+0A82F30h], eax
00000001803670B1  8B 83 C4 2F A8 00           mov     eax, [rbx+0A82FC4h]
00000001803670B7  89 83 34 2F A8 00           mov     [rbx+0A82F34h], eax
00000001803670BD  8B 83 C8 2F A8 00           mov     eax, [rbx+0A82FC8h]
00000001803670C3  89 83 38 2F A8 00           mov     [rbx+0A82F38h], eax
00000001803670C9  8B 83 CC 2F A8 00           mov     eax, [rbx+0A82FCCh]
00000001803670CF  89 83 3C 2F A8 00           mov     [rbx+0A82F3Ch], eax
00000001803670D5  8B 83 D0 2F A8 00           mov     eax, [rbx+0A82FD0h]
00000001803670DB  89 83 40 2F A8 00           mov     [rbx+0A82F40h], eax
00000001803670E1  8B 83 D4 2F A8 00           mov     eax, [rbx+0A82FD4h]
00000001803670E7  89 83 44 2F A8 00           mov     [rbx+0A82F44h], eax
00000001803670ED  8B 83 D8 2F A8 00           mov     eax, [rbx+0A82FD8h]
00000001803670F3  89 83 48 2F A8 00           mov     [rbx+0A82F48h], eax
00000001803670F9  8B 83 DC 2F A8 00           mov     eax, [rbx+0A82FDCh]
00000001803670FF  89 83 4C 2F A8 00           mov     [rbx+0A82F4Ch], eax
0000000180367105  8B 83 E0 2F A8 00           mov     eax, [rbx+0A82FE0h]
000000018036710B  89 83 50 2F A8 00           mov     [rbx+0A82F50h], eax
0000000180367111  8B 83 E4 2F A8 00           mov     eax, [rbx+0A82FE4h]
0000000180367117  89 83 54 2F A8 00           mov     [rbx+0A82F54h], eax
000000018036711D  8B 83 E8 2F A8 00           mov     eax, [rbx+0A82FE8h]
0000000180367123  89 83 58 2F A8 00           mov     [rbx+0A82F58h], eax
0000000180367129  8B 83 EC 2F A8 00           mov     eax, [rbx+0A82FECh]
000000018036712F  89 83 5C 2F A8 00           mov     [rbx+0A82F5Ch], eax
0000000180367135  8B 83 F0 2F A8 00           mov     eax, [rbx+0A82FF0h]
000000018036713B  89 83 60 2F A8 00           mov     [rbx+0A82F60h], eax
0000000180367141  8B 83 F4 2F A8 00           mov     eax, [rbx+0A82FF4h]
0000000180367147  89 83 64 2F A8 00           mov     [rbx+0A82F64h], eax
000000018036714D  8B 83 F8 2F A8 00           mov     eax, [rbx+0A82FF8h]
0000000180367153  89 83 68 2F A8 00           mov     [rbx+0A82F68h], eax
0000000180367159  8B 83 FC 2F A8 00           mov     eax, [rbx+0A82FFCh]
000000018036715F  89 83 6C 2F A8 00           mov     [rbx+0A82F6Ch], eax
0000000180367165  8B 83 00 30 A8 00           mov     eax, [rbx+0A83000h]
000000018036716B  89 83 70 2F A8 00           mov     [rbx+0A82F70h], eax
0000000180367171  8B 83 04 30 A8 00           mov     eax, [rbx+0A83004h]
0000000180367177  89 83 74 2F A8 00           mov     [rbx+0A82F74h], eax
000000018036717D  89 B3 10 2C A4 00           mov     [rbx+0A42C10h], esi
0000000180367183  89 B3 00 2C A4 00           mov     [rbx+0A42C00h], esi
0000000180367189  89 B3 F0 2B A4 00           mov     [rbx+0A42BF0h], esi
000000018036718F  89 B3 E0 2B A4 00           mov     [rbx+0A42BE0h], esi
0000000180367195  89 B3 D0 2B A4 00           mov     [rbx+0A42BD0h], esi
000000018036719B  89 B3 90 2C A4 00           mov     [rbx+0A42C90h], esi
00000001803671A1  89 B3 80 2C A4 00           mov     [rbx+0A42C80h], esi
00000001803671A7  89 B3 70 2C A4 00           mov     [rbx+0A42C70h], esi
00000001803671AD  89 B3 60 2C A4 00           mov     [rbx+0A42C60h], esi
00000001803671B3  89 B3 50 2C A4 00           mov     [rbx+0A42C50h], esi
00000001803671B9  89 B3 40 2C A4 00           mov     [rbx+0A42C40h], esi
00000001803671BF  89 B3 30 2C A4 00           mov     [rbx+0A42C30h], esi
00000001803671C5  89 B3 20 2C A4 00           mov     [rbx+0A42C20h], esi
00000001803671CB  89 B3 B0 2C A4 00           mov     [rbx+0A42CB0h], esi
00000001803671D1  89 B3 A0 2C A4 00           mov     [rbx+0A42CA0h], esi
00000001803671D7  F3 0F 10 83 20 8B 01 00     movss   xmm0, dword ptr [rbx+18B20h]
00000001803671DF  8B 83 10 8B 01 00           mov     eax, [rbx+18B10h]
00000001803671E5  48 8B B4 24 D0 00 00 00     mov     rsi, [rsp+0C8h+arg_0]
00000001803671ED  89 83 30 8B 01 00           mov     [rbx+18B30h], eax
00000001803671F3  F3 0F 11 83 40 8B 01 00     movss   dword ptr [rbx+18B40h], xmm0
00000001803671FB  F3 0F 10 A3 30 8B 01 00     movss   xmm4, dword ptr [rbx+18B30h]
0000000180367203  0F 28 C4                    movaps  xmm0, xmm4
0000000180367206  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018036720A  F3 41 0F 59 C0              mulss   xmm0, xmm8
000000018036720F  F3 0F 11 83 50 8B 01 00     movss   dword ptr [rbx+18B50h], xmm0
0000000180367217  F3 0F 11 A3 60 8B 01 00     movss   dword ptr [rbx+18B60h], xmm4
000000018036721F  F3 0F 10 83 40 8B 01 00     movss   xmm0, dword ptr [rbx+18B40h]
0000000180367227  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018036722B  0F 28 E8                    movaps  xmm5, xmm0
000000018036722E  F3 0F 59 AB 50 8B 01 00     mulss   xmm5, dword ptr [rbx+18B50h]
0000000180367236  F3 0F 11 AB 70 8B 01 00     movss   dword ptr [rbx+18B70h], xmm5
000000018036723E  F3 0F 11 A3 80 8B 01 00     movss   dword ptr [rbx+18B80h], xmm4
0000000180367246  F3 0F 10 83 B0 8B 01 00     movss   xmm0, dword ptr [rbx+18BB0h]
000000018036724E  F3 0F 10 BB E0 8B 01 00     movss   xmm7, dword ptr [rbx+18BE0h]
0000000180367256  F3 0F 10 9B D0 8B 01 00     movss   xmm3, dword ptr [rbx+18BD0h]
000000018036725E  0F 28 CF                    movaps  xmm1, xmm7
0000000180367261  F3 44 0F 10 83 F0 8B 01 00  movss   xmm8, dword ptr [rbx+18BF0h]
000000018036726A  F3 44 0F 10 93 00 8C 01 00  movss   xmm10, dword ptr [rbx+18C00h]
0000000180367273  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180367277  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018036727B  41 0F 28 C0                 movaps  xmm0, xmm8
000000018036727F  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180367283  0F 28 D5                    movaps  xmm2, xmm5
0000000180367286  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018036728A  F3 0F 58 CB                 addss   xmm1, xmm3
000000018036728E  F3 0F 59 FC                 mulss   xmm7, xmm4
0000000180367292  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180367296  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018036729A  F3 0F 58 FB                 addss   xmm7, xmm3
000000018036729E  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803672A2  41 0F 28 C2                 movaps  xmm0, xmm10
00000001803672A6  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803672AA  F3 0F 59 D5                 mulss   xmm2, xmm5
00000001803672AE  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803672B2  F3 0F 10 83 50 8C 01 00     movss   xmm0, dword ptr [rbx+18C50h]
00000001803672BA  F3 0F 5C C5                 subss   xmm0, xmm5
00000001803672BE  0F 28 F2                    movaps  xmm6, xmm2
00000001803672C1  F3 0F 59 D5                 mulss   xmm2, xmm5
00000001803672C5  F3 0F 59 B3 10 8C 01 00     mulss   xmm6, dword ptr [rbx+18C10h]
00000001803672CD  41 0F 2F C5                 comiss  xmm0, xmm13
00000001803672D1  F3 0F 59 93 20 8C 01 00     mulss   xmm2, dword ptr [rbx+18C20h]
00000001803672D9  F3 0F 58 F1                 addss   xmm6, xmm1
00000001803672DD  0F 28 CC                    movaps  xmm1, xmm4
00000001803672E0  F3 0F 59 CC                 mulss   xmm1, xmm4
00000001803672E4  F3 0F 58 F2                 addss   xmm6, xmm2
00000001803672E8  77 08                       ja      short loc_1803672F2
00000001803672EA  F3 0F 10 B3 60 8C 01 00     movss   xmm6, dword ptr [rbx+18C60h]
00000001803672F2  F3 0F 10 83 30 8C 01 00     movss   xmm0, dword ptr [rbx+18C30h]
00000001803672FA  F3 44 0F 59 C1              mulss   xmm8, xmm1
00000001803672FF  F3 0F 5C C5                 subss   xmm0, xmm5
0000000180367303  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180367307  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018036730C  41 0F 2F C5                 comiss  xmm0, xmm13
0000000180367310  72 08                       jb      short loc_18036731A
0000000180367312  F3 0F 10 B3 40 8C 01 00     movss   xmm6, dword ptr [rbx+18C40h]
000000018036731A  F3 0F 59 B3 C0 8B 01 00     mulss   xmm6, dword ptr [rbx+18BC0h]
0000000180367322  F3 44 0F 59 D1              mulss   xmm10, xmm1
0000000180367327  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018036732B  F3 0F 11 B3 90 8B 01 00     movss   dword ptr [rbx+18B90h], xmm6
0000000180367333  F3 41 0F 58 FA              addss   xmm7, xmm10
0000000180367338  F3 0F 10 83 50 8C 01 00     movss   xmm0, dword ptr [rbx+18C50h]
0000000180367340  0F 28 D1                    movaps  xmm2, xmm1
0000000180367343  F3 0F 5C C4                 subss   xmm0, xmm4
0000000180367347  F3 0F 59 93 10 8C 01 00     mulss   xmm2, dword ptr [rbx+18C10h]
000000018036734F  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180367353  41 0F 2F C5                 comiss  xmm0, xmm13
0000000180367357  F3 0F 59 8B 20 8C 01 00     mulss   xmm1, dword ptr [rbx+18C20h]
000000018036735F  F3 0F 58 D7                 addss   xmm2, xmm7
0000000180367363  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180367367  77 08                       ja      short loc_180367371
0000000180367369  F3 0F 10 93 60 8C 01 00     movss   xmm2, dword ptr [rbx+18C60h]
0000000180367371  F3 0F 10 83 30 8C 01 00     movss   xmm0, dword ptr [rbx+18C30h]
0000000180367379  F3 0F 5C C4                 subss   xmm0, xmm4
000000018036737D  41 0F 2F C5                 comiss  xmm0, xmm13
0000000180367381  72 08                       jb      short loc_18036738B
0000000180367383  F3 0F 10 93 40 8C 01 00     movss   xmm2, dword ptr [rbx+18C40h]
000000018036738B  F3 0F 59 93 C0 8B 01 00     mulss   xmm2, dword ptr [rbx+18BC0h]
0000000180367393  F3 0F 11 93 A0 8B 01 00     movss   dword ptr [rbx+18BA0h], xmm2
000000018036739B  F3 0F 11 73 20              movss   dword ptr [rbx+20h], xmm6
00000001803673A0  F3 0F 11 53 24              movss   dword ptr [rbx+24h], xmm2
00000001803673A5  48 8B 83 88 00 00 00        mov     rax, [rbx+88h]
00000001803673AC  48 8B 48 70                 mov     rcx, [rax+70h]
00000001803673B0  8B 01                       mov     eax, [rcx]
00000001803673B2  83 F8 01                    cmp     eax, 1
00000001803673B5  0F 84 E0 13 00 00           jz      loc_18036879B
00000001803673BB  0F 8E 18 0E 00 00           jle     loc_1803681D9
00000001803673C1  83 F8 04                    cmp     eax, 4
00000001803673C4  0F 8E 5E 05 00 00           jle     loc_180367928
00000001803673CA  83 F8 05                    cmp     eax, 5
00000001803673CD  0F 85 06 0E 00 00           jnz     loc_1803681D9
00000001803673D3  8B 83 C0 76 01 00           mov     eax, [rbx+176C0h]
00000001803673D9  F3 0F 10 83 90 4A 01 00     movss   xmm0, dword ptr [rbx+14A90h]
00000001803673E1  89 83 D0 76 01 00           mov     [rbx+176D0h], eax
00000001803673E7  8B 83 B0 76 01 00           mov     eax, [rbx+176B0h]
00000001803673ED  89 83 C0 76 01 00           mov     [rbx+176C0h], eax
00000001803673F3  8B 83 60 77 01 00           mov     eax, [rbx+17760h]
00000001803673F9  89 83 70 77 01 00           mov     [rbx+17770h], eax
00000001803673FF  8B 83 50 77 01 00           mov     eax, [rbx+17750h]
0000000180367405  89 83 60 77 01 00           mov     [rbx+17760h], eax
000000018036740B  8B 83 40 77 01 00           mov     eax, [rbx+17740h]
0000000180367411  89 83 50 77 01 00           mov     [rbx+17750h], eax
0000000180367417  8B 83 30 77 01 00           mov     eax, [rbx+17730h]
000000018036741D  89 83 40 77 01 00           mov     [rbx+17740h], eax
0000000180367423  8B 83 20 77 01 00           mov     eax, [rbx+17720h]
0000000180367429  89 83 30 77 01 00           mov     [rbx+17730h], eax
000000018036742F  8B 83 10 77 01 00           mov     eax, [rbx+17710h]
0000000180367435  89 83 20 77 01 00           mov     [rbx+17720h], eax
000000018036743B  8B 83 00 77 01 00           mov     eax, [rbx+17700h]
0000000180367441  89 83 10 77 01 00           mov     [rbx+17710h], eax
0000000180367447  8B 83 F0 76 01 00           mov     eax, [rbx+176F0h]
000000018036744D  89 83 00 77 01 00           mov     [rbx+17700h], eax
0000000180367453  8B 83 E0 76 01 00           mov     eax, [rbx+176E0h]
0000000180367459  89 83 F0 76 01 00           mov     [rbx+176F0h], eax
000000018036745F  8B 83 80 77 01 00           mov     eax, [rbx+17780h]
0000000180367465  89 83 90 77 01 00           mov     [rbx+17790h], eax
000000018036746B  8B 83 A0 77 01 00           mov     eax, [rbx+177A0h]
0000000180367471  89 83 B0 77 01 00           mov     [rbx+177B0h], eax
0000000180367477  8B 83 C0 77 01 00           mov     eax, [rbx+177C0h]
000000018036747D  89 83 D0 77 01 00           mov     [rbx+177D0h], eax
0000000180367483  8B 83 F0 77 01 00           mov     eax, [rbx+177F0h]
0000000180367489  89 83 00 78 01 00           mov     [rbx+17800h], eax
000000018036748F  8B 83 E0 77 01 00           mov     eax, [rbx+177E0h]
0000000180367495  89 83 F0 77 01 00           mov     [rbx+177F0h], eax
000000018036749B  F3 0F 11 83 90 76 01 00     movss   dword ptr [rbx+17690h], xmm0
00000001803674A3  F3 0F 11 83 A0 76 01 00     movss   dword ptr [rbx+176A0h], xmm0
00000001803674AB  F3 0F 10 83 B0 77 01 00     movss   xmm0, dword ptr [rbx+177B0h]
00000001803674B3  F3 0F 58 83 90 77 01 00     addss   xmm0, dword ptr [rbx+17790h]
00000001803674BB  F3 0F 58 83 60 78 01 00     addss   xmm0, dword ptr [rbx+17860h]
00000001803674C3  E8 68 1A 00 00              call    sub_180368F30
00000001803674C8  0F 28 D0                    movaps  xmm2, xmm0
00000001803674CB  41 0F 2F D5                 comiss  xmm2, xmm13
00000001803674CF  F3 0F 11 93 A0 77 01 00     movss   dword ptr [rbx+177A0h], xmm2
00000001803674D7  F3 0F 10 83 10 7A 01 00     movss   xmm0, dword ptr [rbx+17A10h]
00000001803674DF  73 07                       jnb     short loc_1803674E8
00000001803674E1  0F 57 05 D8 E2 77 00        xorps   xmm0, cs:xmmword_180AE57C0
00000001803674E8  0F 54 15 A1 E2 77 00        andps   xmm2, cs:xmmword_180AE5790
00000001803674EF  F3 0F 11 83 80 77 01 00     movss   dword ptr [rbx+17780h], xmm0
00000001803674F7  F3 0F 11 93 10 78 01 00     movss   dword ptr [rbx+17810h], xmm2
00000001803674FF  F3 0F 59 93 70 78 01 00     mulss   xmm2, dword ptr [rbx+17870h]
0000000180367507  F3 0F 10 A3 A0 76 01 00     movss   xmm4, dword ptr [rbx+176A0h]
000000018036750F  F3 0F 59 93 20 7A 01 00     mulss   xmm2, dword ptr [rbx+17A20h]
0000000180367517  F3 0F 58 93 30 7A 01 00     addss   xmm2, dword ptr [rbx+17A30h]
000000018036751F  F3 0F 11 93 20 78 01 00     movss   dword ptr [rbx+17820h], xmm2
0000000180367527  F3 0F 58 A3 90 76 01 00     addss   xmm4, dword ptr [rbx+17690h]
000000018036752F  F3 0F 10 9B A0 78 01 00     movss   xmm3, dword ptr [rbx+178A0h]
0000000180367537  F3 0F 10 93 90 78 01 00     movss   xmm2, dword ptr [rbx+17890h]
000000018036753F  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180367543  F3 0F 59 25 C1 DA 77 00     mulss   xmm4, cs:dword_180AE500C
000000018036754B  F3 0F 11 A3 B0 76 01 00     movss   dword ptr [rbx+176B0h], xmm4
0000000180367553  F3 0F 10 8B C0 78 01 00     movss   xmm1, dword ptr [rbx+178C0h]
000000018036755B  F3 0F 59 8B C0 76 01 00     mulss   xmm1, dword ptr [rbx+176C0h]
0000000180367563  F3 0F 10 83 D0 78 01 00     movss   xmm0, dword ptr [rbx+178D0h]
000000018036756B  F3 0F 59 83 D0 76 01 00     mulss   xmm0, dword ptr [rbx+176D0h]
0000000180367573  F3 0F 59 A3 B0 78 01 00     mulss   xmm4, dword ptr [rbx+178B0h]
000000018036757B  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036757F  F3 0F 10 83 F0 77 01 00     movss   xmm0, dword ptr [rbx+177F0h]
0000000180367587  F3 0F 58 CC                 addss   xmm1, xmm4
000000018036758B  F3 0F 11 8B C0 76 01 00     movss   dword ptr [rbx+176C0h], xmm1
0000000180367593  F3 0F 58 83 40 7A 01 00     addss   xmm0, dword ptr [rbx+17A40h]
000000018036759B  F3 0F 59 D1                 mulss   xmm2, xmm1
000000018036759F  F3 0F 11 93 B0 8A 01 00     movss   dword ptr [rbx+18AB0h], xmm2
00000001803675A7  F3 0F 10 8B 50 7A 01 00     movss   xmm1, dword ptr [rbx+17A50h]
00000001803675AF  F3 0F 5D C8                 minss   xmm1, xmm0
00000001803675B3  F3 0F 59 CB                 mulss   xmm1, xmm3
00000001803675B7  F3 0F 11 8B E0 77 01 00     movss   dword ptr [rbx+177E0h], xmm1
00000001803675BF  F3 0F 5C 8B D0 77 01 00     subss   xmm1, dword ptr [rbx+177D0h]
00000001803675C7  41 0F 2F CD                 comiss  xmm1, xmm13
00000001803675CB  73 0A                       jnb     short loc_1803675D7
00000001803675CD  F3 0F 10 83 70 7A 01 00     movss   xmm0, dword ptr [rbx+17A70h]
00000001803675D5  EB 08                       jmp     short loc_1803675DF
00000001803675D7  F3 0F 10 83 60 7A 01 00     movss   xmm0, dword ptr [rbx+17A60h]
00000001803675DF  F3 0F 58 83 00 78 01 00     addss   xmm0, dword ptr [rbx+17800h]
00000001803675E7  F3 0F 10 93 50 78 01 00     movss   xmm2, dword ptr [rbx+17850h]
00000001803675EF  F3 0F 10 9B D0 77 01 00     movss   xmm3, dword ptr [rbx+177D0h]
00000001803675F7  0F 28 CA                    movaps  xmm1, xmm2
00000001803675FA  F3 0F 5C CB                 subss   xmm1, xmm3
00000001803675FE  41 0F 2F C5                 comiss  xmm0, xmm13
0000000180367602  76 04                       jbe     short loc_180367608
0000000180367604  44 0F 5A F8                 cvtps2pd xmm15, xmm0
0000000180367608  F3 0F 59 8B 80 78 01 00     mulss   xmm1, dword ptr [rbx+17880h]
0000000180367610  0F 57 C0                    xorps   xmm0, xmm0
0000000180367613  F2 41 0F 5A C7              cvtsd2ss xmm0, xmm15
0000000180367618  F3 0F 58 CB                 addss   xmm1, xmm3
000000018036761C  41 0F 2F C4                 comiss  xmm0, xmm12
0000000180367620  72 09                       jb      short loc_18036762B
0000000180367622  44 0F 28 E0                 movaps  xmm12, xmm0
0000000180367626  F3 45 0F 5D E6              minss   xmm12, xmm14
000000018036762B  F3 44 0F 59 A3 A0 78 01 00  mulss   xmm12, dword ptr [rbx+178A0h]
0000000180367634  0F 28 C1                    movaps  xmm0, xmm1
0000000180367637  F3 0F 5C C3                 subss   xmm0, xmm3
000000018036763B  F3 44 0F 11 A3 F0 77 01 00  movss   dword ptr [rbx+177F0h], xmm12
0000000180367644  41 0F 2E C5                 ucomiss xmm0, xmm13
0000000180367648  74 03                       jz      short loc_18036764D
000000018036764A  0F 28 D1                    movaps  xmm2, xmm1
000000018036764D  F3 0F 11 93 C0 77 01 00     movss   dword ptr [rbx+177C0h], xmm2
0000000180367655  F3 0F 58 93 20 78 01 00     addss   xmm2, dword ptr [rbx+17820h]
000000018036765D  8B 83 A0 8A 01 00           mov     eax, [rbx+18AA0h]
0000000180367663  0F 28 C2                    movaps  xmm0, xmm2
0000000180367666  F3 41 0F 59 D1              mulss   xmm2, xmm9
000000018036766B  F3 41 0F 59 C3              mulss   xmm0, xmm11
0000000180367670  0F 5A CA                    cvtps2pd xmm1, xmm2
0000000180367673  F3 0F 2C D0                 cvttss2si edx, xmm0
0000000180367677  2B C2                       sub     eax, edx
0000000180367679  48 63 C8                    movsxd  rcx, eax
000000018036767C  48 63 83 A4 8A 01 00        movsxd  rax, dword ptr [rbx+18AA4h]
0000000180367683  48 FF C1                    inc     rcx
0000000180367686  48 FF C8                    dec     rax
0000000180367689  48 23 C8                    and     rcx, rax
000000018036768C  8B 84 8B A0 7A 01 00        mov     eax, [rbx+rcx*4+17AA0h]
0000000180367693  89 83 C0 8A 01 00           mov     [rbx+18AC0h], eax
0000000180367699  8B 83 A0 8A 01 00           mov     eax, [rbx+18AA0h]
000000018036769F  2B C2                       sub     eax, edx
00000001803676A1  48 63 C8                    movsxd  rcx, eax
00000001803676A4  48 63 83 A4 8A 01 00        movsxd  rax, dword ptr [rbx+18AA4h]
00000001803676AB  48 83 C1 02                 add     rcx, 2
00000001803676AF  48 FF C8                    dec     rax
00000001803676B2  48 23 C8                    and     rcx, rax
00000001803676B5  8B 84 8B A0 7A 01 00        mov     eax, [rbx+rcx*4+17AA0h]
00000001803676BC  89 83 C4 8A 01 00           mov     [rbx+18AC4h], eax
00000001803676C2  F3 0F 2C C2                 cvttss2si eax, xmm2
00000001803676C6  66 0F 6E C0                 movd    xmm0, eax
00000001803676CA  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00000001803676CE  F2 0F 5C C8                 subsd   xmm1, xmm0
00000001803676D2  66 0F 5A D1                 cvtpd2ps xmm2, xmm1
00000001803676D6  F3 0F 11 93 C8 8A 01 00     movss   dword ptr [rbx+18AC8h], xmm2
00000001803676DE  0F 28 CA                    movaps  xmm1, xmm2
00000001803676E1  F3 0F 59 8B C4 8A 01 00     mulss   xmm1, dword ptr [rbx+18AC4h]
00000001803676E9  F3 0F 10 83 C0 8A 01 00     movss   xmm0, dword ptr [rbx+18AC0h]
00000001803676F1  F3 0F 59 D0                 mulss   xmm2, xmm0
00000001803676F5  F3 0F 5C CA                 subss   xmm1, xmm2
00000001803676F9  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803676FD  F3 0F 59 8B 00 78 01 00     mulss   xmm1, dword ptr [rbx+17800h]
0000000180367705  F3 0F 11 8B E0 76 01 00     movss   dword ptr [rbx+176E0h], xmm1
000000018036770D  F3 0F 59 8B E0 78 01 00     mulss   xmm1, dword ptr [rbx+178E0h]
0000000180367715  F3 0F 10 93 00 79 01 00     movss   xmm2, dword ptr [rbx+17900h]
000000018036771D  F3 0F 59 93 00 77 01 00     mulss   xmm2, dword ptr [rbx+17700h]
0000000180367725  F3 0F 10 A3 10 77 01 00     movss   xmm4, dword ptr [rbx+17710h]
000000018036772D  F3 0F 10 83 F0 78 01 00     movss   xmm0, dword ptr [rbx+178F0h]
0000000180367735  F3 0F 59 83 F0 76 01 00     mulss   xmm0, dword ptr [rbx+176F0h]
000000018036773D  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180367741  F3 0F 10 83 20 79 01 00     movss   xmm0, dword ptr [rbx+17920h]
0000000180367749  F3 0F 59 83 20 77 01 00     mulss   xmm0, dword ptr [rbx+17720h]
0000000180367751  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180367755  0F 28 CC                    movaps  xmm1, xmm4
0000000180367758  F3 0F 59 8B 10 79 01 00     mulss   xmm1, dword ptr [rbx+17910h]
0000000180367760  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180367764  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180367768  F3 0F 11 93 00 77 01 00     movss   dword ptr [rbx+17700h], xmm2
0000000180367770  0F 28 CA                    movaps  xmm1, xmm2
0000000180367773  F3 0F 59 A3 40 79 01 00     mulss   xmm4, dword ptr [rbx+17940h]
000000018036777B  F3 0F 59 8B 30 79 01 00     mulss   xmm1, dword ptr [rbx+17930h]
0000000180367783  F3 0F 10 83 50 79 01 00     movss   xmm0, dword ptr [rbx+17950h]
000000018036778B  F3 0F 59 83 30 77 01 00     mulss   xmm0, dword ptr [rbx+17730h]
0000000180367793  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180367797  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036779B  F3 0F 11 A3 20 77 01 00     movss   dword ptr [rbx+17720h], xmm4
00000001803677A3  F3 0F 59 A3 70 79 01 00     mulss   xmm4, dword ptr [rbx+17970h]
00000001803677AB  F3 0F 10 8B 40 77 01 00     movss   xmm1, dword ptr [rbx+17740h]
00000001803677B3  F3 0F 59 93 60 79 01 00     mulss   xmm2, dword ptr [rbx+17960h]
00000001803677BB  F3 0F 58 E2                 addss   xmm4, xmm2
00000001803677BF  F3 0F 10 93 50 77 01 00     movss   xmm2, dword ptr [rbx+17750h]
00000001803677C7  0F 28 DC                    movaps  xmm3, xmm4
00000001803677CA  F3 0F 5C D9                 subss   xmm3, xmm1
00000001803677CE  0F 28 C3                    movaps  xmm0, xmm3
00000001803677D1  F3 0F 59 83 80 79 01 00     mulss   xmm0, dword ptr [rbx+17980h]
00000001803677D9  F3 0F 58 C1                 addss   xmm0, xmm1
00000001803677DD  F3 0F 11 83 30 77 01 00     movss   dword ptr [rbx+17730h], xmm0
00000001803677E5  F3 0F 59 9B A0 79 01 00     mulss   xmm3, dword ptr [rbx+179A0h]
00000001803677ED  F3 0F 59 A3 90 79 01 00     mulss   xmm4, dword ptr [rbx+17990h]
00000001803677F5  F3 0F 10 8B 10 78 01 00     movss   xmm1, dword ptr [rbx+17810h]
00000001803677FD  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180367801  F3 0F 5C DA                 subss   xmm3, xmm2
0000000180367805  0F 28 C3                    movaps  xmm0, xmm3
0000000180367808  F3 0F 59 83 B0 79 01 00     mulss   xmm0, dword ptr [rbx+179B0h]
0000000180367810  F3 0F 58 C2                 addss   xmm0, xmm2
0000000180367814  F3 0F 10 93 60 77 01 00     movss   xmm2, dword ptr [rbx+17760h]
000000018036781C  F3 41 0F 5C CE              subss   xmm1, xmm14
0000000180367821  F3 0F 11 83 40 77 01 00     movss   dword ptr [rbx+17740h], xmm0
0000000180367829  F3 0F 5C DA                 subss   xmm3, xmm2
000000018036782D  F3 0F 59 C9                 mulss   xmm1, xmm1
0000000180367831  F3 0F 11 9B 60 77 01 00     movss   dword ptr [rbx+17760h], xmm3
0000000180367839  0F 28 C3                    movaps  xmm0, xmm3
000000018036783C  F3 0F 59 83 C0 79 01 00     mulss   xmm0, dword ptr [rbx+179C0h]
0000000180367844  F3 0F 10 AB 70 77 01 00     movss   xmm5, dword ptr [rbx+17770h]
000000018036784C  F3 44 0F 5C F1              subss   xmm14, xmm1
0000000180367851  F3 0F 58 C2                 addss   xmm0, xmm2
0000000180367855  F3 44 0F 59 B3 00 7A 01 00  mulss   xmm14, dword ptr [rbx+17A00h]
000000018036785E  F3 0F 11 83 50 77 01 00     movss   dword ptr [rbx+17750h], xmm0
0000000180367866  F3 0F 59 AB E0 79 01 00     mulss   xmm5, dword ptr [rbx+179E0h]
000000018036786E  F3 0F 59 9B D0 79 01 00     mulss   xmm3, dword ptr [rbx+179D0h]
0000000180367876  F3 0F 10 93 90 76 01 00     movss   xmm2, dword ptr [rbx+17690h]
000000018036787E  F3 0F 10 A3 A0 76 01 00     movss   xmm4, dword ptr [rbx+176A0h]
0000000180367886  F3 44 0F 58 B3 F0 79 01 00  addss   xmm14, dword ptr [rbx+179F0h]
000000018036788F  F3 0F 10 8B 80 7A 01 00     movss   xmm1, dword ptr [rbx+17A80h]
0000000180367897  F3 0F 58 EB                 addss   xmm5, xmm3
000000018036789B  F3 0F 59 8B B0 76 01 00     mulss   xmm1, dword ptr [rbx+176B0h]
00000001803678A3  F3 0F 10 9B 90 78 01 00     movss   xmm3, dword ptr [rbx+17890h]
00000001803678AB  0F 28 C3                    movaps  xmm0, xmm3
00000001803678AE  F3 41 0F 59 EE              mulss   xmm5, xmm14
00000001803678B3  F3 0F 59 CB                 mulss   xmm1, xmm3
00000001803678B7  F3 0F 59 AB 90 7A 01 00     mulss   xmm5, dword ptr [rbx+17A90h]
00000001803678BF  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803678C3  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803678C7  F3 0F 5C C8                 subss   xmm1, xmm0
00000001803678CB  F3 0F 5C EB                 subss   xmm5, xmm3
00000001803678CF  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803678D3  F3 0F 58 EC                 addss   xmm5, xmm4
00000001803678D7  F3 0F 11 8B 30 78 01 00     movss   dword ptr [rbx+17830h], xmm1
00000001803678DF  F3 0F 11 AB 40 78 01 00     movss   dword ptr [rbx+17840h], xmm5
00000001803678E7  8B 8B A4 8A 01 00           mov     ecx, [rbx+18AA4h]
00000001803678ED  8B 83 A0 8A 01 00           mov     eax, [rbx+18AA0h]
00000001803678F3  FF C9                       dec     ecx
00000001803678F5  FF C8                       dec     eax
00000001803678F7  23 C8                       and     ecx, eax
00000001803678F9  89 8B A0 8A 01 00           mov     [rbx+18AA0h], ecx
00000001803678FF  8B 83 B0 8A 01 00           mov     eax, [rbx+18AB0h]
0000000180367905  48 63 C9                    movsxd  rcx, ecx
0000000180367908  89 84 8B A0 7A 01 00        mov     [rbx+rcx*4+17AA0h], eax
000000018036790F  8B 83 30 78 01 00           mov     eax, [rbx+17830h]
0000000180367915  89 83 C0 4A 01 00           mov     [rbx+14AC0h], eax
000000018036791B  F3 0F 10 83 40 78 01 00     movss   xmm0, dword ptr [rbx+17840h]
0000000180367923  E9 B9 13 00 00              jmp     loc_180368CE1
0000000180367928  8B 83 80 61 01 00           mov     eax, [rbx+16180h]
000000018036792E  F3 0F 10 83 90 4A 01 00     movss   xmm0, dword ptr [rbx+14A90h]
0000000180367936  89 83 90 61 01 00           mov     [rbx+16190h], eax
000000018036793C  8B 83 70 61 01 00           mov     eax, [rbx+16170h]
0000000180367942  89 83 80 61 01 00           mov     [rbx+16180h], eax
0000000180367948  8B 83 60 61 01 00           mov     eax, [rbx+16160h]
000000018036794E  89 83 70 61 01 00           mov     [rbx+16170h], eax
0000000180367954  8B 83 50 61 01 00           mov     eax, [rbx+16150h]
000000018036795A  89 83 60 61 01 00           mov     [rbx+16160h], eax
0000000180367960  8B 83 40 61 01 00           mov     eax, [rbx+16140h]
0000000180367966  89 83 50 61 01 00           mov     [rbx+16150h], eax
000000018036796C  8B 83 30 61 01 00           mov     eax, [rbx+16130h]
0000000180367972  89 83 40 61 01 00           mov     [rbx+16140h], eax
0000000180367978  8B 83 20 61 01 00           mov     eax, [rbx+16120h]
000000018036797E  89 83 30 61 01 00           mov     [rbx+16130h], eax
0000000180367984  8B 83 B0 61 01 00           mov     eax, [rbx+161B0h]
000000018036798A  89 83 C0 61 01 00           mov     [rbx+161C0h], eax
0000000180367990  8B 83 A0 61 01 00           mov     eax, [rbx+161A0h]
0000000180367996  89 83 B0 61 01 00           mov     [rbx+161B0h], eax
000000018036799C  8B 83 E0 61 01 00           mov     eax, [rbx+161E0h]
00000001803679A2  89 83 F0 61 01 00           mov     [rbx+161F0h], eax
00000001803679A8  8B 83 D0 61 01 00           mov     eax, [rbx+161D0h]
00000001803679AE  89 83 E0 61 01 00           mov     [rbx+161E0h], eax
00000001803679B4  8B 83 00 62 01 00           mov     eax, [rbx+16200h]
00000001803679BA  89 83 10 62 01 00           mov     [rbx+16210h], eax
00000001803679C0  8B 83 20 62 01 00           mov     eax, [rbx+16220h]
00000001803679C6  89 83 30 62 01 00           mov     [rbx+16230h], eax
00000001803679CC  8B 83 40 62 01 00           mov     eax, [rbx+16240h]
00000001803679D2  89 83 50 62 01 00           mov     [rbx+16250h], eax
00000001803679D8  8B 83 70 62 01 00           mov     eax, [rbx+16270h]
00000001803679DE  89 83 80 62 01 00           mov     [rbx+16280h], eax
00000001803679E4  8B 83 60 62 01 00           mov     eax, [rbx+16260h]
00000001803679EA  89 83 70 62 01 00           mov     [rbx+16270h], eax
00000001803679F0  8B 83 D0 62 01 00           mov     eax, [rbx+162D0h]
00000001803679F6  89 83 E0 62 01 00           mov     [rbx+162E0h], eax
00000001803679FC  8B 83 30 63 01 00           mov     eax, [rbx+16330h]
0000000180367A02  89 83 40 63 01 00           mov     [rbx+16340h], eax
0000000180367A08  8B 83 20 63 01 00           mov     eax, [rbx+16320h]
0000000180367A0E  89 83 30 63 01 00           mov     [rbx+16330h], eax
0000000180367A14  8B 83 10 63 01 00           mov     eax, [rbx+16310h]
0000000180367A1A  89 83 20 63 01 00           mov     [rbx+16320h], eax
0000000180367A20  8B 83 00 63 01 00           mov     eax, [rbx+16300h]
0000000180367A26  89 83 10 63 01 00           mov     [rbx+16310h], eax
0000000180367A2C  8B 83 F0 62 01 00           mov     eax, [rbx+162F0h]
0000000180367A32  89 83 00 63 01 00           mov     [rbx+16300h], eax
0000000180367A38  8B 83 90 63 01 00           mov     eax, [rbx+16390h]
0000000180367A3E  89 83 A0 63 01 00           mov     [rbx+163A0h], eax
0000000180367A44  8B 83 80 63 01 00           mov     eax, [rbx+16380h]
0000000180367A4A  89 83 90 63 01 00           mov     [rbx+16390h], eax
0000000180367A50  8B 83 70 63 01 00           mov     eax, [rbx+16370h]
0000000180367A56  89 83 80 63 01 00           mov     [rbx+16380h], eax
0000000180367A5C  8B 83 60 63 01 00           mov     eax, [rbx+16360h]
0000000180367A62  89 83 70 63 01 00           mov     [rbx+16370h], eax
0000000180367A68  8B 83 50 63 01 00           mov     eax, [rbx+16350h]
0000000180367A6E  89 83 60 63 01 00           mov     [rbx+16360h], eax
0000000180367A74  F3 0F 11 83 00 61 01 00     movss   dword ptr [rbx+16100h], xmm0
0000000180367A7C  F3 0F 11 83 10 61 01 00     movss   dword ptr [rbx+16110h], xmm0
0000000180367A84  F3 0F 10 83 30 62 01 00     movss   xmm0, dword ptr [rbx+16230h]
0000000180367A8C  F3 0F 58 83 10 62 01 00     addss   xmm0, dword ptr [rbx+16210h]
0000000180367A94  F3 0F 58 83 10 64 01 00     addss   xmm0, dword ptr [rbx+16410h]
0000000180367A9C  E8 8F 14 00 00              call    sub_180368F30
0000000180367AA1  41 0F 2F C5                 comiss  xmm0, xmm13
0000000180367AA5  F3 44 0F 10 15 12 DD 77 00  movss   xmm10, dword ptr cs:xmmword_180AE57C0
0000000180367AAE  F3 0F 11 83 20 62 01 00     movss   dword ptr [rbx+16220h], xmm0
0000000180367AB6  F3 0F 10 8B 40 65 01 00     movss   xmm1, dword ptr [rbx+16540h]
0000000180367ABE  73 04                       jnb     short loc_180367AC4
0000000180367AC0  41 0F 57 CA                 xorps   xmm1, xmm10
0000000180367AC4  F3 0F 10 83 E0 62 01 00     movss   xmm0, dword ptr [rbx+162E0h]
0000000180367ACC  44 0F 28 C8                 movaps  xmm9, xmm0
0000000180367AD0  F3 0F 11 8B 00 62 01 00     movss   dword ptr [rbx+16200h], xmm1
0000000180367AD8  F3 44 0F 59 8B B0 65 01 00  mulss   xmm9, dword ptr [rbx+165B0h]
0000000180367AE1  41 0F 57 C2                 xorps   xmm0, xmm10
0000000180367AE5  F3 44 0F 11 8B 50 63 01 00  movss   dword ptr [rbx+16350h], xmm9
0000000180367AEE  E8 6D 12 00 00              call    sub_180368D60
0000000180367AF3  0F 28 F8                    movaps  xmm7, xmm0
0000000180367AF6  41 0F 57 C2                 xorps   xmm0, xmm10
0000000180367AFA  F3 0F 59 BB B0 65 01 00     mulss   xmm7, dword ptr [rbx+165B0h]
0000000180367B02  F3 0F 11 BB F0 62 01 00     movss   dword ptr [rbx+162F0h], xmm7
0000000180367B0A  E8 51 12 00 00              call    sub_180368D60
0000000180367B0F  F3 0F 11 83 D0 62 01 00     movss   dword ptr [rbx+162D0h], xmm0
0000000180367B17  F3 0F 10 8B E0 65 01 00     movss   xmm1, dword ptr [rbx+165E0h]
0000000180367B1F  F3 0F 10 93 10 63 01 00     movss   xmm2, dword ptr [rbx+16310h]
0000000180367B27  0F 28 C1                    movaps  xmm0, xmm1
0000000180367B2A  F3 0F 59 83 00 63 01 00     mulss   xmm0, dword ptr [rbx+16300h]
0000000180367B32  F3 0F 59 8B 60 63 01 00     mulss   xmm1, dword ptr [rbx+16360h]
0000000180367B3A  F3 44 0F 10 9B D0 65 01 00  movss   xmm11, dword ptr [rbx+165D0h]
0000000180367B43  41 0F 28 E3                 movaps  xmm4, xmm11
0000000180367B47  F3 45 0F 59 D9              mulss   xmm11, xmm9
0000000180367B4C  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180367B50  F3 0F 10 BB 70 63 01 00     movss   xmm7, dword ptr [rbx+16370h]
0000000180367B58  F3 44 0F 58 D9              addss   xmm11, xmm1
0000000180367B5D  F3 0F 10 8B F0 65 01 00     movss   xmm1, dword ptr [rbx+165F0h]
0000000180367B65  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180367B69  0F 28 C1                    movaps  xmm0, xmm1
0000000180367B6C  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180367B70  F3 0F 59 CF                 mulss   xmm1, xmm7
0000000180367B74  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180367B78  F3 44 0F 58 D9              addss   xmm11, xmm1
0000000180367B7D  F3 0F 11 A3 00 63 01 00     movss   dword ptr [rbx+16300h], xmm4
0000000180367B85  F3 44 0F 11 9B 60 63 01 00  movss   dword ptr [rbx+16360h], xmm11
0000000180367B8E  F3 0F 10 9B 10 66 01 00     movss   xmm3, dword ptr [rbx+16610h]
0000000180367B96  F3 0F 10 AB 20 66 01 00     movss   xmm5, dword ptr [rbx+16620h]
0000000180367B9E  0F 28 C3                    movaps  xmm0, xmm3
0000000180367BA1  F3 44 0F 10 83 40 66 01 00  movss   xmm8, dword ptr [rbx+16640h]
0000000180367BAA  0F 28 CD                    movaps  xmm1, xmm5
0000000180367BAD  F3 0F 59 8B 20 63 01 00     mulss   xmm1, dword ptr [rbx+16320h]
0000000180367BB5  F3 44 0F 10 93 00 66 01 00  movss   xmm10, dword ptr [rbx+16600h]
0000000180367BBE  F3 0F 59 AB 80 63 01 00     mulss   xmm5, dword ptr [rbx+16380h]
0000000180367BC6  45 0F 28 CA                 movaps  xmm9, xmm10
0000000180367BCA  F3 0F 10 B3 30 66 01 00     movss   xmm6, dword ptr [rbx+16630h]
0000000180367BD2  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180367BD6  F3 44 0F 59 CC              mulss   xmm9, xmm4
0000000180367BDB  F3 45 0F 59 D3              mulss   xmm10, xmm11
0000000180367BE0  F3 44 0F 58 C8              addss   xmm9, xmm0
0000000180367BE5  F3 0F 59 DF                 mulss   xmm3, xmm7
0000000180367BE9  0F 28 C6                    movaps  xmm0, xmm6
0000000180367BEC  F3 0F 59 B3 90 63 01 00     mulss   xmm6, dword ptr [rbx+16390h]
0000000180367BF4  F3 0F 59 83 30 63 01 00     mulss   xmm0, dword ptr [rbx+16330h]
0000000180367BFC  F3 44 0F 58 D3              addss   xmm10, xmm3
0000000180367C01  F3 44 0F 58 C9              addss   xmm9, xmm1
0000000180367C06  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180367C0A  F3 0F 59 8B 40 63 01 00     mulss   xmm1, dword ptr [rbx+16340h]
0000000180367C12  F3 44 0F 59 83 A0 63 01 00  mulss   xmm8, dword ptr [rbx+163A0h]
0000000180367C1B  F3 44 0F 58 D5              addss   xmm10, xmm5
0000000180367C20  F3 44 0F 58 C8              addss   xmm9, xmm0
0000000180367C25  F3 0F 10 83 20 62 01 00     movss   xmm0, dword ptr [rbx+16220h]
0000000180367C2D  0F 28 F8                    movaps  xmm7, xmm0
0000000180367C30  0F 54 3D 59 DB 77 00        andps   xmm7, cs:xmmword_180AE5790
0000000180367C37  F3 44 0F 58 D6              addss   xmm10, xmm6
0000000180367C3C  F3 44 0F 58 C9              addss   xmm9, xmm1
0000000180367C41  F3 45 0F 58 D0              addss   xmm10, xmm8
0000000180367C46  F3 44 0F 11 8B 20 63 01 00  movss   dword ptr [rbx+16320h], xmm9
0000000180367C4F  F3 44 0F 11 93 80 63 01 00  movss   dword ptr [rbx+16380h], xmm10
0000000180367C58  F3 0F 11 BB 90 62 01 00     movss   dword ptr [rbx+16290h], xmm7
0000000180367C60  F3 0F 58 83 20 64 01 00     addss   xmm0, dword ptr [rbx+16420h]
0000000180367C68  F3 44 0F 10 83 30 64 01 00  movss   xmm8, dword ptr [rbx+16430h]
0000000180367C71  E8 BA 12 00 00              call    sub_180368F30
0000000180367C76  0F 54 05 13 DB 77 00        andps   xmm0, cs:xmmword_180AE5790
0000000180367C7D  F3 0F 11 83 A0 62 01 00     movss   dword ptr [rbx+162A0h], xmm0
0000000180367C85  F3 0F 10 8B 50 65 01 00     movss   xmm1, dword ptr [rbx+16550h]
0000000180367C8D  F3 0F 10 93 60 65 01 00     movss   xmm2, dword ptr [rbx+16560h]
0000000180367C95  F3 0F 10 A3 10 61 01 00     movss   xmm4, dword ptr [rbx+16110h]
0000000180367C9D  F3 41 0F 59 F8              mulss   xmm7, xmm8
0000000180367CA2  F3 0F 59 F9                 mulss   xmm7, xmm1
0000000180367CA6  F3 0F 58 FA                 addss   xmm7, xmm2
0000000180367CAA  F3 0F 11 BB B0 62 01 00     movss   dword ptr [rbx+162B0h], xmm7
0000000180367CB2  F3 44 0F 59 83 00 64 01 00  mulss   xmm8, dword ptr [rbx+16400h]
0000000180367CBB  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180367CC0  F3 44 0F 59 C1              mulss   xmm8, xmm1
0000000180367CC5  F3 44 0F 58 C2              addss   xmm8, xmm2
0000000180367CCA  F3 44 0F 11 83 C0 62 01 00  movss   dword ptr [rbx+162C0h], xmm8
0000000180367CD3  F3 0F 58 A3 00 61 01 00     addss   xmm4, dword ptr [rbx+16100h]
0000000180367CDB  F3 0F 59 25 29 D3 77 00     mulss   xmm4, cs:dword_180AE500C
0000000180367CE3  F3 0F 11 A3 20 61 01 00     movss   dword ptr [rbx+16120h], xmm4
0000000180367CEB  F3 0F 10 9B 50 61 01 00     movss   xmm3, dword ptr [rbx+16150h]
0000000180367CF3  F3 0F 10 93 30 61 01 00     movss   xmm2, dword ptr [rbx+16130h]
0000000180367CFB  F3 0F 59 93 B0 64 01 00     mulss   xmm2, dword ptr [rbx+164B0h]
0000000180367D03  F3 0F 10 83 C0 64 01 00     movss   xmm0, dword ptr [rbx+164C0h]
0000000180367D0B  F3 0F 59 83 40 61 01 00     mulss   xmm0, dword ptr [rbx+16140h]
0000000180367D13  F3 0F 10 AB 60 61 01 00     movss   xmm5, dword ptr [rbx+16160h]
0000000180367D1B  F3 0F 59 A3 A0 64 01 00     mulss   xmm4, dword ptr [rbx+164A0h]
0000000180367D23  0F 28 CD                    movaps  xmm1, xmm5
0000000180367D26  F3 0F 59 8B E0 64 01 00     mulss   xmm1, dword ptr [rbx+164E0h]
0000000180367D2E  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180367D32  0F 28 C3                    movaps  xmm0, xmm3
0000000180367D35  F3 0F 59 83 D0 64 01 00     mulss   xmm0, dword ptr [rbx+164D0h]
0000000180367D3D  F3 0F 58 D4                 addss   xmm2, xmm4
0000000180367D41  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180367D45  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180367D49  F3 0F 11 93 40 61 01 00     movss   dword ptr [rbx+16140h], xmm2
0000000180367D51  F3 0F 59 9B B0 64 01 00     mulss   xmm3, dword ptr [rbx+164B0h]
0000000180367D59  F3 0F 59 AB C0 64 01 00     mulss   xmm5, dword ptr [rbx+164C0h]
0000000180367D61  F3 0F 10 83 80 61 01 00     movss   xmm0, dword ptr [rbx+16180h]
0000000180367D69  F3 0F 59 83 E0 64 01 00     mulss   xmm0, dword ptr [rbx+164E0h]
0000000180367D71  F3 0F 59 93 A0 64 01 00     mulss   xmm2, dword ptr [rbx+164A0h]
0000000180367D79  F3 0F 58 EB                 addss   xmm5, xmm3
0000000180367D7D  F3 0F 10 9B 70 61 01 00     movss   xmm3, dword ptr [rbx+16170h]
0000000180367D85  0F 28 CB                    movaps  xmm1, xmm3
0000000180367D88  F3 0F 59 8B D0 64 01 00     mulss   xmm1, dword ptr [rbx+164D0h]
0000000180367D90  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180367D94  F3 0F 10 93 90 64 01 00     movss   xmm2, dword ptr [rbx+16490h]
0000000180367D9C  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180367DA0  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180367DA4  F3 0F 10 8B 80 64 01 00     movss   xmm1, dword ptr [rbx+16480h]
0000000180367DAC  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180367DB0  F3 0F 11 AB 60 61 01 00     movss   dword ptr [rbx+16160h], xmm5
0000000180367DB8  F3 0F 10 83 10 65 01 00     movss   xmm0, dword ptr [rbx+16510h]
0000000180367DC0  F3 0F 59 83 90 61 01 00     mulss   xmm0, dword ptr [rbx+16190h]
0000000180367DC8  F3 0F 59 9B 00 65 01 00     mulss   xmm3, dword ptr [rbx+16500h]
0000000180367DD0  F3 0F 59 AB F0 64 01 00     mulss   xmm5, dword ptr [rbx+164F0h]
0000000180367DD8  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180367DDC  F3 0F 10 83 70 62 01 00     movss   xmm0, dword ptr [rbx+16270h]
0000000180367DE4  F3 0F 58 DD                 addss   xmm3, xmm5
0000000180367DE8  F3 0F 59 CB                 mulss   xmm1, xmm3
0000000180367DEC  F3 0F 11 9B 80 61 01 00     movss   dword ptr [rbx+16180h], xmm3
0000000180367DF4  F3 0F 58 83 70 65 01 00     addss   xmm0, dword ptr [rbx+16570h]
0000000180367DFC  F3 0F 11 8B 60 76 01 00     movss   dword ptr [rbx+17660h], xmm1
0000000180367E04  F3 0F 10 8B 80 65 01 00     movss   xmm1, dword ptr [rbx+16580h]
0000000180367E0C  F3 0F 5D C8                 minss   xmm1, xmm0
0000000180367E10  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180367E14  F3 0F 11 8B 60 62 01 00     movss   dword ptr [rbx+16260h], xmm1
0000000180367E1C  F3 0F 5C 8B 50 62 01 00     subss   xmm1, dword ptr [rbx+16250h]
0000000180367E24  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180367E28  73 0A                       jnb     short loc_180367E34
0000000180367E2A  F3 0F 10 83 A0 65 01 00     movss   xmm0, dword ptr [rbx+165A0h]
0000000180367E32  EB 08                       jmp     short loc_180367E3C
0000000180367E34  F3 0F 10 83 90 65 01 00     movss   xmm0, dword ptr [rbx+16590h]
0000000180367E3C  F3 0F 58 83 80 62 01 00     addss   xmm0, dword ptr [rbx+16280h]
0000000180367E44  F3 0F 10 93 F0 63 01 00     movss   xmm2, dword ptr [rbx+163F0h]
0000000180367E4C  F3 0F 10 9B 50 62 01 00     movss   xmm3, dword ptr [rbx+16250h]
0000000180367E54  0F 28 CA                    movaps  xmm1, xmm2
0000000180367E57  F3 0F 5C CB                 subss   xmm1, xmm3
0000000180367E5B  41 0F 2F C5                 comiss  xmm0, xmm13
0000000180367E5F  76 04                       jbe     short loc_180367E65
0000000180367E61  44 0F 5A F8                 cvtps2pd xmm15, xmm0
0000000180367E65  F3 0F 59 8B 70 64 01 00     mulss   xmm1, dword ptr [rbx+16470h]
0000000180367E6D  0F 57 C0                    xorps   xmm0, xmm0
0000000180367E70  F2 41 0F 5A C7              cvtsd2ss xmm0, xmm15
0000000180367E75  F3 0F 58 CB                 addss   xmm1, xmm3
0000000180367E79  41 0F 2F C4                 comiss  xmm0, xmm12
0000000180367E7D  72 09                       jb      short loc_180367E88
0000000180367E7F  44 0F 28 E0                 movaps  xmm12, xmm0
0000000180367E83  F3 45 0F 5D E6              minss   xmm12, xmm14
0000000180367E88  F3 44 0F 59 A3 90 64 01 00  mulss   xmm12, dword ptr [rbx+16490h]
0000000180367E91  0F 28 C1                    movaps  xmm0, xmm1
0000000180367E94  F3 0F 5C C3                 subss   xmm0, xmm3
0000000180367E98  F3 44 0F 11 A3 70 62 01 00  movss   dword ptr [rbx+16270h], xmm12
0000000180367EA1  41 0F 2E C5                 ucomiss xmm0, xmm13
0000000180367EA5  74 03                       jz      short loc_180367EAA
0000000180367EA7  0F 28 D1                    movaps  xmm2, xmm1
0000000180367EAA  F3 0F 11 93 40 62 01 00     movss   dword ptr [rbx+16240h], xmm2
0000000180367EB2  0F 28 E2                    movaps  xmm4, xmm2
0000000180367EB5  F3 0F 58 93 B0 62 01 00     addss   xmm2, dword ptr [rbx+162B0h]
0000000180367EBD  8B 83 50 76 01 00           mov     eax, [rbx+17650h]
0000000180367EC3  0F 28 C2                    movaps  xmm0, xmm2
0000000180367EC6  F3 0F 59 15 D2 2D 62 00     mulss   xmm2, cs:dword_18098ACA0
0000000180367ECE  F3 0F 59 05 E2 2D 62 00     mulss   xmm0, cs:dword_18098ACB8
0000000180367ED6  0F 5A CA                    cvtps2pd xmm1, xmm2
0000000180367ED9  F3 0F 2C D0                 cvttss2si edx, xmm0
0000000180367EDD  2B C2                       sub     eax, edx
0000000180367EDF  48 63 C8                    movsxd  rcx, eax
0000000180367EE2  48 63 83 54 76 01 00        movsxd  rax, dword ptr [rbx+17654h]
0000000180367EE9  48 FF C1                    inc     rcx
0000000180367EEC  48 FF C8                    dec     rax
0000000180367EEF  48 23 C8                    and     rcx, rax
0000000180367EF2  8B 84 8B 50 66 01 00        mov     eax, [rbx+rcx*4+16650h]
0000000180367EF9  89 83 70 76 01 00           mov     [rbx+17670h], eax
0000000180367EFF  8B 83 50 76 01 00           mov     eax, [rbx+17650h]
0000000180367F05  2B C2                       sub     eax, edx
0000000180367F07  48 63 C8                    movsxd  rcx, eax
0000000180367F0A  48 63 83 54 76 01 00        movsxd  rax, dword ptr [rbx+17654h]
0000000180367F11  48 83 C1 02                 add     rcx, 2
0000000180367F15  48 FF C8                    dec     rax
0000000180367F18  48 23 C8                    and     rcx, rax
0000000180367F1B  8B 84 8B 50 66 01 00        mov     eax, [rbx+rcx*4+16650h]
0000000180367F22  89 83 74 76 01 00           mov     [rbx+17674h], eax
0000000180367F28  F3 0F 2C C2                 cvttss2si eax, xmm2
0000000180367F2C  66 0F 6E C0                 movd    xmm0, eax
0000000180367F30  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
0000000180367F34  F2 0F 5C C8                 subsd   xmm1, xmm0
0000000180367F38  66 0F 5A D1                 cvtpd2ps xmm2, xmm1
0000000180367F3C  F3 0F 11 93 78 76 01 00     movss   dword ptr [rbx+17678h], xmm2
0000000180367F44  0F 28 C2                    movaps  xmm0, xmm2
0000000180367F47  F3 0F 59 83 74 76 01 00     mulss   xmm0, dword ptr [rbx+17674h]
0000000180367F4F  8B 83 50 76 01 00           mov     eax, [rbx+17650h]
0000000180367F55  F3 0F 58 A3 C0 62 01 00     addss   xmm4, dword ptr [rbx+162C0h]
0000000180367F5D  F3 44 0F 10 8B 70 76 01 00  movss   xmm9, dword ptr [rbx+17670h]
0000000180367F66  F3 41 0F 59 D1              mulss   xmm2, xmm9
0000000180367F6B  F3 0F 5C C2                 subss   xmm0, xmm2
0000000180367F6F  F3 44 0F 58 C8              addss   xmm9, xmm0
0000000180367F74  0F 28 C4                    movaps  xmm0, xmm4
0000000180367F77  F3 0F 59 05 39 2D 62 00     mulss   xmm0, cs:dword_18098ACB8
0000000180367F7F  F3 0F 59 25 19 2D 62 00     mulss   xmm4, cs:dword_18098ACA0
0000000180367F87  F3 0F 2C D0                 cvttss2si edx, xmm0
0000000180367F8B  0F 5A CC                    cvtps2pd xmm1, xmm4
0000000180367F8E  2B C2                       sub     eax, edx
0000000180367F90  48 63 C8                    movsxd  rcx, eax
0000000180367F93  48 63 83 54 76 01 00        movsxd  rax, dword ptr [rbx+17654h]
0000000180367F9A  48 FF C1                    inc     rcx
0000000180367F9D  48 FF C8                    dec     rax
0000000180367FA0  48 23 C8                    and     rcx, rax
0000000180367FA3  8B 84 8B 50 66 01 00        mov     eax, [rbx+rcx*4+16650h]
0000000180367FAA  89 83 80 76 01 00           mov     [rbx+17680h], eax
0000000180367FB0  8B 83 50 76 01 00           mov     eax, [rbx+17650h]
0000000180367FB6  2B C2                       sub     eax, edx
0000000180367FB8  48 63 C8                    movsxd  rcx, eax
0000000180367FBB  48 63 83 54 76 01 00        movsxd  rax, dword ptr [rbx+17654h]
0000000180367FC2  48 83 C1 02                 add     rcx, 2
0000000180367FC6  48 FF C8                    dec     rax
0000000180367FC9  48 23 C8                    and     rcx, rax
0000000180367FCC  8B 84 8B 50 66 01 00        mov     eax, [rbx+rcx*4+16650h]
0000000180367FD3  89 83 84 76 01 00           mov     [rbx+17684h], eax
0000000180367FD9  F3 0F 2C C4                 cvttss2si eax, xmm4
0000000180367FDD  66 0F 6E C0                 movd    xmm0, eax
0000000180367FE1  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
0000000180367FE5  F2 0F 5C C8                 subsd   xmm1, xmm0
0000000180367FE9  66 0F 5A D1                 cvtpd2ps xmm2, xmm1
0000000180367FED  F3 0F 11 93 88 76 01 00     movss   dword ptr [rbx+17688h], xmm2
0000000180367FF5  44 0F 28 C2                 movaps  xmm8, xmm2
0000000180367FF9  F3 0F 10 83 80 76 01 00     movss   xmm0, dword ptr [rbx+17680h]
0000000180368001  F3 44 0F 59 83 84 76 01 00  mulss   xmm8, dword ptr [rbx+17684h]
000000018036800A  F3 0F 10 9B 30 65 01 00     movss   xmm3, dword ptr [rbx+16530h]
0000000180368012  F3 0F 10 8B B0 61 01 00     movss   xmm1, dword ptr [rbx+161B0h]
000000018036801A  F3 0F 10 B3 C0 61 01 00     movss   xmm6, dword ptr [rbx+161C0h]
0000000180368022  F3 0F 10 A3 E0 61 01 00     movss   xmm4, dword ptr [rbx+161E0h]
000000018036802A  F3 0F 10 BB F0 61 01 00     movss   xmm7, dword ptr [rbx+161F0h]
0000000180368032  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180368036  F3 44 0F 5C C2              subss   xmm8, xmm2
000000018036803B  F3 0F 10 93 20 65 01 00     movss   xmm2, dword ptr [rbx+16520h]
0000000180368043  F3 44 0F 58 C0              addss   xmm8, xmm0
0000000180368048  0F 28 C3                    movaps  xmm0, xmm3
000000018036804B  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036804F  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180368053  F3 0F 58 C6                 addss   xmm0, xmm6
0000000180368057  F3 0F 58 DF                 addss   xmm3, xmm7
000000018036805B  F3 44 0F 5C C8              subss   xmm9, xmm0
0000000180368060  F3 44 0F 5C C3              subss   xmm8, xmm3
0000000180368065  F3 44 0F 59 CA              mulss   xmm9, xmm2
000000018036806A  F3 44 0F 59 C2              mulss   xmm8, xmm2
000000018036806F  F3 44 0F 58 C9              addss   xmm9, xmm1
0000000180368074  F3 44 0F 58 C4              addss   xmm8, xmm4
0000000180368079  F3 44 0F 11 8B A0 61 01 00  movss   dword ptr [rbx+161A0h], xmm9
0000000180368082  F3 44 0F 11 83 D0 61 01 00  movss   dword ptr [rbx+161D0h], xmm8
000000018036808B  F3 0F 10 A3 20 65 01 00     movss   xmm4, dword ptr [rbx+16520h]
0000000180368093  0F 28 EC                    movaps  xmm5, xmm4
0000000180368096  F3 41 0F 59 E0              mulss   xmm4, xmm8
000000018036809B  F3 41 0F 59 E9              mulss   xmm5, xmm9
00000001803680A0  F3 0F 58 E7                 addss   xmm4, xmm7
00000001803680A4  F3 0F 58 EE                 addss   xmm5, xmm6
00000001803680A8  F3 0F 11 AB B0 61 01 00     movss   dword ptr [rbx+161B0h], xmm5
00000001803680B0  F3 0F 11 A3 E0 61 01 00     movss   dword ptr [rbx+161E0h], xmm4
00000001803680B8  F3 0F 10 8B 40 64 01 00     movss   xmm1, dword ptr [rbx+16440h]
00000001803680C0  F3 0F 10 B3 C0 65 01 00     movss   xmm6, dword ptr [rbx+165C0h]
00000001803680C8  F3 0F 10 BB 80 62 01 00     movss   xmm7, dword ptr [rbx+16280h]
00000001803680D0  0F 28 C6                    movaps  xmm0, xmm6
00000001803680D3  F3 0F 58 83 A0 62 01 00     addss   xmm0, dword ptr [rbx+162A0h]
00000001803680DB  F3 0F 58 B3 90 62 01 00     addss   xmm6, dword ptr [rbx+16290h]
00000001803680E3  F3 0F 10 93 00 61 01 00     movss   xmm2, dword ptr [rbx+16100h]
00000001803680EB  F3 0F 59 83 20 63 01 00     mulss   xmm0, dword ptr [rbx+16320h]
00000001803680F3  F3 0F 59 B3 80 63 01 00     mulss   xmm6, dword ptr [rbx+16380h]
00000001803680FB  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803680FF  F3 0F 59 F1                 mulss   xmm6, xmm1
0000000180368103  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180368107  F3 0F 10 83 60 64 01 00     movss   xmm0, dword ptr [rbx+16460h]
000000018036810F  F3 0F 58 F4                 addss   xmm6, xmm4
0000000180368113  F3 0F 10 A3 50 64 01 00     movss   xmm4, dword ptr [rbx+16450h]
000000018036811B  F3 0F 59 F7                 mulss   xmm6, xmm7
000000018036811F  F3 0F 59 FD                 mulss   xmm7, xmm5
0000000180368123  F3 0F 10 AB 10 61 01 00     movss   xmm5, dword ptr [rbx+16110h]
000000018036812B  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018036812F  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180368133  0F 28 C4                    movaps  xmm0, xmm4
0000000180368136  F3 0F 11 B3 B0 63 01 00     movss   dword ptr [rbx+163B0h], xmm6
000000018036813E  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180368142  F3 0F 11 BB C0 63 01 00     movss   dword ptr [rbx+163C0h], xmm7
000000018036814A  F3 0F 10 9B 80 64 01 00     movss   xmm3, dword ptr [rbx+16480h]
0000000180368152  F3 44 0F 5C F3              subss   xmm14, xmm3
0000000180368157  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018036815B  0F 28 CB                    movaps  xmm1, xmm3
000000018036815E  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180368162  41 0F 28 C6                 movaps  xmm0, xmm14
0000000180368166  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018036816A  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036816E  F3 44 0F 59 F5              mulss   xmm14, xmm5
0000000180368173  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180368177  F3 41 0F 58 DE              addss   xmm3, xmm14
000000018036817C  F3 0F 58 8B B0 63 01 00     addss   xmm1, dword ptr [rbx+163B0h]
0000000180368184  F3 0F 58 DF                 addss   xmm3, xmm7
0000000180368188  F3 0F 11 8B D0 63 01 00     movss   dword ptr [rbx+163D0h], xmm1
0000000180368190  F3 0F 11 9B E0 63 01 00     movss   dword ptr [rbx+163E0h], xmm3
0000000180368198  8B 8B 54 76 01 00           mov     ecx, [rbx+17654h]
000000018036819E  8B 83 50 76 01 00           mov     eax, [rbx+17650h]
00000001803681A4  FF C9                       dec     ecx
00000001803681A6  FF C8                       dec     eax
00000001803681A8  23 C8                       and     ecx, eax
00000001803681AA  89 8B 50 76 01 00           mov     [rbx+17650h], ecx
00000001803681B0  8B 83 60 76 01 00           mov     eax, [rbx+17660h]
00000001803681B6  48 63 C9                    movsxd  rcx, ecx
00000001803681B9  89 84 8B 50 66 01 00        mov     [rbx+rcx*4+16650h], eax
00000001803681C0  8B 83 D0 63 01 00           mov     eax, [rbx+163D0h]
00000001803681C6  89 83 C0 4A 01 00           mov     [rbx+14AC0h], eax
00000001803681CC  F3 0F 10 83 E0 63 01 00     movss   xmm0, dword ptr [rbx+163E0h]
00000001803681D4  E9 08 0B 00 00              jmp     loc_180368CE1
00000001803681D9  F3 0F 10 93 90 4A 01 00     movss   xmm2, dword ptr [rbx+14A90h]
00000001803681E1  8B 83 50 4C 01 00           mov     eax, [rbx+14C50h]
00000001803681E7  89 83 60 4C 01 00           mov     [rbx+14C60h], eax
00000001803681ED  8B 83 40 4C 01 00           mov     eax, [rbx+14C40h]
00000001803681F3  89 83 50 4C 01 00           mov     [rbx+14C50h], eax
00000001803681F9  8B 83 30 4C 01 00           mov     eax, [rbx+14C30h]
00000001803681FF  89 83 40 4C 01 00           mov     [rbx+14C40h], eax
0000000180368205  8B 83 20 4C 01 00           mov     eax, [rbx+14C20h]
000000018036820B  89 83 30 4C 01 00           mov     [rbx+14C30h], eax
0000000180368211  8B 83 10 4C 01 00           mov     eax, [rbx+14C10h]
0000000180368217  89 83 20 4C 01 00           mov     [rbx+14C20h], eax
000000018036821D  8B 83 00 4C 01 00           mov     eax, [rbx+14C00h]
0000000180368223  89 83 10 4C 01 00           mov     [rbx+14C10h], eax
0000000180368229  8B 83 F0 4B 01 00           mov     eax, [rbx+14BF0h]
000000018036822F  89 83 00 4C 01 00           mov     [rbx+14C00h], eax
0000000180368235  8B 83 E0 4B 01 00           mov     eax, [rbx+14BE0h]
000000018036823B  89 83 F0 4B 01 00           mov     [rbx+14BF0h], eax
0000000180368241  8B 83 70 4C 01 00           mov     eax, [rbx+14C70h]
0000000180368247  89 83 80 4C 01 00           mov     [rbx+14C80h], eax
000000018036824D  8B 83 50 4E 01 00           mov     eax, [rbx+14E50h]
0000000180368253  89 83 60 4E 01 00           mov     [rbx+14E60h], eax
0000000180368259  8B 83 70 4E 01 00           mov     eax, [rbx+14E70h]
000000018036825F  89 83 80 4E 01 00           mov     [rbx+14E80h], eax
0000000180368265  8B 83 90 4E 01 00           mov     eax, [rbx+14E90h]
000000018036826B  89 83 A0 4E 01 00           mov     [rbx+14EA0h], eax
0000000180368271  8B 83 B0 4E 01 00           mov     eax, [rbx+14EB0h]
0000000180368277  89 83 C0 4E 01 00           mov     [rbx+14EC0h], eax
000000018036827D  8B 83 D0 4E 01 00           mov     eax, [rbx+14ED0h]
0000000180368283  89 83 E0 4E 01 00           mov     [rbx+14EE0h], eax
0000000180368289  F3 0F 11 93 A0 4B 01 00     movss   dword ptr [rbx+14BA0h], xmm2
0000000180368291  F3 0F 11 93 B0 4B 01 00     movss   dword ptr [rbx+14BB0h], xmm2
0000000180368299  F3 0F 58 D2                 addss   xmm2, xmm2
000000018036829D  F3 0F 10 8B 90 4C 01 00     movss   xmm1, dword ptr [rbx+14C90h]
00000001803682A5  F3 0F 10 BB 70 4D 01 00     movss   xmm7, dword ptr [rbx+14D70h]
00000001803682AD  0F 28 F1                    movaps  xmm6, xmm1
00000001803682B0  F3 0F 10 A3 F0 4B 01 00     movss   xmm4, dword ptr [rbx+14BF0h]
00000001803682B8  0F 28 E9                    movaps  xmm5, xmm1
00000001803682BB  F3 0F 59 AB 50 4D 01 00     mulss   xmm5, dword ptr [rbx+14D50h]
00000001803682C3  F3 0F 59 93 D0 4C 01 00     mulss   xmm2, dword ptr [rbx+14CD0h]
00000001803682CB  F3 44 0F 10 83 40 4E 01 00  movss   xmm8, dword ptr [rbx+14E40h]
00000001803682D4  F3 44 0F 58 83 80 4C 01 00  addss   xmm8, dword ptr [rbx+14C80h]
00000001803682DD  F3 0F 58 AB 40 4D 01 00     addss   xmm5, dword ptr [rbx+14D40h]
00000001803682E5  F3 0F 59 F1                 mulss   xmm6, xmm1
00000001803682E9  F3 44 0F 5D 83 C0 4C 01 00  minss   xmm8, dword ptr [rbx+14CC0h]
00000001803682F2  0F 28 C6                    movaps  xmm0, xmm6
00000001803682F5  F3 0F 59 F1                 mulss   xmm6, xmm1
00000001803682F9  F3 0F 59 83 60 4D 01 00     mulss   xmm0, dword ptr [rbx+14D60h]
0000000180368301  F3 0F 11 93 E0 4B 01 00     movss   dword ptr [rbx+14BE0h], xmm2
0000000180368309  F3 0F 59 A3 F0 4C 01 00     mulss   xmm4, dword ptr [rbx+14CF0h]
0000000180368311  F3 0F 59 93 E0 4C 01 00     mulss   xmm2, dword ptr [rbx+14CE0h]
0000000180368319  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036831D  F3 0F 10 9B 00 4C 01 00     movss   xmm3, dword ptr [rbx+14C00h]
0000000180368325  F3 0F 10 8B 10 4C 01 00     movss   xmm1, dword ptr [rbx+14C10h]
000000018036832D  0F 28 C3                    movaps  xmm0, xmm3
0000000180368330  F3 44 0F 11 83 70 4C 01 00  movss   dword ptr [rbx+14C70h], xmm8
0000000180368339  F3 0F 58 E2                 addss   xmm4, xmm2
000000018036833D  F3 0F 59 83 00 4D 01 00     mulss   xmm0, dword ptr [rbx+14D00h]
0000000180368345  F3 0F 59 8B 30 4D 01 00     mulss   xmm1, dword ptr [rbx+14D30h]
000000018036834D  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180368351  F3 0F 59 FE                 mulss   xmm7, xmm6
0000000180368355  F3 0F 58 FD                 addss   xmm7, xmm5
0000000180368359  F3 0F 11 A3 F0 4B 01 00     movss   dword ptr [rbx+14BF0h], xmm4
0000000180368361  0F 28 C4                    movaps  xmm0, xmm4
0000000180368364  F3 0F 59 83 10 4D 01 00     mulss   xmm0, dword ptr [rbx+14D10h]
000000018036836C  F3 0F 59 9B 20 4D 01 00     mulss   xmm3, dword ptr [rbx+14D20h]
0000000180368374  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180368378  F3 0F 58 D9                 addss   xmm3, xmm1
000000018036837C  F3 0F 11 9B 00 4C 01 00     movss   dword ptr [rbx+14C00h], xmm3
0000000180368384  F3 0F 58 BB 80 4D 01 00     addss   xmm7, dword ptr [rbx+14D80h]
000000018036838C  F3 0F 10 93 30 4C 01 00     movss   xmm2, dword ptr [rbx+14C30h]
0000000180368394  F3 0F 59 A3 90 4D 01 00     mulss   xmm4, dword ptr [rbx+14D90h]
000000018036839C  F3 0F 10 8B B0 4C 01 00     movss   xmm1, dword ptr [rbx+14CB0h]
00000001803683A4  F3 0F 59 FB                 mulss   xmm7, xmm3
00000001803683A8  F3 0F 58 FC                 addss   xmm7, xmm4
00000001803683AC  F3 0F 5C FA                 subss   xmm7, xmm2
00000001803683B0  F3 0F 11 BB 10 4C 01 00     movss   dword ptr [rbx+14C10h], xmm7
00000001803683B8  0F 28 C7                    movaps  xmm0, xmm7
00000001803683BB  F3 0F 59 83 A0 4D 01 00     mulss   xmm0, dword ptr [rbx+14DA0h]
00000001803683C3  F3 0F 58 C2                 addss   xmm0, xmm2
00000001803683C7  F3 0F 11 83 20 4C 01 00     movss   dword ptr [rbx+14C20h], xmm0
00000001803683CF  F3 44 0F 59 83 B0 4D 01 00  mulss   xmm8, dword ptr [rbx+14DB0h]
00000001803683D8  F3 44 0F 59 05 9B 28 62 00  mulss   xmm8, cs:dword_18098AC7C
00000001803683E1  F3 0F 10 A3 F0 4B 01 00     movss   xmm4, dword ptr [rbx+14BF0h]
00000001803683E9  F3 0F 59 CF                 mulss   xmm1, xmm7
00000001803683ED  F3 44 0F 58 C1              addss   xmm8, xmm1
00000001803683F2  41 0F 28 D0                 movaps  xmm2, xmm8
00000001803683F6  F3 0F 11 93 50 4E 01 00     movss   dword ptr [rbx+14E50h], xmm2
00000001803683FE  F3 0F 10 9B 20 4F 01 00     movss   xmm3, dword ptr [rbx+14F20h]
0000000180368406  F3 0F 10 8B 60 4E 01 00     movss   xmm1, dword ptr [rbx+14E60h]
000000018036840E  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180368412  41 0F 2F D4                 comiss  xmm2, xmm12
0000000180368416  73 06                       jnb     short loc_18036841E
0000000180368418  41 0F 28 D4                 movaps  xmm2, xmm12
000000018036841C  EB 05                       jmp     short loc_180368423
000000018036841E  F3 41 0F 5D D6              minss   xmm2, xmm14
0000000180368423  F3 44 0F 59 83 10 4F 01 00  mulss   xmm8, dword ptr [rbx+14F10h]
000000018036842C  0F 28 C1                    movaps  xmm0, xmm1
000000018036842F  F3 0F 59 83 00 4F 01 00     mulss   xmm0, dword ptr [rbx+14F00h]
0000000180368437  F3 44 0F 58 C0              addss   xmm8, xmm0
000000018036843C  0F 28 C2                    movaps  xmm0, xmm2
000000018036843F  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180368443  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180368447  F3 0F 59 93 30 4F 01 00     mulss   xmm2, dword ptr [rbx+14F30h]
000000018036844F  F3 0F 59 83 40 4F 01 00     mulss   xmm0, dword ptr [rbx+14F40h]
0000000180368457  F3 44 0F 59 C3              mulss   xmm8, xmm3
000000018036845C  F3 0F 58 C2                 addss   xmm0, xmm2
0000000180368460  45 0F 2F C4                 comiss  xmm8, xmm12
0000000180368464  F3 0F 11 83 70 4E 01 00     movss   dword ptr [rbx+14E70h], xmm0
000000018036846C  73 06                       jnb     short loc_180368474
000000018036846E  45 0F 28 C4                 movaps  xmm8, xmm12
0000000180368472  EB 05                       jmp     short loc_180368479
0000000180368474  F3 45 0F 5D C6              minss   xmm8, xmm14
0000000180368479  F3 0F 58 8B 50 4E 01 00     addss   xmm1, dword ptr [rbx+14E50h]
0000000180368481  F3 0F 10 93 60 4E 01 00     movss   xmm2, dword ptr [rbx+14E60h]
0000000180368489  41 0F 28 C0                 movaps  xmm0, xmm8
000000018036848D  F3 41 0F 59 C0              mulss   xmm0, xmm8
0000000180368492  F3 0F 59 8B F0 4E 01 00     mulss   xmm1, dword ptr [rbx+14EF0h]
000000018036849A  F3 41 0F 59 C0              mulss   xmm0, xmm8
000000018036849F  F3 44 0F 59 83 30 4F 01 00  mulss   xmm8, dword ptr [rbx+14F30h]
00000001803684A8  F3 0F 59 83 40 4F 01 00     mulss   xmm0, dword ptr [rbx+14F40h]
00000001803684B0  F3 0F 59 8B 20 4F 01 00     mulss   xmm1, dword ptr [rbx+14F20h]
00000001803684B8  F3 41 0F 58 C0              addss   xmm0, xmm8
00000001803684BD  41 0F 2F CC                 comiss  xmm1, xmm12
00000001803684C1  F3 0F 11 83 90 4E 01 00     movss   dword ptr [rbx+14E90h], xmm0
00000001803684C9  73 06                       jnb     short loc_1803684D1
00000001803684CB  41 0F 28 CC                 movaps  xmm1, xmm12
00000001803684CF  EB 05                       jmp     short loc_1803684D6
00000001803684D1  F3 41 0F 5D CE              minss   xmm1, xmm14
00000001803684D6  F3 0F 10 83 00 4F 01 00     movss   xmm0, dword ptr [rbx+14F00h]
00000001803684DE  F3 0F 59 83 50 4E 01 00     mulss   xmm0, dword ptr [rbx+14E50h]
00000001803684E6  F3 0F 59 93 10 4F 01 00     mulss   xmm2, dword ptr [rbx+14F10h]
00000001803684EE  F3 0F 10 9B 70 4E 01 00     movss   xmm3, dword ptr [rbx+14E70h]
00000001803684F6  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803684FA  0F 28 C1                    movaps  xmm0, xmm1
00000001803684FD  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180368501  F3 0F 59 93 20 4F 01 00     mulss   xmm2, dword ptr [rbx+14F20h]
0000000180368509  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036850D  41 0F 2F D4                 comiss  xmm2, xmm12
0000000180368511  F3 0F 59 83 40 4F 01 00     mulss   xmm0, dword ptr [rbx+14F40h]
0000000180368519  F3 0F 59 8B 30 4F 01 00     mulss   xmm1, dword ptr [rbx+14F30h]
0000000180368521  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180368525  F3 0F 11 83 B0 4E 01 00     movss   dword ptr [rbx+14EB0h], xmm0
000000018036852D  72 09                       jb      short loc_180368538
000000018036852F  44 0F 28 E2                 movaps  xmm12, xmm2
0000000180368533  F3 45 0F 5D E6              minss   xmm12, xmm14
0000000180368538  F3 0F 58 9B E0 4E 01 00     addss   xmm3, dword ptr [rbx+14EE0h]
0000000180368540  F3 0F 10 83 60 4F 01 00     movss   xmm0, dword ptr [rbx+14F60h]
0000000180368548  F3 0F 59 83 90 4E 01 00     mulss   xmm0, dword ptr [rbx+14E90h]
0000000180368550  F3 0F 10 8B C0 4E 01 00     movss   xmm1, dword ptr [rbx+14EC0h]
0000000180368558  F3 0F 59 9B 50 4F 01 00     mulss   xmm3, dword ptr [rbx+14F50h]
0000000180368560  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180368564  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180368568  F3 41 0F 59 C4              mulss   xmm0, xmm12
000000018036856D  F3 41 0F 59 C4              mulss   xmm0, xmm12
0000000180368572  F3 44 0F 59 A3 30 4F 01 00  mulss   xmm12, dword ptr [rbx+14F30h]
000000018036857B  F3 0F 59 83 40 4F 01 00     mulss   xmm0, dword ptr [rbx+14F40h]
0000000180368583  F3 41 0F 58 C4              addss   xmm0, xmm12
0000000180368588  F3 0F 11 83 D0 4E 01 00     movss   dword ptr [rbx+14ED0h], xmm0
0000000180368590  F3 0F 59 8B 60 4F 01 00     mulss   xmm1, dword ptr [rbx+14F60h]
0000000180368598  F3 0F 58 83 80 4E 01 00     addss   xmm0, dword ptr [rbx+14E80h]
00000001803685A0  F3 0F 59 A3 D0 4D 01 00     mulss   xmm4, dword ptr [rbx+14DD0h]
00000001803685A8  F3 0F 10 93 B0 4E 01 00     movss   xmm2, dword ptr [rbx+14EB0h]
00000001803685B0  F3 0F 58 CB                 addss   xmm1, xmm3
00000001803685B4  F3 0F 58 93 A0 4E 01 00     addss   xmm2, dword ptr [rbx+14EA0h]
00000001803685BC  F3 0F 59 83 80 4F 01 00     mulss   xmm0, dword ptr [rbx+14F80h]
00000001803685C4  F3 0F 59 93 70 4F 01 00     mulss   xmm2, dword ptr [rbx+14F70h]
00000001803685CC  F3 0F 58 D1                 addss   xmm2, xmm1
00000001803685D0  F3 0F 10 8B 40 4C 01 00     movss   xmm1, dword ptr [rbx+14C40h]
00000001803685D8  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803685DC  F3 0F 59 93 C0 4D 01 00     mulss   xmm2, dword ptr [rbx+14DC0h]
00000001803685E4  F3 0F 58 D4                 addss   xmm2, xmm4
00000001803685E8  F3 0F 11 93 30 4C 01 00     movss   dword ptr [rbx+14C30h], xmm2
00000001803685F0  F3 0F 59 8B F0 4D 01 00     mulss   xmm1, dword ptr [rbx+14DF0h]
00000001803685F8  F3 0F 10 9B 50 4C 01 00     movss   xmm3, dword ptr [rbx+14C50h]
0000000180368600  F3 0F 59 93 E0 4D 01 00     mulss   xmm2, dword ptr [rbx+14DE0h]
0000000180368608  0F 28 C3                    movaps  xmm0, xmm3
000000018036860B  F3 0F 59 83 00 4E 01 00     mulss   xmm0, dword ptr [rbx+14E00h]
0000000180368613  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180368617  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036861B  F3 0F 11 8B 40 4C 01 00     movss   dword ptr [rbx+14C40h], xmm1
0000000180368623  F3 0F 59 9B 20 4E 01 00     mulss   xmm3, dword ptr [rbx+14E20h]
000000018036862B  F3 0F 59 8B 10 4E 01 00     mulss   xmm1, dword ptr [rbx+14E10h]
0000000180368633  F3 0F 10 83 30 4E 01 00     movss   xmm0, dword ptr [rbx+14E30h]
000000018036863B  F3 0F 59 83 60 4C 01 00     mulss   xmm0, dword ptr [rbx+14C60h]
0000000180368643  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180368647  F3 0F 58 D8                 addss   xmm3, xmm0
000000018036864B  F3 0F 11 9B 50 4C 01 00     movss   dword ptr [rbx+14C50h], xmm3
0000000180368653  F3 0F 59 9B A0 4C 01 00     mulss   xmm3, dword ptr [rbx+14CA0h]
000000018036865B  F3 0F 59 9B B0 4C 01 00     mulss   xmm3, dword ptr [rbx+14CB0h]
0000000180368663  F3 0F 11 9B C0 4B 01 00     movss   dword ptr [rbx+14BC0h], xmm3
000000018036866B  0F 28 C3                    movaps  xmm0, xmm3
000000018036866E  F3 0F 11 9B D0 4B 01 00     movss   dword ptr [rbx+14BD0h], xmm3
0000000180368676  8B 83 B0 4F 01 00           mov     eax, [rbx+14FB0h]
000000018036867C  89 83 C0 4F 01 00           mov     [rbx+14FC0h], eax
0000000180368682  8B 83 A0 4F 01 00           mov     eax, [rbx+14FA0h]
0000000180368688  89 83 B0 4F 01 00           mov     [rbx+14FB0h], eax
000000018036868E  8B 83 90 4F 01 00           mov     eax, [rbx+14F90h]
0000000180368694  89 83 A0 4F 01 00           mov     [rbx+14FA0h], eax
000000018036869A  F3 0F 11 9B 90 4F 01 00     movss   dword ptr [rbx+14F90h], xmm3
00000001803686A2  F3 0F 59 83 F0 4F 01 00     mulss   xmm0, dword ptr [rbx+14FF0h]
00000001803686AA  F3 0F 10 A3 A0 4F 01 00     movss   xmm4, dword ptr [rbx+14FA0h]
00000001803686B2  F3 0F 10 8B 10 50 01 00     movss   xmm1, dword ptr [rbx+15010h]
00000001803686BA  0F 28 EC                    movaps  xmm5, xmm4
00000001803686BD  F3 0F 59 8B B0 4F 01 00     mulss   xmm1, dword ptr [rbx+14FB0h]
00000001803686C5  F3 0F 59 AB 00 50 01 00     mulss   xmm5, dword ptr [rbx+15000h]
00000001803686CD  F3 0F 59 A3 30 50 01 00     mulss   xmm4, dword ptr [rbx+15030h]
00000001803686D5  F3 0F 10 B3 E0 4F 01 00     movss   xmm6, dword ptr [rbx+14FE0h]
00000001803686DD  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803686E1  41 0F 2F F5                 comiss  xmm6, xmm13
00000001803686E5  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803686E9  0F 28 C3                    movaps  xmm0, xmm3
00000001803686EC  F3 0F 59 83 20 50 01 00     mulss   xmm0, dword ptr [rbx+15020h]
00000001803686F4  F3 0F 10 8B 40 50 01 00     movss   xmm1, dword ptr [rbx+15040h]
00000001803686FC  F3 0F 59 8B C0 4F 01 00     mulss   xmm1, dword ptr [rbx+14FC0h]
0000000180368704  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180368708  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036870C  76 05                       jbe     short loc_180368713
000000018036870E  0F 5A C6                    cvtps2pd xmm0, xmm6
0000000180368711  EB 04                       jmp     short loc_180368717
0000000180368713  41 0F 28 C7                 movaps  xmm0, xmm15
0000000180368717  0F 2F 35 A2 CD 77 00        comiss  xmm6, cs:dword_180AE54C0
000000018036871E  F2 0F 5A C0                 cvtsd2ss xmm0, xmm0
0000000180368722  F3 0F 11 AB A0 4F 01 00     movss   dword ptr [rbx+14FA0h], xmm5
000000018036872A  0F 28 D0                    movaps  xmm2, xmm0
000000018036872D  F3 0F 11 A3 B0 4F 01 00     movss   dword ptr [rbx+14FB0h], xmm4
0000000180368735  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180368739  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018036873D  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180368741  0F 28 C6                    movaps  xmm0, xmm6
0000000180368744  0F 57 05 75 D0 77 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018036874B  F3 0F 58 D3                 addss   xmm2, xmm3
000000018036874F  73 09                       jnb     short loc_18036875A
0000000180368751  45 0F 57 FF                 xorps   xmm15, xmm15
0000000180368755  F3 44 0F 5A F8              cvtss2sd xmm15, xmm0
000000018036875A  41 0F 2F F5                 comiss  xmm6, xmm13
000000018036875E  0F 57 C0                    xorps   xmm0, xmm0
0000000180368761  F2 41 0F 5A C7              cvtsd2ss xmm0, xmm15
0000000180368766  0F 28 C8                    movaps  xmm1, xmm0
0000000180368769  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018036876D  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180368771  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180368775  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180368779  72 03                       jb      short loc_18036877E
000000018036877B  0F 28 DA                    movaps  xmm3, xmm2
000000018036877E  F3 0F 11 9B D0 4F 01 00     movss   dword ptr [rbx+14FD0h], xmm3
0000000180368786  F3 0F 11 9B C0 4A 01 00     movss   dword ptr [rbx+14AC0h], xmm3
000000018036878E  F3 0F 10 83 D0 4F 01 00     movss   xmm0, dword ptr [rbx+14FD0h]
0000000180368796  E9 46 05 00 00              jmp     loc_180368CE1
000000018036879B  F3 0F 10 A3 90 4A 01 00     movss   xmm4, dword ptr [rbx+14A90h]
00000001803687A3  8B 83 F0 50 01 00           mov     eax, [rbx+150F0h]
00000001803687A9  89 83 00 51 01 00           mov     [rbx+15100h], eax
00000001803687AF  8B 83 E0 50 01 00           mov     eax, [rbx+150E0h]
00000001803687B5  89 83 F0 50 01 00           mov     [rbx+150F0h], eax
00000001803687BB  8B 83 D0 50 01 00           mov     eax, [rbx+150D0h]
00000001803687C1  89 83 E0 50 01 00           mov     [rbx+150E0h], eax
00000001803687C7  8B 83 C0 50 01 00           mov     eax, [rbx+150C0h]
00000001803687CD  89 83 D0 50 01 00           mov     [rbx+150D0h], eax
00000001803687D3  8B 83 B0 50 01 00           mov     eax, [rbx+150B0h]
00000001803687D9  89 83 C0 50 01 00           mov     [rbx+150C0h], eax
00000001803687DF  8B 83 A0 50 01 00           mov     eax, [rbx+150A0h]
00000001803687E5  89 83 B0 50 01 00           mov     [rbx+150B0h], eax
00000001803687EB  8B 83 90 50 01 00           mov     eax, [rbx+15090h]
00000001803687F1  89 83 A0 50 01 00           mov     [rbx+150A0h], eax
00000001803687F7  8B 83 80 52 01 00           mov     eax, [rbx+15280h]
00000001803687FD  89 83 90 52 01 00           mov     [rbx+15290h], eax
0000000180368803  8B 83 A0 52 01 00           mov     eax, [rbx+152A0h]
0000000180368809  89 83 B0 52 01 00           mov     [rbx+152B0h], eax
000000018036880F  8B 83 C0 52 01 00           mov     eax, [rbx+152C0h]
0000000180368815  89 83 D0 52 01 00           mov     [rbx+152D0h], eax
000000018036881B  8B 83 E0 52 01 00           mov     eax, [rbx+152E0h]
0000000180368821  89 83 F0 52 01 00           mov     [rbx+152F0h], eax
0000000180368827  8B 83 00 53 01 00           mov     eax, [rbx+15300h]
000000018036882D  89 83 10 53 01 00           mov     [rbx+15310h], eax
0000000180368833  F3 0F 11 A3 50 50 01 00     movss   dword ptr [rbx+15050h], xmm4
000000018036883B  F3 0F 11 A3 60 50 01 00     movss   dword ptr [rbx+15060h], xmm4
0000000180368843  F3 0F 58 E4                 addss   xmm4, xmm4
0000000180368847  F3 0F 10 9B 10 51 01 00     movss   xmm3, dword ptr [rbx+15110h]
000000018036884F  0F 28 D3                    movaps  xmm2, xmm3
0000000180368852  0F 28 CB                    movaps  xmm1, xmm3
0000000180368855  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180368859  0F 28 EB                    movaps  xmm5, xmm3
000000018036885C  F3 0F 59 AB 00 52 01 00     mulss   xmm5, dword ptr [rbx+15200h]
0000000180368864  F3 0F 59 A3 50 51 01 00     mulss   xmm4, dword ptr [rbx+15150h]
000000018036886C  0F 28 C2                    movaps  xmm0, xmm2
000000018036886F  F3 0F 59 83 10 52 01 00     mulss   xmm0, dword ptr [rbx+15210h]
0000000180368877  F3 0F 58 AB F0 51 01 00     addss   xmm5, dword ptr [rbx+151F0h]
000000018036887F  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180368883  F3 0F 59 8B 20 52 01 00     mulss   xmm1, dword ptr [rbx+15220h]
000000018036888B  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036888F  0F 5A C3                    cvtps2pd xmm0, xmm3
0000000180368892  F3 0F 10 9B A0 50 01 00     movss   xmm3, dword ptr [rbx+150A0h]
000000018036889A  F3 0F 58 E9                 addss   xmm5, xmm1
000000018036889E  F2 0F 5F 05 E2 23 62 00     maxsd   xmm0, cs:qword_18098AC88
00000001803688A6  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00000001803688AA  0F 28 D1                    movaps  xmm2, xmm1
00000001803688AD  F3 0F 59 C9                 mulss   xmm1, xmm1
00000001803688B1  F3 0F 59 93 A0 51 01 00     mulss   xmm2, dword ptr [rbx+151A0h]
00000001803688B9  F3 0F 59 8B B0 51 01 00     mulss   xmm1, dword ptr [rbx+151B0h]
00000001803688C1  F3 0F 58 93 90 51 01 00     addss   xmm2, dword ptr [rbx+15190h]
00000001803688C9  F3 0F 11 A3 90 50 01 00     movss   dword ptr [rbx+15090h], xmm4
00000001803688D1  F3 0F 59 9B 70 51 01 00     mulss   xmm3, dword ptr [rbx+15170h]
00000001803688D9  F3 0F 59 A3 60 51 01 00     mulss   xmm4, dword ptr [rbx+15160h]
00000001803688E1  F3 0F 10 83 80 51 01 00     movss   xmm0, dword ptr [rbx+15180h]
00000001803688E9  F3 0F 58 D1                 addss   xmm2, xmm1
00000001803688ED  F3 0F 59 83 B0 50 01 00     mulss   xmm0, dword ptr [rbx+150B0h]
00000001803688F5  F3 0F 58 DC                 addss   xmm3, xmm4
00000001803688F9  41 0F 2F D4                 comiss  xmm2, xmm12
00000001803688FD  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180368901  73 06                       jnb     short loc_180368909
0000000180368903  41 0F 28 D4                 movaps  xmm2, xmm12
0000000180368907  EB 05                       jmp     short loc_18036890E
0000000180368909  F3 41 0F 5D D6              minss   xmm2, xmm14
000000018036890E  F3 0F 10 83 D0 50 01 00     movss   xmm0, dword ptr [rbx+150D0h]
0000000180368916  F3 0F 11 9B A0 50 01 00     movss   dword ptr [rbx+150A0h], xmm3
000000018036891E  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180368922  F3 0F 59 93 C0 51 01 00     mulss   xmm2, dword ptr [rbx+151C0h]
000000018036892A  F3 0F 58 93 D0 51 01 00     addss   xmm2, dword ptr [rbx+151D0h]
0000000180368932  F3 0F 11 9B B0 50 01 00     movss   dword ptr [rbx+150B0h], xmm3
000000018036893A  F3 0F 10 8B E0 50 01 00     movss   xmm1, dword ptr [rbx+150E0h]
0000000180368942  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180368946  F3 0F 59 9B E0 51 01 00     mulss   xmm3, dword ptr [rbx+151E0h]
000000018036894E  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180368952  F3 0F 11 93 C0 50 01 00     movss   dword ptr [rbx+150C0h], xmm2
000000018036895A  F3 0F 58 AB 30 52 01 00     addss   xmm5, dword ptr [rbx+15230h]
0000000180368962  F3 0F 10 B3 30 51 01 00     movss   xmm6, dword ptr [rbx+15130h]
000000018036896A  F3 0F 59 EB                 mulss   xmm5, xmm3
000000018036896E  F3 0F 5C E9                 subss   xmm5, xmm1
0000000180368972  0F 28 C5                    movaps  xmm0, xmm5
0000000180368975  F3 0F 59 F5                 mulss   xmm6, xmm5
0000000180368979  F3 0F 59 83 40 52 01 00     mulss   xmm0, dword ptr [rbx+15240h]
0000000180368981  0F 28 E6                    movaps  xmm4, xmm6
0000000180368984  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180368988  F3 0F 11 83 D0 50 01 00     movss   dword ptr [rbx+150D0h], xmm0
0000000180368990  F3 0F 10 9B F0 50 01 00     movss   xmm3, dword ptr [rbx+150F0h]
0000000180368998  F3 0F 11 A3 80 52 01 00     movss   dword ptr [rbx+15280h], xmm4
00000001803689A0  F3 0F 10 83 50 53 01 00     movss   xmm0, dword ptr [rbx+15350h]
00000001803689A8  F3 0F 10 8B 90 52 01 00     movss   xmm1, dword ptr [rbx+15290h]
00000001803689B0  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803689B4  41 0F 2F E4                 comiss  xmm4, xmm12
00000001803689B8  73 06                       jnb     short loc_1803689C0
00000001803689BA  41 0F 28 E4                 movaps  xmm4, xmm12
00000001803689BE  EB 05                       jmp     short loc_1803689C5
00000001803689C0  F3 41 0F 5D E6              minss   xmm4, xmm14
00000001803689C5  F3 0F 59 B3 40 53 01 00     mulss   xmm6, dword ptr [rbx+15340h]
00000001803689CD  0F 28 D1                    movaps  xmm2, xmm1
00000001803689D0  F3 0F 59 93 30 53 01 00     mulss   xmm2, dword ptr [rbx+15330h]
00000001803689D8  F3 0F 58 D6                 addss   xmm2, xmm6
00000001803689DC  F3 0F 59 D0                 mulss   xmm2, xmm0
00000001803689E0  0F 28 C4                    movaps  xmm0, xmm4
00000001803689E3  F3 0F 59 C4                 mulss   xmm0, xmm4
00000001803689E7  41 0F 2F D4                 comiss  xmm2, xmm12
00000001803689EB  F3 0F 59 C4                 mulss   xmm0, xmm4
00000001803689EF  F3 0F 59 A3 60 53 01 00     mulss   xmm4, dword ptr [rbx+15360h]
00000001803689F7  F3 0F 59 83 70 53 01 00     mulss   xmm0, dword ptr [rbx+15370h]
00000001803689FF  F3 0F 58 C4                 addss   xmm0, xmm4
0000000180368A03  F3 0F 11 83 A0 52 01 00     movss   dword ptr [rbx+152A0h], xmm0
0000000180368A0B  73 06                       jnb     short loc_180368A13
0000000180368A0D  41 0F 28 D4                 movaps  xmm2, xmm12
0000000180368A11  EB 05                       jmp     short loc_180368A18
0000000180368A13  F3 41 0F 5D D6              minss   xmm2, xmm14
0000000180368A18  F3 0F 58 8B 80 52 01 00     addss   xmm1, dword ptr [rbx+15280h]
0000000180368A20  F3 0F 10 A3 90 52 01 00     movss   xmm4, dword ptr [rbx+15290h]
0000000180368A28  0F 28 C2                    movaps  xmm0, xmm2
0000000180368A2B  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180368A2F  F3 0F 59 8B 20 53 01 00     mulss   xmm1, dword ptr [rbx+15320h]
0000000180368A37  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180368A3B  F3 0F 59 93 60 53 01 00     mulss   xmm2, dword ptr [rbx+15360h]
0000000180368A43  F3 0F 59 83 70 53 01 00     mulss   xmm0, dword ptr [rbx+15370h]
0000000180368A4B  F3 0F 59 8B 50 53 01 00     mulss   xmm1, dword ptr [rbx+15350h]
0000000180368A53  F3 0F 58 C2                 addss   xmm0, xmm2
0000000180368A57  41 0F 2F CC                 comiss  xmm1, xmm12
0000000180368A5B  F3 0F 11 83 C0 52 01 00     movss   dword ptr [rbx+152C0h], xmm0
0000000180368A63  73 06                       jnb     short loc_180368A6B
0000000180368A65  41 0F 28 CC                 movaps  xmm1, xmm12
0000000180368A69  EB 05                       jmp     short loc_180368A70
0000000180368A6B  F3 41 0F 5D CE              minss   xmm1, xmm14
0000000180368A70  F3 0F 10 83 30 53 01 00     movss   xmm0, dword ptr [rbx+15330h]
0000000180368A78  F3 0F 59 83 80 52 01 00     mulss   xmm0, dword ptr [rbx+15280h]
0000000180368A80  F3 0F 59 A3 40 53 01 00     mulss   xmm4, dword ptr [rbx+15340h]
0000000180368A88  F3 0F 10 AB A0 52 01 00     movss   xmm5, dword ptr [rbx+152A0h]
0000000180368A90  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180368A94  0F 28 C1                    movaps  xmm0, xmm1
0000000180368A97  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180368A9B  F3 0F 59 A3 50 53 01 00     mulss   xmm4, dword ptr [rbx+15350h]
0000000180368AA3  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180368AA7  41 0F 2F E4                 comiss  xmm4, xmm12
0000000180368AAB  F3 0F 59 83 70 53 01 00     mulss   xmm0, dword ptr [rbx+15370h]
0000000180368AB3  F3 0F 59 8B 60 53 01 00     mulss   xmm1, dword ptr [rbx+15360h]
0000000180368ABB  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180368ABF  F3 0F 11 83 E0 52 01 00     movss   dword ptr [rbx+152E0h], xmm0
0000000180368AC7  72 09                       jb      short loc_180368AD2
0000000180368AC9  44 0F 28 E4                 movaps  xmm12, xmm4
0000000180368ACD  F3 45 0F 5D E6              minss   xmm12, xmm14
0000000180368AD2  F3 0F 58 AB 10 53 01 00     addss   xmm5, dword ptr [rbx+15310h]
0000000180368ADA  F3 0F 10 83 90 53 01 00     movss   xmm0, dword ptr [rbx+15390h]
0000000180368AE2  41 0F 28 D4                 movaps  xmm2, xmm12
0000000180368AE6  F3 0F 59 83 C0 52 01 00     mulss   xmm0, dword ptr [rbx+152C0h]
0000000180368AEE  F3 0F 10 8B F0 52 01 00     movss   xmm1, dword ptr [rbx+152F0h]
0000000180368AF6  F3 0F 59 AB 80 53 01 00     mulss   xmm5, dword ptr [rbx+15380h]
0000000180368AFE  F3 41 0F 59 D4              mulss   xmm2, xmm12
0000000180368B03  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180368B07  F3 41 0F 59 D4              mulss   xmm2, xmm12
0000000180368B0C  F3 44 0F 59 A3 60 53 01 00  mulss   xmm12, dword ptr [rbx+15360h]
0000000180368B15  F3 0F 59 93 70 53 01 00     mulss   xmm2, dword ptr [rbx+15370h]
0000000180368B1D  F3 41 0F 58 D4              addss   xmm2, xmm12
0000000180368B22  F3 0F 11 93 00 53 01 00     movss   dword ptr [rbx+15300h], xmm2
0000000180368B2A  F3 0F 59 8B 90 53 01 00     mulss   xmm1, dword ptr [rbx+15390h]
0000000180368B32  F3 0F 58 93 B0 52 01 00     addss   xmm2, dword ptr [rbx+152B0h]
0000000180368B3A  F3 0F 10 83 E0 52 01 00     movss   xmm0, dword ptr [rbx+152E0h]
0000000180368B42  F3 0F 58 83 D0 52 01 00     addss   xmm0, dword ptr [rbx+152D0h]
0000000180368B4A  F3 0F 58 CD                 addss   xmm1, xmm5
0000000180368B4E  F3 0F 59 93 B0 53 01 00     mulss   xmm2, dword ptr [rbx+153B0h]
0000000180368B56  F3 0F 59 83 A0 53 01 00     mulss   xmm0, dword ptr [rbx+153A0h]
0000000180368B5E  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180368B62  F3 0F 58 C2                 addss   xmm0, xmm2
0000000180368B66  F3 0F 11 83 E0 50 01 00     movss   dword ptr [rbx+150E0h], xmm0
0000000180368B6E  F3 0F 59 83 50 52 01 00     mulss   xmm0, dword ptr [rbx+15250h]
0000000180368B76  F3 0F 59 9B 60 52 01 00     mulss   xmm3, dword ptr [rbx+15260h]
0000000180368B7E  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180368B82  F3 0F 10 83 70 52 01 00     movss   xmm0, dword ptr [rbx+15270h]
0000000180368B8A  F3 0F 59 83 00 51 01 00     mulss   xmm0, dword ptr [rbx+15100h]
0000000180368B92  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180368B96  F3 0F 11 9B F0 50 01 00     movss   dword ptr [rbx+150F0h], xmm3
0000000180368B9E  F3 0F 59 9B 20 51 01 00     mulss   xmm3, dword ptr [rbx+15120h]
0000000180368BA6  F3 0F 59 9B 30 51 01 00     mulss   xmm3, dword ptr [rbx+15130h]
0000000180368BAE  F3 0F 11 9B 70 50 01 00     movss   dword ptr [rbx+15070h], xmm3
0000000180368BB6  0F 28 C3                    movaps  xmm0, xmm3
0000000180368BB9  F3 0F 11 9B 80 50 01 00     movss   dword ptr [rbx+15080h], xmm3
0000000180368BC1  8B 83 E0 53 01 00           mov     eax, [rbx+153E0h]
0000000180368BC7  89 83 F0 53 01 00           mov     [rbx+153F0h], eax
0000000180368BCD  8B 83 D0 53 01 00           mov     eax, [rbx+153D0h]
0000000180368BD3  89 83 E0 53 01 00           mov     [rbx+153E0h], eax
0000000180368BD9  8B 83 C0 53 01 00           mov     eax, [rbx+153C0h]
0000000180368BDF  89 83 D0 53 01 00           mov     [rbx+153D0h], eax
0000000180368BE5  F3 0F 11 9B C0 53 01 00     movss   dword ptr [rbx+153C0h], xmm3
0000000180368BED  F3 0F 59 83 20 54 01 00     mulss   xmm0, dword ptr [rbx+15420h]
0000000180368BF5  F3 0F 10 93 D0 53 01 00     movss   xmm2, dword ptr [rbx+153D0h]
0000000180368BFD  F3 0F 10 8B 40 54 01 00     movss   xmm1, dword ptr [rbx+15440h]
0000000180368C05  0F 28 EA                    movaps  xmm5, xmm2
0000000180368C08  F3 0F 59 8B E0 53 01 00     mulss   xmm1, dword ptr [rbx+153E0h]
0000000180368C10  F3 0F 59 AB 30 54 01 00     mulss   xmm5, dword ptr [rbx+15430h]
0000000180368C18  F3 0F 59 93 60 54 01 00     mulss   xmm2, dword ptr [rbx+15460h]
0000000180368C20  F3 0F 10 B3 10 54 01 00     movss   xmm6, dword ptr [rbx+15410h]
0000000180368C28  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180368C2C  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180368C30  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180368C34  0F 28 C3                    movaps  xmm0, xmm3
0000000180368C37  F3 0F 59 83 50 54 01 00     mulss   xmm0, dword ptr [rbx+15450h]
0000000180368C3F  F3 0F 10 8B 70 54 01 00     movss   xmm1, dword ptr [rbx+15470h]
0000000180368C47  F3 0F 59 8B F0 53 01 00     mulss   xmm1, dword ptr [rbx+153F0h]
0000000180368C4F  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180368C53  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180368C57  76 05                       jbe     short loc_180368C5E
0000000180368C59  0F 5A C6                    cvtps2pd xmm0, xmm6
0000000180368C5C  EB 04                       jmp     short loc_180368C62
0000000180368C5E  41 0F 28 C7                 movaps  xmm0, xmm15
0000000180368C62  0F 2F 35 57 C8 77 00        comiss  xmm6, cs:dword_180AE54C0
0000000180368C69  F2 0F 5A C0                 cvtsd2ss xmm0, xmm0
0000000180368C6D  F3 0F 11 AB D0 53 01 00     movss   dword ptr [rbx+153D0h], xmm5
0000000180368C75  0F 28 E0                    movaps  xmm4, xmm0
0000000180368C78  F3 0F 11 93 E0 53 01 00     movss   dword ptr [rbx+153E0h], xmm2
0000000180368C80  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180368C84  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180368C88  F3 0F 5C E0                 subss   xmm4, xmm0
0000000180368C8C  0F 28 C6                    movaps  xmm0, xmm6
0000000180368C8F  0F 57 05 2A CB 77 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180368C96  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180368C9A  73 09                       jnb     short loc_180368CA5
0000000180368C9C  45 0F 57 FF                 xorps   xmm15, xmm15
0000000180368CA0  F3 44 0F 5A F8              cvtss2sd xmm15, xmm0
0000000180368CA5  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180368CA9  0F 57 C0                    xorps   xmm0, xmm0
0000000180368CAC  F2 41 0F 5A C7              cvtsd2ss xmm0, xmm15
0000000180368CB1  0F 28 C8                    movaps  xmm1, xmm0
0000000180368CB4  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180368CB8  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180368CBC  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180368CC0  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180368CC4  72 03                       jb      short loc_180368CC9
0000000180368CC6  0F 28 DC                    movaps  xmm3, xmm4
0000000180368CC9  F3 0F 11 9B 00 54 01 00     movss   dword ptr [rbx+15400h], xmm3
0000000180368CD1  F3 0F 11 9B C0 4A 01 00     movss   dword ptr [rbx+14AC0h], xmm3
0000000180368CD9  F3 0F 10 83 00 54 01 00     movss   xmm0, dword ptr [rbx+15400h]
0000000180368CE1  F3 0F 11 83 E0 4A 01 00     movss   dword ptr [rbx+14AE0h], xmm0
0000000180368CE9  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
0000000180368CF1  F3 0F 10 83 90 8B 01 00     movss   xmm0, dword ptr [rbx+18B90h]
0000000180368CF9  48 8B 07                    mov     rax, [rdi]
0000000180368CFC  F3 0F 58 C0                 addss   xmm0, xmm0
0000000180368D00  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
0000000180368D05  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
0000000180368D0A  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
0000000180368D0F  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
0000000180368D14  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
0000000180368D19  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
0000000180368D1E  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
0000000180368D23  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
0000000180368D28  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
0000000180368D2E  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
0000000180368D34  F3 0F 11 00                 movss   dword ptr [rax], xmm0
0000000180368D38  F3 0F 10 8B A0 8B 01 00     movss   xmm1, dword ptr [rbx+18BA0h]
0000000180368D40  48 8B 47 08                 mov     rax, [rdi+8]
0000000180368D44  F3 0F 58 C9                 addss   xmm1, xmm1
0000000180368D48  49 8B 5B 18                 mov     rbx, [r11+18h]
0000000180368D4C  F3 0F 11 08                 movss   dword ptr [rax], xmm1
0000000180368D50  49 8B E3                    mov     rsp, r11
0000000180368D53  5F                          pop     rdi
0000000180368D54  C3                          retn
