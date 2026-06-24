; sub_7FF91DFC3380 @ rva 0x363380

00007FF91DFC3380  48 8B C4                    mov     rax, rsp
00007FF91DFC3383  48 89 58 10                 mov     [rax+10h], rbx
00007FF91DFC3387  57                          push    rdi
00007FF91DFC3388  48 81 EC C0 00 00 00        sub     rsp, 0C0h
00007FF91DFC338F  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
00007FF91DFC3393  49 8B F8                    mov     rdi, r8
00007FF91DFC3396  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
00007FF91DFC339A  48 8B D9                    mov     rbx, rcx
00007FF91DFC339D  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
00007FF91DFC33A2  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
00007FF91DFC33A7  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
00007FF91DFC33AC  F3 44 0F 10 91 10 4A 01 00  movss   xmm10, dword ptr [rcx+14A10h]
00007FF91DFC33B5  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
00007FF91DFC33BA  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
00007FF91DFC33BF  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
00007FF91DFC33C5  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
00007FF91DFC33CB  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
00007FF91DFC33D1  48 89 70 08                 mov     [rax+8], rsi
00007FF91DFC33D5  33 F6                       xor     esi, esi
00007FF91DFC33D7  48 8B 02                    mov     rax, [rdx]
00007FF91DFC33DA  F3 0F 10 20                 movss   xmm4, dword ptr [rax]
00007FF91DFC33DE  F3 0F 11 A1 B0 29 00 00     movss   dword ptr [rcx+29B0h], xmm4
00007FF91DFC33E6  48 8B 42 10                 mov     rax, [rdx+10h]
00007FF91DFC33EA  F3 0F 10 28                 movss   xmm5, dword ptr [rax]
00007FF91DFC33EE  F3 0F 11 A9 C0 52 00 00     movss   dword ptr [rcx+52C0h], xmm5
00007FF91DFC33F6  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFC33FA  48 8B 42 20                 mov     rax, [rdx+20h]
00007FF91DFC33FE  F3 0F 10 A1 40 4A 01 00     movss   xmm4, dword ptr [rcx+14A40h]
00007FF91DFC3406  F3 0F 10 00                 movss   xmm0, dword ptr [rax]
00007FF91DFC340A  F3 0F 59 A9 E0 49 01 00     mulss   xmm5, dword ptr [rcx+149E0h]
00007FF91DFC3412  F3 0F 11 81 D0 7B 00 00     movss   dword ptr [rcx+7BD0h], xmm0
00007FF91DFC341A  48 8B 42 30                 mov     rax, [rdx+30h]
00007FF91DFC341E  F3 0F 10 38                 movss   xmm7, dword ptr [rax]
00007FF91DFC3422  F3 0F 11 B9 E0 A4 00 00     movss   dword ptr [rcx+0A4E0h], xmm7
00007FF91DFC342A  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFC342E  48 8B 42 40                 mov     rax, [rdx+40h]
00007FF91DFC3432  F3 0F 10 81 50 4A 01 00     movss   xmm0, dword ptr [rcx+14A50h]
00007FF91DFC343A  F3 0F 10 18                 movss   xmm3, dword ptr [rax]
00007FF91DFC343E  F3 0F 59 B9 F0 49 01 00     mulss   xmm7, dword ptr [rcx+149F0h]
00007FF91DFC3446  F3 0F 11 99 F0 CD 00 00     movss   dword ptr [rcx+0CDF0h], xmm3
00007FF91DFC344E  48 8B 42 50                 mov     rax, [rdx+50h]
00007FF91DFC3452  F3 0F 58 FD                 addss   xmm7, xmm5
00007FF91DFC3456  F3 0F 10 30                 movss   xmm6, dword ptr [rax]
00007FF91DFC345A  F3 0F 11 B1 00 F7 00 00     movss   dword ptr [rcx+0F700h], xmm6
00007FF91DFC3462  F3 0F 58 F3                 addss   xmm6, xmm3
00007FF91DFC3466  48 8B 42 60                 mov     rax, [rdx+60h]
00007FF91DFC346A  F3 0F 10 99 E0 4A 01 00     movss   xmm3, dword ptr [rcx+14AE0h]
00007FF91DFC3472  F3 0F 10 08                 movss   xmm1, dword ptr [rax]
00007FF91DFC3476  F3 0F 59 B1 00 4A 01 00     mulss   xmm6, dword ptr [rcx+14A00h]
00007FF91DFC347E  F3 0F 11 89 10 20 01 00     movss   dword ptr [rcx+12010h], xmm1
00007FF91DFC3486  48 8B 42 70                 mov     rax, [rdx+70h]
00007FF91DFC348A  F3 0F 10 10                 movss   xmm2, dword ptr [rax]
00007FF91DFC348E  8B 81 60 4B 01 00           mov     eax, [rcx+14B60h]
00007FF91DFC3494  F3 0F 11 91 20 49 01 00     movss   dword ptr [rcx+14920h], xmm2
00007FF91DFC349C  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC34A0  F3 0F 10 89 20 4B 01 00     movss   xmm1, dword ptr [rcx+14B20h]
00007FF91DFC34A8  F3 0F 11 89 30 4B 01 00     movss   dword ptr [rcx+14B30h], xmm1
00007FF91DFC34B0  F3 0F 59 89 50 4B 01 00     mulss   xmm1, dword ptr [rcx+14B50h]
00007FF91DFC34B8  89 B1 80 4A 01 00           mov     [rcx+14A80h], esi
00007FF91DFC34BE  F3 41 0F 59 D2              mulss   xmm2, xmm10
00007FF91DFC34C3  89 81 70 4B 01 00           mov     [rcx+14B70h], eax
00007FF91DFC34C9  F3 0F 11 81 70 4A 01 00     movss   dword ptr [rcx+14A70h], xmm0
00007FF91DFC34D1  F3 0F 11 99 F0 4A 01 00     movss   dword ptr [rcx+14AF0h], xmm3
00007FF91DFC34D9  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFC34DD  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFC34E1  F3 0F 10 91 C0 4A 01 00     movss   xmm2, dword ptr [rcx+14AC0h]
00007FF91DFC34E9  F3 0F 11 91 D0 4A 01 00     movss   dword ptr [rcx+14AD0h], xmm2
00007FF91DFC34F1  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFC34F5  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC34F8  F3 0F 58 FE                 addss   xmm7, xmm6
00007FF91DFC34FC  F3 0F 11 A1 60 4A 01 00     movss   dword ptr [rcx+14A60h], xmm4
00007FF91DFC3504  F3 0F 11 99 10 4B 01 00     movss   dword ptr [rcx+14B10h], xmm3
00007FF91DFC350C  F3 0F 11 91 00 4B 01 00     movss   dword ptr [rcx+14B00h], xmm2
00007FF91DFC3514  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFC3518  F3 0F 59 B9 20 4A 01 00     mulss   xmm7, dword ptr [rcx+14A20h]
00007FF91DFC3520  F3 0F 11 B9 30 4A 01 00     movss   dword ptr [rcx+14A30h], xmm7
00007FF91DFC3528  F3 0F 59 B9 A0 4A 01 00     mulss   xmm7, dword ptr [rcx+14AA0h]
00007FF91DFC3530  F3 0F 58 B9 B0 4A 01 00     addss   xmm7, dword ptr [rcx+14AB0h]
00007FF91DFC3538  F3 0F 11 B9 90 4A 01 00     movss   dword ptr [rcx+14A90h], xmm7
00007FF91DFC3540  F3 0F 11 B9 20 4B 01 00     movss   dword ptr [rcx+14B20h], xmm7
00007FF91DFC3548  F3 0F 59 B9 40 4B 01 00     mulss   xmm7, dword ptr [rcx+14B40h]
00007FF91DFC3550  F3 0F 58 CF                 addss   xmm1, xmm7
00007FF91DFC3554  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC3558  F3 0F 11 89 60 4B 01 00     movss   dword ptr [rcx+14B60h], xmm1
00007FF91DFC3560  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC3564  F3 44 0F 10 81 D0 8A 01 00  movss   xmm8, dword ptr [rcx+18AD0h]
00007FF91DFC356D  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC3571  F3 44 0F 10 1D 6E 1C 78 00  movss   xmm11, cs:flt_7FF91E7451E8
00007FF91DFC357A  45 0F 28 C8                 movaps  xmm9, xmm8
00007FF91DFC357E  F3 44 0F 10 3D 85 1A 78 00  movss   xmm15, cs:dword_7FF91E74500C
00007FF91DFC3587  F3 44 0F 10 25 00 22 78 00  movss   xmm12, dword ptr cs:xmmword_7FF91E745790
00007FF91DFC3590  F3 44 0F 11 81 E0 8A 01 00  movss   dword ptr [rcx+18AE0h], xmm8
00007FF91DFC3599  F3 0F 11 91 80 4B 01 00     movss   dword ptr [rcx+14B80h], xmm2
00007FF91DFC35A1  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFC35A5  F3 44 0F 59 CA              mulss   xmm9, xmm2
00007FF91DFC35AA  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFC35AE  F3 44 0F 11 89 F0 8A 01 00  movss   dword ptr [rcx+18AF0h], xmm9
00007FF91DFC35B7  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFC35BB  F3 0F 11 99 90 4B 01 00     movss   dword ptr [rcx+14B90h], xmm3
00007FF91DFC35C3  F3 44 0F 59 C3              mulss   xmm8, xmm3
00007FF91DFC35C8  F3 44 0F 11 81 00 8B 01 00  movss   dword ptr [rcx+18B00h], xmm8
00007FF91DFC35D1  48 8B 81 88 00 00 00        mov     rax, [rcx+88h]
00007FF91DFC35D8  48 8B 88 88 00 00 00        mov     rcx, [rax+88h]
00007FF91DFC35DF  8B 01                       mov     eax, [rcx]
00007FF91DFC35E1  83 F8 01                    cmp     eax, 1
00007FF91DFC35E4  0F 84 DF 2A 00 00           jz      loc_7FF91DFC60C9
00007FF91DFC35EA  0F 8E AA 22 00 00           jle     loc_7FF91DFC589A
00007FF91DFC35F0  83 F8 03                    cmp     eax, 3
00007FF91DFC35F3  0F 8E F0 1A 00 00           jle     loc_7FF91DFC50E9
00007FF91DFC35F9  83 F8 04                    cmp     eax, 4
00007FF91DFC35FC  0F 84 92 11 00 00           jz      loc_7FF91DFC4794
00007FF91DFC3602  83 F8 05                    cmp     eax, 5
00007FF91DFC3605  0F 85 8F 22 00 00           jnz     loc_7FF91DFC589A
00007FF91DFC360B  39 83 0C 30 A8 00           cmp     [rbx+0A8300Ch], eax
00007FF91DFC3611  74 24                       jz      short loc_7FF91DFC3637
00007FF91DFC3613  89 B3 40 23 63 00           mov     [rbx+632340h], esi
00007FF91DFC3619  89 B3 50 23 63 00           mov     [rbx+632350h], esi
00007FF91DFC361F  89 B3 60 23 63 00           mov     [rbx+632360h], esi
00007FF91DFC3625  89 B3 00 29 A3 00           mov     [rbx+0A32900h], esi
00007FF91DFC362B  89 B3 10 29 A3 00           mov     [rbx+0A32910h], esi
00007FF91DFC3631  89 B3 20 29 A3 00           mov     [rbx+0A32920h], esi
00007FF91DFC3637  C7 83 0C 30 A8 00 05 00 00 00  mov     dword ptr [rbx+0A8300Ch], 5
00007FF91DFC3641  41 0F 28 E1                 movaps  xmm4, xmm9
00007FF91DFC3645  8B 83 C0 21 63 00           mov     eax, [rbx+6321C0h]
00007FF91DFC364B  89 83 D0 21 63 00           mov     [rbx+6321D0h], eax
00007FF91DFC3651  8B 83 B0 21 63 00           mov     eax, [rbx+6321B0h]
00007FF91DFC3657  89 83 C0 21 63 00           mov     [rbx+6321C0h], eax
00007FF91DFC365D  8B 83 A0 21 63 00           mov     eax, [rbx+6321A0h]
00007FF91DFC3663  89 83 B0 21 63 00           mov     [rbx+6321B0h], eax
00007FF91DFC3669  8B 83 90 21 63 00           mov     eax, [rbx+632190h]
00007FF91DFC366F  89 83 A0 21 63 00           mov     [rbx+6321A0h], eax
00007FF91DFC3675  8B 83 80 21 63 00           mov     eax, [rbx+632180h]
00007FF91DFC367B  89 83 90 21 63 00           mov     [rbx+632190h], eax
00007FF91DFC3681  8B 83 70 21 63 00           mov     eax, [rbx+632170h]
00007FF91DFC3687  89 83 80 21 63 00           mov     [rbx+632180h], eax
00007FF91DFC368D  8B 83 60 21 63 00           mov     eax, [rbx+632160h]
00007FF91DFC3693  89 83 70 21 63 00           mov     [rbx+632170h], eax
00007FF91DFC3699  8B 83 40 22 63 00           mov     eax, [rbx+632240h]
00007FF91DFC369F  89 83 50 22 63 00           mov     [rbx+632250h], eax
00007FF91DFC36A5  8B 83 30 22 63 00           mov     eax, [rbx+632230h]
00007FF91DFC36AB  89 83 40 22 63 00           mov     [rbx+632240h], eax
00007FF91DFC36B1  8B 83 20 22 63 00           mov     eax, [rbx+632220h]
00007FF91DFC36B7  89 83 30 22 63 00           mov     [rbx+632230h], eax
00007FF91DFC36BD  8B 83 10 22 63 00           mov     eax, [rbx+632210h]
00007FF91DFC36C3  89 83 20 22 63 00           mov     [rbx+632220h], eax
00007FF91DFC36C9  8B 83 00 22 63 00           mov     eax, [rbx+632200h]
00007FF91DFC36CF  89 83 10 22 63 00           mov     [rbx+632210h], eax
00007FF91DFC36D5  8B 83 F0 21 63 00           mov     eax, [rbx+6321F0h]
00007FF91DFC36DB  89 83 00 22 63 00           mov     [rbx+632200h], eax
00007FF91DFC36E1  8B 83 E0 21 63 00           mov     eax, [rbx+6321E0h]
00007FF91DFC36E7  89 83 F0 21 63 00           mov     [rbx+6321F0h], eax
00007FF91DFC36ED  8B 83 90 22 63 00           mov     eax, [rbx+632290h]
00007FF91DFC36F3  89 83 A0 22 63 00           mov     [rbx+6322A0h], eax
00007FF91DFC36F9  8B 83 80 22 63 00           mov     eax, [rbx+632280h]
00007FF91DFC36FF  89 83 90 22 63 00           mov     [rbx+632290h], eax
00007FF91DFC3705  8B 83 70 22 63 00           mov     eax, [rbx+632270h]
00007FF91DFC370B  89 83 80 22 63 00           mov     [rbx+632280h], eax
00007FF91DFC3711  8B 83 60 22 63 00           mov     eax, [rbx+632260h]
00007FF91DFC3717  89 83 70 22 63 00           mov     [rbx+632270h], eax
00007FF91DFC371D  8B 83 E0 22 63 00           mov     eax, [rbx+6322E0h]
00007FF91DFC3723  89 83 F0 22 63 00           mov     [rbx+6322F0h], eax
00007FF91DFC3729  8B 83 D0 22 63 00           mov     eax, [rbx+6322D0h]
00007FF91DFC372F  89 83 E0 22 63 00           mov     [rbx+6322E0h], eax
00007FF91DFC3735  8B 83 C0 22 63 00           mov     eax, [rbx+6322C0h]
00007FF91DFC373B  89 83 D0 22 63 00           mov     [rbx+6322D0h], eax
00007FF91DFC3741  8B 83 B0 22 63 00           mov     eax, [rbx+6322B0h]
00007FF91DFC3747  89 83 C0 22 63 00           mov     [rbx+6322C0h], eax
00007FF91DFC374D  8B 83 50 23 63 00           mov     eax, [rbx+632350h]
00007FF91DFC3753  89 83 60 23 63 00           mov     [rbx+632360h], eax
00007FF91DFC3759  8B 83 40 23 63 00           mov     eax, [rbx+632340h]
00007FF91DFC375F  89 83 50 23 63 00           mov     [rbx+632350h], eax
00007FF91DFC3765  8B 83 20 23 63 00           mov     eax, [rbx+632320h]
00007FF91DFC376B  89 83 30 23 63 00           mov     [rbx+632330h], eax
00007FF91DFC3771  8B 83 10 23 63 00           mov     eax, [rbx+632310h]
00007FF91DFC3777  89 83 20 23 63 00           mov     [rbx+632320h], eax
00007FF91DFC377D  8B 83 00 23 63 00           mov     eax, [rbx+632300h]
00007FF91DFC3783  89 83 10 23 63 00           mov     [rbx+632310h], eax
00007FF91DFC3789  F3 44 0F 11 8B 40 21 63 00  movss   dword ptr [rbx+632140h], xmm9
00007FF91DFC3792  F3 44 0F 11 83 50 21 63 00  movss   dword ptr [rbx+632150h], xmm8
00007FF91DFC379B  F3 44 0F 11 8B 60 22 63 00  movss   dword ptr [rbx+632260h], xmm9
00007FF91DFC37A4  F3 0F 59 A3 A0 23 63 00     mulss   xmm4, dword ptr [rbx+6323A0h]
00007FF91DFC37AC  F3 0F 10 83 B0 23 63 00     movss   xmm0, dword ptr [rbx+6323B0h]
00007FF91DFC37B4  F3 0F 59 83 70 22 63 00     mulss   xmm0, dword ptr [rbx+632270h]
00007FF91DFC37BC  F3 0F 10 8B 80 22 63 00     movss   xmm1, dword ptr [rbx+632280h]
00007FF91DFC37C4  F3 0F 59 8B C0 23 63 00     mulss   xmm1, dword ptr [rbx+6323C0h]
00007FF91DFC37CC  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC37D0  F3 0F 10 83 D0 23 63 00     movss   xmm0, dword ptr [rbx+6323D0h]
00007FF91DFC37D8  F3 0F 59 83 90 22 63 00     mulss   xmm0, dword ptr [rbx+632290h]
00007FF91DFC37E0  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC37E4  F3 0F 10 8B E0 23 63 00     movss   xmm1, dword ptr [rbx+6323E0h]
00007FF91DFC37EC  F3 0F 59 8B A0 22 63 00     mulss   xmm1, dword ptr [rbx+6322A0h]
00007FF91DFC37F4  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC37F8  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC37FC  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFC3800  F3 0F 11 A3 80 22 63 00     movss   dword ptr [rbx+632280h], xmm4
00007FF91DFC3808  F3 0F 10 93 70 21 63 00     movss   xmm2, dword ptr [rbx+632170h]
00007FF91DFC3810  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC3813  F3 0F 59 83 10 24 63 00     mulss   xmm0, dword ptr [rbx+632410h]
00007FF91DFC381B  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC381F  F3 0F 5C 8B 80 21 63 00     subss   xmm1, dword ptr [rbx+632180h]
00007FF91DFC3827  F3 0F 59 8B 00 24 63 00     mulss   xmm1, dword ptr [rbx+632400h]
00007FF91DFC382F  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC3833  F3 0F 11 8B 60 21 63 00     movss   dword ptr [rbx+632160h], xmm1
00007FF91DFC383B  45 0F 57 ED                 xorps   xmm13, xmm13
00007FF91DFC383F  F3 0F 10 9B 00 24 63 00     movss   xmm3, dword ptr [rbx+632400h]
00007FF91DFC3847  F3 0F 59 9B 70 21 63 00     mulss   xmm3, dword ptr [rbx+632170h]
00007FF91DFC384F  F3 44 0F 10 35 5C 18 78 00  movss   xmm14, cs:dword_7FF91E7450B4
00007FF91DFC3858  41 0F 28 D6                 movaps  xmm2, xmm14
00007FF91DFC385C  F3 0F 58 9B 80 21 63 00     addss   xmm3, dword ptr [rbx+632180h]
00007FF91DFC3864  F3 0F 11 9B 70 21 63 00     movss   dword ptr [rbx+632170h], xmm3
00007FF91DFC386C  F3 0F 10 83 F0 23 63 00     movss   xmm0, dword ptr [rbx+6323F0h]
00007FF91DFC3874  F3 0F 10 8B 20 24 63 00     movss   xmm1, dword ptr [rbx+632420h]
00007FF91DFC387C  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC3880  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFC3884  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFC3888  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC388C  41 0F 28 C6                 movaps  xmm0, xmm14
00007FF91DFC3890  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFC3894  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC3898  F3 41 0F 59 C1              mulss   xmm0, xmm9
00007FF91DFC389D  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC38A1  F3 0F 10 83 60 24 63 00     movss   xmm0, dword ptr [rbx+632460h]
00007FF91DFC38A9  F3 0F 59 83 C0 21 63 00     mulss   xmm0, dword ptr [rbx+6321C0h]
00007FF91DFC38B1  F3 0F 59 93 70 24 63 00     mulss   xmm2, dword ptr [rbx+632470h]
00007FF91DFC38B9  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC38BD  F3 0F 59 93 80 24 63 00     mulss   xmm2, dword ptr [rbx+632480h]
00007FF91DFC38C5  F3 0F 11 93 70 25 A3 00     movss   dword ptr [rbx+0A32570h], xmm2
00007FF91DFC38CD  F3 0F 10 AB 50 21 63 00     movss   xmm5, dword ptr [rbx+632150h]
00007FF91DFC38D5  F3 0F 11 AB B0 22 63 00     movss   dword ptr [rbx+6322B0h], xmm5
00007FF91DFC38DD  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFC38E0  F3 0F 59 A3 A0 23 63 00     mulss   xmm4, dword ptr [rbx+6323A0h]
00007FF91DFC38E8  F3 0F 10 83 B0 23 63 00     movss   xmm0, dword ptr [rbx+6323B0h]
00007FF91DFC38F0  F3 0F 59 83 C0 22 63 00     mulss   xmm0, dword ptr [rbx+6322C0h]
00007FF91DFC38F8  F3 0F 10 8B C0 23 63 00     movss   xmm1, dword ptr [rbx+6323C0h]
00007FF91DFC3900  F3 0F 59 8B D0 22 63 00     mulss   xmm1, dword ptr [rbx+6322D0h]
00007FF91DFC3908  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC390C  F3 0F 10 83 E0 22 63 00     movss   xmm0, dword ptr [rbx+6322E0h]
00007FF91DFC3914  F3 0F 59 83 D0 23 63 00     mulss   xmm0, dword ptr [rbx+6323D0h]
00007FF91DFC391C  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC3920  F3 0F 10 8B E0 23 63 00     movss   xmm1, dword ptr [rbx+6323E0h]
00007FF91DFC3928  F3 0F 59 8B F0 22 63 00     mulss   xmm1, dword ptr [rbx+6322F0h]
00007FF91DFC3930  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC3934  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC3938  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFC393B  F3 0F 11 A3 D0 22 63 00     movss   dword ptr [rbx+6322D0h], xmm4
00007FF91DFC3943  F3 0F 10 93 F0 21 63 00     movss   xmm2, dword ptr [rbx+6321F0h]
00007FF91DFC394B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC394E  F3 0F 59 83 10 24 63 00     mulss   xmm0, dword ptr [rbx+632410h]
00007FF91DFC3956  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC395A  F3 0F 5C 8B 00 22 63 00     subss   xmm1, dword ptr [rbx+632200h]
00007FF91DFC3962  F3 0F 59 8B 00 24 63 00     mulss   xmm1, dword ptr [rbx+632400h]
00007FF91DFC396A  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC396E  41 0F 28 D6                 movaps  xmm2, xmm14
00007FF91DFC3972  F3 0F 11 8B E0 21 63 00     movss   dword ptr [rbx+6321E0h], xmm1
00007FF91DFC397A  F3 0F 10 9B F0 21 63 00     movss   xmm3, dword ptr [rbx+6321F0h]
00007FF91DFC3982  F3 0F 59 9B 00 24 63 00     mulss   xmm3, dword ptr [rbx+632400h]
00007FF91DFC398A  F3 0F 58 9B 00 22 63 00     addss   xmm3, dword ptr [rbx+632200h]
00007FF91DFC3992  F3 0F 11 9B F0 21 63 00     movss   dword ptr [rbx+6321F0h], xmm3
00007FF91DFC399A  F3 0F 10 83 F0 23 63 00     movss   xmm0, dword ptr [rbx+6323F0h]
00007FF91DFC39A2  F3 0F 10 8B 20 24 63 00     movss   xmm1, dword ptr [rbx+632420h]
00007FF91DFC39AA  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC39AE  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFC39B2  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFC39B6  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC39BA  41 0F 28 C6                 movaps  xmm0, xmm14
00007FF91DFC39BE  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFC39C2  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC39C6  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC39CA  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC39CE  F3 0F 10 83 60 24 63 00     movss   xmm0, dword ptr [rbx+632460h]
00007FF91DFC39D6  F3 0F 59 83 40 22 63 00     mulss   xmm0, dword ptr [rbx+632240h]
00007FF91DFC39DE  F3 0F 59 93 70 24 63 00     mulss   xmm2, dword ptr [rbx+632470h]
00007FF91DFC39E6  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC39EA  F3 0F 59 93 80 24 63 00     mulss   xmm2, dword ptr [rbx+632480h]
00007FF91DFC39F2  F3 0F 11 93 90 25 A3 00     movss   dword ptr [rbx+0A32590h], xmm2
00007FF91DFC39FA  F3 0F 10 8B 00 25 63 00     movss   xmm1, dword ptr [rbx+632500h]
00007FF91DFC3A02  F3 0F 58 8B 50 23 63 00     addss   xmm1, dword ptr [rbx+632350h]
00007FF91DFC3A0A  F3 41 0F 59 CA              mulss   xmm1, xmm10
00007FF91DFC3A0F  F3 0F 11 8B 40 23 63 00     movss   dword ptr [rbx+632340h], xmm1
00007FF91DFC3A17  F3 0F 5C 8B 30 23 63 00     subss   xmm1, dword ptr [rbx+632330h]
00007FF91DFC3A1F  F3 0F 10 B3 60 23 63 00     movss   xmm6, dword ptr [rbx+632360h]
00007FF91DFC3A27  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFC3A2B  73 0A                       jnb     short loc_7FF91DFC3A37
00007FF91DFC3A2D  F3 0F 10 83 30 25 63 00     movss   xmm0, dword ptr [rbx+632530h]
00007FF91DFC3A35  EB 08                       jmp     short loc_7FF91DFC3A3F
00007FF91DFC3A37  F3 0F 10 83 20 25 63 00     movss   xmm0, dword ptr [rbx+632520h]
00007FF91DFC3A3F  F3 0F 10 AB 90 23 63 00     movss   xmm5, dword ptr [rbx+632390h]
00007FF91DFC3A47  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFC3A4B  F3 0F 11 AB 00 23 63 00     movss   dword ptr [rbx+632300h], xmm5
00007FF91DFC3A53  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFC3A56  F3 0F 5C 83 10 23 63 00     subss   xmm0, dword ptr [rbx+632310h]
00007FF91DFC3A5E  F3 0F 10 93 30 23 63 00     movss   xmm2, dword ptr [rbx+632330h]
00007FF91DFC3A66  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFC3A69  F3 0F 10 9B 20 23 63 00     movss   xmm3, dword ptr [rbx+632320h]
00007FF91DFC3A71  F3 0F 5C E2                 subss   xmm4, xmm2
00007FF91DFC3A75  F3 0F 10 BB 40 25 63 00     movss   xmm7, dword ptr [rbx+632540h]
00007FF91DFC3A7D  41 0F 2E C5                 ucomiss xmm0, xmm13
00007FF91DFC3A81  74 03                       jz      short loc_7FF91DFC3A86
00007FF91DFC3A83  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFC3A86  41 0F 2F E5                 comiss  xmm4, xmm13
00007FF91DFC3A8A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC3A8D  F3 0F 11 9B 10 23 63 00     movss   dword ptr [rbx+632310h], xmm3
00007FF91DFC3A95  41 0F 54 DC                 andps   xmm3, xmm12
00007FF91DFC3A99  F3 0F 59 DF                 mulss   xmm3, xmm7
00007FF91DFC3A9D  F3 0F 5C D3                 subss   xmm2, xmm3
00007FF91DFC3AA1  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFC3AA5  F3 0F 5F D5                 maxss   xmm2, xmm5
00007FF91DFC3AA9  76 07                       jbe     short loc_7FF91DFC3AB2
00007FF91DFC3AAB  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFC3AAE  F3 0F 5D D5                 minss   xmm2, xmm5
00007FF91DFC3AB2  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFC3AB6  F3 0F 11 93 20 23 63 00     movss   dword ptr [rbx+632320h], xmm2
00007FF91DFC3ABE  45 0F 57 FF                 xorps   xmm15, xmm15
00007FF91DFC3AC2  76 05                       jbe     short loc_7FF91DFC3AC9
00007FF91DFC3AC4  0F 5A C6                    cvtps2pd xmm0, xmm6
00007FF91DFC3AC7  EB 03                       jmp     short loc_7FF91DFC3ACC
00007FF91DFC3AC9  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC3ACC  F3 44 0F 10 25 0F 1A 78 00  movss   xmm12, cs:dword_7FF91E7454E4
00007FF91DFC3AD5  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFC3AD9  41 0F 2F C4                 comiss  xmm0, xmm12
00007FF91DFC3ADD  73 06                       jnb     short loc_7FF91DFC3AE5
00007FF91DFC3ADF  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFC3AE3  EB 05                       jmp     short loc_7FF91DFC3AEA
00007FF91DFC3AE5  F3 41 0F 5D C6              minss   xmm0, xmm14
00007FF91DFC3AEA  F3 0F 59 83 80 24 63 00     mulss   xmm0, dword ptr [rbx+632480h]
00007FF91DFC3AF2  F3 44 0F 10 1D BD 71 62 00  movss   xmm11, cs:dword_7FF91E5EACB8
00007FF91DFC3AFB  F3 44 0F 10 0D 9C 71 62 00  movss   xmm9, cs:dword_7FF91E5EACA0
00007FF91DFC3B04  F3 0F 11 83 50 23 63 00     movss   dword ptr [rbx+632350h], xmm0
00007FF91DFC3B0C  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC3B0F  8B 83 50 25 83 00           mov     eax, [rbx+832550h]
00007FF91DFC3B15  F3 41 0F 59 C3              mulss   xmm0, xmm11
00007FF91DFC3B1A  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFC3B1F  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC3B23  0F 5A CA                    cvtps2pd xmm1, xmm2
00007FF91DFC3B26  2B C2                       sub     eax, edx
00007FF91DFC3B28  48 63 C8                    movsxd  rcx, eax
00007FF91DFC3B2B  48 63 83 54 25 83 00        movsxd  rax, dword ptr [rbx+832554h]
00007FF91DFC3B32  48 FF C1                    inc     rcx
00007FF91DFC3B35  48 FF C8                    dec     rax
00007FF91DFC3B38  48 23 C8                    and     rcx, rax
00007FF91DFC3B3B  8B 84 8B 50 25 63 00        mov     eax, [rbx+rcx*4+632550h]
00007FF91DFC3B42  89 83 80 25 A3 00           mov     [rbx+0A32580h], eax
00007FF91DFC3B48  8B 83 50 25 83 00           mov     eax, [rbx+832550h]
00007FF91DFC3B4E  2B C2                       sub     eax, edx
00007FF91DFC3B50  48 63 C8                    movsxd  rcx, eax
00007FF91DFC3B53  48 63 83 54 25 83 00        movsxd  rax, dword ptr [rbx+832554h]
00007FF91DFC3B5A  48 83 C1 02                 add     rcx, 2
00007FF91DFC3B5E  48 FF C8                    dec     rax
00007FF91DFC3B61  48 23 C8                    and     rcx, rax
00007FF91DFC3B64  8B 84 8B 50 25 63 00        mov     eax, [rbx+rcx*4+632550h]
00007FF91DFC3B6B  89 83 84 25 A3 00           mov     [rbx+0A32584h], eax
00007FF91DFC3B71  F3 0F 2C C2                 cvttss2si eax, xmm2
00007FF91DFC3B75  66 0F 6E C0                 movd    xmm0, eax
00007FF91DFC3B79  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00007FF91DFC3B7D  F2 0F 5C C8                 subsd   xmm1, xmm0
00007FF91DFC3B81  66 44 0F 5A C1              cvtpd2ps xmm8, xmm1
00007FF91DFC3B86  F3 44 0F 11 83 88 25 A3 00  movss   dword ptr [rbx+0A32588h], xmm8
00007FF91DFC3B8F  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFC3B93  F3 0F 10 8B 80 25 A3 00     movss   xmm1, dword ptr [rbx+0A32580h]
00007FF91DFC3B9B  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFC3B9F  8B 83 60 25 A3 00           mov     eax, [rbx+0A32560h]
00007FF91DFC3BA5  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC3BA9  2B C2                       sub     eax, edx
00007FF91DFC3BAB  48 63 C8                    movsxd  rcx, eax
00007FF91DFC3BAE  48 63 83 64 25 A3 00        movsxd  rax, dword ptr [rbx+0A32564h]
00007FF91DFC3BB5  48 FF C1                    inc     rcx
00007FF91DFC3BB8  48 FF C8                    dec     rax
00007FF91DFC3BBB  48 23 C8                    and     rcx, rax
00007FF91DFC3BBE  8B 84 8B 60 25 83 00        mov     eax, [rbx+rcx*4+832560h]
00007FF91DFC3BC5  89 83 A0 25 A3 00           mov     [rbx+0A325A0h], eax
00007FF91DFC3BCB  8B 83 60 25 A3 00           mov     eax, [rbx+0A32560h]
00007FF91DFC3BD1  2B C2                       sub     eax, edx
00007FF91DFC3BD3  48 63 C8                    movsxd  rcx, eax
00007FF91DFC3BD6  48 63 83 64 25 A3 00        movsxd  rax, dword ptr [rbx+0A32564h]
00007FF91DFC3BDD  48 83 C1 02                 add     rcx, 2
00007FF91DFC3BE1  48 FF C8                    dec     rax
00007FF91DFC3BE4  48 23 C8                    and     rcx, rax
00007FF91DFC3BE7  8B 84 8B 60 25 83 00        mov     eax, [rbx+rcx*4+832560h]
00007FF91DFC3BEE  89 83 A4 25 A3 00           mov     [rbx+0A325A4h], eax
00007FF91DFC3BF4  F3 44 0F 11 83 A8 25 A3 00  movss   dword ptr [rbx+0A325A8h], xmm8
00007FF91DFC3BFD  F3 0F 59 9B 84 25 A3 00     mulss   xmm3, dword ptr [rbx+0A32584h]
00007FF91DFC3C05  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFC3C09  F3 0F 10 83 A0 21 63 00     movss   xmm0, dword ptr [rbx+6321A0h]
00007FF91DFC3C11  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFC3C15  F3 0F 59 9B 60 23 63 00     mulss   xmm3, dword ptr [rbx+632360h]
00007FF91DFC3C1D  F3 0F 11 9B 80 21 63 00     movss   dword ptr [rbx+632180h], xmm3
00007FF91DFC3C25  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFC3C29  F3 0F 10 93 B0 21 63 00     movss   xmm2, dword ptr [rbx+6321B0h]
00007FF91DFC3C31  F3 0F 10 A3 A0 24 63 00     movss   xmm4, dword ptr [rbx+6324A0h]
00007FF91DFC3C39  F3 0F 10 BB A0 25 A3 00     movss   xmm7, dword ptr [rbx+0A325A0h]
00007FF91DFC3C41  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFC3C45  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC3C48  F3 0F 59 8B 90 24 63 00     mulss   xmm1, dword ptr [rbx+632490h]
00007FF91DFC3C50  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC3C54  F3 0F 10 83 B0 24 63 00     movss   xmm0, dword ptr [rbx+6324B0h]
00007FF91DFC3C5C  F3 0F 11 8B 90 21 63 00     movss   dword ptr [rbx+632190h], xmm1
00007FF91DFC3C64  F3 0F 10 9B D0 21 63 00     movss   xmm3, dword ptr [rbx+6321D0h]
00007FF91DFC3C6C  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC3C70  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFC3C74  F3 0F 10 83 D0 24 63 00     movss   xmm0, dword ptr [rbx+6324D0h]
00007FF91DFC3C7C  F3 0F 5C E2                 subss   xmm4, xmm2
00007FF91DFC3C80  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFC3C83  F3 0F 59 8B C0 24 63 00     mulss   xmm1, dword ptr [rbx+6324C0h]
00007FF91DFC3C8B  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC3C8F  F3 0F 10 93 E0 24 63 00     movss   xmm2, dword ptr [rbx+6324E0h]
00007FF91DFC3C97  F3 0F 11 8B A0 21 63 00     movss   dword ptr [rbx+6321A0h], xmm1
00007FF91DFC3C9F  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFC3CA3  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC3CA7  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFC3CAB  F3 44 0F 59 C7              mulss   xmm8, xmm7
00007FF91DFC3CB0  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC3CB4  F3 0F 5C D3                 subss   xmm2, xmm3
00007FF91DFC3CB8  F3 0F 11 93 B0 21 63 00     movss   dword ptr [rbx+6321B0h], xmm2
00007FF91DFC3CC0  F3 0F 59 93 F0 24 63 00     mulss   xmm2, dword ptr [rbx+6324F0h]
00007FF91DFC3CC8  F3 0F 58 D3                 addss   xmm2, xmm3
00007FF91DFC3CCC  F3 0F 11 93 C0 21 63 00     movss   dword ptr [rbx+6321C0h], xmm2
00007FF91DFC3CD4  F3 0F 59 AB A4 25 A3 00     mulss   xmm5, dword ptr [rbx+0A325A4h]
00007FF91DFC3CDC  F3 0F 10 83 20 22 63 00     movss   xmm0, dword ptr [rbx+632220h]
00007FF91DFC3CE4  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFC3CE9  F3 0F 58 EF                 addss   xmm5, xmm7
00007FF91DFC3CED  F3 0F 59 AB 60 23 63 00     mulss   xmm5, dword ptr [rbx+632360h]
00007FF91DFC3CF5  F3 0F 11 AB 00 22 63 00     movss   dword ptr [rbx+632200h], xmm5
00007FF91DFC3CFD  F3 0F 5C E8                 subss   xmm5, xmm0
00007FF91DFC3D01  F3 0F 10 A3 A0 24 63 00     movss   xmm4, dword ptr [rbx+6324A0h]
00007FF91DFC3D09  F3 0F 10 93 30 22 63 00     movss   xmm2, dword ptr [rbx+632230h]
00007FF91DFC3D11  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFC3D15  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFC3D18  F3 0F 59 8B 90 24 63 00     mulss   xmm1, dword ptr [rbx+632490h]
00007FF91DFC3D20  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC3D24  F3 0F 10 83 B0 24 63 00     movss   xmm0, dword ptr [rbx+6324B0h]
00007FF91DFC3D2C  F3 0F 11 8B 10 22 63 00     movss   dword ptr [rbx+632210h], xmm1
00007FF91DFC3D34  F3 0F 10 9B 50 22 63 00     movss   xmm3, dword ptr [rbx+632250h]
00007FF91DFC3D3C  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC3D40  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFC3D44  F3 0F 10 83 D0 24 63 00     movss   xmm0, dword ptr [rbx+6324D0h]
00007FF91DFC3D4C  F3 0F 5C E2                 subss   xmm4, xmm2
00007FF91DFC3D50  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFC3D54  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFC3D57  F3 0F 59 8B C0 24 63 00     mulss   xmm1, dword ptr [rbx+6324C0h]
00007FF91DFC3D5F  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC3D63  F3 0F 10 93 E0 24 63 00     movss   xmm2, dword ptr [rbx+6324E0h]
00007FF91DFC3D6B  F3 0F 11 8B 20 22 63 00     movss   dword ptr [rbx+632220h], xmm1
00007FF91DFC3D73  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC3D77  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC3D7B  F3 0F 5C D3                 subss   xmm2, xmm3
00007FF91DFC3D7F  F3 0F 11 93 30 22 63 00     movss   dword ptr [rbx+632230h], xmm2
00007FF91DFC3D87  F3 0F 10 83 40 24 63 00     movss   xmm0, dword ptr [rbx+632440h]
00007FF91DFC3D8F  F3 0F 59 93 F0 24 63 00     mulss   xmm2, dword ptr [rbx+6324F0h]
00007FF91DFC3D97  F3 0F 10 BB 80 21 63 00     movss   xmm7, dword ptr [rbx+632180h]
00007FF91DFC3D9F  F3 44 0F 10 83 00 22 63 00  movss   xmm8, dword ptr [rbx+632200h]
00007FF91DFC3DA8  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFC3DAC  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFC3DB0  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFC3DB5  F3 0F 11 9B 40 22 63 00     movss   dword ptr [rbx+632240h], xmm3
00007FF91DFC3DBD  41 0F 28 DE                 movaps  xmm3, xmm14
00007FF91DFC3DC1  F3 0F 10 AB 70 24 63 00     movss   xmm5, dword ptr [rbx+632470h]
00007FF91DFC3DC9  F3 0F 10 A3 30 24 63 00     movss   xmm4, dword ptr [rbx+632430h]
00007FF91DFC3DD1  F3 0F 5C DD                 subss   xmm3, xmm5
00007FF91DFC3DD5  F3 0F 10 93 40 21 63 00     movss   xmm2, dword ptr [rbx+632140h]
00007FF91DFC3DDD  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFC3DE0  F3 0F 10 B3 50 21 63 00     movss   xmm6, dword ptr [rbx+632150h]
00007FF91DFC3DE8  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC3DEB  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC3DEF  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFC3DF3  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFC3DF7  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC3DFA  F3 0F 59 EC                 mulss   xmm5, xmm4
00007FF91DFC3DFE  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC3E02  F3 0F 59 DE                 mulss   xmm3, xmm6
00007FF91DFC3E06  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC3E0A  F3 0F 58 EB                 addss   xmm5, xmm3
00007FF91DFC3E0E  F3 0F 58 CF                 addss   xmm1, xmm7
00007FF91DFC3E12  F3 41 0F 58 E8              addss   xmm5, xmm8
00007FF91DFC3E17  F3 0F 11 8B 70 23 63 00     movss   dword ptr [rbx+632370h], xmm1
00007FF91DFC3E1F  F3 0F 11 AB 80 23 63 00     movss   dword ptr [rbx+632380h], xmm5
00007FF91DFC3E27  8B 8B 54 25 83 00           mov     ecx, [rbx+832554h]
00007FF91DFC3E2D  8B 83 50 25 83 00           mov     eax, [rbx+832550h]
00007FF91DFC3E33  FF C9                       dec     ecx
00007FF91DFC3E35  FF C8                       dec     eax
00007FF91DFC3E37  23 C8                       and     ecx, eax
00007FF91DFC3E39  89 8B 50 25 83 00           mov     [rbx+832550h], ecx
00007FF91DFC3E3F  8B 83 70 25 A3 00           mov     eax, [rbx+0A32570h]
00007FF91DFC3E45  48 63 C9                    movsxd  rcx, ecx
00007FF91DFC3E48  89 84 8B 50 25 63 00        mov     [rbx+rcx*4+632550h], eax
00007FF91DFC3E4F  8B 8B 64 25 A3 00           mov     ecx, [rbx+0A32564h]
00007FF91DFC3E55  FF C9                       dec     ecx
00007FF91DFC3E57  8B 83 60 25 A3 00           mov     eax, [rbx+0A32560h]
00007FF91DFC3E5D  FF C8                       dec     eax
00007FF91DFC3E5F  23 C8                       and     ecx, eax
00007FF91DFC3E61  89 8B 60 25 A3 00           mov     [rbx+0A32560h], ecx
00007FF91DFC3E67  8B 83 90 25 A3 00           mov     eax, [rbx+0A32590h]
00007FF91DFC3E6D  48 63 C9                    movsxd  rcx, ecx
00007FF91DFC3E70  89 84 8B 60 25 83 00        mov     [rbx+rcx*4+832560h], eax
00007FF91DFC3E77  F3 0F 10 8B B0 25 A3 00     movss   xmm1, dword ptr [rbx+0A325B0h]
00007FF91DFC3E7F  F3 0F 10 83 C0 25 A3 00     movss   xmm0, dword ptr [rbx+0A325C0h]
00007FF91DFC3E87  F3 0F 11 8B D0 25 A3 00     movss   dword ptr [rbx+0A325D0h], xmm1
00007FF91DFC3E8F  F3 0F 11 83 E0 25 A3 00     movss   dword ptr [rbx+0A325E0h], xmm0
00007FF91DFC3E97  F3 0F 58 8B 10 26 A3 00     addss   xmm1, dword ptr [rbx+0A32610h]
00007FF91DFC3E9F  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFC3EA2  E8 19 4F 00 00              call    sub_7FF91DFC8DC0
00007FF91DFC3EA7  F3 44 0F 10 15 38 13 78 00  movss   xmm10, cs:flt_7FF91E7451E8
00007FF91DFC3EB0  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFC3EB3  F2 0F 5A C8                 cvtsd2ss xmm1, xmm0
00007FF91DFC3EB7  F3 0F 5D 0D D9 6D 62 00     minss   xmm1, cs:dword_7FF91E5EAC98
00007FF91DFC3EBF  F3 0F 5F 0D E9 6D 62 00     maxss   xmm1, cs:dword_7FF91E5EACB0
00007FF91DFC3EC7  F3 0F 11 8B F0 25 A3 00     movss   dword ptr [rbx+0A325F0h], xmm1
00007FF91DFC3ECF  F3 0F 10 83 D0 26 A3 00     movss   xmm0, dword ptr [rbx+0A326D0h]
00007FF91DFC3ED7  F3 0F 10 BB E0 25 A3 00     movss   xmm7, dword ptr [rbx+0A325E0h]
00007FF91DFC3EDF  F3 0F 11 83 E0 26 A3 00     movss   dword ptr [rbx+0A326E0h], xmm0
00007FF91DFC3EE7  F3 0F 59 8B 00 27 A3 00     mulss   xmm1, dword ptr [rbx+0A32700h]
00007FF91DFC3EEF  0F 2F 0D DA 13 78 00        comiss  xmm1, cs:dword_7FF91E7452D0
00007FF91DFC3EF6  72 0A                       jb      short loc_7FF91DFC3F02
00007FF91DFC3EF8  F3 0F 58 0D 10 16 78 00     addss   xmm1, cs:dword_7FF91E745510
00007FF91DFC3F00  EB 0E                       jmp     short loc_7FF91DFC3F10
00007FF91DFC3F02  41 0F 2F CA                 comiss  xmm1, xmm10
00007FF91DFC3F06  72 08                       jb      short loc_7FF91DFC3F10
00007FF91DFC3F08  F3 0F 58 0D E8 15 78 00     addss   xmm1, cs:dword_7FF91E7454F8
00007FF91DFC3F10  41 0F 2E CD                 ucomiss xmm1, xmm13
00007FF91DFC3F14  75 08                       jnz     short loc_7FF91DFC3F1E
00007FF91DFC3F16  F3 0F 10 8B 10 27 A3 00     movss   xmm1, dword ptr [rbx+0A32710h]
00007FF91DFC3F1E  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFC3F22  E8 69 50 00 00              call    sub_7FF91DFC8F90
00007FF91DFC3F27  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFC3F2A  E8 91 50 00 00              call    sub_7FF91DFC8FC0
00007FF91DFC3F2F  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFC3F32  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFC3F36  F3 0F 11 AB F0 26 A3 00     movss   dword ptr [rbx+0A326F0h], xmm5
00007FF91DFC3F3E  F3 41 0F 5C FE              subss   xmm7, xmm14
00007FF91DFC3F43  F3 0F 58 F7                 addss   xmm6, xmm7
00007FF91DFC3F47  F3 0F 11 B3 D0 26 A3 00     movss   dword ptr [rbx+0A326D0h], xmm6
00007FF91DFC3F4F  F3 0F 59 AB 30 27 A3 00     mulss   xmm5, dword ptr [rbx+0A32730h]
00007FF91DFC3F57  F3 0F 58 AB 40 27 A3 00     addss   xmm5, dword ptr [rbx+0A32740h]
00007FF91DFC3F5F  F3 0F 11 AB 20 27 A3 00     movss   dword ptr [rbx+0A32720h], xmm5
00007FF91DFC3F67  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFC3F6A  F3 0F 10 8B 80 23 63 00     movss   xmm1, dword ptr [rbx+632380h]
00007FF91DFC3F72  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFC3F75  8B 83 C0 27 A3 00           mov     eax, [rbx+0A327C0h]
00007FF91DFC3F7B  F3 0F 10 B3 70 23 63 00     movss   xmm6, dword ptr [rbx+632370h]
00007FF91DFC3F83  89 83 D0 27 A3 00           mov     [rbx+0A327D0h], eax
00007FF91DFC3F89  8B 83 B0 27 A3 00           mov     eax, [rbx+0A327B0h]
00007FF91DFC3F8F  89 83 C0 27 A3 00           mov     [rbx+0A327C0h], eax
00007FF91DFC3F95  8B 83 A0 27 A3 00           mov     eax, [rbx+0A327A0h]
00007FF91DFC3F9B  89 83 B0 27 A3 00           mov     [rbx+0A327B0h], eax
00007FF91DFC3FA1  8B 83 90 27 A3 00           mov     eax, [rbx+0A32790h]
00007FF91DFC3FA7  89 83 A0 27 A3 00           mov     [rbx+0A327A0h], eax
00007FF91DFC3FAD  8B 83 80 27 A3 00           mov     eax, [rbx+0A32780h]
00007FF91DFC3FB3  89 83 90 27 A3 00           mov     [rbx+0A32790h], eax
00007FF91DFC3FB9  8B 83 20 28 A3 00           mov     eax, [rbx+0A32820h]
00007FF91DFC3FBF  89 83 30 28 A3 00           mov     [rbx+0A32830h], eax
00007FF91DFC3FC5  8B 83 10 28 A3 00           mov     eax, [rbx+0A32810h]
00007FF91DFC3FCB  89 83 20 28 A3 00           mov     [rbx+0A32820h], eax
00007FF91DFC3FD1  8B 83 00 28 A3 00           mov     eax, [rbx+0A32800h]
00007FF91DFC3FD7  F3 0F 59 15 2D 10 78 00     mulss   xmm2, cs:dword_7FF91E74500C
00007FF91DFC3FDF  89 83 10 28 A3 00           mov     [rbx+0A32810h], eax
00007FF91DFC3FE5  8B 83 F0 27 A3 00           mov     eax, [rbx+0A327F0h]
00007FF91DFC3FEB  89 83 00 28 A3 00           mov     [rbx+0A32800h], eax
00007FF91DFC3FF1  8B 83 E0 27 A3 00           mov     eax, [rbx+0A327E0h]
00007FF91DFC3FF7  89 83 F0 27 A3 00           mov     [rbx+0A327F0h], eax
00007FF91DFC3FFD  8B 83 70 28 A3 00           mov     eax, [rbx+0A32870h]
00007FF91DFC4003  89 83 80 28 A3 00           mov     [rbx+0A32880h], eax
00007FF91DFC4009  8B 83 60 28 A3 00           mov     eax, [rbx+0A32860h]
00007FF91DFC400F  89 83 70 28 A3 00           mov     [rbx+0A32870h], eax
00007FF91DFC4015  8B 83 50 28 A3 00           mov     eax, [rbx+0A32850h]
00007FF91DFC401B  89 83 60 28 A3 00           mov     [rbx+0A32860h], eax
00007FF91DFC4021  8B 83 40 28 A3 00           mov     eax, [rbx+0A32840h]
00007FF91DFC4027  89 83 50 28 A3 00           mov     [rbx+0A32850h], eax
00007FF91DFC402D  8B 83 C0 28 A3 00           mov     eax, [rbx+0A328C0h]
00007FF91DFC4033  89 83 D0 28 A3 00           mov     [rbx+0A328D0h], eax
00007FF91DFC4039  8B 83 B0 28 A3 00           mov     eax, [rbx+0A328B0h]
00007FF91DFC403F  89 83 C0 28 A3 00           mov     [rbx+0A328C0h], eax
00007FF91DFC4045  8B 83 A0 28 A3 00           mov     eax, [rbx+0A328A0h]
00007FF91DFC404B  89 83 B0 28 A3 00           mov     [rbx+0A328B0h], eax
00007FF91DFC4051  8B 83 90 28 A3 00           mov     eax, [rbx+0A32890h]
00007FF91DFC4057  89 83 A0 28 A3 00           mov     [rbx+0A328A0h], eax
00007FF91DFC405D  8B 83 E0 28 A3 00           mov     eax, [rbx+0A328E0h]
00007FF91DFC4063  89 83 F0 28 A3 00           mov     [rbx+0A328F0h], eax
00007FF91DFC4069  8B 83 10 29 A3 00           mov     eax, [rbx+0A32910h]
00007FF91DFC406F  89 83 20 29 A3 00           mov     [rbx+0A32920h], eax
00007FF91DFC4075  8B 83 00 29 A3 00           mov     eax, [rbx+0A32900h]
00007FF91DFC407B  89 83 10 29 A3 00           mov     [rbx+0A32910h], eax
00007FF91DFC4081  F3 0F 11 AB 70 27 A3 00     movss   dword ptr [rbx+0A32770h], xmm5
00007FF91DFC4089  F3 0F 10 83 B0 29 A3 00     movss   xmm0, dword ptr [rbx+0A329B0h]
00007FF91DFC4091  F3 0F 59 A3 E0 2A A3 00     mulss   xmm4, dword ptr [rbx+0A32AE0h]
00007FF91DFC4099  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC409D  F3 0F 58 A3 F0 2A A3 00     addss   xmm4, dword ptr [rbx+0A32AF0h]
00007FF91DFC40A5  F3 0F 11 B3 50 27 A3 00     movss   dword ptr [rbx+0A32750h], xmm6
00007FF91DFC40AD  F3 0F 11 8B 60 27 A3 00     movss   dword ptr [rbx+0A32760h], xmm1
00007FF91DFC40B5  F3 0F 10 8B A0 29 A3 00     movss   xmm1, dword ptr [rbx+0A329A0h]
00007FF91DFC40BD  F3 0F 59 D2                 mulss   xmm2, xmm2
00007FF91DFC40C1  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFC40C4  F3 0F 59 1D 40 0F 78 00     mulss   xmm3, cs:dword_7FF91E74500C
00007FF91DFC40CC  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC40D0  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFC40D4  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC40D7  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC40DB  F3 0F 59 DB                 mulss   xmm3, xmm3
00007FF91DFC40DF  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC40E3  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFC40E7  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC40EB  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFC40EF  F3 0F 5C D9                 subss   xmm3, xmm1
00007FF91DFC40F3  F3 0F 10 8B 00 2B A3 00     movss   xmm1, dword ptr [rbx+0A32B00h]
00007FF91DFC40FB  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFC40FF  F3 0F 10 9B C0 29 A3 00     movss   xmm3, dword ptr [rbx+0A329C0h]
00007FF91DFC4107  F3 0F 10 93 10 2B A3 00     movss   xmm2, dword ptr [rbx+0A32B10h]
00007FF91DFC410F  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC4112  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC4116  41 0F 28 EE                 movaps  xmm5, xmm14
00007FF91DFC411A  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFC411E  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFC4121  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC4125  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFC4129  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFC412D  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFC4131  F3 0F 11 83 30 29 A3 00     movss   dword ptr [rbx+0A32930h], xmm0
00007FF91DFC4139  F3 0F 11 9B 40 29 A3 00     movss   dword ptr [rbx+0A32940h], xmm3
00007FF91DFC4141  F3 0F 11 B3 40 28 A3 00     movss   dword ptr [rbx+0A32840h], xmm6
00007FF91DFC4149  F3 0F 59 A3 D0 29 A3 00     mulss   xmm4, dword ptr [rbx+0A329D0h]
00007FF91DFC4151  F3 0F 10 83 E0 29 A3 00     movss   xmm0, dword ptr [rbx+0A329E0h]
00007FF91DFC4159  F3 0F 59 83 50 28 A3 00     mulss   xmm0, dword ptr [rbx+0A32850h]
00007FF91DFC4161  F3 0F 10 8B F0 29 A3 00     movss   xmm1, dword ptr [rbx+0A329F0h]
00007FF91DFC4169  F3 0F 59 8B 60 28 A3 00     mulss   xmm1, dword ptr [rbx+0A32860h]
00007FF91DFC4171  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC4175  F3 0F 10 83 00 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A00h]
00007FF91DFC417D  F3 0F 59 83 70 28 A3 00     mulss   xmm0, dword ptr [rbx+0A32870h]
00007FF91DFC4185  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC4189  F3 0F 10 8B 80 28 A3 00     movss   xmm1, dword ptr [rbx+0A32880h]
00007FF91DFC4191  F3 0F 59 8B 10 2A A3 00     mulss   xmm1, dword ptr [rbx+0A32A10h]
00007FF91DFC4199  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC419D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC41A1  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFC41A4  F3 0F 11 A3 60 28 A3 00     movss   dword ptr [rbx+0A32860h], xmm4
00007FF91DFC41AC  F3 0F 10 93 90 27 A3 00     movss   xmm2, dword ptr [rbx+0A32790h]
00007FF91DFC41B4  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC41B7  F3 0F 59 83 40 2A A3 00     mulss   xmm0, dword ptr [rbx+0A32A40h]
00007FF91DFC41BF  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC41C3  F3 0F 5C 8B A0 27 A3 00     subss   xmm1, dword ptr [rbx+0A327A0h]
00007FF91DFC41CB  F3 0F 59 8B 30 2A A3 00     mulss   xmm1, dword ptr [rbx+0A32A30h]
00007FF91DFC41D3  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC41D7  F3 0F 11 8B 80 27 A3 00     movss   dword ptr [rbx+0A32780h], xmm1
00007FF91DFC41DF  F3 0F 10 9B 90 27 A3 00     movss   xmm3, dword ptr [rbx+0A32790h]
00007FF91DFC41E7  F3 0F 59 9B 30 2A A3 00     mulss   xmm3, dword ptr [rbx+0A32A30h]
00007FF91DFC41EF  F3 0F 58 9B A0 27 A3 00     addss   xmm3, dword ptr [rbx+0A327A0h]
00007FF91DFC41F7  F3 0F 11 9B 90 27 A3 00     movss   dword ptr [rbx+0A32790h], xmm3
00007FF91DFC41FF  F3 0F 10 83 20 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A20h]
00007FF91DFC4207  F3 0F 10 8B 50 2A A3 00     movss   xmm1, dword ptr [rbx+0A32A50h]
00007FF91DFC420F  F3 0F 5C E8                 subss   xmm5, xmm0
00007FF91DFC4213  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFC4217  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFC421B  F3 0F 10 9B B0 27 A3 00     movss   xmm3, dword ptr [rbx+0A327B0h]
00007FF91DFC4223  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC4227  41 0F 28 C6                 movaps  xmm0, xmm14
00007FF91DFC422B  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFC422F  F3 0F 59 E9                 mulss   xmm5, xmm1
00007FF91DFC4233  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFC4237  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC423B  F3 0F 10 83 70 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A70h]
00007FF91DFC4243  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFC4246  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC424A  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFC424D  F3 0F 5C E3                 subss   xmm4, xmm3
00007FF91DFC4251  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC4255  F3 0F 59 A3 60 2A A3 00     mulss   xmm4, dword ptr [rbx+0A32A60h]
00007FF91DFC425D  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC4261  F3 0F 10 83 C0 2A A3 00     movss   xmm0, dword ptr [rbx+0A32AC0h]
00007FF91DFC4269  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFC426D  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFC4271  F3 0F 10 8B B0 2A A3 00     movss   xmm1, dword ptr [rbx+0A32AB0h]
00007FF91DFC4279  F3 0F 11 A3 A0 27 A3 00     movss   dword ptr [rbx+0A327A0h], xmm4
00007FF91DFC4281  F3 0F 59 8B C0 27 A3 00     mulss   xmm1, dword ptr [rbx+0A327C0h]
00007FF91DFC4289  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC428D  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC4291  F3 0F 59 8B D0 2A A3 00     mulss   xmm1, dword ptr [rbx+0A32AD0h]
00007FF91DFC4299  F3 0F 11 8B 90 2B A4 00     movss   dword ptr [rbx+0A42B90h], xmm1
00007FF91DFC42A1  F3 0F 10 AB 60 27 A3 00     movss   xmm5, dword ptr [rbx+0A32760h]
00007FF91DFC42A9  F3 0F 11 AB 90 28 A3 00     movss   dword ptr [rbx+0A32890h], xmm5
00007FF91DFC42B1  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFC42B4  F3 0F 10 83 A0 28 A3 00     movss   xmm0, dword ptr [rbx+0A328A0h]
00007FF91DFC42BC  F3 0F 59 83 E0 29 A3 00     mulss   xmm0, dword ptr [rbx+0A329E0h]
00007FF91DFC42C4  F3 0F 59 A3 D0 29 A3 00     mulss   xmm4, dword ptr [rbx+0A329D0h]
00007FF91DFC42CC  F3 0F 10 8B B0 28 A3 00     movss   xmm1, dword ptr [rbx+0A328B0h]
00007FF91DFC42D4  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC42D8  F3 0F 59 8B F0 29 A3 00     mulss   xmm1, dword ptr [rbx+0A329F0h]
00007FF91DFC42E0  41 0F 28 F6                 movaps  xmm6, xmm14
00007FF91DFC42E4  F3 0F 10 83 00 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A00h]
00007FF91DFC42EC  F3 0F 59 83 C0 28 A3 00     mulss   xmm0, dword ptr [rbx+0A328C0h]
00007FF91DFC42F4  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC42F8  F3 0F 10 8B D0 28 A3 00     movss   xmm1, dword ptr [rbx+0A328D0h]
00007FF91DFC4300  F3 0F 59 8B 10 2A A3 00     mulss   xmm1, dword ptr [rbx+0A32A10h]
00007FF91DFC4308  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC430C  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC4310  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFC4313  F3 0F 11 A3 B0 28 A3 00     movss   dword ptr [rbx+0A328B0h], xmm4
00007FF91DFC431B  F3 0F 10 93 F0 27 A3 00     movss   xmm2, dword ptr [rbx+0A327F0h]
00007FF91DFC4323  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC4326  F3 0F 59 83 40 2A A3 00     mulss   xmm0, dword ptr [rbx+0A32A40h]
00007FF91DFC432E  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC4332  F3 0F 5C 8B 00 28 A3 00     subss   xmm1, dword ptr [rbx+0A32800h]
00007FF91DFC433A  F3 0F 59 8B 30 2A A3 00     mulss   xmm1, dword ptr [rbx+0A32A30h]
00007FF91DFC4342  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC4346  F3 0F 11 8B E0 27 A3 00     movss   dword ptr [rbx+0A327E0h], xmm1
00007FF91DFC434E  F3 0F 10 9B F0 27 A3 00     movss   xmm3, dword ptr [rbx+0A327F0h]
00007FF91DFC4356  F3 0F 59 9B 30 2A A3 00     mulss   xmm3, dword ptr [rbx+0A32A30h]
00007FF91DFC435E  F3 0F 58 9B 00 28 A3 00     addss   xmm3, dword ptr [rbx+0A32800h]
00007FF91DFC4366  F3 0F 11 9B F0 27 A3 00     movss   dword ptr [rbx+0A327F0h], xmm3
00007FF91DFC436E  F3 0F 10 83 20 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A20h]
00007FF91DFC4376  F3 0F 10 8B 50 2A A3 00     movss   xmm1, dword ptr [rbx+0A32A50h]
00007FF91DFC437E  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFC4382  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFC4386  F3 0F 59 F3                 mulss   xmm6, xmm3
00007FF91DFC438A  F3 0F 10 9B 10 28 A3 00     movss   xmm3, dword ptr [rbx+0A32810h]
00007FF91DFC4392  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFC4396  41 0F 28 C6                 movaps  xmm0, xmm14
00007FF91DFC439A  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFC439E  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFC43A2  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC43A6  F3 0F 10 AB B0 2A A3 00     movss   xmm5, dword ptr [rbx+0A32AB0h]
00007FF91DFC43AE  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFC43B2  F3 0F 10 83 70 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A70h]
00007FF91DFC43BA  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFC43BD  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFC43C1  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFC43C4  F3 0F 5C E3                 subss   xmm4, xmm3
00007FF91DFC43C8  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC43CC  F3 0F 59 A3 60 2A A3 00     mulss   xmm4, dword ptr [rbx+0A32A60h]
00007FF91DFC43D4  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC43D8  F3 0F 10 83 C0 2A A3 00     movss   xmm0, dword ptr [rbx+0A32AC0h]
00007FF91DFC43E0  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFC43E4  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFC43E8  F3 0F 11 A3 00 28 A3 00     movss   dword ptr [rbx+0A32800h], xmm4
00007FF91DFC43F0  F3 0F 10 93 D0 2A A3 00     movss   xmm2, dword ptr [rbx+0A32AD0h]
00007FF91DFC43F8  F3 0F 59 AB 20 28 A3 00     mulss   xmm5, dword ptr [rbx+0A32820h]
00007FF91DFC4400  F3 0F 10 8B 30 2B A3 00     movss   xmm1, dword ptr [rbx+0A32B30h]
00007FF91DFC4408  F3 0F 58 8B 10 29 A3 00     addss   xmm1, dword ptr [rbx+0A32910h]
00007FF91DFC4410  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFC4414  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC4418  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC441B  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC441F  F3 0F 11 83 B0 2B A4 00     movss   dword ptr [rbx+0A42BB0h], xmm0
00007FF91DFC4427  F3 0F 10 9B 40 2B A3 00     movss   xmm3, dword ptr [rbx+0A32B40h]
00007FF91DFC442F  F3 0F 5D D9                 minss   xmm3, xmm1
00007FF91DFC4433  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFC4437  F3 0F 11 9B 00 29 A3 00     movss   dword ptr [rbx+0A32900h], xmm3
00007FF91DFC443F  F3 0F 5C 9B F0 28 A3 00     subss   xmm3, dword ptr [rbx+0A328F0h]
00007FF91DFC4447  F3 0F 10 93 20 29 A3 00     movss   xmm2, dword ptr [rbx+0A32920h]
00007FF91DFC444F  41 0F 2F DD                 comiss  xmm3, xmm13
00007FF91DFC4453  73 0A                       jnb     short loc_7FF91DFC445F
00007FF91DFC4455  F3 0F 58 93 60 2B A3 00     addss   xmm2, dword ptr [rbx+0A32B60h]
00007FF91DFC445D  EB 08                       jmp     short loc_7FF91DFC4467
00007FF91DFC445F  F3 0F 58 93 50 2B A3 00     addss   xmm2, dword ptr [rbx+0A32B50h]
00007FF91DFC4467  41 0F 2F D5                 comiss  xmm2, xmm13
00007FF91DFC446B  F3 0F 10 9B 90 29 A3 00     movss   xmm3, dword ptr [rbx+0A32990h]
00007FF91DFC4473  F3 0F 10 A3 F0 28 A3 00     movss   xmm4, dword ptr [rbx+0A328F0h]
00007FF91DFC447B  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC447E  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFC4482  76 05                       jbe     short loc_7FF91DFC4489
00007FF91DFC4484  0F 5A C2                    cvtps2pd xmm0, xmm2
00007FF91DFC4487  EB 03                       jmp     short loc_7FF91DFC448C
00007FF91DFC4489  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC448C  F3 0F 59 8B A0 2A A3 00     mulss   xmm1, dword ptr [rbx+0A32AA0h]
00007FF91DFC4494  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFC4498  F3 0F 58 CC                 addss   xmm1, xmm4
00007FF91DFC449C  41 0F 2F C4                 comiss  xmm0, xmm12
00007FF91DFC44A0  73 06                       jnb     short loc_7FF91DFC44A8
00007FF91DFC44A2  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFC44A6  EB 05                       jmp     short loc_7FF91DFC44AD
00007FF91DFC44A8  F3 41 0F 5D C6              minss   xmm0, xmm14
00007FF91DFC44AD  F3 0F 59 83 D0 2A A3 00     mulss   xmm0, dword ptr [rbx+0A32AD0h]
00007FF91DFC44B5  F3 0F 11 83 10 29 A3 00     movss   dword ptr [rbx+0A32910h], xmm0
00007FF91DFC44BD  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC44C0  F3 0F 5C C4                 subss   xmm0, xmm4
00007FF91DFC44C4  41 0F 2E C5                 ucomiss xmm0, xmm13
00007FF91DFC44C8  74 03                       jz      short loc_7FF91DFC44CD
00007FF91DFC44CA  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFC44CD  F3 0F 11 9B E0 28 A3 00     movss   dword ptr [rbx+0A328E0h], xmm3
00007FF91DFC44D5  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFC44D8  F3 0F 58 9B 30 29 A3 00     addss   xmm3, dword ptr [rbx+0A32930h]
00007FF91DFC44E0  8B 83 70 AB A3 00           mov     eax, [rbx+0A3AB70h]
00007FF91DFC44E6  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC44E9  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFC44EE  F3 41 0F 59 C3              mulss   xmm0, xmm11
00007FF91DFC44F3  0F 5A CB                    cvtps2pd xmm1, xmm3
00007FF91DFC44F6  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC44FA  2B C2                       sub     eax, edx
00007FF91DFC44FC  48 63 C8                    movsxd  rcx, eax
00007FF91DFC44FF  48 63 83 74 AB A3 00        movsxd  rax, dword ptr [rbx+0A3AB74h]
00007FF91DFC4506  48 FF C1                    inc     rcx
00007FF91DFC4509  48 FF C8                    dec     rax
00007FF91DFC450C  48 23 C8                    and     rcx, rax
00007FF91DFC450F  8B 84 8B 70 2B A3 00        mov     eax, [rbx+rcx*4+0A32B70h]
00007FF91DFC4516  89 83 A0 2B A4 00           mov     [rbx+0A42BA0h], eax
00007FF91DFC451C  8B 83 70 AB A3 00           mov     eax, [rbx+0A3AB70h]
00007FF91DFC4522  2B C2                       sub     eax, edx
00007FF91DFC4524  48 63 C8                    movsxd  rcx, eax
00007FF91DFC4527  48 63 83 74 AB A3 00        movsxd  rax, dword ptr [rbx+0A3AB74h]
00007FF91DFC452E  48 83 C1 02                 add     rcx, 2
00007FF91DFC4532  48 FF C8                    dec     rax
00007FF91DFC4535  48 23 C8                    and     rcx, rax
00007FF91DFC4538  8B 84 8B 70 2B A3 00        mov     eax, [rbx+rcx*4+0A32B70h]
00007FF91DFC453F  89 83 A4 2B A4 00           mov     [rbx+0A42BA4h], eax
00007FF91DFC4545  F3 0F 2C C3                 cvttss2si eax, xmm3
00007FF91DFC4549  66 0F 6E C0                 movd    xmm0, eax
00007FF91DFC454D  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00007FF91DFC4551  F2 0F 5C C8                 subsd   xmm1, xmm0
00007FF91DFC4555  66 0F 5A E9                 cvtpd2ps xmm5, xmm1
00007FF91DFC4559  F3 0F 11 AB A8 2B A4 00     movss   dword ptr [rbx+0A42BA8h], xmm5
00007FF91DFC4561  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFC4564  F3 0F 58 A3 40 29 A3 00     addss   xmm4, dword ptr [rbx+0A32940h]
00007FF91DFC456C  F3 0F 10 9B A0 2B A4 00     movss   xmm3, dword ptr [rbx+0A42BA0h]
00007FF91DFC4574  8B 83 80 2B A4 00           mov     eax, [rbx+0A42B80h]
00007FF91DFC457A  F3 0F 10 B3 20 29 A3 00     movss   xmm6, dword ptr [rbx+0A32920h]
00007FF91DFC4582  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFC4586  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC4589  F3 41 0F 59 E1              mulss   xmm4, xmm9
00007FF91DFC458E  F3 41 0F 59 C3              mulss   xmm0, xmm11
00007FF91DFC4593  0F 5A CC                    cvtps2pd xmm1, xmm4
00007FF91DFC4596  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC459A  2B C2                       sub     eax, edx
00007FF91DFC459C  48 63 C8                    movsxd  rcx, eax
00007FF91DFC459F  48 63 83 84 2B A4 00        movsxd  rax, dword ptr [rbx+0A42B84h]
00007FF91DFC45A6  48 FF C1                    inc     rcx
00007FF91DFC45A9  48 FF C8                    dec     rax
00007FF91DFC45AC  48 23 C8                    and     rcx, rax
00007FF91DFC45AF  8B 84 8B 80 AB A3 00        mov     eax, [rbx+rcx*4+0A3AB80h]
00007FF91DFC45B6  89 83 C0 2B A4 00           mov     [rbx+0A42BC0h], eax
00007FF91DFC45BC  8B 83 80 2B A4 00           mov     eax, [rbx+0A42B80h]
00007FF91DFC45C2  2B C2                       sub     eax, edx
00007FF91DFC45C4  48 63 C8                    movsxd  rcx, eax
00007FF91DFC45C7  48 63 83 84 2B A4 00        movsxd  rax, dword ptr [rbx+0A42B84h]
00007FF91DFC45CE  48 83 C1 02                 add     rcx, 2
00007FF91DFC45D2  48 FF C8                    dec     rax
00007FF91DFC45D5  48 23 C8                    and     rcx, rax
00007FF91DFC45D8  8B 84 8B 80 AB A3 00        mov     eax, [rbx+rcx*4+0A3AB80h]
00007FF91DFC45DF  89 83 C4 2B A4 00           mov     [rbx+0A42BC4h], eax
00007FF91DFC45E5  F3 0F 2C C4                 cvttss2si eax, xmm4
00007FF91DFC45E9  66 0F 6E C0                 movd    xmm0, eax
00007FF91DFC45ED  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00007FF91DFC45F1  F2 0F 5C C8                 subsd   xmm1, xmm0
00007FF91DFC45F5  66 0F 5A E1                 cvtpd2ps xmm4, xmm1
00007FF91DFC45F9  F3 0F 11 A3 C8 2B A4 00     movss   dword ptr [rbx+0A42BC8h], xmm4
00007FF91DFC4601  44 0F 28 C4                 movaps  xmm8, xmm4
00007FF91DFC4605  F3 0F 59 BB A4 2B A4 00     mulss   xmm7, dword ptr [rbx+0A42BA4h]
00007FF91DFC460D  F3 0F 10 83 D0 27 A3 00     movss   xmm0, dword ptr [rbx+0A327D0h]
00007FF91DFC4615  F3 0F 5C FD                 subss   xmm7, xmm5
00007FF91DFC4619  F3 0F 58 FB                 addss   xmm7, xmm3
00007FF91DFC461D  F3 0F 10 9B C0 2B A4 00     movss   xmm3, dword ptr [rbx+0A42BC0h]
00007FF91DFC4625  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFC4629  F3 0F 59 FE                 mulss   xmm7, xmm6
00007FF91DFC462D  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFC4630  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC4634  F3 0F 11 8B B0 27 A3 00     movss   dword ptr [rbx+0A327B0h], xmm1
00007FF91DFC463C  F3 0F 59 8B 20 2B A3 00     mulss   xmm1, dword ptr [rbx+0A32B20h]
00007FF91DFC4644  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC4648  F3 0F 11 8B C0 27 A3 00     movss   dword ptr [rbx+0A327C0h], xmm1
00007FF91DFC4650  F3 44 0F 59 83 C4 2B A4 00  mulss   xmm8, dword ptr [rbx+0A42BC4h]
00007FF91DFC4659  F3 0F 10 8B 30 28 A3 00     movss   xmm1, dword ptr [rbx+0A32830h]
00007FF91DFC4661  F3 44 0F 5C C4              subss   xmm8, xmm4
00007FF91DFC4666  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFC466B  F3 44 0F 59 C6              mulss   xmm8, xmm6
00007FF91DFC4670  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFC4674  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFC4678  F3 0F 11 93 10 28 A3 00     movss   dword ptr [rbx+0A32810h], xmm2
00007FF91DFC4680  F3 0F 59 93 20 2B A3 00     mulss   xmm2, dword ptr [rbx+0A32B20h]
00007FF91DFC4688  F3 0F 10 83 90 2A A3 00     movss   xmm0, dword ptr [rbx+0A32A90h]
00007FF91DFC4690  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFC4694  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC4698  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFC469D  F3 0F 11 93 20 28 A3 00     movss   dword ptr [rbx+0A32820h], xmm2
00007FF91DFC46A5  41 0F 28 D6                 movaps  xmm2, xmm14
00007FF91DFC46A9  F3 0F 10 B3 60 27 A3 00     movss   xmm6, dword ptr [rbx+0A32760h]
00007FF91DFC46B1  F3 0F 10 9B 50 27 A3 00     movss   xmm3, dword ptr [rbx+0A32750h]
00007FF91DFC46B9  F3 0F 10 AB 80 2A A3 00     movss   xmm5, dword ptr [rbx+0A32A80h]
00007FF91DFC46C1  F3 0F 11 BB 50 29 A3 00     movss   dword ptr [rbx+0A32950h], xmm7
00007FF91DFC46C9  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFC46CC  F3 44 0F 11 83 60 29 A3 00  movss   dword ptr [rbx+0A32960h], xmm8
00007FF91DFC46D5  F3 0F 10 A3 C0 2A A3 00     movss   xmm4, dword ptr [rbx+0A32AC0h]
00007FF91DFC46DD  F3 0F 5C D4                 subss   xmm2, xmm4
00007FF91DFC46E1  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFC46E5  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFC46E8  F3 0F 59 EE                 mulss   xmm5, xmm6
00007FF91DFC46EC  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFC46F0  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC46F3  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFC46F7  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFC46FB  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFC46FF  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFC4703  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC4707  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFC470C  F3 0F 58 8B 50 29 A3 00     addss   xmm1, dword ptr [rbx+0A32950h]
00007FF91DFC4714  F3 0F 11 8B 70 29 A3 00     movss   dword ptr [rbx+0A32970h], xmm1
00007FF91DFC471C  F3 0F 11 A3 80 29 A3 00     movss   dword ptr [rbx+0A32980h], xmm4
00007FF91DFC4724  8B 8B 74 AB A3 00           mov     ecx, [rbx+0A3AB74h]
00007FF91DFC472A  8B 83 70 AB A3 00           mov     eax, [rbx+0A3AB70h]
00007FF91DFC4730  FF C9                       dec     ecx
00007FF91DFC4732  FF C8                       dec     eax
00007FF91DFC4734  23 C8                       and     ecx, eax
00007FF91DFC4736  89 8B 70 AB A3 00           mov     [rbx+0A3AB70h], ecx
00007FF91DFC473C  8B 83 90 2B A4 00           mov     eax, [rbx+0A42B90h]
00007FF91DFC4742  48 63 C9                    movsxd  rcx, ecx
00007FF91DFC4745  89 84 8B 70 2B A3 00        mov     [rbx+rcx*4+0A32B70h], eax
00007FF91DFC474C  8B 8B 80 2B A4 00           mov     ecx, [rbx+0A42B80h]
00007FF91DFC4752  8B 83 84 2B A4 00           mov     eax, [rbx+0A42B84h]
00007FF91DFC4758  FF C9                       dec     ecx
00007FF91DFC475A  FF C8                       dec     eax
00007FF91DFC475C  23 C8                       and     ecx, eax
00007FF91DFC475E  89 8B 80 2B A4 00           mov     [rbx+0A42B80h], ecx
00007FF91DFC4764  8B 83 B0 2B A4 00           mov     eax, [rbx+0A42BB0h]
00007FF91DFC476A  48 63 C9                    movsxd  rcx, ecx
00007FF91DFC476D  89 84 8B 80 AB A3 00        mov     [rbx+rcx*4+0A3AB80h], eax
00007FF91DFC4774  F3 0F 10 B3 70 8D 01 00     movss   xmm6, dword ptr [rbx+18D70h]
00007FF91DFC477C  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFC477F  F3 0F 59 B3 80 29 A3 00     mulss   xmm6, dword ptr [rbx+0A32980h]
00007FF91DFC4787  F3 0F 59 BB 70 29 A3 00     mulss   xmm7, dword ptr [rbx+0A32970h]
00007FF91DFC478F  E9 E6 1F 00 00              jmp     loc_7FF91DFC677A
00007FF91DFC4794  83 BB 0C 30 A8 00 04        cmp     dword ptr [rbx+0A8300Ch], 4
00007FF91DFC479B  74 12                       jz      short loc_7FF91DFC47AF
00007FF91DFC479D  89 B3 70 1E 62 00           mov     [rbx+621E70h], esi
00007FF91DFC47A3  89 B3 80 1E 62 00           mov     [rbx+621E80h], esi
00007FF91DFC47A9  89 B3 90 1E 62 00           mov     [rbx+621E90h], esi
00007FF91DFC47AF  C7 83 0C 30 A8 00 04 00 00 00  mov     dword ptr [rbx+0A8300Ch], 4
00007FF91DFC47B9  F3 0F 10 8B 20 1B 62 00     movss   xmm1, dword ptr [rbx+621B20h]
00007FF91DFC47C1  F3 0F 10 83 30 1B 62 00     movss   xmm0, dword ptr [rbx+621B30h]
00007FF91DFC47C9  F3 0F 11 8B 40 1B 62 00     movss   dword ptr [rbx+621B40h], xmm1
00007FF91DFC47D1  F3 0F 11 83 50 1B 62 00     movss   dword ptr [rbx+621B50h], xmm0
00007FF91DFC47D9  F3 0F 58 8B 80 1B 62 00     addss   xmm1, dword ptr [rbx+621B80h]
00007FF91DFC47E1  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFC47E4  E8 D7 45 00 00              call    sub_7FF91DFC8DC0
00007FF91DFC47E9  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFC47EC  F2 0F 5A C8                 cvtsd2ss xmm1, xmm0
00007FF91DFC47F0  F3 0F 5D 0D A0 64 62 00     minss   xmm1, cs:dword_7FF91E5EAC98
00007FF91DFC47F8  F3 0F 5F 0D B0 64 62 00     maxss   xmm1, cs:dword_7FF91E5EACB0
00007FF91DFC4800  F3 0F 11 8B 60 1B 62 00     movss   dword ptr [rbx+621B60h], xmm1
00007FF91DFC4808  F3 0F 10 83 40 1C 62 00     movss   xmm0, dword ptr [rbx+621C40h]
00007FF91DFC4810  F3 0F 10 BB 50 1B 62 00     movss   xmm7, dword ptr [rbx+621B50h]
00007FF91DFC4818  F3 0F 11 83 50 1C 62 00     movss   dword ptr [rbx+621C50h], xmm0
00007FF91DFC4820  F3 0F 59 8B 70 1C 62 00     mulss   xmm1, dword ptr [rbx+621C70h]
00007FF91DFC4828  0F 2F 0D A1 0A 78 00        comiss  xmm1, cs:dword_7FF91E7452D0
00007FF91DFC482F  72 0A                       jb      short loc_7FF91DFC483B
00007FF91DFC4831  F3 0F 58 0D D7 0C 78 00     addss   xmm1, cs:dword_7FF91E745510
00007FF91DFC4839  EB 0E                       jmp     short loc_7FF91DFC4849
00007FF91DFC483B  41 0F 2F CB                 comiss  xmm1, xmm11
00007FF91DFC483F  72 08                       jb      short loc_7FF91DFC4849
00007FF91DFC4841  F3 0F 58 0D AF 0C 78 00     addss   xmm1, cs:dword_7FF91E7454F8
00007FF91DFC4849  45 0F 57 ED                 xorps   xmm13, xmm13
00007FF91DFC484D  41 0F 2E CD                 ucomiss xmm1, xmm13
00007FF91DFC4851  75 08                       jnz     short loc_7FF91DFC485B
00007FF91DFC4853  F3 0F 10 8B 80 1C 62 00     movss   xmm1, dword ptr [rbx+621C80h]
00007FF91DFC485B  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFC485F  E8 2C 47 00 00              call    sub_7FF91DFC8F90
00007FF91DFC4864  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFC4867  E8 54 47 00 00              call    sub_7FF91DFC8FC0
00007FF91DFC486C  F3 44 0F 10 35 3F 08 78 00  movss   xmm14, cs:dword_7FF91E7450B4
00007FF91DFC4875  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFC4878  F3 0F 11 AB 60 1C 62 00     movss   dword ptr [rbx+621C60h], xmm5
00007FF91DFC4880  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFC4884  F3 41 0F 5C FE              subss   xmm7, xmm14
00007FF91DFC4889  F3 0F 58 F7                 addss   xmm6, xmm7
00007FF91DFC488D  F3 0F 11 B3 40 1C 62 00     movss   dword ptr [rbx+621C40h], xmm6
00007FF91DFC4895  F3 0F 59 AB A0 1C 62 00     mulss   xmm5, dword ptr [rbx+621CA0h]
00007FF91DFC489D  F3 0F 58 AB B0 1C 62 00     addss   xmm5, dword ptr [rbx+621CB0h]
00007FF91DFC48A5  F3 0F 11 AB 90 1C 62 00     movss   dword ptr [rbx+621C90h], xmm5
00007FF91DFC48AD  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFC48B0  8B 83 30 1D 62 00           mov     eax, [rbx+621D30h]
00007FF91DFC48B6  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFC48B9  89 83 40 1D 62 00           mov     [rbx+621D40h], eax
00007FF91DFC48BF  8B 83 20 1D 62 00           mov     eax, [rbx+621D20h]
00007FF91DFC48C5  89 83 30 1D 62 00           mov     [rbx+621D30h], eax
00007FF91DFC48CB  8B 83 10 1D 62 00           mov     eax, [rbx+621D10h]
00007FF91DFC48D1  89 83 20 1D 62 00           mov     [rbx+621D20h], eax
00007FF91DFC48D7  8B 83 00 1D 62 00           mov     eax, [rbx+621D00h]
00007FF91DFC48DD  89 83 10 1D 62 00           mov     [rbx+621D10h], eax
00007FF91DFC48E3  8B 83 F0 1C 62 00           mov     eax, [rbx+621CF0h]
00007FF91DFC48E9  89 83 00 1D 62 00           mov     [rbx+621D00h], eax
00007FF91DFC48EF  8B 83 90 1D 62 00           mov     eax, [rbx+621D90h]
00007FF91DFC48F5  89 83 A0 1D 62 00           mov     [rbx+621DA0h], eax
00007FF91DFC48FB  8B 83 80 1D 62 00           mov     eax, [rbx+621D80h]
00007FF91DFC4901  89 83 90 1D 62 00           mov     [rbx+621D90h], eax
00007FF91DFC4907  8B 83 70 1D 62 00           mov     eax, [rbx+621D70h]
00007FF91DFC490D  89 83 80 1D 62 00           mov     [rbx+621D80h], eax
00007FF91DFC4913  8B 83 60 1D 62 00           mov     eax, [rbx+621D60h]
00007FF91DFC4919  89 83 70 1D 62 00           mov     [rbx+621D70h], eax
00007FF91DFC491F  8B 83 50 1D 62 00           mov     eax, [rbx+621D50h]
00007FF91DFC4925  89 83 60 1D 62 00           mov     [rbx+621D60h], eax
00007FF91DFC492B  8B 83 E0 1D 62 00           mov     eax, [rbx+621DE0h]
00007FF91DFC4931  89 83 F0 1D 62 00           mov     [rbx+621DF0h], eax
00007FF91DFC4937  8B 83 D0 1D 62 00           mov     eax, [rbx+621DD0h]
00007FF91DFC493D  89 83 E0 1D 62 00           mov     [rbx+621DE0h], eax
00007FF91DFC4943  8B 83 C0 1D 62 00           mov     eax, [rbx+621DC0h]
00007FF91DFC4949  89 83 D0 1D 62 00           mov     [rbx+621DD0h], eax
00007FF91DFC494F  8B 83 B0 1D 62 00           mov     eax, [rbx+621DB0h]
00007FF91DFC4955  89 83 C0 1D 62 00           mov     [rbx+621DC0h], eax
00007FF91DFC495B  8B 83 30 1E 62 00           mov     eax, [rbx+621E30h]
00007FF91DFC4961  89 83 40 1E 62 00           mov     [rbx+621E40h], eax
00007FF91DFC4967  8B 83 20 1E 62 00           mov     eax, [rbx+621E20h]
00007FF91DFC496D  89 83 30 1E 62 00           mov     [rbx+621E30h], eax
00007FF91DFC4973  8B 83 10 1E 62 00           mov     eax, [rbx+621E10h]
00007FF91DFC4979  89 83 20 1E 62 00           mov     [rbx+621E20h], eax
00007FF91DFC497F  8B 83 00 1E 62 00           mov     eax, [rbx+621E00h]
00007FF91DFC4985  89 83 10 1E 62 00           mov     [rbx+621E10h], eax
00007FF91DFC498B  8B 83 50 1E 62 00           mov     eax, [rbx+621E50h]
00007FF91DFC4991  89 83 60 1E 62 00           mov     [rbx+621E60h], eax
00007FF91DFC4997  8B 83 80 1E 62 00           mov     eax, [rbx+621E80h]
00007FF91DFC499D  89 83 90 1E 62 00           mov     [rbx+621E90h], eax
00007FF91DFC49A3  8B 83 70 1E 62 00           mov     eax, [rbx+621E70h]
00007FF91DFC49A9  89 83 80 1E 62 00           mov     [rbx+621E80h], eax
00007FF91DFC49AF  F3 0F 11 AB E0 1C 62 00     movss   dword ptr [rbx+621CE0h], xmm5
00007FF91DFC49B7  F3 0F 59 A3 50 20 62 00     mulss   xmm4, dword ptr [rbx+622050h]
00007FF91DFC49BF  F3 0F 10 83 20 1F 62 00     movss   xmm0, dword ptr [rbx+621F20h]
00007FF91DFC49C7  F3 41 0F 59 D7              mulss   xmm2, xmm15
00007FF91DFC49CC  F3 0F 58 A3 60 20 62 00     addss   xmm4, dword ptr [rbx+622060h]
00007FF91DFC49D4  F3 44 0F 11 8B C0 1C 62 00  movss   dword ptr [rbx+621CC0h], xmm9
00007FF91DFC49DD  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC49E1  F3 44 0F 11 83 D0 1C 62 00  movss   dword ptr [rbx+621CD0h], xmm8
00007FF91DFC49EA  F3 0F 10 8B 10 1F 62 00     movss   xmm1, dword ptr [rbx+621F10h]
00007FF91DFC49F2  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFC49F5  F3 41 0F 59 DF              mulss   xmm3, xmm15
00007FF91DFC49FA  F3 0F 59 D2                 mulss   xmm2, xmm2
00007FF91DFC49FE  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFC4A02  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC4A05  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC4A09  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC4A0D  F3 0F 59 DB                 mulss   xmm3, xmm3
00007FF91DFC4A11  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC4A15  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFC4A19  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC4A1D  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFC4A21  F3 0F 5C D9                 subss   xmm3, xmm1
00007FF91DFC4A25  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFC4A29  F3 0F 10 9B 30 1F 62 00     movss   xmm3, dword ptr [rbx+621F30h]
00007FF91DFC4A31  F3 0F 10 8B 70 20 62 00     movss   xmm1, dword ptr [rbx+622070h]
00007FF91DFC4A39  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC4A3C  F3 0F 10 93 80 20 62 00     movss   xmm2, dword ptr [rbx+622080h]
00007FF91DFC4A44  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC4A48  41 0F 28 EE                 movaps  xmm5, xmm14
00007FF91DFC4A4C  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFC4A50  41 0F 28 E1                 movaps  xmm4, xmm9
00007FF91DFC4A54  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC4A58  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFC4A5C  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFC4A60  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFC4A64  F3 0F 11 83 A0 1E 62 00     movss   dword ptr [rbx+621EA0h], xmm0
00007FF91DFC4A6C  F3 0F 11 9B B0 1E 62 00     movss   dword ptr [rbx+621EB0h], xmm3
00007FF91DFC4A74  F3 44 0F 11 8B B0 1D 62 00  movss   dword ptr [rbx+621DB0h], xmm9
00007FF91DFC4A7D  F3 0F 59 A3 40 1F 62 00     mulss   xmm4, dword ptr [rbx+621F40h]
00007FF91DFC4A85  F3 0F 10 83 50 1F 62 00     movss   xmm0, dword ptr [rbx+621F50h]
00007FF91DFC4A8D  F3 0F 59 83 C0 1D 62 00     mulss   xmm0, dword ptr [rbx+621DC0h]
00007FF91DFC4A95  F3 0F 10 8B 60 1F 62 00     movss   xmm1, dword ptr [rbx+621F60h]
00007FF91DFC4A9D  F3 0F 59 8B D0 1D 62 00     mulss   xmm1, dword ptr [rbx+621DD0h]
00007FF91DFC4AA5  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC4AA9  F3 0F 10 83 E0 1D 62 00     movss   xmm0, dword ptr [rbx+621DE0h]
00007FF91DFC4AB1  F3 0F 59 83 70 1F 62 00     mulss   xmm0, dword ptr [rbx+621F70h]
00007FF91DFC4AB9  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC4ABD  F3 0F 10 8B 80 1F 62 00     movss   xmm1, dword ptr [rbx+621F80h]
00007FF91DFC4AC5  F3 0F 59 8B F0 1D 62 00     mulss   xmm1, dword ptr [rbx+621DF0h]
00007FF91DFC4ACD  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC4AD1  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC4AD5  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFC4AD9  F3 0F 11 A3 D0 1D 62 00     movss   dword ptr [rbx+621DD0h], xmm4
00007FF91DFC4AE1  F3 0F 10 93 00 1D 62 00     movss   xmm2, dword ptr [rbx+621D00h]
00007FF91DFC4AE9  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC4AEC  F3 0F 59 83 B0 1F 62 00     mulss   xmm0, dword ptr [rbx+621FB0h]
00007FF91DFC4AF4  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC4AF8  F3 0F 5C 8B 10 1D 62 00     subss   xmm1, dword ptr [rbx+621D10h]
00007FF91DFC4B00  F3 0F 59 8B A0 1F 62 00     mulss   xmm1, dword ptr [rbx+621FA0h]
00007FF91DFC4B08  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC4B0C  F3 0F 11 8B F0 1C 62 00     movss   dword ptr [rbx+621CF0h], xmm1
00007FF91DFC4B14  F3 0F 10 9B 00 1D 62 00     movss   xmm3, dword ptr [rbx+621D00h]
00007FF91DFC4B1C  F3 0F 59 9B A0 1F 62 00     mulss   xmm3, dword ptr [rbx+621FA0h]
00007FF91DFC4B24  F3 0F 58 9B 10 1D 62 00     addss   xmm3, dword ptr [rbx+621D10h]
00007FF91DFC4B2C  F3 0F 11 9B 00 1D 62 00     movss   dword ptr [rbx+621D00h], xmm3
00007FF91DFC4B34  F3 0F 10 83 90 1F 62 00     movss   xmm0, dword ptr [rbx+621F90h]
00007FF91DFC4B3C  F3 0F 10 8B C0 1F 62 00     movss   xmm1, dword ptr [rbx+621FC0h]
00007FF91DFC4B44  F3 0F 5C E8                 subss   xmm5, xmm0
00007FF91DFC4B48  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFC4B4C  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFC4B50  F3 0F 10 9B 20 1D 62 00     movss   xmm3, dword ptr [rbx+621D20h]
00007FF91DFC4B58  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC4B5C  41 0F 28 C6                 movaps  xmm0, xmm14
00007FF91DFC4B60  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFC4B64  F3 0F 59 E9                 mulss   xmm5, xmm1
00007FF91DFC4B68  F3 41 0F 59 C1              mulss   xmm0, xmm9
00007FF91DFC4B6D  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC4B71  F3 0F 10 83 E0 1F 62 00     movss   xmm0, dword ptr [rbx+621FE0h]
00007FF91DFC4B79  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFC4B7C  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC4B80  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFC4B83  F3 0F 5C E3                 subss   xmm4, xmm3
00007FF91DFC4B87  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC4B8B  F3 0F 59 A3 D0 1F 62 00     mulss   xmm4, dword ptr [rbx+621FD0h]
00007FF91DFC4B93  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC4B97  F3 0F 10 83 30 20 62 00     movss   xmm0, dword ptr [rbx+622030h]
00007FF91DFC4B9F  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFC4BA3  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFC4BA7  F3 0F 10 8B 20 20 62 00     movss   xmm1, dword ptr [rbx+622020h]
00007FF91DFC4BAF  F3 0F 11 A3 10 1D 62 00     movss   dword ptr [rbx+621D10h], xmm4
00007FF91DFC4BB7  F3 0F 59 8B 30 1D 62 00     mulss   xmm1, dword ptr [rbx+621D30h]
00007FF91DFC4BBF  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC4BC3  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC4BC7  F3 0F 59 8B 40 20 62 00     mulss   xmm1, dword ptr [rbx+622040h]
00007FF91DFC4BCF  F3 0F 11 8B 00 21 63 00     movss   dword ptr [rbx+632100h], xmm1
00007FF91DFC4BD7  F3 0F 10 AB D0 1C 62 00     movss   xmm5, dword ptr [rbx+621CD0h]
00007FF91DFC4BDF  F3 0F 11 AB 00 1E 62 00     movss   dword ptr [rbx+621E00h], xmm5
00007FF91DFC4BE7  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFC4BEA  F3 0F 10 A3 10 1E 62 00     movss   xmm4, dword ptr [rbx+621E10h]
00007FF91DFC4BF2  F3 0F 59 A3 50 1F 62 00     mulss   xmm4, dword ptr [rbx+621F50h]
00007FF91DFC4BFA  F3 0F 59 83 40 1F 62 00     mulss   xmm0, dword ptr [rbx+621F40h]
00007FF91DFC4C02  F3 0F 10 8B 60 1F 62 00     movss   xmm1, dword ptr [rbx+621F60h]
00007FF91DFC4C0A  F3 0F 59 8B 20 1E 62 00     mulss   xmm1, dword ptr [rbx+621E20h]
00007FF91DFC4C12  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC4C16  F3 0F 10 83 30 1E 62 00     movss   xmm0, dword ptr [rbx+621E30h]
00007FF91DFC4C1E  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC4C22  F3 0F 59 83 70 1F 62 00     mulss   xmm0, dword ptr [rbx+621F70h]
00007FF91DFC4C2A  41 0F 28 F6                 movaps  xmm6, xmm14
00007FF91DFC4C2E  F3 0F 10 8B 40 1E 62 00     movss   xmm1, dword ptr [rbx+621E40h]
00007FF91DFC4C36  F3 0F 59 8B 80 1F 62 00     mulss   xmm1, dword ptr [rbx+621F80h]
00007FF91DFC4C3E  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC4C42  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC4C46  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFC4C49  F3 0F 11 A3 20 1E 62 00     movss   dword ptr [rbx+621E20h], xmm4
00007FF91DFC4C51  F3 0F 10 93 60 1D 62 00     movss   xmm2, dword ptr [rbx+621D60h]
00007FF91DFC4C59  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC4C5C  F3 0F 59 83 B0 1F 62 00     mulss   xmm0, dword ptr [rbx+621FB0h]
00007FF91DFC4C64  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC4C68  F3 0F 5C 8B 70 1D 62 00     subss   xmm1, dword ptr [rbx+621D70h]
00007FF91DFC4C70  F3 0F 59 8B A0 1F 62 00     mulss   xmm1, dword ptr [rbx+621FA0h]
00007FF91DFC4C78  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC4C7C  F3 0F 11 8B 50 1D 62 00     movss   dword ptr [rbx+621D50h], xmm1
00007FF91DFC4C84  F3 0F 10 9B 60 1D 62 00     movss   xmm3, dword ptr [rbx+621D60h]
00007FF91DFC4C8C  F3 0F 59 9B A0 1F 62 00     mulss   xmm3, dword ptr [rbx+621FA0h]
00007FF91DFC4C94  F3 0F 58 9B 70 1D 62 00     addss   xmm3, dword ptr [rbx+621D70h]
00007FF91DFC4C9C  F3 0F 11 9B 60 1D 62 00     movss   dword ptr [rbx+621D60h], xmm3
00007FF91DFC4CA4  F3 0F 10 83 90 1F 62 00     movss   xmm0, dword ptr [rbx+621F90h]
00007FF91DFC4CAC  F3 0F 10 8B C0 1F 62 00     movss   xmm1, dword ptr [rbx+621FC0h]
00007FF91DFC4CB4  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFC4CB8  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFC4CBC  F3 0F 59 F3                 mulss   xmm6, xmm3
00007FF91DFC4CC0  F3 0F 10 9B 80 1D 62 00     movss   xmm3, dword ptr [rbx+621D80h]
00007FF91DFC4CC8  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFC4CCC  41 0F 28 C6                 movaps  xmm0, xmm14
00007FF91DFC4CD0  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFC4CD4  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFC4CD8  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC4CDC  F3 0F 10 AB 20 20 62 00     movss   xmm5, dword ptr [rbx+622020h]
00007FF91DFC4CE4  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFC4CE8  F3 0F 10 83 E0 1F 62 00     movss   xmm0, dword ptr [rbx+621FE0h]
00007FF91DFC4CF0  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFC4CF3  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFC4CF7  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFC4CFA  F3 0F 5C E3                 subss   xmm4, xmm3
00007FF91DFC4CFE  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC4D02  F3 0F 59 A3 D0 1F 62 00     mulss   xmm4, dword ptr [rbx+621FD0h]
00007FF91DFC4D0A  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC4D0E  F3 0F 10 83 30 20 62 00     movss   xmm0, dword ptr [rbx+622030h]
00007FF91DFC4D16  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFC4D1A  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFC4D1E  F3 0F 11 A3 70 1D 62 00     movss   dword ptr [rbx+621D70h], xmm4
00007FF91DFC4D26  F3 0F 10 93 40 20 62 00     movss   xmm2, dword ptr [rbx+622040h]
00007FF91DFC4D2E  F3 0F 59 AB 90 1D 62 00     mulss   xmm5, dword ptr [rbx+621D90h]
00007FF91DFC4D36  F3 0F 10 8B A0 20 62 00     movss   xmm1, dword ptr [rbx+6220A0h]
00007FF91DFC4D3E  F3 0F 58 8B 80 1E 62 00     addss   xmm1, dword ptr [rbx+621E80h]
00007FF91DFC4D46  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFC4D4A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC4D4E  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC4D51  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC4D55  F3 0F 11 83 20 21 63 00     movss   dword ptr [rbx+632120h], xmm0
00007FF91DFC4D5D  F3 0F 10 9B B0 20 62 00     movss   xmm3, dword ptr [rbx+6220B0h]
00007FF91DFC4D65  F3 0F 5D D9                 minss   xmm3, xmm1
00007FF91DFC4D69  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFC4D6D  F3 0F 11 9B 70 1E 62 00     movss   dword ptr [rbx+621E70h], xmm3
00007FF91DFC4D75  F3 0F 5C 9B 60 1E 62 00     subss   xmm3, dword ptr [rbx+621E60h]
00007FF91DFC4D7D  F3 0F 10 93 90 1E 62 00     movss   xmm2, dword ptr [rbx+621E90h]
00007FF91DFC4D85  41 0F 2F DD                 comiss  xmm3, xmm13
00007FF91DFC4D89  73 0A                       jnb     short loc_7FF91DFC4D95
00007FF91DFC4D8B  F3 0F 58 93 D0 20 62 00     addss   xmm2, dword ptr [rbx+6220D0h]
00007FF91DFC4D93  EB 08                       jmp     short loc_7FF91DFC4D9D
00007FF91DFC4D95  F3 0F 58 93 C0 20 62 00     addss   xmm2, dword ptr [rbx+6220C0h]
00007FF91DFC4D9D  41 0F 2F D5                 comiss  xmm2, xmm13
00007FF91DFC4DA1  F3 0F 10 9B 00 1F 62 00     movss   xmm3, dword ptr [rbx+621F00h]
00007FF91DFC4DA9  45 0F 57 FF                 xorps   xmm15, xmm15
00007FF91DFC4DAD  F3 0F 10 A3 60 1E 62 00     movss   xmm4, dword ptr [rbx+621E60h]
00007FF91DFC4DB5  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC4DB8  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFC4DBC  76 05                       jbe     short loc_7FF91DFC4DC3
00007FF91DFC4DBE  0F 5A C2                    cvtps2pd xmm0, xmm2
00007FF91DFC4DC1  EB 03                       jmp     short loc_7FF91DFC4DC6
00007FF91DFC4DC3  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC4DC6  F3 0F 59 8B 10 20 62 00     mulss   xmm1, dword ptr [rbx+622010h]
00007FF91DFC4DCE  F3 44 0F 10 25 0D 07 78 00  movss   xmm12, cs:dword_7FF91E7454E4
00007FF91DFC4DD7  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFC4DDB  F3 0F 58 CC                 addss   xmm1, xmm4
00007FF91DFC4DDF  41 0F 2F C4                 comiss  xmm0, xmm12
00007FF91DFC4DE3  73 06                       jnb     short loc_7FF91DFC4DEB
00007FF91DFC4DE5  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFC4DE9  EB 05                       jmp     short loc_7FF91DFC4DF0
00007FF91DFC4DEB  F3 41 0F 5D C6              minss   xmm0, xmm14
00007FF91DFC4DF0  F3 0F 59 83 40 20 62 00     mulss   xmm0, dword ptr [rbx+622040h]
00007FF91DFC4DF8  F3 0F 11 83 80 1E 62 00     movss   dword ptr [rbx+621E80h], xmm0
00007FF91DFC4E00  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC4E03  F3 0F 5C C4                 subss   xmm0, xmm4
00007FF91DFC4E07  41 0F 2E C5                 ucomiss xmm0, xmm13
00007FF91DFC4E0B  74 03                       jz      short loc_7FF91DFC4E10
00007FF91DFC4E0D  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFC4E10  F3 44 0F 10 1D 9F 5E 62 00  movss   xmm11, cs:dword_7FF91E5EACB8
00007FF91DFC4E19  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFC4E1C  F3 44 0F 10 0D 7B 5E 62 00  movss   xmm9, cs:dword_7FF91E5EACA0
00007FF91DFC4E25  F3 0F 11 9B 50 1E 62 00     movss   dword ptr [rbx+621E50h], xmm3
00007FF91DFC4E2D  F3 0F 58 9B A0 1E 62 00     addss   xmm3, dword ptr [rbx+621EA0h]
00007FF91DFC4E35  8B 83 E0 A0 62 00           mov     eax, [rbx+62A0E0h]
00007FF91DFC4E3B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC4E3E  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFC4E43  F3 41 0F 59 C3              mulss   xmm0, xmm11
00007FF91DFC4E48  0F 5A CB                    cvtps2pd xmm1, xmm3
00007FF91DFC4E4B  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC4E4F  2B C2                       sub     eax, edx
00007FF91DFC4E51  48 63 C8                    movsxd  rcx, eax
00007FF91DFC4E54  48 63 83 E4 A0 62 00        movsxd  rax, dword ptr [rbx+62A0E4h]
00007FF91DFC4E5B  48 FF C1                    inc     rcx
00007FF91DFC4E5E  48 FF C8                    dec     rax
00007FF91DFC4E61  48 23 C8                    and     rcx, rax
00007FF91DFC4E64  8B 84 8B E0 20 62 00        mov     eax, [rbx+rcx*4+6220E0h]
00007FF91DFC4E6B  89 83 10 21 63 00           mov     [rbx+632110h], eax
00007FF91DFC4E71  8B 83 E0 A0 62 00           mov     eax, [rbx+62A0E0h]
00007FF91DFC4E77  2B C2                       sub     eax, edx
00007FF91DFC4E79  48 63 C8                    movsxd  rcx, eax
00007FF91DFC4E7C  48 63 83 E4 A0 62 00        movsxd  rax, dword ptr [rbx+62A0E4h]
00007FF91DFC4E83  48 83 C1 02                 add     rcx, 2
00007FF91DFC4E87  48 FF C8                    dec     rax
00007FF91DFC4E8A  48 23 C8                    and     rcx, rax
00007FF91DFC4E8D  8B 84 8B E0 20 62 00        mov     eax, [rbx+rcx*4+6220E0h]
00007FF91DFC4E94  89 83 14 21 63 00           mov     [rbx+632114h], eax
00007FF91DFC4E9A  F3 0F 2C C3                 cvttss2si eax, xmm3
00007FF91DFC4E9E  66 0F 6E C0                 movd    xmm0, eax
00007FF91DFC4EA2  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00007FF91DFC4EA6  F2 0F 5C C8                 subsd   xmm1, xmm0
00007FF91DFC4EAA  66 0F 5A E9                 cvtpd2ps xmm5, xmm1
00007FF91DFC4EAE  F3 0F 11 AB 18 21 63 00     movss   dword ptr [rbx+632118h], xmm5
00007FF91DFC4EB6  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFC4EB9  F3 0F 58 A3 B0 1E 62 00     addss   xmm4, dword ptr [rbx+621EB0h]
00007FF91DFC4EC1  F3 0F 10 9B 10 21 63 00     movss   xmm3, dword ptr [rbx+632110h]
00007FF91DFC4EC9  8B 83 F0 20 63 00           mov     eax, [rbx+6320F0h]
00007FF91DFC4ECF  F3 0F 10 B3 90 1E 62 00     movss   xmm6, dword ptr [rbx+621E90h]
00007FF91DFC4ED7  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFC4EDB  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC4EDE  F3 41 0F 59 E1              mulss   xmm4, xmm9
00007FF91DFC4EE3  F3 41 0F 59 C3              mulss   xmm0, xmm11
00007FF91DFC4EE8  0F 5A CC                    cvtps2pd xmm1, xmm4
00007FF91DFC4EEB  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC4EEF  2B C2                       sub     eax, edx
00007FF91DFC4EF1  48 63 C8                    movsxd  rcx, eax
00007FF91DFC4EF4  48 63 83 F4 20 63 00        movsxd  rax, dword ptr [rbx+6320F4h]
00007FF91DFC4EFB  48 FF C1                    inc     rcx
00007FF91DFC4EFE  48 FF C8                    dec     rax
00007FF91DFC4F01  48 23 C8                    and     rcx, rax
00007FF91DFC4F04  8B 84 8B F0 A0 62 00        mov     eax, [rbx+rcx*4+62A0F0h]
00007FF91DFC4F0B  89 83 30 21 63 00           mov     [rbx+632130h], eax
00007FF91DFC4F11  8B 83 F0 20 63 00           mov     eax, [rbx+6320F0h]
00007FF91DFC4F17  2B C2                       sub     eax, edx
00007FF91DFC4F19  48 63 C8                    movsxd  rcx, eax
00007FF91DFC4F1C  48 63 83 F4 20 63 00        movsxd  rax, dword ptr [rbx+6320F4h]
00007FF91DFC4F23  48 83 C1 02                 add     rcx, 2
00007FF91DFC4F27  48 FF C8                    dec     rax
00007FF91DFC4F2A  48 23 C8                    and     rcx, rax
00007FF91DFC4F2D  8B 84 8B F0 A0 62 00        mov     eax, [rbx+rcx*4+62A0F0h]
00007FF91DFC4F34  89 83 34 21 63 00           mov     [rbx+632134h], eax
00007FF91DFC4F3A  F3 0F 2C C4                 cvttss2si eax, xmm4
00007FF91DFC4F3E  66 0F 6E C0                 movd    xmm0, eax
00007FF91DFC4F42  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00007FF91DFC4F46  F2 0F 5C C8                 subsd   xmm1, xmm0
00007FF91DFC4F4A  66 0F 5A E1                 cvtpd2ps xmm4, xmm1
00007FF91DFC4F4E  F3 0F 11 A3 38 21 63 00     movss   dword ptr [rbx+632138h], xmm4
00007FF91DFC4F56  44 0F 28 C4                 movaps  xmm8, xmm4
00007FF91DFC4F5A  F3 0F 59 BB 14 21 63 00     mulss   xmm7, dword ptr [rbx+632114h]
00007FF91DFC4F62  F3 0F 10 83 40 1D 62 00     movss   xmm0, dword ptr [rbx+621D40h]
00007FF91DFC4F6A  F3 0F 5C FD                 subss   xmm7, xmm5
00007FF91DFC4F6E  F3 0F 58 FB                 addss   xmm7, xmm3
00007FF91DFC4F72  F3 0F 10 9B 30 21 63 00     movss   xmm3, dword ptr [rbx+632130h]
00007FF91DFC4F7A  F3 0F 59 FE                 mulss   xmm7, xmm6
00007FF91DFC4F7E  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFC4F81  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC4F85  F3 0F 11 8B 20 1D 62 00     movss   dword ptr [rbx+621D20h], xmm1
00007FF91DFC4F8D  F3 0F 59 8B 90 20 62 00     mulss   xmm1, dword ptr [rbx+622090h]
00007FF91DFC4F95  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC4F99  F3 0F 11 8B 30 1D 62 00     movss   dword ptr [rbx+621D30h], xmm1
00007FF91DFC4FA1  F3 44 0F 59 83 34 21 63 00  mulss   xmm8, dword ptr [rbx+632134h]
00007FF91DFC4FAA  F3 0F 10 8B A0 1D 62 00     movss   xmm1, dword ptr [rbx+621DA0h]
00007FF91DFC4FB2  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFC4FB6  F3 44 0F 5C C4              subss   xmm8, xmm4
00007FF91DFC4FBB  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFC4FC0  F3 44 0F 59 C6              mulss   xmm8, xmm6
00007FF91DFC4FC5  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFC4FC9  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFC4FCD  F3 0F 11 93 80 1D 62 00     movss   dword ptr [rbx+621D80h], xmm2
00007FF91DFC4FD5  F3 0F 59 93 90 20 62 00     mulss   xmm2, dword ptr [rbx+622090h]
00007FF91DFC4FDD  F3 0F 10 83 00 20 62 00     movss   xmm0, dword ptr [rbx+622000h]
00007FF91DFC4FE5  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFC4FE9  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC4FED  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFC4FF2  F3 0F 11 93 90 1D 62 00     movss   dword ptr [rbx+621D90h], xmm2
00007FF91DFC4FFA  41 0F 28 D6                 movaps  xmm2, xmm14
00007FF91DFC4FFE  F3 0F 10 B3 D0 1C 62 00     movss   xmm6, dword ptr [rbx+621CD0h]
00007FF91DFC5006  F3 0F 10 9B C0 1C 62 00     movss   xmm3, dword ptr [rbx+621CC0h]
00007FF91DFC500E  F3 0F 10 AB F0 1F 62 00     movss   xmm5, dword ptr [rbx+621FF0h]
00007FF91DFC5016  F3 0F 11 BB C0 1E 62 00     movss   dword ptr [rbx+621EC0h], xmm7
00007FF91DFC501E  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFC5021  F3 44 0F 11 83 D0 1E 62 00  movss   dword ptr [rbx+621ED0h], xmm8
00007FF91DFC502A  F3 0F 10 A3 30 20 62 00     movss   xmm4, dword ptr [rbx+622030h]
00007FF91DFC5032  F3 0F 5C D4                 subss   xmm2, xmm4
00007FF91DFC5036  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFC503A  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFC503D  F3 0F 59 EE                 mulss   xmm5, xmm6
00007FF91DFC5041  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFC5045  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC5048  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFC504C  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFC5050  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFC5054  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFC5058  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC505C  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFC5061  F3 0F 58 8B C0 1E 62 00     addss   xmm1, dword ptr [rbx+621EC0h]
00007FF91DFC5069  F3 0F 11 8B E0 1E 62 00     movss   dword ptr [rbx+621EE0h], xmm1
00007FF91DFC5071  F3 0F 11 A3 F0 1E 62 00     movss   dword ptr [rbx+621EF0h], xmm4
00007FF91DFC5079  8B 8B E4 A0 62 00           mov     ecx, [rbx+62A0E4h]
00007FF91DFC507F  8B 83 E0 A0 62 00           mov     eax, [rbx+62A0E0h]
00007FF91DFC5085  FF C9                       dec     ecx
00007FF91DFC5087  FF C8                       dec     eax
00007FF91DFC5089  23 C8                       and     ecx, eax
00007FF91DFC508B  89 8B E0 A0 62 00           mov     [rbx+62A0E0h], ecx
00007FF91DFC5091  8B 83 00 21 63 00           mov     eax, [rbx+632100h]
00007FF91DFC5097  48 63 C9                    movsxd  rcx, ecx
00007FF91DFC509A  89 84 8B E0 20 62 00        mov     [rbx+rcx*4+6220E0h], eax
00007FF91DFC50A1  8B 8B F4 20 63 00           mov     ecx, [rbx+6320F4h]
00007FF91DFC50A7  8B 83 F0 20 63 00           mov     eax, [rbx+6320F0h]
00007FF91DFC50AD  FF C9                       dec     ecx
00007FF91DFC50AF  FF C8                       dec     eax
00007FF91DFC50B1  23 C8                       and     ecx, eax
00007FF91DFC50B3  89 8B F0 20 63 00           mov     [rbx+6320F0h], ecx
00007FF91DFC50B9  8B 83 20 21 63 00           mov     eax, [rbx+632120h]
00007FF91DFC50BF  48 63 C9                    movsxd  rcx, ecx
00007FF91DFC50C2  89 84 8B F0 A0 62 00        mov     [rbx+rcx*4+62A0F0h], eax
00007FF91DFC50C9  F3 0F 10 B3 70 8D 01 00     movss   xmm6, dword ptr [rbx+18D70h]
00007FF91DFC50D1  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFC50D4  F3 0F 59 B3 F0 1E 62 00     mulss   xmm6, dword ptr [rbx+621EF0h]
00007FF91DFC50DC  F3 0F 59 BB E0 1E 62 00     mulss   xmm7, dword ptr [rbx+621EE0h]
00007FF91DFC50E4  E9 88 16 00 00              jmp     loc_7FF91DFC6771
00007FF91DFC50E9  83 BB 0C 30 A8 00 02        cmp     dword ptr [rbx+0A8300Ch], 2
00007FF91DFC50F0  74 12                       jz      short loc_7FF91DFC5104
00007FF91DFC50F2  89 B3 50 98 61 00           mov     [rbx+619850h], esi
00007FF91DFC50F8  89 B3 60 98 61 00           mov     [rbx+619860h], esi
00007FF91DFC50FE  89 B3 70 98 61 00           mov     [rbx+619870h], esi
00007FF91DFC5104  C7 83 0C 30 A8 00 02 00 00 00  mov     dword ptr [rbx+0A8300Ch], 2
00007FF91DFC510E  F3 0F 10 8B B0 95 61 00     movss   xmm1, dword ptr [rbx+6195B0h]
00007FF91DFC5116  F3 0F 10 83 C0 95 61 00     movss   xmm0, dword ptr [rbx+6195C0h]
00007FF91DFC511E  F3 0F 11 8B D0 95 61 00     movss   dword ptr [rbx+6195D0h], xmm1
00007FF91DFC5126  F3 0F 11 83 E0 95 61 00     movss   dword ptr [rbx+6195E0h], xmm0
00007FF91DFC512E  F3 0F 58 8B 10 96 61 00     addss   xmm1, dword ptr [rbx+619610h]
00007FF91DFC5136  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFC5139  E8 82 3C 00 00              call    sub_7FF91DFC8DC0
00007FF91DFC513E  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFC5141  F2 0F 5A C8                 cvtsd2ss xmm1, xmm0
00007FF91DFC5145  F3 0F 5D 0D 4B 5B 62 00     minss   xmm1, cs:dword_7FF91E5EAC98
00007FF91DFC514D  F3 0F 5F 0D 5B 5B 62 00     maxss   xmm1, cs:dword_7FF91E5EACB0
00007FF91DFC5155  F3 0F 11 8B F0 95 61 00     movss   dword ptr [rbx+6195F0h], xmm1
00007FF91DFC515D  F3 0F 10 B3 D0 96 61 00     movss   xmm6, dword ptr [rbx+6196D0h]
00007FF91DFC5165  F3 44 0F 10 93 E0 95 61 00  movss   xmm10, dword ptr [rbx+6195E0h]
00007FF91DFC516E  F3 0F 11 B3 E0 96 61 00     movss   dword ptr [rbx+6196E0h], xmm6
00007FF91DFC5176  F3 0F 59 8B 00 97 61 00     mulss   xmm1, dword ptr [rbx+619700h]
00007FF91DFC517E  0F 2F 0D 4B 01 78 00        comiss  xmm1, cs:dword_7FF91E7452D0
00007FF91DFC5185  72 0A                       jb      short loc_7FF91DFC5191
00007FF91DFC5187  F3 0F 58 0D 81 03 78 00     addss   xmm1, cs:dword_7FF91E745510
00007FF91DFC518F  EB 0E                       jmp     short loc_7FF91DFC519F
00007FF91DFC5191  41 0F 2F CB                 comiss  xmm1, xmm11
00007FF91DFC5195  72 08                       jb      short loc_7FF91DFC519F
00007FF91DFC5197  F3 0F 58 0D 59 03 78 00     addss   xmm1, cs:dword_7FF91E7454F8
00007FF91DFC519F  45 0F 57 ED                 xorps   xmm13, xmm13
00007FF91DFC51A3  41 0F 2E CD                 ucomiss xmm1, xmm13
00007FF91DFC51A7  75 08                       jnz     short loc_7FF91DFC51B1
00007FF91DFC51A9  F3 0F 10 8B 10 97 61 00     movss   xmm1, dword ptr [rbx+619710h]
00007FF91DFC51B1  F3 44 0F 10 35 FA FE 77 00  movss   xmm14, cs:dword_7FF91E7450B4
00007FF91DFC51BA  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFC51BE  41 0F 28 FA                 movaps  xmm7, xmm10
00007FF91DFC51C2  F3 41 0F 5C FE              subss   xmm7, xmm14
00007FF91DFC51C7  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFC51CB  76 19                       jbe     short loc_7FF91DFC51E6
00007FF91DFC51CD  F3 41 0F 58 F6              addss   xmm6, xmm14
00007FF91DFC51D2  41 0F 28 CB                 movaps  xmm1, xmm11; Y
00007FF91DFC51D6  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFC51D9  E8 FA A2 38 00              call    fmodf
00007FF91DFC51DE  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFC51E1  F3 41 0F 5C F6              subss   xmm6, xmm14
00007FF91DFC51E6  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFC51E9  E8 D2 3D 00 00              call    sub_7FF91DFC8FC0
00007FF91DFC51EE  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFC51F1  F3 41 0F 59 F2              mulss   xmm6, xmm10
00007FF91DFC51F6  F3 0F 11 AB F0 96 61 00     movss   dword ptr [rbx+6196F0h], xmm5
00007FF91DFC51FE  41 0F 28 E6                 movaps  xmm4, xmm14
00007FF91DFC5202  F3 0F 58 F7                 addss   xmm6, xmm7
00007FF91DFC5206  F3 0F 11 B3 D0 96 61 00     movss   dword ptr [rbx+6196D0h], xmm6
00007FF91DFC520E  F3 0F 59 AB 30 97 61 00     mulss   xmm5, dword ptr [rbx+619730h]
00007FF91DFC5216  F3 0F 58 AB 40 97 61 00     addss   xmm5, dword ptr [rbx+619740h]
00007FF91DFC521E  F3 0F 11 AB 20 97 61 00     movss   dword ptr [rbx+619720h], xmm5
00007FF91DFC5226  F3 0F 5C E5                 subss   xmm4, xmm5
00007FF91DFC522A  8B 83 C0 97 61 00           mov     eax, [rbx+6197C0h]
00007FF91DFC5230  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFC5233  89 83 D0 97 61 00           mov     [rbx+6197D0h], eax
00007FF91DFC5239  8B 83 B0 97 61 00           mov     eax, [rbx+6197B0h]
00007FF91DFC523F  89 83 C0 97 61 00           mov     [rbx+6197C0h], eax
00007FF91DFC5245  8B 83 A0 97 61 00           mov     eax, [rbx+6197A0h]
00007FF91DFC524B  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFC524E  89 83 B0 97 61 00           mov     [rbx+6197B0h], eax
00007FF91DFC5254  8B 83 90 97 61 00           mov     eax, [rbx+619790h]
00007FF91DFC525A  89 83 A0 97 61 00           mov     [rbx+6197A0h], eax
00007FF91DFC5260  8B 83 80 97 61 00           mov     eax, [rbx+619780h]
00007FF91DFC5266  89 83 90 97 61 00           mov     [rbx+619790h], eax
00007FF91DFC526C  8B 83 10 98 61 00           mov     eax, [rbx+619810h]
00007FF91DFC5272  89 83 20 98 61 00           mov     [rbx+619820h], eax
00007FF91DFC5278  8B 83 00 98 61 00           mov     eax, [rbx+619800h]
00007FF91DFC527E  89 83 10 98 61 00           mov     [rbx+619810h], eax
00007FF91DFC5284  8B 83 F0 97 61 00           mov     eax, [rbx+6197F0h]
00007FF91DFC528A  89 83 00 98 61 00           mov     [rbx+619800h], eax
00007FF91DFC5290  8B 83 E0 97 61 00           mov     eax, [rbx+6197E0h]
00007FF91DFC5296  89 83 F0 97 61 00           mov     [rbx+6197F0h], eax
00007FF91DFC529C  8B 83 30 98 61 00           mov     eax, [rbx+619830h]
00007FF91DFC52A2  89 83 40 98 61 00           mov     [rbx+619840h], eax
00007FF91DFC52A8  8B 83 60 98 61 00           mov     eax, [rbx+619860h]
00007FF91DFC52AE  89 83 70 98 61 00           mov     [rbx+619870h], eax
00007FF91DFC52B4  8B 83 50 98 61 00           mov     eax, [rbx+619850h]
00007FF91DFC52BA  89 83 60 98 61 00           mov     [rbx+619860h], eax
00007FF91DFC52C0  F3 0F 11 AB 70 97 61 00     movss   dword ptr [rbx+619770h], xmm5
00007FF91DFC52C8  F3 0F 10 83 00 99 61 00     movss   xmm0, dword ptr [rbx+619900h]
00007FF91DFC52D0  F3 44 0F 11 8B 50 97 61 00  movss   dword ptr [rbx+619750h], xmm9
00007FF91DFC52D9  F3 44 0F 11 83 60 97 61 00  movss   dword ptr [rbx+619760h], xmm8
00007FF91DFC52E2  F3 45 0F 58 C1              addss   xmm8, xmm9
00007FF91DFC52E7  F3 0F 10 8B F0 98 61 00     movss   xmm1, dword ptr [rbx+6198F0h]
00007FF91DFC52EF  F3 41 0F 59 DF              mulss   xmm3, xmm15
00007FF91DFC52F4  F3 41 0F 59 D7              mulss   xmm2, xmm15
00007FF91DFC52F9  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFC52FD  F3 45 0F 59 C7              mulss   xmm8, xmm15
00007FF91DFC5302  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC5306  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC5309  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC530D  F3 0F 59 DB                 mulss   xmm3, xmm3
00007FF91DFC5311  F3 0F 59 D2                 mulss   xmm2, xmm2
00007FF91DFC5315  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFC5319  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC531D  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC5321  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC5325  F3 0F 5C D9                 subss   xmm3, xmm1
00007FF91DFC5329  F3 0F 10 8B 70 9A 61 00     movss   xmm1, dword ptr [rbx+619A70h]
00007FF91DFC5331  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFC5335  F3 0F 10 93 80 9A 61 00     movss   xmm2, dword ptr [rbx+619A80h]
00007FF91DFC533D  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFC5341  F3 0F 10 9B 10 99 61 00     movss   xmm3, dword ptr [rbx+619910h]
00007FF91DFC5349  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC534C  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC5350  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFC5354  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC5358  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFC535C  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFC5360  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFC5364  F3 0F 11 83 80 98 61 00     movss   dword ptr [rbx+619880h], xmm0
00007FF91DFC536C  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFC5370  F3 0F 11 9B 90 98 61 00     movss   dword ptr [rbx+619890h], xmm3
00007FF91DFC5378  F3 44 0F 11 83 E0 97 61 00  movss   dword ptr [rbx+6197E0h], xmm8
00007FF91DFC5381  F3 0F 10 A3 30 99 61 00     movss   xmm4, dword ptr [rbx+619930h]
00007FF91DFC5389  F3 0F 59 A3 F0 97 61 00     mulss   xmm4, dword ptr [rbx+6197F0h]
00007FF91DFC5391  F3 0F 59 83 20 99 61 00     mulss   xmm0, dword ptr [rbx+619920h]
00007FF91DFC5399  F3 0F 10 8B 40 99 61 00     movss   xmm1, dword ptr [rbx+619940h]
00007FF91DFC53A1  F3 0F 59 8B 00 98 61 00     mulss   xmm1, dword ptr [rbx+619800h]
00007FF91DFC53A9  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC53AD  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC53B1  F3 0F 10 83 50 99 61 00     movss   xmm0, dword ptr [rbx+619950h]
00007FF91DFC53B9  41 0F 28 F6                 movaps  xmm6, xmm14
00007FF91DFC53BD  F3 0F 59 83 10 98 61 00     mulss   xmm0, dword ptr [rbx+619810h]
00007FF91DFC53C5  F3 0F 10 8B 60 99 61 00     movss   xmm1, dword ptr [rbx+619960h]
00007FF91DFC53CD  F3 0F 59 8B 20 98 61 00     mulss   xmm1, dword ptr [rbx+619820h]
00007FF91DFC53D5  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC53D9  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC53DD  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFC53E1  F3 0F 11 A3 00 98 61 00     movss   dword ptr [rbx+619800h], xmm4
00007FF91DFC53E9  F3 0F 10 93 90 97 61 00     movss   xmm2, dword ptr [rbx+619790h]
00007FF91DFC53F1  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC53F4  F3 0F 59 83 90 99 61 00     mulss   xmm0, dword ptr [rbx+619990h]
00007FF91DFC53FC  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC5400  F3 0F 5C 8B A0 97 61 00     subss   xmm1, dword ptr [rbx+6197A0h]
00007FF91DFC5408  F3 0F 59 8B 80 99 61 00     mulss   xmm1, dword ptr [rbx+619980h]
00007FF91DFC5410  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC5414  F3 0F 11 8B 80 97 61 00     movss   dword ptr [rbx+619780h], xmm1
00007FF91DFC541C  F3 0F 10 9B 90 97 61 00     movss   xmm3, dword ptr [rbx+619790h]
00007FF91DFC5424  F3 0F 59 9B 80 99 61 00     mulss   xmm3, dword ptr [rbx+619980h]
00007FF91DFC542C  F3 0F 58 9B A0 97 61 00     addss   xmm3, dword ptr [rbx+6197A0h]
00007FF91DFC5434  F3 0F 11 9B 90 97 61 00     movss   dword ptr [rbx+619790h], xmm3
00007FF91DFC543C  F3 0F 10 83 70 99 61 00     movss   xmm0, dword ptr [rbx+619970h]
00007FF91DFC5444  F3 0F 10 8B A0 99 61 00     movss   xmm1, dword ptr [rbx+6199A0h]
00007FF91DFC544C  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFC5450  F3 0F 10 AB 00 9A 61 00     movss   xmm5, dword ptr [rbx+619A00h]
00007FF91DFC5458  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFC545C  F3 0F 59 F3                 mulss   xmm6, xmm3
00007FF91DFC5460  F3 0F 10 9B B0 97 61 00     movss   xmm3, dword ptr [rbx+6197B0h]
00007FF91DFC5468  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFC546C  41 0F 28 C6                 movaps  xmm0, xmm14
00007FF91DFC5470  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFC5474  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFC5478  F3 41 0F 59 C0              mulss   xmm0, xmm8
00007FF91DFC547D  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFC5481  F3 0F 10 83 C0 99 61 00     movss   xmm0, dword ptr [rbx+6199C0h]
00007FF91DFC5489  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFC548C  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFC5490  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFC5493  F3 0F 5C E3                 subss   xmm4, xmm3
00007FF91DFC5497  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC549B  F3 0F 59 A3 B0 99 61 00     mulss   xmm4, dword ptr [rbx+6199B0h]
00007FF91DFC54A3  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC54A7  F3 0F 10 83 10 9A 61 00     movss   xmm0, dword ptr [rbx+619A10h]
00007FF91DFC54AF  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFC54B3  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFC54B7  F3 0F 11 A3 A0 97 61 00     movss   dword ptr [rbx+6197A0h], xmm4
00007FF91DFC54BF  F3 0F 10 93 20 9A 61 00     movss   xmm2, dword ptr [rbx+619A20h]
00007FF91DFC54C7  F3 0F 59 AB C0 97 61 00     mulss   xmm5, dword ptr [rbx+6197C0h]
00007FF91DFC54CF  F3 0F 10 8B A0 9A 61 00     movss   xmm1, dword ptr [rbx+619AA0h]
00007FF91DFC54D7  F3 0F 58 8B 60 98 61 00     addss   xmm1, dword ptr [rbx+619860h]
00007FF91DFC54DF  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFC54E3  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC54E7  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC54EA  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC54EE  F3 0F 11 83 F0 1A 62 00     movss   dword ptr [rbx+621AF0h], xmm0
00007FF91DFC54F6  F3 0F 10 9B B0 9A 61 00     movss   xmm3, dword ptr [rbx+619AB0h]
00007FF91DFC54FE  F3 0F 5D D9                 minss   xmm3, xmm1
00007FF91DFC5502  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFC5506  F3 0F 11 9B 50 98 61 00     movss   dword ptr [rbx+619850h], xmm3
00007FF91DFC550E  F3 0F 5C 9B 40 98 61 00     subss   xmm3, dword ptr [rbx+619840h]
00007FF91DFC5516  41 0F 2F DD                 comiss  xmm3, xmm13
00007FF91DFC551A  73 0A                       jnb     short loc_7FF91DFC5526
00007FF91DFC551C  F3 0F 10 83 D0 9A 61 00     movss   xmm0, dword ptr [rbx+619AD0h]
00007FF91DFC5524  EB 08                       jmp     short loc_7FF91DFC552E
00007FF91DFC5526  F3 0F 10 83 C0 9A 61 00     movss   xmm0, dword ptr [rbx+619AC0h]
00007FF91DFC552E  F3 0F 58 83 70 98 61 00     addss   xmm0, dword ptr [rbx+619870h]
00007FF91DFC5536  F3 0F 10 9B E0 98 61 00     movss   xmm3, dword ptr [rbx+6198E0h]
00007FF91DFC553E  45 0F 57 FF                 xorps   xmm15, xmm15
00007FF91DFC5542  F3 0F 10 93 40 98 61 00     movss   xmm2, dword ptr [rbx+619840h]
00007FF91DFC554A  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC554D  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFC5551  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFC5555  76 05                       jbe     short loc_7FF91DFC555C
00007FF91DFC5557  0F 5A E0                    cvtps2pd xmm4, xmm0
00007FF91DFC555A  EB 03                       jmp     short loc_7FF91DFC555F
00007FF91DFC555C  0F 57 E4                    xorps   xmm4, xmm4
00007FF91DFC555F  F3 0F 59 8B F0 99 61 00     mulss   xmm1, dword ptr [rbx+6199F0h]
00007FF91DFC5567  F3 44 0F 10 25 74 FF 77 00  movss   xmm12, cs:dword_7FF91E7454E4
00007FF91DFC5570  66 0F 5A C4                 cvtpd2ps xmm0, xmm4
00007FF91DFC5574  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC5578  41 0F 2F C4                 comiss  xmm0, xmm12
00007FF91DFC557C  73 06                       jnb     short loc_7FF91DFC5584
00007FF91DFC557E  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFC5582  EB 05                       jmp     short loc_7FF91DFC5589
00007FF91DFC5584  F3 41 0F 5D C6              minss   xmm0, xmm14
00007FF91DFC5589  F3 0F 59 83 20 9A 61 00     mulss   xmm0, dword ptr [rbx+619A20h]
00007FF91DFC5591  F3 0F 11 83 60 98 61 00     movss   dword ptr [rbx+619860h], xmm0
00007FF91DFC5599  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC559C  F3 0F 5C C2                 subss   xmm0, xmm2
00007FF91DFC55A0  41 0F 2E C5                 ucomiss xmm0, xmm13
00007FF91DFC55A4  74 03                       jz      short loc_7FF91DFC55A9
00007FF91DFC55A6  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFC55A9  F3 44 0F 10 1D 06 57 62 00  movss   xmm11, cs:dword_7FF91E5EACB8
00007FF91DFC55B2  0F 28 EB                    movaps  xmm5, xmm3
00007FF91DFC55B5  F3 0F 11 9B 30 98 61 00     movss   dword ptr [rbx+619830h], xmm3
00007FF91DFC55BD  F3 0F 58 9B 80 98 61 00     addss   xmm3, dword ptr [rbx+619880h]
00007FF91DFC55C5  8B 83 E0 1A 62 00           mov     eax, [rbx+621AE0h]
00007FF91DFC55CB  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC55CE  F3 0F 59 1D CA 56 62 00     mulss   xmm3, cs:dword_7FF91E5EACA0
00007FF91DFC55D6  F3 41 0F 59 C3              mulss   xmm0, xmm11
00007FF91DFC55DB  0F 5A CB                    cvtps2pd xmm1, xmm3
00007FF91DFC55DE  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC55E2  2B C2                       sub     eax, edx
00007FF91DFC55E4  48 63 C8                    movsxd  rcx, eax
00007FF91DFC55E7  48 63 83 E4 1A 62 00        movsxd  rax, dword ptr [rbx+621AE4h]
00007FF91DFC55EE  48 FF C1                    inc     rcx
00007FF91DFC55F1  48 FF C8                    dec     rax
00007FF91DFC55F4  48 23 C8                    and     rcx, rax
00007FF91DFC55F7  8B 84 8B E0 9A 61 00        mov     eax, [rbx+rcx*4+619AE0h]
00007FF91DFC55FE  89 83 00 1B 62 00           mov     [rbx+621B00h], eax
00007FF91DFC5604  8B 83 E0 1A 62 00           mov     eax, [rbx+621AE0h]
00007FF91DFC560A  2B C2                       sub     eax, edx
00007FF91DFC560C  48 63 C8                    movsxd  rcx, eax
00007FF91DFC560F  48 63 83 E4 1A 62 00        movsxd  rax, dword ptr [rbx+621AE4h]
00007FF91DFC5616  48 83 C1 02                 add     rcx, 2
00007FF91DFC561A  48 FF C8                    dec     rax
00007FF91DFC561D  48 23 C8                    and     rcx, rax
00007FF91DFC5620  8B 84 8B E0 9A 61 00        mov     eax, [rbx+rcx*4+619AE0h]
00007FF91DFC5627  89 83 04 1B 62 00           mov     [rbx+621B04h], eax
00007FF91DFC562D  F3 0F 2C C3                 cvttss2si eax, xmm3
00007FF91DFC5631  66 0F 6E C0                 movd    xmm0, eax
00007FF91DFC5635  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00007FF91DFC5639  F2 0F 5C C8                 subsd   xmm1, xmm0
00007FF91DFC563D  66 0F 5A E1                 cvtpd2ps xmm4, xmm1
00007FF91DFC5641  F3 0F 11 A3 08 1B 62 00     movss   dword ptr [rbx+621B08h], xmm4
00007FF91DFC5649  44 0F 28 D4                 movaps  xmm10, xmm4
00007FF91DFC564D  F3 0F 58 AB 90 98 61 00     addss   xmm5, dword ptr [rbx+619890h]
00007FF91DFC5655  F3 0F 10 9B 00 1B 62 00     movss   xmm3, dword ptr [rbx+621B00h]
00007FF91DFC565D  8B 83 E0 1A 62 00           mov     eax, [rbx+621AE0h]
00007FF91DFC5663  F3 0F 10 B3 70 98 61 00     movss   xmm6, dword ptr [rbx+619870h]
00007FF91DFC566B  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFC566F  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFC5672  F3 0F 59 2D 26 56 62 00     mulss   xmm5, cs:dword_7FF91E5EACA0
00007FF91DFC567A  F3 41 0F 59 C3              mulss   xmm0, xmm11
00007FF91DFC567F  0F 5A CD                    cvtps2pd xmm1, xmm5
00007FF91DFC5682  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC5686  2B C2                       sub     eax, edx
00007FF91DFC5688  48 63 C8                    movsxd  rcx, eax
00007FF91DFC568B  48 63 83 E4 1A 62 00        movsxd  rax, dword ptr [rbx+621AE4h]
00007FF91DFC5692  48 FF C1                    inc     rcx
00007FF91DFC5695  48 FF C8                    dec     rax
00007FF91DFC5698  48 23 C8                    and     rcx, rax
00007FF91DFC569B  8B 84 8B E0 9A 61 00        mov     eax, [rbx+rcx*4+619AE0h]
00007FF91DFC56A2  89 83 10 1B 62 00           mov     [rbx+621B10h], eax
00007FF91DFC56A8  8B 83 E0 1A 62 00           mov     eax, [rbx+621AE0h]
00007FF91DFC56AE  2B C2                       sub     eax, edx
00007FF91DFC56B0  48 63 C8                    movsxd  rcx, eax
00007FF91DFC56B3  48 63 83 E4 1A 62 00        movsxd  rax, dword ptr [rbx+621AE4h]
00007FF91DFC56BA  48 83 C1 02                 add     rcx, 2
00007FF91DFC56BE  48 FF C8                    dec     rax
00007FF91DFC56C1  48 23 C8                    and     rcx, rax
00007FF91DFC56C4  8B 84 8B E0 9A 61 00        mov     eax, [rbx+rcx*4+619AE0h]
00007FF91DFC56CB  89 83 14 1B 62 00           mov     [rbx+621B14h], eax
00007FF91DFC56D1  F3 0F 2C C5                 cvttss2si eax, xmm5
00007FF91DFC56D5  66 0F 6E C0                 movd    xmm0, eax
00007FF91DFC56D9  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00007FF91DFC56DD  F2 0F 5C C8                 subsd   xmm1, xmm0
00007FF91DFC56E1  66 0F 5A E9                 cvtpd2ps xmm5, xmm1
00007FF91DFC56E5  F3 0F 11 AB 18 1B 62 00     movss   dword ptr [rbx+621B18h], xmm5
00007FF91DFC56ED  F3 44 0F 59 93 04 1B 62 00  mulss   xmm10, dword ptr [rbx+621B04h]
00007FF91DFC56F6  F3 0F 10 83 D0 97 61 00     movss   xmm0, dword ptr [rbx+6197D0h]
00007FF91DFC56FE  F3 44 0F 5C D4              subss   xmm10, xmm4
00007FF91DFC5703  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFC5706  F3 44 0F 58 D3              addss   xmm10, xmm3
00007FF91DFC570B  F3 0F 10 9B 10 1B 62 00     movss   xmm3, dword ptr [rbx+621B10h]
00007FF91DFC5713  F3 44 0F 59 D6              mulss   xmm10, xmm6
00007FF91DFC5718  41 0F 28 CA                 movaps  xmm1, xmm10
00007FF91DFC571C  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC5720  F3 0F 11 8B B0 97 61 00     movss   dword ptr [rbx+6197B0h], xmm1
00007FF91DFC5728  F3 0F 59 8B 90 9A 61 00     mulss   xmm1, dword ptr [rbx+619A90h]
00007FF91DFC5730  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC5734  F3 0F 11 8B C0 97 61 00     movss   dword ptr [rbx+6197C0h], xmm1
00007FF91DFC573C  F3 0F 59 A3 14 1B 62 00     mulss   xmm4, dword ptr [rbx+621B14h]
00007FF91DFC5744  F3 0F 10 BB 40 9A 61 00     movss   xmm7, dword ptr [rbx+619A40h]
00007FF91DFC574C  41 0F 28 CE                 movaps  xmm1, xmm14
00007FF91DFC5750  F3 0F 10 93 30 9A 61 00     movss   xmm2, dword ptr [rbx+619A30h]
00007FF91DFC5758  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFC575B  F3 44 0F 10 83 60 97 61 00  movss   xmm8, dword ptr [rbx+619760h]
00007FF91DFC5764  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFC5768  F3 44 0F 10 8B 60 9A 61 00  movss   xmm9, dword ptr [rbx+619A60h]
00007FF91DFC5771  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFC5775  F3 41 0F 59 CA              mulss   xmm1, xmm10
00007FF91DFC577A  F3 0F 5C E5                 subss   xmm4, xmm5
00007FF91DFC577E  41 0F 28 EE                 movaps  xmm5, xmm14
00007FF91DFC5782  F3 0F 5C EF                 subss   xmm5, xmm7
00007FF91DFC5786  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC578A  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFC578E  0F 28 DF                    movaps  xmm3, xmm7
00007FF91DFC5791  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFC5796  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFC579B  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFC579F  F3 0F 10 B3 50 97 61 00     movss   xmm6, dword ptr [rbx+619750h]
00007FF91DFC57A7  F3 0F 58 DE                 addss   xmm3, xmm6
00007FF91DFC57AB  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFC57AF  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC57B3  F3 0F 10 83 E0 99 61 00     movss   xmm0, dword ptr [rbx+6199E0h]
00007FF91DFC57BB  F3 44 0F 59 D0              mulss   xmm10, xmm0
00007FF91DFC57C0  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC57C4  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFC57C8  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFC57CC  F3 45 0F 59 CA              mulss   xmm9, xmm10
00007FF91DFC57D1  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC57D5  41 0F 28 D6                 movaps  xmm2, xmm14
00007FF91DFC57D9  F3 0F 11 83 A0 98 61 00     movss   dword ptr [rbx+6198A0h], xmm0
00007FF91DFC57E1  F3 44 0F 11 8B B0 98 61 00  movss   dword ptr [rbx+6198B0h], xmm9
00007FF91DFC57EA  F3 0F 10 83 D0 99 61 00     movss   xmm0, dword ptr [rbx+6199D0h]
00007FF91DFC57F2  F3 0F 10 A3 10 9A 61 00     movss   xmm4, dword ptr [rbx+619A10h]
00007FF91DFC57FA  F3 0F 5C D4                 subss   xmm2, xmm4
00007FF91DFC57FE  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFC5802  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFC5806  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFC5809  F3 0F 10 83 50 9A 61 00     movss   xmm0, dword ptr [rbx+619A50h]
00007FF91DFC5811  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFC5815  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFC5819  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC581C  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFC5820  F3 0F 59 CB                 mulss   xmm1, xmm3
00007FF91DFC5824  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFC5828  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFC582D  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC5831  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFC5835  F3 0F 58 8B A0 98 61 00     addss   xmm1, dword ptr [rbx+6198A0h]
00007FF91DFC583D  F3 41 0F 58 E1              addss   xmm4, xmm9
00007FF91DFC5842  F3 0F 11 8B C0 98 61 00     movss   dword ptr [rbx+6198C0h], xmm1
00007FF91DFC584A  F3 0F 11 A3 D0 98 61 00     movss   dword ptr [rbx+6198D0h], xmm4
00007FF91DFC5852  8B 8B E4 1A 62 00           mov     ecx, [rbx+621AE4h]
00007FF91DFC5858  8B 83 E0 1A 62 00           mov     eax, [rbx+621AE0h]
00007FF91DFC585E  FF C9                       dec     ecx
00007FF91DFC5860  FF C8                       dec     eax
00007FF91DFC5862  23 C8                       and     ecx, eax
00007FF91DFC5864  89 8B E0 1A 62 00           mov     [rbx+621AE0h], ecx
00007FF91DFC586A  8B 83 F0 1A 62 00           mov     eax, [rbx+621AF0h]
00007FF91DFC5870  48 63 C9                    movsxd  rcx, ecx
00007FF91DFC5873  89 84 8B E0 9A 61 00        mov     [rbx+rcx*4+619AE0h], eax
00007FF91DFC587A  F3 0F 10 B3 70 8D 01 00     movss   xmm6, dword ptr [rbx+18D70h]
00007FF91DFC5882  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFC5885  F3 0F 59 B3 D0 98 61 00     mulss   xmm6, dword ptr [rbx+6198D0h]
00007FF91DFC588D  F3 0F 59 BB C0 98 61 00     mulss   xmm7, dword ptr [rbx+6198C0h]
00007FF91DFC5895  E9 CE 0E 00 00              jmp     loc_7FF91DFC6768
00007FF91DFC589A  45 0F 57 ED                 xorps   xmm13, xmm13
00007FF91DFC589E  39 B3 0C 30 A8 00           cmp     [rbx+0A8300Ch], esi
00007FF91DFC58A4  74 09                       jz      short loc_7FF91DFC58AF
00007FF91DFC58A6  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC58A9  45 0F 57 DB                 xorps   xmm11, xmm11
00007FF91DFC58AD  EB 11                       jmp     short loc_7FF91DFC58C0
00007FF91DFC58AF  F3 0F 10 83 90 8F 01 00     movss   xmm0, dword ptr [rbx+18F90h]
00007FF91DFC58B7  F3 44 0F 10 9B 80 8F 01 00  movss   xmm11, dword ptr [rbx+18F80h]
00007FF91DFC58C0  F3 0F 10 AB A0 8D 01 00     movss   xmm5, dword ptr [rbx+18DA0h]
00007FF91DFC58C8  F3 0F 10 93 C0 8E 01 00     movss   xmm2, dword ptr [rbx+18EC0h]
00007FF91DFC58D0  F3 0F 10 9B D0 8E 01 00     movss   xmm3, dword ptr [rbx+18ED0h]
00007FF91DFC58D8  F3 0F 10 B3 B0 8D 01 00     movss   xmm6, dword ptr [rbx+18DB0h]
00007FF91DFC58E0  F3 0F 10 A3 A0 8E 01 00     movss   xmm4, dword ptr [rbx+18EA0h]
00007FF91DFC58E8  F3 0F 10 8B B0 8E 01 00     movss   xmm1, dword ptr [rbx+18EB0h]
00007FF91DFC58F0  F3 0F 59 8B 00 90 01 00     mulss   xmm1, dword ptr [rbx+19000h]
00007FF91DFC58F8  8B 83 00 8E 01 00           mov     eax, [rbx+18E00h]
00007FF91DFC58FE  F3 0F 10 BB F0 8D 01 00     movss   xmm7, dword ptr [rbx+18DF0h]
00007FF91DFC5906  F3 44 0F 10 35 A5 F7 77 00  movss   xmm14, cs:dword_7FF91E7450B4
00007FF91DFC590F  89 83 10 8E 01 00           mov     [rbx+18E10h], eax
00007FF91DFC5915  8B 83 E0 8D 01 00           mov     eax, [rbx+18DE0h]
00007FF91DFC591B  89 83 F0 8D 01 00           mov     [rbx+18DF0h], eax
00007FF91DFC5921  8B 83 D0 8D 01 00           mov     eax, [rbx+18DD0h]
00007FF91DFC5927  89 83 E0 8D 01 00           mov     [rbx+18DE0h], eax
00007FF91DFC592D  8B 83 C0 8D 01 00           mov     eax, [rbx+18DC0h]
00007FF91DFC5933  89 83 D0 8D 01 00           mov     [rbx+18DD0h], eax
00007FF91DFC5939  8B 83 80 8E 01 00           mov     eax, [rbx+18E80h]
00007FF91DFC593F  89 83 90 8E 01 00           mov     [rbx+18E90h], eax
00007FF91DFC5945  8B 83 70 8E 01 00           mov     eax, [rbx+18E70h]
00007FF91DFC594B  89 83 80 8E 01 00           mov     [rbx+18E80h], eax
00007FF91DFC5951  8B 83 60 8E 01 00           mov     eax, [rbx+18E60h]
00007FF91DFC5957  89 83 70 8E 01 00           mov     [rbx+18E70h], eax
00007FF91DFC595D  8B 83 50 8E 01 00           mov     eax, [rbx+18E50h]
00007FF91DFC5963  89 83 60 8E 01 00           mov     [rbx+18E60h], eax
00007FF91DFC5969  8B 83 40 8E 01 00           mov     eax, [rbx+18E40h]
00007FF91DFC596F  89 83 50 8E 01 00           mov     [rbx+18E50h], eax
00007FF91DFC5975  8B 83 30 8E 01 00           mov     eax, [rbx+18E30h]
00007FF91DFC597B  89 83 40 8E 01 00           mov     [rbx+18E40h], eax
00007FF91DFC5981  8B 83 20 8E 01 00           mov     eax, [rbx+18E20h]
00007FF91DFC5987  89 83 30 8E 01 00           mov     [rbx+18E30h], eax
00007FF91DFC598D  8B 83 20 8F 01 00           mov     eax, [rbx+18F20h]
00007FF91DFC5993  89 83 30 8F 01 00           mov     [rbx+18F30h], eax
00007FF91DFC5999  8B 83 10 8F 01 00           mov     eax, [rbx+18F10h]
00007FF91DFC599F  F3 0F 11 83 A0 8F 01 00     movss   dword ptr [rbx+18FA0h], xmm0
00007FF91DFC59A7  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFC59AB  F3 0F 59 83 E0 8F 01 00     mulss   xmm0, dword ptr [rbx+18FE0h]
00007FF91DFC59B3  89 83 20 8F 01 00           mov     [rbx+18F20h], eax
00007FF91DFC59B9  8B 83 00 8F 01 00           mov     eax, [rbx+18F00h]
00007FF91DFC59BF  F3 0F 11 A3 B0 8E 01 00     movss   dword ptr [rbx+18EB0h], xmm4
00007FF91DFC59C7  F3 0F 59 A3 F0 8F 01 00     mulss   xmm4, dword ptr [rbx+18FF0h]
00007FF91DFC59CF  89 83 10 8F 01 00           mov     [rbx+18F10h], eax
00007FF91DFC59D5  8B 83 F0 8E 01 00           mov     eax, [rbx+18EF0h]
00007FF91DFC59DB  F3 0F 11 9B E0 8E 01 00     movss   dword ptr [rbx+18EE0h], xmm3
00007FF91DFC59E3  F3 0F 59 9B 20 90 01 00     mulss   xmm3, dword ptr [rbx+19020h]
00007FF91DFC59EB  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC59EF  89 83 00 8F 01 00           mov     [rbx+18F00h], eax
00007FF91DFC59F5  8B 83 60 8F 01 00           mov     eax, [rbx+18F60h]
00007FF91DFC59FB  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFC59FE  F3 0F 59 83 50 90 01 00     mulss   xmm0, dword ptr [rbx+19050h]
00007FF91DFC5A06  89 83 70 8F 01 00           mov     [rbx+18F70h], eax
00007FF91DFC5A0C  8B 83 50 8F 01 00           mov     eax, [rbx+18F50h]
00007FF91DFC5A12  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC5A16  F3 0F 11 93 D0 8E 01 00     movss   dword ptr [rbx+18ED0h], xmm2
00007FF91DFC5A1E  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFC5A22  F3 0F 59 93 10 90 01 00     mulss   xmm2, dword ptr [rbx+19010h]
00007FF91DFC5A2A  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC5A2E  89 83 60 8F 01 00           mov     [rbx+18F60h], eax
00007FF91DFC5A34  8B 83 40 8F 01 00           mov     eax, [rbx+18F40h]
00007FF91DFC5A3A  F3 0F 10 83 30 90 01 00     movss   xmm0, dword ptr [rbx+19030h]
00007FF91DFC5A42  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFC5A46  F3 0F 11 BB 00 8E 01 00     movss   dword ptr [rbx+18E00h], xmm7
00007FF91DFC5A4E  F3 0F 5C CE                 subss   xmm1, xmm6
00007FF91DFC5A52  F3 0F 11 B3 C0 8D 01 00     movss   dword ptr [rbx+18DC0h], xmm6
00007FF91DFC5A5A  F3 44 0F 11 9B 90 8F 01 00  movss   dword ptr [rbx+18F90h], xmm11
00007FF91DFC5A63  41 0F 28 D6                 movaps  xmm2, xmm14
00007FF91DFC5A67  F3 44 0F 11 8B 80 8D 01 00  movss   dword ptr [rbx+18D80h], xmm9
00007FF91DFC5A70  F3 44 0F 11 83 90 8D 01 00  movss   dword ptr [rbx+18D90h], xmm8
00007FF91DFC5A79  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFC5A7D  F3 44 0F 11 8B A0 8E 01 00  movss   dword ptr [rbx+18EA0h], xmm9
00007FF91DFC5A86  F3 0F 10 9B 40 90 01 00     movss   xmm3, dword ptr [rbx+19040h]
00007FF91DFC5A8E  F3 0F 59 CB                 mulss   xmm1, xmm3
00007FF91DFC5A92  89 B3 0C 30 A8 00           mov     [rbx+0A8300Ch], esi
00007FF91DFC5A98  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFC5A9C  89 83 50 8F 01 00           mov     [rbx+18F50h], eax
00007FF91DFC5AA2  F3 0F 58 CD                 addss   xmm1, xmm5
00007FF91DFC5AA6  F3 0F 11 A3 C0 8E 01 00     movss   dword ptr [rbx+18EC0h], xmm4
00007FF91DFC5AAE  F3 0F 58 DE                 addss   xmm3, xmm6
00007FF91DFC5AB2  F3 0F 11 8B A0 8D 01 00     movss   dword ptr [rbx+18DA0h], xmm1
00007FF91DFC5ABA  F3 0F 10 8B 60 90 01 00     movss   xmm1, dword ptr [rbx+19060h]
00007FF91DFC5AC2  F3 0F 11 9B B0 8D 01 00     movss   dword ptr [rbx+18DB0h], xmm3
00007FF91DFC5ACA  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC5ACE  F3 0F 59 BB A0 90 01 00     mulss   xmm7, dword ptr [rbx+190A0h]
00007FF91DFC5AD6  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFC5ADA  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFC5ADE  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC5AE2  41 0F 28 C6                 movaps  xmm0, xmm14
00007FF91DFC5AE6  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFC5AEA  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC5AEE  F3 41 0F 59 C1              mulss   xmm0, xmm9
00007FF91DFC5AF3  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC5AF7  F3 0F 59 93 B0 90 01 00     mulss   xmm2, dword ptr [rbx+190B0h]
00007FF91DFC5AFF  F3 0F 58 D7                 addss   xmm2, xmm7
00007FF91DFC5B03  F3 0F 59 93 C0 90 01 00     mulss   xmm2, dword ptr [rbx+190C0h]
00007FF91DFC5B0B  F3 0F 11 93 B0 91 41 00     movss   dword ptr [rbx+4191B0h], xmm2
00007FF91DFC5B13  F3 0F 10 93 30 8E 01 00     movss   xmm2, dword ptr [rbx+18E30h]
00007FF91DFC5B1B  F3 0F 10 B3 90 8D 01 00     movss   xmm6, dword ptr [rbx+18D90h]
00007FF91DFC5B23  F3 0F 10 8B 10 8F 01 00     movss   xmm1, dword ptr [rbx+18F10h]
00007FF91DFC5B2B  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFC5B2E  F3 0F 59 83 E0 8F 01 00     mulss   xmm0, dword ptr [rbx+18FE0h]
00007FF91DFC5B36  F3 0F 59 8B 00 90 01 00     mulss   xmm1, dword ptr [rbx+19000h]
00007FF91DFC5B3E  F3 0F 10 AB 00 8F 01 00     movss   xmm5, dword ptr [rbx+18F00h]
00007FF91DFC5B46  F3 0F 59 AB F0 8F 01 00     mulss   xmm5, dword ptr [rbx+18FF0h]
00007FF91DFC5B4E  F3 0F 10 9B 40 8E 01 00     movss   xmm3, dword ptr [rbx+18E40h]
00007FF91DFC5B56  F3 0F 10 A3 40 90 01 00     movss   xmm4, dword ptr [rbx+19040h]
00007FF91DFC5B5E  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC5B62  F3 0F 11 B3 F0 8E 01 00     movss   dword ptr [rbx+18EF0h], xmm6
00007FF91DFC5B6A  F3 0F 10 83 10 90 01 00     movss   xmm0, dword ptr [rbx+19010h]
00007FF91DFC5B72  F3 0F 59 83 20 8F 01 00     mulss   xmm0, dword ptr [rbx+18F20h]
00007FF91DFC5B7A  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFC5B7E  F3 0F 10 8B 20 90 01 00     movss   xmm1, dword ptr [rbx+19020h]
00007FF91DFC5B86  F3 0F 59 8B 30 8F 01 00     mulss   xmm1, dword ptr [rbx+18F30h]
00007FF91DFC5B8E  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC5B92  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC5B95  F3 0F 59 83 50 90 01 00     mulss   xmm0, dword ptr [rbx+19050h]
00007FF91DFC5B9D  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFC5BA1  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFC5BA4  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC5BA8  F3 0F 10 83 30 90 01 00     movss   xmm0, dword ptr [rbx+19030h]
00007FF91DFC5BB0  F3 0F 11 AB 10 8F 01 00     movss   dword ptr [rbx+18F10h], xmm5
00007FF91DFC5BB8  F3 0F 5C CB                 subss   xmm1, xmm3
00007FF91DFC5BBC  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC5BC0  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFC5BC4  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC5BC8  41 0F 28 D6                 movaps  xmm2, xmm14
00007FF91DFC5BCC  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC5BD0  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC5BD4  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFC5BD8  F3 0F 11 8B 20 8E 01 00     movss   dword ptr [rbx+18E20h], xmm1
00007FF91DFC5BE0  F3 0F 10 8B 60 90 01 00     movss   xmm1, dword ptr [rbx+19060h]
00007FF91DFC5BE8  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFC5BEC  F3 0F 11 A3 30 8E 01 00     movss   dword ptr [rbx+18E30h], xmm4
00007FF91DFC5BF4  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC5BF8  41 0F 28 C6                 movaps  xmm0, xmm14
00007FF91DFC5BFC  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFC5C00  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC5C04  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFC5C08  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC5C0C  F3 0F 10 83 A0 90 01 00     movss   xmm0, dword ptr [rbx+190A0h]
00007FF91DFC5C14  F3 0F 59 83 80 8E 01 00     mulss   xmm0, dword ptr [rbx+18E80h]
00007FF91DFC5C1C  F3 0F 59 93 B0 90 01 00     mulss   xmm2, dword ptr [rbx+190B0h]
00007FF91DFC5C24  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC5C28  F3 0F 59 93 C0 90 01 00     mulss   xmm2, dword ptr [rbx+190C0h]
00007FF91DFC5C30  F3 0F 11 93 D0 91 41 00     movss   dword ptr [rbx+4191D0h], xmm2
00007FF91DFC5C38  F3 0F 10 83 40 91 01 00     movss   xmm0, dword ptr [rbx+19140h]
00007FF91DFC5C40  F3 0F 58 83 90 8F 01 00     addss   xmm0, dword ptr [rbx+18F90h]
00007FF91DFC5C48  F3 0F 10 93 70 8F 01 00     movss   xmm2, dword ptr [rbx+18F70h]
00007FF91DFC5C50  F3 0F 10 AB A0 8F 01 00     movss   xmm5, dword ptr [rbx+18FA0h]
00007FF91DFC5C58  F3 41 0F 59 C2              mulss   xmm0, xmm10
00007FF91DFC5C5D  F3 0F 11 83 80 8F 01 00     movss   dword ptr [rbx+18F80h], xmm0
00007FF91DFC5C65  F3 0F 5C C2                 subss   xmm0, xmm2
00007FF91DFC5C69  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFC5C6D  73 0A                       jnb     short loc_7FF91DFC5C79
00007FF91DFC5C6F  F3 0F 10 83 70 91 01 00     movss   xmm0, dword ptr [rbx+19170h]
00007FF91DFC5C77  EB 08                       jmp     short loc_7FF91DFC5C81
00007FF91DFC5C79  F3 0F 10 83 60 91 01 00     movss   xmm0, dword ptr [rbx+19160h]
00007FF91DFC5C81  F3 0F 10 A3 D0 8F 01 00     movss   xmm4, dword ptr [rbx+18FD0h]
00007FF91DFC5C89  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC5C8D  F3 0F 10 8B 60 8F 01 00     movss   xmm1, dword ptr [rbx+18F60h]
00007FF91DFC5C95  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC5C98  F3 0F 5C 83 50 8F 01 00     subss   xmm0, dword ptr [rbx+18F50h]
00007FF91DFC5CA0  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFC5CA3  F3 0F 11 A3 40 8F 01 00     movss   dword ptr [rbx+18F40h], xmm4
00007FF91DFC5CAB  F3 0F 5C DA                 subss   xmm3, xmm2
00007FF91DFC5CAF  41 0F 2E C5                 ucomiss xmm0, xmm13
00007FF91DFC5CB3  74 03                       jz      short loc_7FF91DFC5CB8
00007FF91DFC5CB5  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC5CB8  41 0F 2F DD                 comiss  xmm3, xmm13
00007FF91DFC5CBC  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC5CBF  F3 0F 11 8B 50 8F 01 00     movss   dword ptr [rbx+18F50h], xmm1
00007FF91DFC5CC7  41 0F 54 CC                 andps   xmm1, xmm12
00007FF91DFC5CCB  F3 0F 59 8B 80 91 01 00     mulss   xmm1, dword ptr [rbx+19180h]
00007FF91DFC5CD3  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFC5CD7  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFC5CDB  F3 0F 5F D4                 maxss   xmm2, xmm4
00007FF91DFC5CDF  76 07                       jbe     short loc_7FF91DFC5CE8
00007FF91DFC5CE1  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFC5CE4  F3 0F 5D D4                 minss   xmm2, xmm4
00007FF91DFC5CE8  41 0F 2F ED                 comiss  xmm5, xmm13
00007FF91DFC5CEC  F3 0F 11 93 60 8F 01 00     movss   dword ptr [rbx+18F60h], xmm2
00007FF91DFC5CF4  45 0F 57 FF                 xorps   xmm15, xmm15
00007FF91DFC5CF8  76 05                       jbe     short loc_7FF91DFC5CFF
00007FF91DFC5CFA  0F 5A C5                    cvtps2pd xmm0, xmm5
00007FF91DFC5CFD  EB 03                       jmp     short loc_7FF91DFC5D02
00007FF91DFC5CFF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC5D02  F3 44 0F 10 25 D9 F7 77 00  movss   xmm12, cs:dword_7FF91E7454E4
00007FF91DFC5D0B  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFC5D0F  41 0F 2F C4                 comiss  xmm0, xmm12
00007FF91DFC5D13  73 06                       jnb     short loc_7FF91DFC5D1B
00007FF91DFC5D15  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFC5D19  EB 05                       jmp     short loc_7FF91DFC5D20
00007FF91DFC5D1B  F3 41 0F 5D C6              minss   xmm0, xmm14
00007FF91DFC5D20  F3 0F 59 83 C0 90 01 00     mulss   xmm0, dword ptr [rbx+190C0h]
00007FF91DFC5D28  8B 83 90 91 21 00           mov     eax, [rbx+219190h]
00007FF91DFC5D2E  F3 44 0F 10 1D 81 4F 62 00  movss   xmm11, cs:dword_7FF91E5EACB8
00007FF91DFC5D37  F3 0F 11 83 90 8F 01 00     movss   dword ptr [rbx+18F90h], xmm0
00007FF91DFC5D3F  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC5D42  F3 0F 59 15 56 4F 62 00     mulss   xmm2, cs:dword_7FF91E5EACA0
00007FF91DFC5D4A  F3 41 0F 59 C3              mulss   xmm0, xmm11
00007FF91DFC5D4F  0F 5A CA                    cvtps2pd xmm1, xmm2
00007FF91DFC5D52  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC5D56  2B C2                       sub     eax, edx
00007FF91DFC5D58  48 63 C8                    movsxd  rcx, eax
00007FF91DFC5D5B  48 63 83 94 91 21 00        movsxd  rax, dword ptr [rbx+219194h]
00007FF91DFC5D62  48 FF C1                    inc     rcx
00007FF91DFC5D65  48 FF C8                    dec     rax
00007FF91DFC5D68  48 23 C8                    and     rcx, rax
00007FF91DFC5D6B  8B 84 8B 90 91 01 00        mov     eax, [rbx+rcx*4+19190h]
00007FF91DFC5D72  89 83 C0 91 41 00           mov     [rbx+4191C0h], eax
00007FF91DFC5D78  8B 83 90 91 21 00           mov     eax, [rbx+219190h]
00007FF91DFC5D7E  2B C2                       sub     eax, edx
00007FF91DFC5D80  48 63 C8                    movsxd  rcx, eax
00007FF91DFC5D83  48 63 83 94 91 21 00        movsxd  rax, dword ptr [rbx+219194h]
00007FF91DFC5D8A  48 83 C1 02                 add     rcx, 2
00007FF91DFC5D8E  48 FF C8                    dec     rax
00007FF91DFC5D91  48 23 C8                    and     rcx, rax
00007FF91DFC5D94  8B 84 8B 90 91 01 00        mov     eax, [rbx+rcx*4+19190h]
00007FF91DFC5D9B  89 83 C4 91 41 00           mov     [rbx+4191C4h], eax
00007FF91DFC5DA1  F3 0F 2C C2                 cvttss2si eax, xmm2
00007FF91DFC5DA5  66 0F 6E C0                 movd    xmm0, eax
00007FF91DFC5DA9  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00007FF91DFC5DAD  F2 0F 5C C8                 subsd   xmm1, xmm0
00007FF91DFC5DB1  66 44 0F 5A C9              cvtpd2ps xmm9, xmm1
00007FF91DFC5DB6  F3 44 0F 11 8B C8 91 41 00  movss   dword ptr [rbx+4191C8h], xmm9
00007FF91DFC5DBF  45 0F 28 D1                 movaps  xmm10, xmm9
00007FF91DFC5DC3  F3 0F 10 8B C0 91 41 00     movss   xmm1, dword ptr [rbx+4191C0h]
00007FF91DFC5DCB  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFC5DCF  8B 83 A0 91 41 00           mov     eax, [rbx+4191A0h]
00007FF91DFC5DD5  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC5DD9  2B C2                       sub     eax, edx
00007FF91DFC5DDB  48 63 C8                    movsxd  rcx, eax
00007FF91DFC5DDE  48 63 83 A4 91 41 00        movsxd  rax, dword ptr [rbx+4191A4h]
00007FF91DFC5DE5  48 FF C1                    inc     rcx
00007FF91DFC5DE8  48 FF C8                    dec     rax
00007FF91DFC5DEB  48 23 C8                    and     rcx, rax
00007FF91DFC5DEE  8B 84 8B A0 91 21 00        mov     eax, [rbx+rcx*4+2191A0h]
00007FF91DFC5DF5  89 83 E0 91 41 00           mov     [rbx+4191E0h], eax
00007FF91DFC5DFB  8B 83 A0 91 41 00           mov     eax, [rbx+4191A0h]
00007FF91DFC5E01  2B C2                       sub     eax, edx
00007FF91DFC5E03  48 63 C8                    movsxd  rcx, eax
00007FF91DFC5E06  48 63 83 A4 91 41 00        movsxd  rax, dword ptr [rbx+4191A4h]
00007FF91DFC5E0D  48 83 C1 02                 add     rcx, 2
00007FF91DFC5E11  48 FF C8                    dec     rax
00007FF91DFC5E14  48 23 C8                    and     rcx, rax
00007FF91DFC5E17  8B 84 8B A0 91 21 00        mov     eax, [rbx+rcx*4+2191A0h]
00007FF91DFC5E1E  89 83 E4 91 41 00           mov     [rbx+4191E4h], eax
00007FF91DFC5E24  F3 44 0F 11 8B E8 91 41 00  movss   dword ptr [rbx+4191E8h], xmm9
00007FF91DFC5E2D  F3 44 0F 59 93 C4 91 41 00  mulss   xmm10, dword ptr [rbx+4191C4h]
00007FF91DFC5E36  F3 0F 10 9B F0 8D 01 00     movss   xmm3, dword ptr [rbx+18DF0h]
00007FF91DFC5E3E  F3 0F 10 A3 10 8E 01 00     movss   xmm4, dword ptr [rbx+18E10h]
00007FF91DFC5E46  F3 44 0F 5C D0              subss   xmm10, xmm0
00007FF91DFC5E4B  F3 0F 10 83 E0 8D 01 00     movss   xmm0, dword ptr [rbx+18DE0h]
00007FF91DFC5E53  F3 44 0F 58 D1              addss   xmm10, xmm1
00007FF91DFC5E58  F3 44 0F 59 93 A0 8F 01 00  mulss   xmm10, dword ptr [rbx+18FA0h]
00007FF91DFC5E61  F3 44 0F 11 93 C0 8D 01 00  movss   dword ptr [rbx+18DC0h], xmm10
00007FF91DFC5E6A  41 0F 28 D2                 movaps  xmm2, xmm10
00007FF91DFC5E6E  F3 0F 10 AB E0 90 01 00     movss   xmm5, dword ptr [rbx+190E0h]
00007FF91DFC5E76  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC5E7A  F3 0F 10 BB E0 91 41 00     movss   xmm7, dword ptr [rbx+4191E0h]
00007FF91DFC5E82  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFC5E86  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFC5E89  F3 0F 59 8B D0 90 01 00     mulss   xmm1, dword ptr [rbx+190D0h]
00007FF91DFC5E91  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC5E95  F3 0F 10 83 F0 90 01 00     movss   xmm0, dword ptr [rbx+190F0h]
00007FF91DFC5E9D  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC5EA1  F3 0F 11 8B D0 8D 01 00     movss   dword ptr [rbx+18DD0h], xmm1
00007FF91DFC5EA9  F3 0F 10 93 20 91 01 00     movss   xmm2, dword ptr [rbx+19120h]
00007FF91DFC5EB1  F3 0F 5C E8                 subss   xmm5, xmm0
00007FF91DFC5EB5  F3 0F 10 83 10 91 01 00     movss   xmm0, dword ptr [rbx+19110h]
00007FF91DFC5EBD  F3 0F 5C EB                 subss   xmm5, xmm3
00007FF91DFC5EC1  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFC5EC4  F3 0F 59 8B 00 91 01 00     mulss   xmm1, dword ptr [rbx+19100h]
00007FF91DFC5ECC  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFC5ED0  F3 0F 10 9B 70 8E 01 00     movss   xmm3, dword ptr [rbx+18E70h]
00007FF91DFC5ED8  45 0F 28 C1                 movaps  xmm8, xmm9
00007FF91DFC5EDC  F3 0F 10 B3 90 8D 01 00     movss   xmm6, dword ptr [rbx+18D90h]
00007FF91DFC5EE4  F3 0F 11 8B E0 8D 01 00     movss   dword ptr [rbx+18DE0h], xmm1
00007FF91DFC5EEC  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC5EF0  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC5EF4  F3 44 0F 59 CF              mulss   xmm9, xmm7
00007FF91DFC5EF9  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC5EFD  F3 0F 10 83 60 8E 01 00     movss   xmm0, dword ptr [rbx+18E60h]
00007FF91DFC5F05  F3 0F 5C D4                 subss   xmm2, xmm4
00007FF91DFC5F09  F3 0F 11 93 F0 8D 01 00     movss   dword ptr [rbx+18DF0h], xmm2
00007FF91DFC5F11  F3 0F 59 93 30 91 01 00     mulss   xmm2, dword ptr [rbx+19130h]
00007FF91DFC5F19  F3 0F 58 D4                 addss   xmm2, xmm4
00007FF91DFC5F1D  F3 0F 10 A3 90 8E 01 00     movss   xmm4, dword ptr [rbx+18E90h]
00007FF91DFC5F25  F3 0F 11 93 00 8E 01 00     movss   dword ptr [rbx+18E00h], xmm2
00007FF91DFC5F2D  F3 44 0F 59 83 E4 91 41 00  mulss   xmm8, dword ptr [rbx+4191E4h]
00007FF91DFC5F36  F3 45 0F 5C C1              subss   xmm8, xmm9
00007FF91DFC5F3B  F3 44 0F 58 C7              addss   xmm8, xmm7
00007FF91DFC5F40  F3 44 0F 59 83 A0 8F 01 00  mulss   xmm8, dword ptr [rbx+18FA0h]
00007FF91DFC5F49  F3 44 0F 11 83 40 8E 01 00  movss   dword ptr [rbx+18E40h], xmm8
00007FF91DFC5F52  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFC5F56  F3 0F 10 AB E0 90 01 00     movss   xmm5, dword ptr [rbx+190E0h]
00007FF91DFC5F5E  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC5F62  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFC5F66  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFC5F69  F3 0F 59 8B D0 90 01 00     mulss   xmm1, dword ptr [rbx+190D0h]
00007FF91DFC5F71  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC5F75  F3 0F 10 83 F0 90 01 00     movss   xmm0, dword ptr [rbx+190F0h]
00007FF91DFC5F7D  F3 0F 11 8B 50 8E 01 00     movss   dword ptr [rbx+18E50h], xmm1
00007FF91DFC5F85  F3 0F 10 93 20 91 01 00     movss   xmm2, dword ptr [rbx+19120h]
00007FF91DFC5F8D  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC5F91  F3 0F 5C E8                 subss   xmm5, xmm0
00007FF91DFC5F95  F3 0F 10 83 10 91 01 00     movss   xmm0, dword ptr [rbx+19110h]
00007FF91DFC5F9D  F3 0F 5C EB                 subss   xmm5, xmm3
00007FF91DFC5FA1  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC5FA5  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFC5FA8  F3 0F 59 8B 00 91 01 00     mulss   xmm1, dword ptr [rbx+19100h]
00007FF91DFC5FB0  F3 0F 10 AB B0 90 01 00     movss   xmm5, dword ptr [rbx+190B0h]
00007FF91DFC5FB8  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFC5FBC  41 0F 28 DE                 movaps  xmm3, xmm14
00007FF91DFC5FC0  F3 0F 5C DD                 subss   xmm3, xmm5
00007FF91DFC5FC4  F3 0F 11 8B 60 8E 01 00     movss   dword ptr [rbx+18E60h], xmm1
00007FF91DFC5FCC  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC5FD0  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFC5FD3  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC5FD7  F3 0F 5C D4                 subss   xmm2, xmm4
00007FF91DFC5FDB  F3 0F 11 93 70 8E 01 00     movss   dword ptr [rbx+18E70h], xmm2
00007FF91DFC5FE3  F3 0F 10 83 80 90 01 00     movss   xmm0, dword ptr [rbx+19080h]
00007FF91DFC5FEB  F3 0F 59 93 30 91 01 00     mulss   xmm2, dword ptr [rbx+19130h]
00007FF91DFC5FF3  F3 44 0F 59 D0              mulss   xmm10, xmm0
00007FF91DFC5FF8  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFC5FFD  F3 0F 58 D4                 addss   xmm2, xmm4
00007FF91DFC6001  F3 0F 11 93 80 8E 01 00     movss   dword ptr [rbx+18E80h], xmm2
00007FF91DFC6009  F3 0F 10 A3 70 90 01 00     movss   xmm4, dword ptr [rbx+19070h]
00007FF91DFC6011  F3 0F 10 93 80 8D 01 00     movss   xmm2, dword ptr [rbx+18D80h]
00007FF91DFC6019  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC601C  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC6020  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFC6024  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFC6028  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC602B  F3 0F 59 EC                 mulss   xmm5, xmm4
00007FF91DFC602F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC6033  F3 0F 59 DE                 mulss   xmm3, xmm6
00007FF91DFC6037  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC603B  F3 0F 58 EB                 addss   xmm5, xmm3
00007FF91DFC603F  F3 41 0F 58 CA              addss   xmm1, xmm10
00007FF91DFC6044  F3 41 0F 58 E8              addss   xmm5, xmm8
00007FF91DFC6049  F3 0F 11 8B B0 8F 01 00     movss   dword ptr [rbx+18FB0h], xmm1
00007FF91DFC6051  F3 0F 11 AB C0 8F 01 00     movss   dword ptr [rbx+18FC0h], xmm5
00007FF91DFC6059  8B 8B 94 91 21 00           mov     ecx, [rbx+219194h]
00007FF91DFC605F  8B 83 90 91 21 00           mov     eax, [rbx+219190h]
00007FF91DFC6065  FF C9                       dec     ecx
00007FF91DFC6067  FF C8                       dec     eax
00007FF91DFC6069  23 C8                       and     ecx, eax
00007FF91DFC606B  89 8B 90 91 21 00           mov     [rbx+219190h], ecx
00007FF91DFC6071  8B 83 B0 91 41 00           mov     eax, [rbx+4191B0h]
00007FF91DFC6077  48 63 C9                    movsxd  rcx, ecx
00007FF91DFC607A  89 84 8B 90 91 01 00        mov     [rbx+rcx*4+19190h], eax
00007FF91DFC6081  8B 8B A4 91 41 00           mov     ecx, [rbx+4191A4h]
00007FF91DFC6087  8B 83 A0 91 41 00           mov     eax, [rbx+4191A0h]
00007FF91DFC608D  FF C9                       dec     ecx
00007FF91DFC608F  FF C8                       dec     eax
00007FF91DFC6091  23 C8                       and     ecx, eax
00007FF91DFC6093  89 8B A0 91 41 00           mov     [rbx+4191A0h], ecx
00007FF91DFC6099  8B 83 D0 91 41 00           mov     eax, [rbx+4191D0h]
00007FF91DFC609F  48 63 C9                    movsxd  rcx, ecx
00007FF91DFC60A2  89 84 8B A0 91 21 00        mov     [rbx+rcx*4+2191A0h], eax
00007FF91DFC60A9  F3 0F 10 B3 70 8D 01 00     movss   xmm6, dword ptr [rbx+18D70h]
00007FF91DFC60B1  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFC60B4  F3 0F 59 B3 C0 8F 01 00     mulss   xmm6, dword ptr [rbx+18FC0h]
00007FF91DFC60BC  F3 0F 59 BB B0 8F 01 00     mulss   xmm7, dword ptr [rbx+18FB0h]
00007FF91DFC60C4  E9 9F 06 00 00              jmp     loc_7FF91DFC6768
00007FF91DFC60C9  83 BB 0C 30 A8 00 01        cmp     dword ptr [rbx+0A8300Ch], 1
00007FF91DFC60D0  74 12                       jz      short loc_7FF91DFC60E4
00007FF91DFC60D2  89 B3 20 93 41 00           mov     [rbx+419320h], esi
00007FF91DFC60D8  89 B3 30 93 41 00           mov     [rbx+419330h], esi
00007FF91DFC60DE  89 B3 40 93 41 00           mov     [rbx+419340h], esi
00007FF91DFC60E4  C7 83 0C 30 A8 00 01 00 00 00  mov     dword ptr [rbx+0A8300Ch], 1
00007FF91DFC60EE  8B 83 70 92 41 00           mov     eax, [rbx+419270h]
00007FF91DFC60F4  89 83 80 92 41 00           mov     [rbx+419280h], eax
00007FF91DFC60FA  8B 83 60 92 41 00           mov     eax, [rbx+419260h]
00007FF91DFC6100  89 83 70 92 41 00           mov     [rbx+419270h], eax
00007FF91DFC6106  8B 83 50 92 41 00           mov     eax, [rbx+419250h]
00007FF91DFC610C  89 83 60 92 41 00           mov     [rbx+419260h], eax
00007FF91DFC6112  8B 83 40 92 41 00           mov     eax, [rbx+419240h]
00007FF91DFC6118  89 83 50 92 41 00           mov     [rbx+419250h], eax
00007FF91DFC611E  8B 83 30 92 41 00           mov     eax, [rbx+419230h]
00007FF91DFC6124  89 83 40 92 41 00           mov     [rbx+419240h], eax
00007FF91DFC612A  8B 83 20 92 41 00           mov     eax, [rbx+419220h]
00007FF91DFC6130  89 83 30 92 41 00           mov     [rbx+419230h], eax
00007FF91DFC6136  8B 83 10 92 41 00           mov     eax, [rbx+419210h]
00007FF91DFC613C  89 83 20 92 41 00           mov     [rbx+419220h], eax
00007FF91DFC6142  8B 83 C0 92 41 00           mov     eax, [rbx+4192C0h]
00007FF91DFC6148  89 83 D0 92 41 00           mov     [rbx+4192D0h], eax
00007FF91DFC614E  8B 83 B0 92 41 00           mov     eax, [rbx+4192B0h]
00007FF91DFC6154  89 83 C0 92 41 00           mov     [rbx+4192C0h], eax
00007FF91DFC615A  8B 83 A0 92 41 00           mov     eax, [rbx+4192A0h]
00007FF91DFC6160  89 83 B0 92 41 00           mov     [rbx+4192B0h], eax
00007FF91DFC6166  8B 83 90 92 41 00           mov     eax, [rbx+419290h]
00007FF91DFC616C  89 83 A0 92 41 00           mov     [rbx+4192A0h], eax
00007FF91DFC6172  8B 83 00 93 41 00           mov     eax, [rbx+419300h]
00007FF91DFC6178  89 83 10 93 41 00           mov     [rbx+419310h], eax
00007FF91DFC617E  8B 83 F0 92 41 00           mov     eax, [rbx+4192F0h]
00007FF91DFC6184  89 83 00 93 41 00           mov     [rbx+419300h], eax
00007FF91DFC618A  8B 83 E0 92 41 00           mov     eax, [rbx+4192E0h]
00007FF91DFC6190  F3 44 0F 10 35 1B EF 77 00  movss   xmm14, cs:dword_7FF91E7450B4
00007FF91DFC6199  89 83 F0 92 41 00           mov     [rbx+4192F0h], eax
00007FF91DFC619F  8B 83 30 93 41 00           mov     eax, [rbx+419330h]
00007FF91DFC61A5  89 83 40 93 41 00           mov     [rbx+419340h], eax
00007FF91DFC61AB  8B 83 20 93 41 00           mov     eax, [rbx+419320h]
00007FF91DFC61B1  89 83 30 93 41 00           mov     [rbx+419330h], eax
00007FF91DFC61B7  F3 44 0F 11 8B F0 91 41 00  movss   dword ptr [rbx+4191F0h], xmm9
00007FF91DFC61C0  F3 44 0F 11 83 00 92 41 00  movss   dword ptr [rbx+419200h], xmm8
00007FF91DFC61C9  F3 45 0F 58 C1              addss   xmm8, xmm9
00007FF91DFC61CE  F3 45 0F 59 C7              mulss   xmm8, xmm15
00007FF91DFC61D3  F3 44 0F 11 83 90 92 41 00  movss   dword ptr [rbx+419290h], xmm8
00007FF91DFC61DC  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFC61E0  F3 0F 59 83 80 93 41 00     mulss   xmm0, dword ptr [rbx+419380h]
00007FF91DFC61E8  F3 0F 10 8B A0 93 41 00     movss   xmm1, dword ptr [rbx+4193A0h]
00007FF91DFC61F0  F3 0F 59 8B B0 92 41 00     mulss   xmm1, dword ptr [rbx+4192B0h]
00007FF91DFC61F8  F3 0F 10 AB 90 93 41 00     movss   xmm5, dword ptr [rbx+419390h]
00007FF91DFC6200  F3 0F 59 AB A0 92 41 00     mulss   xmm5, dword ptr [rbx+4192A0h]
00007FF91DFC6208  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC620C  F3 0F 10 83 B0 93 41 00     movss   xmm0, dword ptr [rbx+4193B0h]
00007FF91DFC6214  F3 0F 59 83 C0 92 41 00     mulss   xmm0, dword ptr [rbx+4192C0h]
00007FF91DFC621C  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFC6220  F3 0F 10 8B C0 93 41 00     movss   xmm1, dword ptr [rbx+4193C0h]
00007FF91DFC6228  F3 0F 59 8B D0 92 41 00     mulss   xmm1, dword ptr [rbx+4192D0h]
00007FF91DFC6230  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC6234  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFC6238  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFC623C  F3 0F 11 AB B0 92 41 00     movss   dword ptr [rbx+4192B0h], xmm5
00007FF91DFC6244  F3 0F 10 93 20 92 41 00     movss   xmm2, dword ptr [rbx+419220h]
00007FF91DFC624C  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC624F  F3 0F 59 83 F0 93 41 00     mulss   xmm0, dword ptr [rbx+4193F0h]
00007FF91DFC6257  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC625B  F3 0F 5C 8B 30 92 41 00     subss   xmm1, dword ptr [rbx+419230h]
00007FF91DFC6263  F3 0F 59 8B E0 93 41 00     mulss   xmm1, dword ptr [rbx+4193E0h]
00007FF91DFC626B  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC626F  41 0F 28 D6                 movaps  xmm2, xmm14
00007FF91DFC6273  F3 0F 11 8B 10 92 41 00     movss   dword ptr [rbx+419210h], xmm1
00007FF91DFC627B  F3 0F 10 9B E0 93 41 00     movss   xmm3, dword ptr [rbx+4193E0h]
00007FF91DFC6283  F3 0F 59 9B 20 92 41 00     mulss   xmm3, dword ptr [rbx+419220h]
00007FF91DFC628B  F3 0F 58 9B 30 92 41 00     addss   xmm3, dword ptr [rbx+419230h]
00007FF91DFC6293  F3 0F 11 9B 20 92 41 00     movss   dword ptr [rbx+419220h], xmm3
00007FF91DFC629B  F3 0F 10 83 D0 93 41 00     movss   xmm0, dword ptr [rbx+4193D0h]
00007FF91DFC62A3  F3 0F 10 8B 00 94 41 00     movss   xmm1, dword ptr [rbx+419400h]
00007FF91DFC62AB  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC62AF  F3 0F 10 A3 20 95 41 00     movss   xmm4, dword ptr [rbx+419520h]
00007FF91DFC62B7  F3 0F 58 A3 30 93 41 00     addss   xmm4, dword ptr [rbx+419330h]
00007FF91DFC62BF  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC62C3  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFC62C7  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC62CB  41 0F 28 C6                 movaps  xmm0, xmm14
00007FF91DFC62CF  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFC62D3  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC62D7  F3 41 0F 59 C0              mulss   xmm0, xmm8
00007FF91DFC62DC  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC62E0  F3 0F 59 93 60 94 41 00     mulss   xmm2, dword ptr [rbx+419460h]
00007FF91DFC62E8  45 0F 57 ED                 xorps   xmm13, xmm13
00007FF91DFC62EC  F3 0F 10 83 50 94 41 00     movss   xmm0, dword ptr [rbx+419450h]
00007FF91DFC62F4  F3 0F 59 83 70 92 41 00     mulss   xmm0, dword ptr [rbx+419270h]
00007FF91DFC62FC  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC6300  F3 0F 59 93 70 94 41 00     mulss   xmm2, dword ptr [rbx+419470h]
00007FF91DFC6308  F3 0F 11 93 80 95 61 00     movss   dword ptr [rbx+619580h], xmm2
00007FF91DFC6310  F3 0F 10 8B 30 95 41 00     movss   xmm1, dword ptr [rbx+419530h]
00007FF91DFC6318  F3 0F 5D CC                 minss   xmm1, xmm4
00007FF91DFC631C  F3 41 0F 59 CA              mulss   xmm1, xmm10
00007FF91DFC6321  F3 0F 11 8B 20 93 41 00     movss   dword ptr [rbx+419320h], xmm1
00007FF91DFC6329  F3 0F 5C 8B 10 93 41 00     subss   xmm1, dword ptr [rbx+419310h]
00007FF91DFC6331  F3 0F 10 B3 40 93 41 00     movss   xmm6, dword ptr [rbx+419340h]
00007FF91DFC6339  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFC633D  73 0A                       jnb     short loc_7FF91DFC6349
00007FF91DFC633F  F3 0F 10 83 50 95 41 00     movss   xmm0, dword ptr [rbx+419550h]
00007FF91DFC6347  EB 08                       jmp     short loc_7FF91DFC6351
00007FF91DFC6349  F3 0F 10 83 40 95 41 00     movss   xmm0, dword ptr [rbx+419540h]
00007FF91DFC6351  F3 0F 10 AB 70 93 41 00     movss   xmm5, dword ptr [rbx+419370h]
00007FF91DFC6359  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFC635D  F3 0F 11 AB E0 92 41 00     movss   dword ptr [rbx+4192E0h], xmm5
00007FF91DFC6365  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFC6368  F3 0F 5C 83 F0 92 41 00     subss   xmm0, dword ptr [rbx+4192F0h]
00007FF91DFC6370  F3 0F 10 93 10 93 41 00     movss   xmm2, dword ptr [rbx+419310h]
00007FF91DFC6378  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFC637B  F3 0F 10 9B 00 93 41 00     movss   xmm3, dword ptr [rbx+419300h]
00007FF91DFC6383  F3 0F 5C E2                 subss   xmm4, xmm2
00007FF91DFC6387  F3 0F 10 BB 60 95 41 00     movss   xmm7, dword ptr [rbx+419560h]
00007FF91DFC638F  41 0F 2E C5                 ucomiss xmm0, xmm13
00007FF91DFC6393  74 03                       jz      short loc_7FF91DFC6398
00007FF91DFC6395  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFC6398  41 0F 2F E5                 comiss  xmm4, xmm13
00007FF91DFC639C  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC639F  F3 0F 11 9B F0 92 41 00     movss   dword ptr [rbx+4192F0h], xmm3
00007FF91DFC63A7  41 0F 54 DC                 andps   xmm3, xmm12
00007FF91DFC63AB  F3 0F 59 DF                 mulss   xmm3, xmm7
00007FF91DFC63AF  F3 0F 5C D3                 subss   xmm2, xmm3
00007FF91DFC63B3  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFC63B7  F3 0F 5F D5                 maxss   xmm2, xmm5
00007FF91DFC63BB  76 07                       jbe     short loc_7FF91DFC63C4
00007FF91DFC63BD  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFC63C0  F3 0F 5D D5                 minss   xmm2, xmm5
00007FF91DFC63C4  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFC63C8  F3 0F 11 93 00 93 41 00     movss   dword ptr [rbx+419300h], xmm2
00007FF91DFC63D0  45 0F 57 FF                 xorps   xmm15, xmm15
00007FF91DFC63D4  76 05                       jbe     short loc_7FF91DFC63DB
00007FF91DFC63D6  0F 5A C6                    cvtps2pd xmm0, xmm6
00007FF91DFC63D9  EB 03                       jmp     short loc_7FF91DFC63DE
00007FF91DFC63DB  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC63DE  F3 44 0F 10 25 FD F0 77 00  movss   xmm12, cs:dword_7FF91E7454E4
00007FF91DFC63E7  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFC63EB  41 0F 2F C4                 comiss  xmm0, xmm12
00007FF91DFC63EF  73 06                       jnb     short loc_7FF91DFC63F7
00007FF91DFC63F1  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFC63F5  EB 05                       jmp     short loc_7FF91DFC63FC
00007FF91DFC63F7  F3 41 0F 5D C6              minss   xmm0, xmm14
00007FF91DFC63FC  F3 0F 59 83 70 94 41 00     mulss   xmm0, dword ptr [rbx+419470h]
00007FF91DFC6404  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFC6407  F3 0F 11 83 30 93 41 00     movss   dword ptr [rbx+419330h], xmm0
00007FF91DFC640F  F3 0F 59 8B 40 94 41 00     mulss   xmm1, dword ptr [rbx+419440h]
00007FF91DFC6417  0F 2F 0D E6 1C 62 00        comiss  xmm1, cs:dword_7FF91E5E8104
00007FF91DFC641E  76 05                       jbe     short loc_7FF91DFC6425
00007FF91DFC6420  0F 5A D9                    cvtps2pd xmm3, xmm1
00007FF91DFC6423  EB 08                       jmp     short loc_7FF91DFC642D
00007FF91DFC6425  F2 0F 10 1D 53 48 62 00     movsd   xmm3, cs:qword_7FF91E5EAC80
00007FF91DFC642D  8B 83 70 95 61 00           mov     eax, [rbx+619570h]
00007FF91DFC6433  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC6436  F3 0F 59 15 62 48 62 00     mulss   xmm2, cs:dword_7FF91E5EACA0
00007FF91DFC643E  F3 44 0F 10 1D 71 48 62 00  movss   xmm11, cs:dword_7FF91E5EACB8
00007FF91DFC6447  F3 41 0F 59 C3              mulss   xmm0, xmm11
00007FF91DFC644C  0F 5A CA                    cvtps2pd xmm1, xmm2
00007FF91DFC644F  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC6453  2B C2                       sub     eax, edx
00007FF91DFC6455  48 63 C8                    movsxd  rcx, eax
00007FF91DFC6458  48 63 83 74 95 61 00        movsxd  rax, dword ptr [rbx+619574h]
00007FF91DFC645F  48 FF C1                    inc     rcx
00007FF91DFC6462  48 FF C8                    dec     rax
00007FF91DFC6465  48 23 C8                    and     rcx, rax
00007FF91DFC6468  8B 84 8B 70 95 41 00        mov     eax, [rbx+rcx*4+419570h]
00007FF91DFC646F  89 83 90 95 61 00           mov     [rbx+619590h], eax
00007FF91DFC6475  8B 83 70 95 61 00           mov     eax, [rbx+619570h]
00007FF91DFC647B  2B C2                       sub     eax, edx
00007FF91DFC647D  48 63 C8                    movsxd  rcx, eax
00007FF91DFC6480  48 63 83 74 95 61 00        movsxd  rax, dword ptr [rbx+619574h]
00007FF91DFC6487  48 83 C1 02                 add     rcx, 2
00007FF91DFC648B  48 FF C8                    dec     rax
00007FF91DFC648E  48 23 C8                    and     rcx, rax
00007FF91DFC6491  8B 84 8B 70 95 41 00        mov     eax, [rbx+rcx*4+419570h]
00007FF91DFC6498  89 83 94 95 61 00           mov     [rbx+619594h], eax
00007FF91DFC649E  F3 0F 2C C2                 cvttss2si eax, xmm2
00007FF91DFC64A2  66 0F 5A D3                 cvtpd2ps xmm2, xmm3
00007FF91DFC64A6  66 0F 6E C0                 movd    xmm0, eax
00007FF91DFC64AA  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00007FF91DFC64AE  F2 0F 5C C8                 subsd   xmm1, xmm0
00007FF91DFC64B2  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC64B5  F3 0F 59 15 E3 47 62 00     mulss   xmm2, cs:dword_7FF91E5EACA0
00007FF91DFC64BD  F3 41 0F 59 C3              mulss   xmm0, xmm11
00007FF91DFC64C2  66 0F 5A F9                 cvtpd2ps xmm7, xmm1
00007FF91DFC64C6  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC64CA  F3 0F 11 BB 98 95 61 00     movss   dword ptr [rbx+619598h], xmm7
00007FF91DFC64D2  0F 28 DF                    movaps  xmm3, xmm7
00007FF91DFC64D5  8B 83 70 95 61 00           mov     eax, [rbx+619570h]
00007FF91DFC64DB  F3 0F 10 AB 90 95 61 00     movss   xmm5, dword ptr [rbx+619590h]
00007FF91DFC64E3  2B C2                       sub     eax, edx
00007FF91DFC64E5  48 63 C8                    movsxd  rcx, eax
00007FF91DFC64E8  48 63 83 74 95 61 00        movsxd  rax, dword ptr [rbx+619574h]
00007FF91DFC64EF  48 FF C1                    inc     rcx
00007FF91DFC64F2  48 FF C8                    dec     rax
00007FF91DFC64F5  F3 0F 59 FD                 mulss   xmm7, xmm5
00007FF91DFC64F9  48 23 C8                    and     rcx, rax
00007FF91DFC64FC  0F 5A CA                    cvtps2pd xmm1, xmm2
00007FF91DFC64FF  8B 84 8B 70 95 41 00        mov     eax, [rbx+rcx*4+419570h]
00007FF91DFC6506  89 83 A0 95 61 00           mov     [rbx+6195A0h], eax
00007FF91DFC650C  8B 83 70 95 61 00           mov     eax, [rbx+619570h]
00007FF91DFC6512  2B C2                       sub     eax, edx
00007FF91DFC6514  48 63 C8                    movsxd  rcx, eax
00007FF91DFC6517  48 63 83 74 95 61 00        movsxd  rax, dword ptr [rbx+619574h]
00007FF91DFC651E  48 83 C1 02                 add     rcx, 2
00007FF91DFC6522  48 FF C8                    dec     rax
00007FF91DFC6525  48 23 C8                    and     rcx, rax
00007FF91DFC6528  8B 84 8B 70 95 41 00        mov     eax, [rbx+rcx*4+419570h]
00007FF91DFC652F  89 83 A4 95 61 00           mov     [rbx+6195A4h], eax
00007FF91DFC6535  F3 0F 2C C2                 cvttss2si eax, xmm2
00007FF91DFC6539  66 0F 6E C0                 movd    xmm0, eax
00007FF91DFC653D  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00007FF91DFC6541  F2 0F 5C C8                 subsd   xmm1, xmm0
00007FF91DFC6545  66 44 0F 5A D1              cvtpd2ps xmm10, xmm1
00007FF91DFC654A  F3 44 0F 11 93 A8 95 61 00  movss   dword ptr [rbx+6195A8h], xmm10
00007FF91DFC6553  F3 0F 59 9B 94 95 61 00     mulss   xmm3, dword ptr [rbx+619594h]
00007FF91DFC655B  F3 0F 10 83 50 92 41 00     movss   xmm0, dword ptr [rbx+419250h]
00007FF91DFC6563  F3 0F 5C DF                 subss   xmm3, xmm7
00007FF91DFC6567  F3 0F 58 DD                 addss   xmm3, xmm5
00007FF91DFC656B  F3 0F 59 9B 40 93 41 00     mulss   xmm3, dword ptr [rbx+419340h]
00007FF91DFC6573  F3 0F 11 9B 30 92 41 00     movss   dword ptr [rbx+419230h], xmm3
00007FF91DFC657B  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFC657F  F3 0F 10 A3 C0 94 41 00     movss   xmm4, dword ptr [rbx+4194C0h]
00007FF91DFC6587  F3 0F 10 BB A0 95 61 00     movss   xmm7, dword ptr [rbx+6195A0h]
00007FF91DFC658F  F3 0F 10 93 60 92 41 00     movss   xmm2, dword ptr [rbx+419260h]
00007FF91DFC6597  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC659A  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFC659E  F3 0F 59 8B B0 94 41 00     mulss   xmm1, dword ptr [rbx+4194B0h]
00007FF91DFC65A6  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC65AA  F3 0F 10 83 D0 94 41 00     movss   xmm0, dword ptr [rbx+4194D0h]
00007FF91DFC65B2  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC65B6  F3 0F 11 8B 40 92 41 00     movss   dword ptr [rbx+419240h], xmm1
00007FF91DFC65BE  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFC65C2  F3 0F 10 9B 80 92 41 00     movss   xmm3, dword ptr [rbx+419280h]
00007FF91DFC65CA  F3 0F 5C E2                 subss   xmm4, xmm2
00007FF91DFC65CE  F3 0F 10 83 F0 94 41 00     movss   xmm0, dword ptr [rbx+4194F0h]
00007FF91DFC65D6  45 0F 28 CA                 movaps  xmm9, xmm10
00007FF91DFC65DA  F3 44 0F 59 D7              mulss   xmm10, xmm7
00007FF91DFC65DF  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFC65E3  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFC65E6  F3 0F 59 8B E0 94 41 00     mulss   xmm1, dword ptr [rbx+4194E0h]
00007FF91DFC65EE  41 0F 28 E6                 movaps  xmm4, xmm14
00007FF91DFC65F2  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC65F6  F3 0F 10 93 00 95 41 00     movss   xmm2, dword ptr [rbx+419500h]
00007FF91DFC65FE  F3 0F 11 8B 50 92 41 00     movss   dword ptr [rbx+419250h], xmm1
00007FF91DFC6606  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC660A  41 0F 28 CE                 movaps  xmm1, xmm14
00007FF91DFC660E  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC6612  F3 0F 5C D3                 subss   xmm2, xmm3
00007FF91DFC6616  F3 0F 11 93 60 92 41 00     movss   dword ptr [rbx+419260h], xmm2
00007FF91DFC661E  F3 0F 59 93 10 95 41 00     mulss   xmm2, dword ptr [rbx+419510h]
00007FF91DFC6626  F3 0F 58 D3                 addss   xmm2, xmm3
00007FF91DFC662A  F3 0F 11 93 70 92 41 00     movss   dword ptr [rbx+419270h], xmm2
00007FF91DFC6632  41 0F 28 D6                 movaps  xmm2, xmm14
00007FF91DFC6636  F3 44 0F 59 8B A4 95 61 00  mulss   xmm9, dword ptr [rbx+6195A4h]
00007FF91DFC663F  F3 0F 10 AB 90 94 41 00     movss   xmm5, dword ptr [rbx+419490h]
00007FF91DFC6647  F3 0F 10 83 80 94 41 00     movss   xmm0, dword ptr [rbx+419480h]
00007FF91DFC664F  F3 0F 5C E5                 subss   xmm4, xmm5
00007FF91DFC6653  F3 0F 10 B3 F0 91 41 00     movss   xmm6, dword ptr [rbx+4191F0h]
00007FF91DFC665B  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC665F  F3 44 0F 10 83 30 92 41 00  movss   xmm8, dword ptr [rbx+419230h]
00007FF91DFC6668  F3 45 0F 5C CA              subss   xmm9, xmm10
00007FF91DFC666D  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFC6670  F3 41 0F 59 C8              mulss   xmm1, xmm8
00007FF91DFC6675  F3 44 0F 58 CF              addss   xmm9, xmm7
00007FF91DFC667A  F3 0F 10 BB 00 92 41 00     movss   xmm7, dword ptr [rbx+419200h]
00007FF91DFC6682  F3 0F 59 DF                 mulss   xmm3, xmm7
00007FF91DFC6686  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFC668A  F3 44 0F 59 8B 40 93 41 00  mulss   xmm9, dword ptr [rbx+419340h]
00007FF91DFC6693  F3 0F 58 DE                 addss   xmm3, xmm6
00007FF91DFC6697  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFC669C  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFC669F  F3 0F 10 AB 60 94 41 00     movss   xmm5, dword ptr [rbx+419460h]
00007FF91DFC66A7  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC66AB  F3 0F 5C D5                 subss   xmm2, xmm5
00007FF91DFC66AF  F3 44 0F 5C C8              subss   xmm9, xmm0
00007FF91DFC66B4  F3 0F 10 83 20 94 41 00     movss   xmm0, dword ptr [rbx+419420h]
00007FF91DFC66BC  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFC66C1  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFC66C6  F3 0F 10 8B A0 94 41 00     movss   xmm1, dword ptr [rbx+4194A0h]
00007FF91DFC66CE  F3 44 0F 59 C1              mulss   xmm8, xmm1
00007FF91DFC66D3  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFC66D8  F3 0F 10 83 10 94 41 00     movss   xmm0, dword ptr [rbx+419410h]
00007FF91DFC66E0  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFC66E4  F3 44 0F 59 C9              mulss   xmm9, xmm1
00007FF91DFC66E9  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFC66EC  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFC66F0  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC66F3  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFC66F7  F3 0F 59 D7                 mulss   xmm2, xmm7
00007FF91DFC66FB  F3 0F 59 CB                 mulss   xmm1, xmm3
00007FF91DFC66FF  F3 0F 59 EC                 mulss   xmm5, xmm4
00007FF91DFC6703  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC6707  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFC670B  F3 41 0F 58 C8              addss   xmm1, xmm8
00007FF91DFC6710  F3 41 0F 58 E9              addss   xmm5, xmm9
00007FF91DFC6715  F3 0F 11 8B 50 93 41 00     movss   dword ptr [rbx+419350h], xmm1
00007FF91DFC671D  F3 0F 11 AB 60 93 41 00     movss   dword ptr [rbx+419360h], xmm5
00007FF91DFC6725  8B 8B 74 95 61 00           mov     ecx, [rbx+619574h]
00007FF91DFC672B  8B 83 70 95 61 00           mov     eax, [rbx+619570h]
00007FF91DFC6731  FF C9                       dec     ecx
00007FF91DFC6733  FF C8                       dec     eax
00007FF91DFC6735  23 C8                       and     ecx, eax
00007FF91DFC6737  89 8B 70 95 61 00           mov     [rbx+619570h], ecx
00007FF91DFC673D  8B 83 80 95 61 00           mov     eax, [rbx+619580h]
00007FF91DFC6743  48 63 C9                    movsxd  rcx, ecx
00007FF91DFC6746  89 84 8B 70 95 41 00        mov     [rbx+rcx*4+419570h], eax
00007FF91DFC674D  F3 0F 10 B3 70 8D 01 00     movss   xmm6, dword ptr [rbx+18D70h]
00007FF91DFC6755  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFC6758  F3 0F 59 B3 60 93 41 00     mulss   xmm6, dword ptr [rbx+419360h]
00007FF91DFC6760  F3 0F 59 BB 50 93 41 00     mulss   xmm7, dword ptr [rbx+419350h]
00007FF91DFC6768  F3 44 0F 10 0D 2F 45 62 00  movss   xmm9, cs:dword_7FF91E5EACA0
00007FF91DFC6771  F3 44 0F 10 15 6E EA 77 00  movss   xmm10, cs:flt_7FF91E7451E8
00007FF91DFC677A  8B 83 B0 2E A4 00           mov     eax, [rbx+0A42EB0h]
00007FF91DFC6780  FF C8                       dec     eax
00007FF91DFC6782  0F B7 C0                    movzx   eax, ax
00007FF91DFC6785  89 83 B0 2E A4 00           mov     [rbx+0A42EB0h], eax
00007FF91DFC678B  F3 0F 10 83 D0 2E A8 00     movss   xmm0, dword ptr [rbx+0A82ED0h]
00007FF91DFC6793  39 B3 C0 2E A4 00           cmp     [rbx+0A42EC0h], esi
00007FF91DFC6799  7E 2A                       jle     short loc_7FF91DFC67C5
00007FF91DFC679B  41 0F 2E C5                 ucomiss xmm0, xmm13
00007FF91DFC679F  74 1F                       jz      short loc_7FF91DFC67C0
00007FF91DFC67A1  F3 0F 5C 05 CB 44 62 00     subss   xmm0, cs:dword_7FF91E5EAC74
00007FF91DFC67A9  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFC67AD  F3 0F 11 83 D0 2E A8 00     movss   dword ptr [rbx+0A82ED0h], xmm0
00007FF91DFC67B5  73 09                       jnb     short loc_7FF91DFC67C0
00007FF91DFC67B7  89 B3 D0 2E A8 00           mov     [rbx+0A82ED0h], esi
00007FF91DFC67BD  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC67C0  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFC67C3  EB 37                       jmp     short loc_7FF91DFC67FC
00007FF91DFC67C5  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFC67C9  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFC67CC  73 2E                       jnb     short loc_7FF91DFC67FC
00007FF91DFC67CE  44 0F 2F AB D0 2C A4 00     comiss  xmm13, dword ptr [rbx+0A42CD0h]
00007FF91DFC67D6  73 24                       jnb     short loc_7FF91DFC67FC
00007FF91DFC67D8  F3 0F 58 0D 94 44 62 00     addss   xmm1, cs:dword_7FF91E5EAC74
00007FF91DFC67E0  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFC67E4  F3 0F 11 8B D0 2E A8 00     movss   dword ptr [rbx+0A82ED0h], xmm1
00007FF91DFC67EC  76 0E                       jbe     short loc_7FF91DFC67FC
00007FF91DFC67EE  C7 83 D0 2E A8 00 00 00 80 3F  mov     dword ptr [rbx+0A82ED0h], 3F800000h
00007FF91DFC67F8  41 0F 28 CE                 movaps  xmm1, xmm14
00007FF91DFC67FC  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFC6800  0F 86 FB 06 00 00           jbe     loc_7FF91DFC6F01
00007FF91DFC6806  F3 0F 10 83 D0 2C A4 00     movss   xmm0, dword ptr [rbx+0A42CD0h]
00007FF91DFC680E  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFC6812  0F 86 E9 06 00 00           jbe     loc_7FF91DFC6F01
00007FF91DFC6818  F3 0F 10 9B 70 2D A4 00     movss   xmm3, dword ptr [rbx+0A42D70h]
00007FF91DFC6820  0F 28 D6                    movaps  xmm2, xmm6
00007FF91DFC6823  F3 0F 59 9B D0 2B A4 00     mulss   xmm3, dword ptr [rbx+0A42BD0h]
00007FF91DFC682B  F3 0F 58 D7                 addss   xmm2, xmm7
00007FF91DFC682F  F3 0F 59 15 41 44 62 00     mulss   xmm2, cs:dword_7FF91E5EAC78
00007FF91DFC6837  F3 0F 59 93 F0 2C A4 00     mulss   xmm2, dword ptr [rbx+0A42CF0h]
00007FF91DFC683F  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFC6843  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC6847  F3 0F 10 8B 80 2D A4 00     movss   xmm1, dword ptr [rbx+0A42D80h]
00007FF91DFC684F  F3 0F 59 8B E0 2B A4 00     mulss   xmm1, dword ptr [rbx+0A42BE0h]
00007FF91DFC6857  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC685A  F3 0F 59 83 60 2D A4 00     mulss   xmm0, dword ptr [rbx+0A42D60h]
00007FF91DFC6862  F3 0F 11 93 D0 2B A4 00     movss   dword ptr [rbx+0A42BD0h], xmm2
00007FF91DFC686A  F3 0F 10 93 E0 2B A4 00     movss   xmm2, dword ptr [rbx+0A42BE0h]
00007FF91DFC6872  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFC6876  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFC6879  F3 0F 59 A3 A0 2D A4 00     mulss   xmm4, dword ptr [rbx+0A42DA0h]
00007FF91DFC6881  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFC6885  F3 0F 10 8B B0 2D A4 00     movss   xmm1, dword ptr [rbx+0A42DB0h]
00007FF91DFC688D  F3 0F 59 8B F0 2B A4 00     mulss   xmm1, dword ptr [rbx+0A42BF0h]
00007FF91DFC6895  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC6898  F3 0F 59 83 90 2D A4 00     mulss   xmm0, dword ptr [rbx+0A42D90h]
00007FF91DFC68A0  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC68A4  F3 0F 10 83 C0 2D A4 00     movss   xmm0, dword ptr [rbx+0A42DC0h]
00007FF91DFC68AC  F3 0F 59 83 00 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42C00h]
00007FF91DFC68B4  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC68B8  F3 0F 10 8B D0 2D A4 00     movss   xmm1, dword ptr [rbx+0A42DD0h]
00007FF91DFC68C0  F3 0F 59 8B 10 2C A4 00     mulss   xmm1, dword ptr [rbx+0A42C10h]
00007FF91DFC68C8  F3 0F 11 93 F0 2B A4 00     movss   dword ptr [rbx+0A42BF0h], xmm2
00007FF91DFC68D0  F3 0F 11 9B E0 2B A4 00     movss   dword ptr [rbx+0A42BE0h], xmm3
00007FF91DFC68D8  8B 83 00 2C A4 00           mov     eax, [rbx+0A42C00h]
00007FF91DFC68DE  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC68E2  89 83 10 2C A4 00           mov     [rbx+0A42C10h], eax
00007FF91DFC68E8  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC68EC  F3 0F 11 A3 00 2C A4 00     movss   dword ptr [rbx+0A42C00h], xmm4
00007FF91DFC68F4  F3 0F 10 83 50 2D A4 00     movss   xmm0, dword ptr [rbx+0A42D50h]
00007FF91DFC68FC  F3 0F 58 83 B0 2C A4 00     addss   xmm0, dword ptr [rbx+0A42CB0h]
00007FF91DFC6904  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFC6908  F3 0F 11 83 A0 2C A4 00     movss   dword ptr [rbx+0A42CA0h], xmm0
00007FF91DFC6910  76 0D                       jbe     short loc_7FF91DFC691F
00007FF91DFC6912  F3 41 0F 5C C2              subss   xmm0, xmm10
00007FF91DFC6917  F3 0F 11 83 A0 2C A4 00     movss   dword ptr [rbx+0A42CA0h], xmm0
00007FF91DFC691F  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFC6923  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFC6926  F3 0F 59 8B 40 2D A4 00     mulss   xmm1, dword ptr [rbx+0A42D40h]
00007FF91DFC692E  72 0A                       jb      short loc_7FF91DFC693A
00007FF91DFC6930  F3 0F 10 15 7C 43 62 00     movss   xmm2, cs:dword_7FF91E5EACB4
00007FF91DFC6938  EB 08                       jmp     short loc_7FF91DFC6942
00007FF91DFC693A  F3 0F 10 15 5A 43 62 00     movss   xmm2, cs:dword_7FF91E5EAC9C
00007FF91DFC6942  F3 0F 11 83 B0 2C A4 00     movss   dword ptr [rbx+0A42CB0h], xmm0
00007FF91DFC694A  8B 83 F0 2E A8 00           mov     eax, [rbx+0A82EF0h]
00007FF91DFC6950  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
00007FF91DFC6956  0F B7 C0                    movzx   eax, ax
00007FF91DFC6959  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFC695D  F3 0F 11 A4 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm4
00007FF91DFC6966  8B 93 B0 2E A4 00           mov     edx, [rbx+0A42EB0h]
00007FF91DFC696C  8B 83 FC 2E A8 00           mov     eax, [rbx+0A82EFCh]
00007FF91DFC6972  8B 8B F4 2E A8 00           mov     ecx, [rbx+0A82EF4h]
00007FF91DFC6978  03 C2                       add     eax, edx
00007FF91DFC697A  0F B7 C0                    movzx   eax, ax
00007FF91DFC697D  F3 0F 10 A4 83 D0 2E A4 00  movss   xmm4, dword ptr [rbx+rax*4+0A42ED0h]
00007FF91DFC6986  F3 0F 2C C1                 cvttss2si eax, xmm1
00007FF91DFC698A  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC698D  F3 0F 59 83 E0 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42CE0h]
00007FF91DFC6995  2B C8                       sub     ecx, eax
00007FF91DFC6997  03 CA                       add     ecx, edx
00007FF91DFC6999  0F B7 C1                    movzx   eax, cx
00007FF91DFC699C  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
00007FF91DFC69A5  8B 83 F8 2E A8 00           mov     eax, [rbx+0A82EF8h]
00007FF91DFC69AB  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC69AF  03 C2                       add     eax, edx
00007FF91DFC69B1  0F B7 C0                    movzx   eax, ax
00007FF91DFC69B4  F3 0F 11 8C 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm1
00007FF91DFC69BD  F3 0F 10 93 E0 2C A4 00     movss   xmm2, dword ptr [rbx+0A42CE0h]
00007FF91DFC69C5  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
00007FF91DFC69CB  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFC69CE  8B 83 04 2F A8 00           mov     eax, [rbx+0A82F04h]
00007FF91DFC69D4  03 C1                       add     eax, ecx
00007FF91DFC69D6  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFC69DA  0F B7 C0                    movzx   eax, ax
00007FF91DFC69DD  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFC69E1  F3 0F 10 84 83 D0 2E A4 00  movss   xmm0, dword ptr [rbx+rax*4+0A42ED0h]
00007FF91DFC69EA  8B 83 00 2F A8 00           mov     eax, [rbx+0A82F00h]
00007FF91DFC69F0  03 C1                       add     eax, ecx
00007FF91DFC69F2  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFC69F6  0F B7 C0                    movzx   eax, ax
00007FF91DFC69F9  F3 0F 5C DA                 subss   xmm3, xmm2
00007FF91DFC69FD  F3 0F 11 9C 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm3
00007FF91DFC6A06  F3 0F 10 8B E0 2C A4 00     movss   xmm1, dword ptr [rbx+0A42CE0h]
00007FF91DFC6A0E  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
00007FF91DFC6A14  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFC6A17  8B 83 0C 2F A8 00           mov     eax, [rbx+0A82F0Ch]
00007FF91DFC6A1D  03 C1                       add     eax, ecx
00007FF91DFC6A1F  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFC6A23  0F B7 C0                    movzx   eax, ax
00007FF91DFC6A26  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC6A2A  F3 0F 10 84 83 D0 2E A4 00  movss   xmm0, dword ptr [rbx+rax*4+0A42ED0h]
00007FF91DFC6A33  8B 83 08 2F A8 00           mov     eax, [rbx+0A82F08h]
00007FF91DFC6A39  03 C1                       add     eax, ecx
00007FF91DFC6A3B  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFC6A3F  0F B7 C0                    movzx   eax, ax
00007FF91DFC6A42  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFC6A46  F3 0F 11 94 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm2
00007FF91DFC6A4F  F3 0F 10 8B E0 2C A4 00     movss   xmm1, dword ptr [rbx+0A42CE0h]
00007FF91DFC6A57  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
00007FF91DFC6A5D  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFC6A60  8B 83 14 2F A8 00           mov     eax, [rbx+0A82F14h]
00007FF91DFC6A66  03 C1                       add     eax, ecx
00007FF91DFC6A68  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFC6A6C  0F B7 C0                    movzx   eax, ax
00007FF91DFC6A6F  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFC6A73  F3 0F 10 84 83 D0 2E A4 00  movss   xmm0, dword ptr [rbx+rax*4+0A42ED0h]
00007FF91DFC6A7C  8B 83 10 2F A8 00           mov     eax, [rbx+0A82F10h]
00007FF91DFC6A82  03 C1                       add     eax, ecx
00007FF91DFC6A84  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFC6A88  0F B7 C0                    movzx   eax, ax
00007FF91DFC6A8B  F3 0F 5C D9                 subss   xmm3, xmm1
00007FF91DFC6A8F  F3 0F 11 9C 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm3
00007FF91DFC6A98  F3 0F 10 93 E0 2C A4 00     movss   xmm2, dword ptr [rbx+0A42CE0h]
00007FF91DFC6AA0  8B 83 1C 2F A8 00           mov     eax, [rbx+0A82F1Ch]
00007FF91DFC6AA6  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFC6AA9  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
00007FF91DFC6AAF  03 C1                       add     eax, ecx
00007FF91DFC6AB1  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFC6AB5  0F B7 C0                    movzx   eax, ax
00007FF91DFC6AB8  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC6ABC  F3 0F 10 84 83 D0 2E A4 00  movss   xmm0, dword ptr [rbx+rax*4+0A42ED0h]
00007FF91DFC6AC5  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFC6AC9  F3 0F 59 25 3B E5 77 00     mulss   xmm4, cs:dword_7FF91E74500C
00007FF91DFC6AD1  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFC6AD4  8B 83 18 2F A8 00           mov     eax, [rbx+0A82F18h]
00007FF91DFC6ADA  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFC6ADE  03 C1                       add     eax, ecx
00007FF91DFC6AE0  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFC6AE3  0F B7 C0                    movzx   eax, ax
00007FF91DFC6AE6  F3 0F 58 8B 30 2C A4 00     addss   xmm1, dword ptr [rbx+0A42C30h]
00007FF91DFC6AEE  F3 0F 11 8C 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm1
00007FF91DFC6AF7  F3 0F 59 8B E0 2C A4 00     mulss   xmm1, dword ptr [rbx+0A42CE0h]
00007FF91DFC6AFF  8B 83 38 2F A8 00           mov     eax, [rbx+0A82F38h]
00007FF91DFC6B05  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
00007FF91DFC6B0B  0F B7 C0                    movzx   eax, ax
00007FF91DFC6B0E  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC6B12  F3 0F 11 8C 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm1
00007FF91DFC6B1B  8B 83 44 2F A8 00           mov     eax, [rbx+0A82F44h]
00007FF91DFC6B21  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
00007FF91DFC6B27  0F B7 C0                    movzx   eax, ax
00007FF91DFC6B2A  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
00007FF91DFC6B33  F3 0F 5C 8B 20 2C A4 00     subss   xmm1, dword ptr [rbx+0A42C20h]
00007FF91DFC6B3B  F3 0F 11 8B 30 2C A4 00     movss   dword ptr [rbx+0A42C30h], xmm1
00007FF91DFC6B43  F3 0F 59 8B E0 2D A4 00     mulss   xmm1, dword ptr [rbx+0A42DE0h]
00007FF91DFC6B4B  F3 0F 58 8B 20 2C A4 00     addss   xmm1, dword ptr [rbx+0A42C20h]
00007FF91DFC6B53  F3 0F 11 8B 20 2C A4 00     movss   dword ptr [rbx+0A42C20h], xmm1
00007FF91DFC6B5B  F3 0F 59 8B 00 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E00h]
00007FF91DFC6B63  F3 0F 10 83 F0 2D A4 00     movss   xmm0, dword ptr [rbx+0A42DF0h]
00007FF91DFC6B6B  F3 0F 59 83 30 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42C30h]
00007FF91DFC6B73  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC6B77  F3 0F 11 8B 30 2C A4 00     movss   dword ptr [rbx+0A42C30h], xmm1
00007FF91DFC6B7F  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
00007FF91DFC6B85  8B 83 24 2F A8 00           mov     eax, [rbx+0A82F24h]
00007FF91DFC6B8B  03 C1                       add     eax, ecx
00007FF91DFC6B8D  0F B7 C0                    movzx   eax, ax
00007FF91DFC6B90  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
00007FF91DFC6B99  8B 83 20 2F A8 00           mov     eax, [rbx+0A82F20h]
00007FF91DFC6B9F  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC6BA2  F3 0F 59 83 E0 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42CE0h]
00007FF91DFC6BAA  03 C1                       add     eax, ecx
00007FF91DFC6BAC  0F B7 C0                    movzx   eax, ax
00007FF91DFC6BAF  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC6BB3  F3 0F 58 93 50 2C A4 00     addss   xmm2, dword ptr [rbx+0A42C50h]
00007FF91DFC6BBB  F3 0F 11 94 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm2
00007FF91DFC6BC4  F3 0F 59 93 E0 2C A4 00     mulss   xmm2, dword ptr [rbx+0A42CE0h]
00007FF91DFC6BCC  8B 83 48 2F A8 00           mov     eax, [rbx+0A82F48h]
00007FF91DFC6BD2  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
00007FF91DFC6BD8  0F B7 C0                    movzx   eax, ax
00007FF91DFC6BDB  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC6BDF  F3 0F 11 94 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm2
00007FF91DFC6BE8  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFC6BEB  8B 83 54 2F A8 00           mov     eax, [rbx+0A82F54h]
00007FF91DFC6BF1  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
00007FF91DFC6BF7  0F B7 C0                    movzx   eax, ax
00007FF91DFC6BFA  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
00007FF91DFC6C03  F3 0F 5C 8B 40 2C A4 00     subss   xmm1, dword ptr [rbx+0A42C40h]
00007FF91DFC6C0B  F3 0F 11 8B 50 2C A4 00     movss   dword ptr [rbx+0A42C50h], xmm1
00007FF91DFC6C13  F3 0F 59 8B 10 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E10h]
00007FF91DFC6C1B  F3 0F 58 8B 40 2C A4 00     addss   xmm1, dword ptr [rbx+0A42C40h]
00007FF91DFC6C23  F3 0F 11 8B 40 2C A4 00     movss   dword ptr [rbx+0A42C40h], xmm1
00007FF91DFC6C2B  F3 0F 10 83 20 2E A4 00     movss   xmm0, dword ptr [rbx+0A42E20h]
00007FF91DFC6C33  F3 0F 59 83 50 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42C50h]
00007FF91DFC6C3B  F3 0F 59 8B 30 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E30h]
00007FF91DFC6C43  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFC6C47  F3 0F 11 83 50 2C A4 00     movss   dword ptr [rbx+0A42C50h], xmm0
00007FF91DFC6C4F  8B 83 2C 2F A8 00           mov     eax, [rbx+0A82F2Ch]
00007FF91DFC6C55  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
00007FF91DFC6C5B  03 C1                       add     eax, ecx
00007FF91DFC6C5D  0F B7 C0                    movzx   eax, ax
00007FF91DFC6C60  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
00007FF91DFC6C69  8B 83 28 2F A8 00           mov     eax, [rbx+0A82F28h]
00007FF91DFC6C6F  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC6C72  F3 0F 59 83 E0 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42CE0h]
00007FF91DFC6C7A  03 C1                       add     eax, ecx
00007FF91DFC6C7C  0F B7 C0                    movzx   eax, ax
00007FF91DFC6C7F  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC6C83  F3 0F 58 93 70 2C A4 00     addss   xmm2, dword ptr [rbx+0A42C70h]
00007FF91DFC6C8B  F3 0F 11 94 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm2
00007FF91DFC6C94  8B 83 58 2F A8 00           mov     eax, [rbx+0A82F58h]
00007FF91DFC6C9A  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
00007FF91DFC6CA0  F3 0F 59 93 E0 2C A4 00     mulss   xmm2, dword ptr [rbx+0A42CE0h]
00007FF91DFC6CA8  0F B7 C0                    movzx   eax, ax
00007FF91DFC6CAB  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC6CAF  F3 0F 11 94 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm2
00007FF91DFC6CB8  8B 83 64 2F A8 00           mov     eax, [rbx+0A82F64h]
00007FF91DFC6CBE  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
00007FF91DFC6CC4  0F B7 C0                    movzx   eax, ax
00007FF91DFC6CC7  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
00007FF91DFC6CD0  F3 0F 5C 8B 60 2C A4 00     subss   xmm1, dword ptr [rbx+0A42C60h]
00007FF91DFC6CD8  F3 0F 11 8B 70 2C A4 00     movss   dword ptr [rbx+0A42C70h], xmm1
00007FF91DFC6CE0  F3 0F 59 8B 40 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E40h]
00007FF91DFC6CE8  F3 0F 58 8B 60 2C A4 00     addss   xmm1, dword ptr [rbx+0A42C60h]
00007FF91DFC6CF0  F3 0F 11 8B 60 2C A4 00     movss   dword ptr [rbx+0A42C60h], xmm1
00007FF91DFC6CF8  F3 0F 59 8B 60 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E60h]
00007FF91DFC6D00  F3 0F 10 83 50 2E A4 00     movss   xmm0, dword ptr [rbx+0A42E50h]
00007FF91DFC6D08  F3 0F 59 83 70 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42C70h]
00007FF91DFC6D10  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFC6D14  F3 0F 11 83 70 2C A4 00     movss   dword ptr [rbx+0A42C70h], xmm0
00007FF91DFC6D1C  8B 8B B0 2E A4 00           mov     ecx, [rbx+0A42EB0h]
00007FF91DFC6D22  8B 83 34 2F A8 00           mov     eax, [rbx+0A82F34h]
00007FF91DFC6D28  03 C1                       add     eax, ecx
00007FF91DFC6D2A  0F B7 C0                    movzx   eax, ax
00007FF91DFC6D2D  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
00007FF91DFC6D36  8B 83 30 2F A8 00           mov     eax, [rbx+0A82F30h]
00007FF91DFC6D3C  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC6D3F  F3 0F 59 83 E0 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42CE0h]
00007FF91DFC6D47  03 C1                       add     eax, ecx
00007FF91DFC6D49  0F B7 C0                    movzx   eax, ax
00007FF91DFC6D4C  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFC6D50  F3 0F 58 A3 90 2C A4 00     addss   xmm4, dword ptr [rbx+0A42C90h]
00007FF91DFC6D58  F3 0F 11 A4 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm4
00007FF91DFC6D61  F3 0F 59 A3 E0 2C A4 00     mulss   xmm4, dword ptr [rbx+0A42CE0h]
00007FF91DFC6D69  8B 83 68 2F A8 00           mov     eax, [rbx+0A82F68h]
00007FF91DFC6D6F  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
00007FF91DFC6D75  0F B7 C0                    movzx   eax, ax
00007FF91DFC6D78  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC6D7C  F3 0F 11 A4 83 D0 2E A4 00  movss   dword ptr [rbx+rax*4+0A42ED0h], xmm4
00007FF91DFC6D85  8B 83 74 2F A8 00           mov     eax, [rbx+0A82F74h]
00007FF91DFC6D8B  03 83 B0 2E A4 00           add     eax, [rbx+0A42EB0h]
00007FF91DFC6D91  0F B7 C0                    movzx   eax, ax
00007FF91DFC6D94  F3 0F 10 8C 83 D0 2E A4 00  movss   xmm1, dword ptr [rbx+rax*4+0A42ED0h]
00007FF91DFC6D9D  F3 0F 5C 8B 80 2C A4 00     subss   xmm1, dword ptr [rbx+0A42C80h]
00007FF91DFC6DA5  F3 0F 11 8B 90 2C A4 00     movss   dword ptr [rbx+0A42C90h], xmm1
00007FF91DFC6DAD  F3 0F 59 8B 70 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E70h]
00007FF91DFC6DB5  F3 0F 58 8B 80 2C A4 00     addss   xmm1, dword ptr [rbx+0A42C80h]
00007FF91DFC6DBD  F3 0F 11 8B 80 2C A4 00     movss   dword ptr [rbx+0A42C80h], xmm1
00007FF91DFC6DC5  F3 0F 10 83 80 2E A4 00     movss   xmm0, dword ptr [rbx+0A42E80h]
00007FF91DFC6DCD  F3 0F 59 83 90 2C A4 00     mulss   xmm0, dword ptr [rbx+0A42C90h]
00007FF91DFC6DD5  F3 0F 59 8B 90 2E A4 00     mulss   xmm1, dword ptr [rbx+0A42E90h]
00007FF91DFC6DDD  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFC6DE1  F3 0F 11 83 90 2C A4 00     movss   dword ptr [rbx+0A42C90h], xmm0
00007FF91DFC6DE9  44 8B 83 B0 2E A4 00        mov     r8d, [rbx+0A42EB0h]
00007FF91DFC6DF0  8B 83 50 2F A8 00           mov     eax, [rbx+0A82F50h]
00007FF91DFC6DF6  F3 0F 10 93 10 2D A4 00     movss   xmm2, dword ptr [rbx+0A42D10h]
00007FF91DFC6DFE  41 03 C0                    add     eax, r8d
00007FF91DFC6E01  F3 0F 10 9B D0 2E A8 00     movss   xmm3, dword ptr [rbx+0A82ED0h]
00007FF91DFC6E09  F3 0F 10 AB 00 2D A4 00     movss   xmm5, dword ptr [rbx+0A42D00h]
00007FF91DFC6E11  F3 0F 10 A3 D0 2C A4 00     movss   xmm4, dword ptr [rbx+0A42CD0h]
00007FF91DFC6E19  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFC6E1C  0F B7 D0                    movzx   edx, ax
00007FF91DFC6E1F  8B 83 3C 2F A8 00           mov     eax, [rbx+0A82F3Ch]
00007FF91DFC6E25  41 03 C0                    add     eax, r8d
00007FF91DFC6E28  F3 0F 59 C7                 mulss   xmm0, xmm7
00007FF91DFC6E2C  0F B7 C8                    movzx   ecx, ax
00007FF91DFC6E2F  F3 44 0F 10 84 93 D0 2E A4 00  movss   xmm8, dword ptr [rbx+rdx*4+0A42ED0h]
00007FF91DFC6E39  8B 83 5C 2F A8 00           mov     eax, [rbx+0A82F5Ch]
00007FF91DFC6E3F  41 03 C0                    add     eax, r8d
00007FF91DFC6E42  F3 44 0F 58 84 8B D0 2E A4 00  addss   xmm8, dword ptr [rbx+rcx*4+0A42ED0h]
00007FF91DFC6E4C  0F B7 C8                    movzx   ecx, ax
00007FF91DFC6E4F  8B 83 70 2F A8 00           mov     eax, [rbx+0A82F70h]
00007FF91DFC6E55  41 03 C0                    add     eax, r8d
00007FF91DFC6E58  F3 44 0F 58 84 8B D0 2E A4 00  addss   xmm8, dword ptr [rbx+rcx*4+0A42ED0h]
00007FF91DFC6E62  0F B7 C8                    movzx   ecx, ax
00007FF91DFC6E65  8B 83 40 2F A8 00           mov     eax, [rbx+0A82F40h]
00007FF91DFC6E6B  41 03 C0                    add     eax, r8d
00007FF91DFC6E6E  0F B7 D0                    movzx   edx, ax
00007FF91DFC6E71  F3 44 0F 58 84 8B D0 2E A4 00  addss   xmm8, dword ptr [rbx+rcx*4+0A42ED0h]
00007FF91DFC6E7B  8B 83 4C 2F A8 00           mov     eax, [rbx+0A82F4Ch]
00007FF91DFC6E81  41 03 C0                    add     eax, r8d
00007FF91DFC6E84  F3 0F 10 BC 93 D0 2E A4 00  movss   xmm7, dword ptr [rbx+rdx*4+0A42ED0h]
00007FF91DFC6E8D  0F B7 C8                    movzx   ecx, ax
00007FF91DFC6E90  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFC6E95  F3 44 0F 59 05 FE E4 77 00  mulss   xmm8, cs:dword_7FF91E74539C
00007FF91DFC6E9E  F3 44 0F 59 C3              mulss   xmm8, xmm3
00007FF91DFC6EA3  F3 44 0F 59 C4              mulss   xmm8, xmm4
00007FF91DFC6EA8  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFC6EAD  F3 0F 58 BC 8B D0 2E A4 00  addss   xmm7, dword ptr [rbx+rcx*4+0A42ED0h]
00007FF91DFC6EB6  8B 83 60 2F A8 00           mov     eax, [rbx+0A82F60h]
00007FF91DFC6EBC  41 03 C0                    add     eax, r8d
00007FF91DFC6EBF  F3 0F 59 EE                 mulss   xmm5, xmm6
00007FF91DFC6EC3  0F B7 C8                    movzx   ecx, ax
00007FF91DFC6EC6  8B 83 6C 2F A8 00           mov     eax, [rbx+0A82F6Ch]
00007FF91DFC6ECC  41 03 C0                    add     eax, r8d
00007FF91DFC6ECF  F3 0F 58 BC 8B D0 2E A4 00  addss   xmm7, dword ptr [rbx+rcx*4+0A42ED0h]
00007FF91DFC6ED8  0F B7 C8                    movzx   ecx, ax
00007FF91DFC6EDB  F3 0F 58 BC 8B D0 2E A4 00  addss   xmm7, dword ptr [rbx+rcx*4+0A42ED0h]
00007FF91DFC6EE4  F3 0F 59 FA                 mulss   xmm7, xmm2
00007FF91DFC6EE8  F3 0F 59 3D AC E4 77 00     mulss   xmm7, cs:dword_7FF91E74539C
00007FF91DFC6EF0  F3 0F 59 FB                 mulss   xmm7, xmm3
00007FF91DFC6EF4  F3 0F 59 FC                 mulss   xmm7, xmm4
00007FF91DFC6EF8  F3 0F 58 FD                 addss   xmm7, xmm5
00007FF91DFC6EFC  E9 D6 02 00 00              jmp     loc_7FF91DFC71D7
00007FF91DFC6F01  44 0F 28 C7                 movaps  xmm8, xmm7
00007FF91DFC6F05  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFC6F08  39 B3 C0 2E A4 00           cmp     [rbx+0A42EC0h], esi
00007FF91DFC6F0E  0F 8E C3 02 00 00           jle     loc_7FF91DFC71D7
00007FF91DFC6F14  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFC6F18  0F 87 B9 02 00 00           ja      loc_7FF91DFC71D7
00007FF91DFC6F1E  8B CE                       mov     ecx, esi
00007FF91DFC6F20  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
00007FF91DFC6F26  C1 E0 08                    shl     eax, 8
00007FF91DFC6F29  03 C1                       add     eax, ecx
00007FF91DFC6F2B  48 98                       cdqe
00007FF91DFC6F2D  89 B4 83 D0 2A A4 00        mov     [rbx+rax*4+0A42AD0h], esi
00007FF91DFC6F34  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
00007FF91DFC6F3A  C1 E0 08                    shl     eax, 8
00007FF91DFC6F3D  03 C1                       add     eax, ecx
00007FF91DFC6F3F  48 98                       cdqe
00007FF91DFC6F41  89 B4 83 D4 2A A4 00        mov     [rbx+rax*4+0A42AD4h], esi
00007FF91DFC6F48  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
00007FF91DFC6F4E  C1 E0 08                    shl     eax, 8
00007FF91DFC6F51  03 C1                       add     eax, ecx
00007FF91DFC6F53  48 98                       cdqe
00007FF91DFC6F55  89 B4 83 D8 2A A4 00        mov     [rbx+rax*4+0A42AD8h], esi
00007FF91DFC6F5C  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
00007FF91DFC6F62  C1 E0 08                    shl     eax, 8
00007FF91DFC6F65  03 C1                       add     eax, ecx
00007FF91DFC6F67  48 98                       cdqe
00007FF91DFC6F69  89 B4 83 DC 2A A4 00        mov     [rbx+rax*4+0A42ADCh], esi
00007FF91DFC6F70  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
00007FF91DFC6F76  C1 E0 08                    shl     eax, 8
00007FF91DFC6F79  03 C1                       add     eax, ecx
00007FF91DFC6F7B  48 98                       cdqe
00007FF91DFC6F7D  89 B4 83 E0 2A A4 00        mov     [rbx+rax*4+0A42AE0h], esi
00007FF91DFC6F84  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
00007FF91DFC6F8A  C1 E0 08                    shl     eax, 8
00007FF91DFC6F8D  03 C1                       add     eax, ecx
00007FF91DFC6F8F  48 98                       cdqe
00007FF91DFC6F91  89 B4 83 E4 2A A4 00        mov     [rbx+rax*4+0A42AE4h], esi
00007FF91DFC6F98  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
00007FF91DFC6F9E  C1 E0 08                    shl     eax, 8
00007FF91DFC6FA1  03 C1                       add     eax, ecx
00007FF91DFC6FA3  48 98                       cdqe
00007FF91DFC6FA5  89 B4 83 E8 2A A4 00        mov     [rbx+rax*4+0A42AE8h], esi
00007FF91DFC6FAC  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
00007FF91DFC6FB2  C1 E0 08                    shl     eax, 8
00007FF91DFC6FB5  03 C1                       add     eax, ecx
00007FF91DFC6FB7  83 C1 08                    add     ecx, 8
00007FF91DFC6FBA  48 98                       cdqe
00007FF91DFC6FBC  89 B4 83 EC 2A A4 00        mov     [rbx+rax*4+0A42AECh], esi
00007FF91DFC6FC3  81 F9 00 01 00 00           cmp     ecx, 100h
00007FF91DFC6FC9  0F 8C 51 FF FF FF           jl      loc_7FF91DFC6F20
00007FF91DFC6FCF  8B 83 C0 2E A4 00           mov     eax, [rbx+0A42EC0h]
00007FF91DFC6FD5  FF C8                       dec     eax
00007FF91DFC6FD7  89 83 C0 2E A4 00           mov     [rbx+0A42EC0h], eax
00007FF91DFC6FDD  85 C0                       test    eax, eax
00007FF91DFC6FDF  0F 8F F2 01 00 00           jg      loc_7FF91DFC71D7
00007FF91DFC6FE5  8B 83 80 2F A8 00           mov     eax, [rbx+0A82F80h]
00007FF91DFC6FEB  89 83 F0 2E A8 00           mov     [rbx+0A82EF0h], eax
00007FF91DFC6FF1  8B 83 84 2F A8 00           mov     eax, [rbx+0A82F84h]
00007FF91DFC6FF7  89 83 F4 2E A8 00           mov     [rbx+0A82EF4h], eax
00007FF91DFC6FFD  8B 83 88 2F A8 00           mov     eax, [rbx+0A82F88h]
00007FF91DFC7003  89 83 F8 2E A8 00           mov     [rbx+0A82EF8h], eax
00007FF91DFC7009  8B 83 8C 2F A8 00           mov     eax, [rbx+0A82F8Ch]
00007FF91DFC700F  89 83 FC 2E A8 00           mov     [rbx+0A82EFCh], eax
00007FF91DFC7015  8B 83 90 2F A8 00           mov     eax, [rbx+0A82F90h]
00007FF91DFC701B  89 83 00 2F A8 00           mov     [rbx+0A82F00h], eax
00007FF91DFC7021  8B 83 94 2F A8 00           mov     eax, [rbx+0A82F94h]
00007FF91DFC7027  89 83 04 2F A8 00           mov     [rbx+0A82F04h], eax
00007FF91DFC702D  8B 83 98 2F A8 00           mov     eax, [rbx+0A82F98h]
00007FF91DFC7033  89 83 08 2F A8 00           mov     [rbx+0A82F08h], eax
00007FF91DFC7039  8B 83 9C 2F A8 00           mov     eax, [rbx+0A82F9Ch]
00007FF91DFC703F  89 83 0C 2F A8 00           mov     [rbx+0A82F0Ch], eax
00007FF91DFC7045  8B 83 A0 2F A8 00           mov     eax, [rbx+0A82FA0h]
00007FF91DFC704B  89 83 10 2F A8 00           mov     [rbx+0A82F10h], eax
00007FF91DFC7051  8B 83 A4 2F A8 00           mov     eax, [rbx+0A82FA4h]
00007FF91DFC7057  89 83 14 2F A8 00           mov     [rbx+0A82F14h], eax
00007FF91DFC705D  8B 83 A8 2F A8 00           mov     eax, [rbx+0A82FA8h]
00007FF91DFC7063  89 83 18 2F A8 00           mov     [rbx+0A82F18h], eax
00007FF91DFC7069  8B 83 AC 2F A8 00           mov     eax, [rbx+0A82FACh]
00007FF91DFC706F  89 83 1C 2F A8 00           mov     [rbx+0A82F1Ch], eax
00007FF91DFC7075  8B 83 B0 2F A8 00           mov     eax, [rbx+0A82FB0h]
00007FF91DFC707B  89 83 20 2F A8 00           mov     [rbx+0A82F20h], eax
00007FF91DFC7081  8B 83 B4 2F A8 00           mov     eax, [rbx+0A82FB4h]
00007FF91DFC7087  89 83 24 2F A8 00           mov     [rbx+0A82F24h], eax
00007FF91DFC708D  8B 83 B8 2F A8 00           mov     eax, [rbx+0A82FB8h]
00007FF91DFC7093  89 83 28 2F A8 00           mov     [rbx+0A82F28h], eax
00007FF91DFC7099  8B 83 BC 2F A8 00           mov     eax, [rbx+0A82FBCh]
00007FF91DFC709F  89 83 2C 2F A8 00           mov     [rbx+0A82F2Ch], eax
00007FF91DFC70A5  8B 83 C0 2F A8 00           mov     eax, [rbx+0A82FC0h]
00007FF91DFC70AB  89 83 30 2F A8 00           mov     [rbx+0A82F30h], eax
00007FF91DFC70B1  8B 83 C4 2F A8 00           mov     eax, [rbx+0A82FC4h]
00007FF91DFC70B7  89 83 34 2F A8 00           mov     [rbx+0A82F34h], eax
00007FF91DFC70BD  8B 83 C8 2F A8 00           mov     eax, [rbx+0A82FC8h]
00007FF91DFC70C3  89 83 38 2F A8 00           mov     [rbx+0A82F38h], eax
00007FF91DFC70C9  8B 83 CC 2F A8 00           mov     eax, [rbx+0A82FCCh]
00007FF91DFC70CF  89 83 3C 2F A8 00           mov     [rbx+0A82F3Ch], eax
00007FF91DFC70D5  8B 83 D0 2F A8 00           mov     eax, [rbx+0A82FD0h]
00007FF91DFC70DB  89 83 40 2F A8 00           mov     [rbx+0A82F40h], eax
00007FF91DFC70E1  8B 83 D4 2F A8 00           mov     eax, [rbx+0A82FD4h]
00007FF91DFC70E7  89 83 44 2F A8 00           mov     [rbx+0A82F44h], eax
00007FF91DFC70ED  8B 83 D8 2F A8 00           mov     eax, [rbx+0A82FD8h]
00007FF91DFC70F3  89 83 48 2F A8 00           mov     [rbx+0A82F48h], eax
00007FF91DFC70F9  8B 83 DC 2F A8 00           mov     eax, [rbx+0A82FDCh]
00007FF91DFC70FF  89 83 4C 2F A8 00           mov     [rbx+0A82F4Ch], eax
00007FF91DFC7105  8B 83 E0 2F A8 00           mov     eax, [rbx+0A82FE0h]
00007FF91DFC710B  89 83 50 2F A8 00           mov     [rbx+0A82F50h], eax
00007FF91DFC7111  8B 83 E4 2F A8 00           mov     eax, [rbx+0A82FE4h]
00007FF91DFC7117  89 83 54 2F A8 00           mov     [rbx+0A82F54h], eax
00007FF91DFC711D  8B 83 E8 2F A8 00           mov     eax, [rbx+0A82FE8h]
00007FF91DFC7123  89 83 58 2F A8 00           mov     [rbx+0A82F58h], eax
00007FF91DFC7129  8B 83 EC 2F A8 00           mov     eax, [rbx+0A82FECh]
00007FF91DFC712F  89 83 5C 2F A8 00           mov     [rbx+0A82F5Ch], eax
00007FF91DFC7135  8B 83 F0 2F A8 00           mov     eax, [rbx+0A82FF0h]
00007FF91DFC713B  89 83 60 2F A8 00           mov     [rbx+0A82F60h], eax
00007FF91DFC7141  8B 83 F4 2F A8 00           mov     eax, [rbx+0A82FF4h]
00007FF91DFC7147  89 83 64 2F A8 00           mov     [rbx+0A82F64h], eax
00007FF91DFC714D  8B 83 F8 2F A8 00           mov     eax, [rbx+0A82FF8h]
00007FF91DFC7153  89 83 68 2F A8 00           mov     [rbx+0A82F68h], eax
00007FF91DFC7159  8B 83 FC 2F A8 00           mov     eax, [rbx+0A82FFCh]
00007FF91DFC715F  89 83 6C 2F A8 00           mov     [rbx+0A82F6Ch], eax
00007FF91DFC7165  8B 83 00 30 A8 00           mov     eax, [rbx+0A83000h]
00007FF91DFC716B  89 83 70 2F A8 00           mov     [rbx+0A82F70h], eax
00007FF91DFC7171  8B 83 04 30 A8 00           mov     eax, [rbx+0A83004h]
00007FF91DFC7177  89 83 74 2F A8 00           mov     [rbx+0A82F74h], eax
00007FF91DFC717D  89 B3 10 2C A4 00           mov     [rbx+0A42C10h], esi
00007FF91DFC7183  89 B3 00 2C A4 00           mov     [rbx+0A42C00h], esi
00007FF91DFC7189  89 B3 F0 2B A4 00           mov     [rbx+0A42BF0h], esi
00007FF91DFC718F  89 B3 E0 2B A4 00           mov     [rbx+0A42BE0h], esi
00007FF91DFC7195  89 B3 D0 2B A4 00           mov     [rbx+0A42BD0h], esi
00007FF91DFC719B  89 B3 90 2C A4 00           mov     [rbx+0A42C90h], esi
00007FF91DFC71A1  89 B3 80 2C A4 00           mov     [rbx+0A42C80h], esi
00007FF91DFC71A7  89 B3 70 2C A4 00           mov     [rbx+0A42C70h], esi
00007FF91DFC71AD  89 B3 60 2C A4 00           mov     [rbx+0A42C60h], esi
00007FF91DFC71B3  89 B3 50 2C A4 00           mov     [rbx+0A42C50h], esi
00007FF91DFC71B9  89 B3 40 2C A4 00           mov     [rbx+0A42C40h], esi
00007FF91DFC71BF  89 B3 30 2C A4 00           mov     [rbx+0A42C30h], esi
00007FF91DFC71C5  89 B3 20 2C A4 00           mov     [rbx+0A42C20h], esi
00007FF91DFC71CB  89 B3 B0 2C A4 00           mov     [rbx+0A42CB0h], esi
00007FF91DFC71D1  89 B3 A0 2C A4 00           mov     [rbx+0A42CA0h], esi
00007FF91DFC71D7  F3 0F 10 83 20 8B 01 00     movss   xmm0, dword ptr [rbx+18B20h]
00007FF91DFC71DF  8B 83 10 8B 01 00           mov     eax, [rbx+18B10h]
00007FF91DFC71E5  48 8B B4 24 D0 00 00 00     mov     rsi, [rsp+0C8h+arg_0]
00007FF91DFC71ED  89 83 30 8B 01 00           mov     [rbx+18B30h], eax
00007FF91DFC71F3  F3 0F 11 83 40 8B 01 00     movss   dword ptr [rbx+18B40h], xmm0
00007FF91DFC71FB  F3 0F 10 A3 30 8B 01 00     movss   xmm4, dword ptr [rbx+18B30h]
00007FF91DFC7203  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC7206  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFC720A  F3 41 0F 59 C0              mulss   xmm0, xmm8
00007FF91DFC720F  F3 0F 11 83 50 8B 01 00     movss   dword ptr [rbx+18B50h], xmm0
00007FF91DFC7217  F3 0F 11 A3 60 8B 01 00     movss   dword ptr [rbx+18B60h], xmm4
00007FF91DFC721F  F3 0F 10 83 40 8B 01 00     movss   xmm0, dword ptr [rbx+18B40h]
00007FF91DFC7227  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFC722B  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFC722E  F3 0F 59 AB 50 8B 01 00     mulss   xmm5, dword ptr [rbx+18B50h]
00007FF91DFC7236  F3 0F 11 AB 70 8B 01 00     movss   dword ptr [rbx+18B70h], xmm5
00007FF91DFC723E  F3 0F 11 A3 80 8B 01 00     movss   dword ptr [rbx+18B80h], xmm4
00007FF91DFC7246  F3 0F 10 83 B0 8B 01 00     movss   xmm0, dword ptr [rbx+18BB0h]
00007FF91DFC724E  F3 0F 10 BB E0 8B 01 00     movss   xmm7, dword ptr [rbx+18BE0h]
00007FF91DFC7256  F3 0F 10 9B D0 8B 01 00     movss   xmm3, dword ptr [rbx+18BD0h]
00007FF91DFC725E  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFC7261  F3 44 0F 10 83 F0 8B 01 00  movss   xmm8, dword ptr [rbx+18BF0h]
00007FF91DFC726A  F3 44 0F 10 93 00 8C 01 00  movss   xmm10, dword ptr [rbx+18C00h]
00007FF91DFC7273  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFC7277  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFC727B  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFC727F  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFC7283  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFC7286  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFC728A  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFC728E  F3 0F 59 FC                 mulss   xmm7, xmm4
00007FF91DFC7292  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC7296  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFC729A  F3 0F 58 FB                 addss   xmm7, xmm3
00007FF91DFC729E  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC72A2  41 0F 28 C2                 movaps  xmm0, xmm10
00007FF91DFC72A6  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC72AA  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFC72AE  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC72B2  F3 0F 10 83 50 8C 01 00     movss   xmm0, dword ptr [rbx+18C50h]
00007FF91DFC72BA  F3 0F 5C C5                 subss   xmm0, xmm5
00007FF91DFC72BE  0F 28 F2                    movaps  xmm6, xmm2
00007FF91DFC72C1  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFC72C5  F3 0F 59 B3 10 8C 01 00     mulss   xmm6, dword ptr [rbx+18C10h]
00007FF91DFC72CD  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFC72D1  F3 0F 59 93 20 8C 01 00     mulss   xmm2, dword ptr [rbx+18C20h]
00007FF91DFC72D9  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFC72DD  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFC72E0  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC72E4  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFC72E8  77 08                       ja      short loc_7FF91DFC72F2
00007FF91DFC72EA  F3 0F 10 B3 60 8C 01 00     movss   xmm6, dword ptr [rbx+18C60h]
00007FF91DFC72F2  F3 0F 10 83 30 8C 01 00     movss   xmm0, dword ptr [rbx+18C30h]
00007FF91DFC72FA  F3 44 0F 59 C1              mulss   xmm8, xmm1
00007FF91DFC72FF  F3 0F 5C C5                 subss   xmm0, xmm5
00007FF91DFC7303  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC7307  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFC730C  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFC7310  72 08                       jb      short loc_7FF91DFC731A
00007FF91DFC7312  F3 0F 10 B3 40 8C 01 00     movss   xmm6, dword ptr [rbx+18C40h]
00007FF91DFC731A  F3 0F 59 B3 C0 8B 01 00     mulss   xmm6, dword ptr [rbx+18BC0h]
00007FF91DFC7322  F3 44 0F 59 D1              mulss   xmm10, xmm1
00007FF91DFC7327  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC732B  F3 0F 11 B3 90 8B 01 00     movss   dword ptr [rbx+18B90h], xmm6
00007FF91DFC7333  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFC7338  F3 0F 10 83 50 8C 01 00     movss   xmm0, dword ptr [rbx+18C50h]
00007FF91DFC7340  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFC7343  F3 0F 5C C4                 subss   xmm0, xmm4
00007FF91DFC7347  F3 0F 59 93 10 8C 01 00     mulss   xmm2, dword ptr [rbx+18C10h]
00007FF91DFC734F  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC7353  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFC7357  F3 0F 59 8B 20 8C 01 00     mulss   xmm1, dword ptr [rbx+18C20h]
00007FF91DFC735F  F3 0F 58 D7                 addss   xmm2, xmm7
00007FF91DFC7363  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC7367  77 08                       ja      short loc_7FF91DFC7371
00007FF91DFC7369  F3 0F 10 93 60 8C 01 00     movss   xmm2, dword ptr [rbx+18C60h]
00007FF91DFC7371  F3 0F 10 83 30 8C 01 00     movss   xmm0, dword ptr [rbx+18C30h]
00007FF91DFC7379  F3 0F 5C C4                 subss   xmm0, xmm4
00007FF91DFC737D  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFC7381  72 08                       jb      short loc_7FF91DFC738B
00007FF91DFC7383  F3 0F 10 93 40 8C 01 00     movss   xmm2, dword ptr [rbx+18C40h]
00007FF91DFC738B  F3 0F 59 93 C0 8B 01 00     mulss   xmm2, dword ptr [rbx+18BC0h]
00007FF91DFC7393  F3 0F 11 93 A0 8B 01 00     movss   dword ptr [rbx+18BA0h], xmm2
00007FF91DFC739B  F3 0F 11 73 20              movss   dword ptr [rbx+20h], xmm6
00007FF91DFC73A0  F3 0F 11 53 24              movss   dword ptr [rbx+24h], xmm2
00007FF91DFC73A5  48 8B 83 88 00 00 00        mov     rax, [rbx+88h]
00007FF91DFC73AC  48 8B 48 70                 mov     rcx, [rax+70h]
00007FF91DFC73B0  8B 01                       mov     eax, [rcx]
00007FF91DFC73B2  83 F8 01                    cmp     eax, 1
00007FF91DFC73B5  0F 84 E0 13 00 00           jz      loc_7FF91DFC879B
00007FF91DFC73BB  0F 8E 18 0E 00 00           jle     loc_7FF91DFC81D9
00007FF91DFC73C1  83 F8 04                    cmp     eax, 4
00007FF91DFC73C4  0F 8E 5E 05 00 00           jle     loc_7FF91DFC7928
00007FF91DFC73CA  83 F8 05                    cmp     eax, 5
00007FF91DFC73CD  0F 85 06 0E 00 00           jnz     loc_7FF91DFC81D9
00007FF91DFC73D3  8B 83 C0 76 01 00           mov     eax, [rbx+176C0h]
00007FF91DFC73D9  F3 0F 10 83 90 4A 01 00     movss   xmm0, dword ptr [rbx+14A90h]
00007FF91DFC73E1  89 83 D0 76 01 00           mov     [rbx+176D0h], eax
00007FF91DFC73E7  8B 83 B0 76 01 00           mov     eax, [rbx+176B0h]
00007FF91DFC73ED  89 83 C0 76 01 00           mov     [rbx+176C0h], eax
00007FF91DFC73F3  8B 83 60 77 01 00           mov     eax, [rbx+17760h]
00007FF91DFC73F9  89 83 70 77 01 00           mov     [rbx+17770h], eax
00007FF91DFC73FF  8B 83 50 77 01 00           mov     eax, [rbx+17750h]
00007FF91DFC7405  89 83 60 77 01 00           mov     [rbx+17760h], eax
00007FF91DFC740B  8B 83 40 77 01 00           mov     eax, [rbx+17740h]
00007FF91DFC7411  89 83 50 77 01 00           mov     [rbx+17750h], eax
00007FF91DFC7417  8B 83 30 77 01 00           mov     eax, [rbx+17730h]
00007FF91DFC741D  89 83 40 77 01 00           mov     [rbx+17740h], eax
00007FF91DFC7423  8B 83 20 77 01 00           mov     eax, [rbx+17720h]
00007FF91DFC7429  89 83 30 77 01 00           mov     [rbx+17730h], eax
00007FF91DFC742F  8B 83 10 77 01 00           mov     eax, [rbx+17710h]
00007FF91DFC7435  89 83 20 77 01 00           mov     [rbx+17720h], eax
00007FF91DFC743B  8B 83 00 77 01 00           mov     eax, [rbx+17700h]
00007FF91DFC7441  89 83 10 77 01 00           mov     [rbx+17710h], eax
00007FF91DFC7447  8B 83 F0 76 01 00           mov     eax, [rbx+176F0h]
00007FF91DFC744D  89 83 00 77 01 00           mov     [rbx+17700h], eax
00007FF91DFC7453  8B 83 E0 76 01 00           mov     eax, [rbx+176E0h]
00007FF91DFC7459  89 83 F0 76 01 00           mov     [rbx+176F0h], eax
00007FF91DFC745F  8B 83 80 77 01 00           mov     eax, [rbx+17780h]
00007FF91DFC7465  89 83 90 77 01 00           mov     [rbx+17790h], eax
00007FF91DFC746B  8B 83 A0 77 01 00           mov     eax, [rbx+177A0h]
00007FF91DFC7471  89 83 B0 77 01 00           mov     [rbx+177B0h], eax
00007FF91DFC7477  8B 83 C0 77 01 00           mov     eax, [rbx+177C0h]
00007FF91DFC747D  89 83 D0 77 01 00           mov     [rbx+177D0h], eax
00007FF91DFC7483  8B 83 F0 77 01 00           mov     eax, [rbx+177F0h]
00007FF91DFC7489  89 83 00 78 01 00           mov     [rbx+17800h], eax
00007FF91DFC748F  8B 83 E0 77 01 00           mov     eax, [rbx+177E0h]
00007FF91DFC7495  89 83 F0 77 01 00           mov     [rbx+177F0h], eax
00007FF91DFC749B  F3 0F 11 83 90 76 01 00     movss   dword ptr [rbx+17690h], xmm0
00007FF91DFC74A3  F3 0F 11 83 A0 76 01 00     movss   dword ptr [rbx+176A0h], xmm0
00007FF91DFC74AB  F3 0F 10 83 B0 77 01 00     movss   xmm0, dword ptr [rbx+177B0h]
00007FF91DFC74B3  F3 0F 58 83 90 77 01 00     addss   xmm0, dword ptr [rbx+17790h]
00007FF91DFC74BB  F3 0F 58 83 60 78 01 00     addss   xmm0, dword ptr [rbx+17860h]
00007FF91DFC74C3  E8 68 1A 00 00              call    sub_7FF91DFC8F30
00007FF91DFC74C8  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFC74CB  41 0F 2F D5                 comiss  xmm2, xmm13
00007FF91DFC74CF  F3 0F 11 93 A0 77 01 00     movss   dword ptr [rbx+177A0h], xmm2
00007FF91DFC74D7  F3 0F 10 83 10 7A 01 00     movss   xmm0, dword ptr [rbx+17A10h]
00007FF91DFC74DF  73 07                       jnb     short loc_7FF91DFC74E8
00007FF91DFC74E1  0F 57 05 D8 E2 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFC74E8  0F 54 15 A1 E2 77 00        andps   xmm2, cs:xmmword_7FF91E745790
00007FF91DFC74EF  F3 0F 11 83 80 77 01 00     movss   dword ptr [rbx+17780h], xmm0
00007FF91DFC74F7  F3 0F 11 93 10 78 01 00     movss   dword ptr [rbx+17810h], xmm2
00007FF91DFC74FF  F3 0F 59 93 70 78 01 00     mulss   xmm2, dword ptr [rbx+17870h]
00007FF91DFC7507  F3 0F 10 A3 A0 76 01 00     movss   xmm4, dword ptr [rbx+176A0h]
00007FF91DFC750F  F3 0F 59 93 20 7A 01 00     mulss   xmm2, dword ptr [rbx+17A20h]
00007FF91DFC7517  F3 0F 58 93 30 7A 01 00     addss   xmm2, dword ptr [rbx+17A30h]
00007FF91DFC751F  F3 0F 11 93 20 78 01 00     movss   dword ptr [rbx+17820h], xmm2
00007FF91DFC7527  F3 0F 58 A3 90 76 01 00     addss   xmm4, dword ptr [rbx+17690h]
00007FF91DFC752F  F3 0F 10 9B A0 78 01 00     movss   xmm3, dword ptr [rbx+178A0h]
00007FF91DFC7537  F3 0F 10 93 90 78 01 00     movss   xmm2, dword ptr [rbx+17890h]
00007FF91DFC753F  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFC7543  F3 0F 59 25 C1 DA 77 00     mulss   xmm4, cs:dword_7FF91E74500C
00007FF91DFC754B  F3 0F 11 A3 B0 76 01 00     movss   dword ptr [rbx+176B0h], xmm4
00007FF91DFC7553  F3 0F 10 8B C0 78 01 00     movss   xmm1, dword ptr [rbx+178C0h]
00007FF91DFC755B  F3 0F 59 8B C0 76 01 00     mulss   xmm1, dword ptr [rbx+176C0h]
00007FF91DFC7563  F3 0F 10 83 D0 78 01 00     movss   xmm0, dword ptr [rbx+178D0h]
00007FF91DFC756B  F3 0F 59 83 D0 76 01 00     mulss   xmm0, dword ptr [rbx+176D0h]
00007FF91DFC7573  F3 0F 59 A3 B0 78 01 00     mulss   xmm4, dword ptr [rbx+178B0h]
00007FF91DFC757B  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC757F  F3 0F 10 83 F0 77 01 00     movss   xmm0, dword ptr [rbx+177F0h]
00007FF91DFC7587  F3 0F 58 CC                 addss   xmm1, xmm4
00007FF91DFC758B  F3 0F 11 8B C0 76 01 00     movss   dword ptr [rbx+176C0h], xmm1
00007FF91DFC7593  F3 0F 58 83 40 7A 01 00     addss   xmm0, dword ptr [rbx+17A40h]
00007FF91DFC759B  F3 0F 59 D1                 mulss   xmm2, xmm1
00007FF91DFC759F  F3 0F 11 93 B0 8A 01 00     movss   dword ptr [rbx+18AB0h], xmm2
00007FF91DFC75A7  F3 0F 10 8B 50 7A 01 00     movss   xmm1, dword ptr [rbx+17A50h]
00007FF91DFC75AF  F3 0F 5D C8                 minss   xmm1, xmm0
00007FF91DFC75B3  F3 0F 59 CB                 mulss   xmm1, xmm3
00007FF91DFC75B7  F3 0F 11 8B E0 77 01 00     movss   dword ptr [rbx+177E0h], xmm1
00007FF91DFC75BF  F3 0F 5C 8B D0 77 01 00     subss   xmm1, dword ptr [rbx+177D0h]
00007FF91DFC75C7  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFC75CB  73 0A                       jnb     short loc_7FF91DFC75D7
00007FF91DFC75CD  F3 0F 10 83 70 7A 01 00     movss   xmm0, dword ptr [rbx+17A70h]
00007FF91DFC75D5  EB 08                       jmp     short loc_7FF91DFC75DF
00007FF91DFC75D7  F3 0F 10 83 60 7A 01 00     movss   xmm0, dword ptr [rbx+17A60h]
00007FF91DFC75DF  F3 0F 58 83 00 78 01 00     addss   xmm0, dword ptr [rbx+17800h]
00007FF91DFC75E7  F3 0F 10 93 50 78 01 00     movss   xmm2, dword ptr [rbx+17850h]
00007FF91DFC75EF  F3 0F 10 9B D0 77 01 00     movss   xmm3, dword ptr [rbx+177D0h]
00007FF91DFC75F7  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFC75FA  F3 0F 5C CB                 subss   xmm1, xmm3
00007FF91DFC75FE  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFC7602  76 04                       jbe     short loc_7FF91DFC7608
00007FF91DFC7604  44 0F 5A F8                 cvtps2pd xmm15, xmm0
00007FF91DFC7608  F3 0F 59 8B 80 78 01 00     mulss   xmm1, dword ptr [rbx+17880h]
00007FF91DFC7610  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC7613  F2 41 0F 5A C7              cvtsd2ss xmm0, xmm15
00007FF91DFC7618  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFC761C  41 0F 2F C4                 comiss  xmm0, xmm12
00007FF91DFC7620  72 09                       jb      short loc_7FF91DFC762B
00007FF91DFC7622  44 0F 28 E0                 movaps  xmm12, xmm0
00007FF91DFC7626  F3 45 0F 5D E6              minss   xmm12, xmm14
00007FF91DFC762B  F3 44 0F 59 A3 A0 78 01 00  mulss   xmm12, dword ptr [rbx+178A0h]
00007FF91DFC7634  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC7637  F3 0F 5C C3                 subss   xmm0, xmm3
00007FF91DFC763B  F3 44 0F 11 A3 F0 77 01 00  movss   dword ptr [rbx+177F0h], xmm12
00007FF91DFC7644  41 0F 2E C5                 ucomiss xmm0, xmm13
00007FF91DFC7648  74 03                       jz      short loc_7FF91DFC764D
00007FF91DFC764A  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFC764D  F3 0F 11 93 C0 77 01 00     movss   dword ptr [rbx+177C0h], xmm2
00007FF91DFC7655  F3 0F 58 93 20 78 01 00     addss   xmm2, dword ptr [rbx+17820h]
00007FF91DFC765D  8B 83 A0 8A 01 00           mov     eax, [rbx+18AA0h]
00007FF91DFC7663  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC7666  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFC766B  F3 41 0F 59 C3              mulss   xmm0, xmm11
00007FF91DFC7670  0F 5A CA                    cvtps2pd xmm1, xmm2
00007FF91DFC7673  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC7677  2B C2                       sub     eax, edx
00007FF91DFC7679  48 63 C8                    movsxd  rcx, eax
00007FF91DFC767C  48 63 83 A4 8A 01 00        movsxd  rax, dword ptr [rbx+18AA4h]
00007FF91DFC7683  48 FF C1                    inc     rcx
00007FF91DFC7686  48 FF C8                    dec     rax
00007FF91DFC7689  48 23 C8                    and     rcx, rax
00007FF91DFC768C  8B 84 8B A0 7A 01 00        mov     eax, [rbx+rcx*4+17AA0h]
00007FF91DFC7693  89 83 C0 8A 01 00           mov     [rbx+18AC0h], eax
00007FF91DFC7699  8B 83 A0 8A 01 00           mov     eax, [rbx+18AA0h]
00007FF91DFC769F  2B C2                       sub     eax, edx
00007FF91DFC76A1  48 63 C8                    movsxd  rcx, eax
00007FF91DFC76A4  48 63 83 A4 8A 01 00        movsxd  rax, dword ptr [rbx+18AA4h]
00007FF91DFC76AB  48 83 C1 02                 add     rcx, 2
00007FF91DFC76AF  48 FF C8                    dec     rax
00007FF91DFC76B2  48 23 C8                    and     rcx, rax
00007FF91DFC76B5  8B 84 8B A0 7A 01 00        mov     eax, [rbx+rcx*4+17AA0h]
00007FF91DFC76BC  89 83 C4 8A 01 00           mov     [rbx+18AC4h], eax
00007FF91DFC76C2  F3 0F 2C C2                 cvttss2si eax, xmm2
00007FF91DFC76C6  66 0F 6E C0                 movd    xmm0, eax
00007FF91DFC76CA  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00007FF91DFC76CE  F2 0F 5C C8                 subsd   xmm1, xmm0
00007FF91DFC76D2  66 0F 5A D1                 cvtpd2ps xmm2, xmm1
00007FF91DFC76D6  F3 0F 11 93 C8 8A 01 00     movss   dword ptr [rbx+18AC8h], xmm2
00007FF91DFC76DE  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFC76E1  F3 0F 59 8B C4 8A 01 00     mulss   xmm1, dword ptr [rbx+18AC4h]
00007FF91DFC76E9  F3 0F 10 83 C0 8A 01 00     movss   xmm0, dword ptr [rbx+18AC0h]
00007FF91DFC76F1  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFC76F5  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFC76F9  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC76FD  F3 0F 59 8B 00 78 01 00     mulss   xmm1, dword ptr [rbx+17800h]
00007FF91DFC7705  F3 0F 11 8B E0 76 01 00     movss   dword ptr [rbx+176E0h], xmm1
00007FF91DFC770D  F3 0F 59 8B E0 78 01 00     mulss   xmm1, dword ptr [rbx+178E0h]
00007FF91DFC7715  F3 0F 10 93 00 79 01 00     movss   xmm2, dword ptr [rbx+17900h]
00007FF91DFC771D  F3 0F 59 93 00 77 01 00     mulss   xmm2, dword ptr [rbx+17700h]
00007FF91DFC7725  F3 0F 10 A3 10 77 01 00     movss   xmm4, dword ptr [rbx+17710h]
00007FF91DFC772D  F3 0F 10 83 F0 78 01 00     movss   xmm0, dword ptr [rbx+178F0h]
00007FF91DFC7735  F3 0F 59 83 F0 76 01 00     mulss   xmm0, dword ptr [rbx+176F0h]
00007FF91DFC773D  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC7741  F3 0F 10 83 20 79 01 00     movss   xmm0, dword ptr [rbx+17920h]
00007FF91DFC7749  F3 0F 59 83 20 77 01 00     mulss   xmm0, dword ptr [rbx+17720h]
00007FF91DFC7751  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC7755  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFC7758  F3 0F 59 8B 10 79 01 00     mulss   xmm1, dword ptr [rbx+17910h]
00007FF91DFC7760  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC7764  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC7768  F3 0F 11 93 00 77 01 00     movss   dword ptr [rbx+17700h], xmm2
00007FF91DFC7770  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFC7773  F3 0F 59 A3 40 79 01 00     mulss   xmm4, dword ptr [rbx+17940h]
00007FF91DFC777B  F3 0F 59 8B 30 79 01 00     mulss   xmm1, dword ptr [rbx+17930h]
00007FF91DFC7783  F3 0F 10 83 50 79 01 00     movss   xmm0, dword ptr [rbx+17950h]
00007FF91DFC778B  F3 0F 59 83 30 77 01 00     mulss   xmm0, dword ptr [rbx+17730h]
00007FF91DFC7793  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC7797  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC779B  F3 0F 11 A3 20 77 01 00     movss   dword ptr [rbx+17720h], xmm4
00007FF91DFC77A3  F3 0F 59 A3 70 79 01 00     mulss   xmm4, dword ptr [rbx+17970h]
00007FF91DFC77AB  F3 0F 10 8B 40 77 01 00     movss   xmm1, dword ptr [rbx+17740h]
00007FF91DFC77B3  F3 0F 59 93 60 79 01 00     mulss   xmm2, dword ptr [rbx+17960h]
00007FF91DFC77BB  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFC77BF  F3 0F 10 93 50 77 01 00     movss   xmm2, dword ptr [rbx+17750h]
00007FF91DFC77C7  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFC77CA  F3 0F 5C D9                 subss   xmm3, xmm1
00007FF91DFC77CE  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC77D1  F3 0F 59 83 80 79 01 00     mulss   xmm0, dword ptr [rbx+17980h]
00007FF91DFC77D9  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFC77DD  F3 0F 11 83 30 77 01 00     movss   dword ptr [rbx+17730h], xmm0
00007FF91DFC77E5  F3 0F 59 9B A0 79 01 00     mulss   xmm3, dword ptr [rbx+179A0h]
00007FF91DFC77ED  F3 0F 59 A3 90 79 01 00     mulss   xmm4, dword ptr [rbx+17990h]
00007FF91DFC77F5  F3 0F 10 8B 10 78 01 00     movss   xmm1, dword ptr [rbx+17810h]
00007FF91DFC77FD  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFC7801  F3 0F 5C DA                 subss   xmm3, xmm2
00007FF91DFC7805  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC7808  F3 0F 59 83 B0 79 01 00     mulss   xmm0, dword ptr [rbx+179B0h]
00007FF91DFC7810  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFC7814  F3 0F 10 93 60 77 01 00     movss   xmm2, dword ptr [rbx+17760h]
00007FF91DFC781C  F3 41 0F 5C CE              subss   xmm1, xmm14
00007FF91DFC7821  F3 0F 11 83 40 77 01 00     movss   dword ptr [rbx+17740h], xmm0
00007FF91DFC7829  F3 0F 5C DA                 subss   xmm3, xmm2
00007FF91DFC782D  F3 0F 59 C9                 mulss   xmm1, xmm1
00007FF91DFC7831  F3 0F 11 9B 60 77 01 00     movss   dword ptr [rbx+17760h], xmm3
00007FF91DFC7839  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC783C  F3 0F 59 83 C0 79 01 00     mulss   xmm0, dword ptr [rbx+179C0h]
00007FF91DFC7844  F3 0F 10 AB 70 77 01 00     movss   xmm5, dword ptr [rbx+17770h]
00007FF91DFC784C  F3 44 0F 5C F1              subss   xmm14, xmm1
00007FF91DFC7851  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFC7855  F3 44 0F 59 B3 00 7A 01 00  mulss   xmm14, dword ptr [rbx+17A00h]
00007FF91DFC785E  F3 0F 11 83 50 77 01 00     movss   dword ptr [rbx+17750h], xmm0
00007FF91DFC7866  F3 0F 59 AB E0 79 01 00     mulss   xmm5, dword ptr [rbx+179E0h]
00007FF91DFC786E  F3 0F 59 9B D0 79 01 00     mulss   xmm3, dword ptr [rbx+179D0h]
00007FF91DFC7876  F3 0F 10 93 90 76 01 00     movss   xmm2, dword ptr [rbx+17690h]
00007FF91DFC787E  F3 0F 10 A3 A0 76 01 00     movss   xmm4, dword ptr [rbx+176A0h]
00007FF91DFC7886  F3 44 0F 58 B3 F0 79 01 00  addss   xmm14, dword ptr [rbx+179F0h]
00007FF91DFC788F  F3 0F 10 8B 80 7A 01 00     movss   xmm1, dword ptr [rbx+17A80h]
00007FF91DFC7897  F3 0F 58 EB                 addss   xmm5, xmm3
00007FF91DFC789B  F3 0F 59 8B B0 76 01 00     mulss   xmm1, dword ptr [rbx+176B0h]
00007FF91DFC78A3  F3 0F 10 9B 90 78 01 00     movss   xmm3, dword ptr [rbx+17890h]
00007FF91DFC78AB  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC78AE  F3 41 0F 59 EE              mulss   xmm5, xmm14
00007FF91DFC78B3  F3 0F 59 CB                 mulss   xmm1, xmm3
00007FF91DFC78B7  F3 0F 59 AB 90 7A 01 00     mulss   xmm5, dword ptr [rbx+17A90h]
00007FF91DFC78BF  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC78C3  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFC78C7  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC78CB  F3 0F 5C EB                 subss   xmm5, xmm3
00007FF91DFC78CF  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC78D3  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFC78D7  F3 0F 11 8B 30 78 01 00     movss   dword ptr [rbx+17830h], xmm1
00007FF91DFC78DF  F3 0F 11 AB 40 78 01 00     movss   dword ptr [rbx+17840h], xmm5
00007FF91DFC78E7  8B 8B A4 8A 01 00           mov     ecx, [rbx+18AA4h]
00007FF91DFC78ED  8B 83 A0 8A 01 00           mov     eax, [rbx+18AA0h]
00007FF91DFC78F3  FF C9                       dec     ecx
00007FF91DFC78F5  FF C8                       dec     eax
00007FF91DFC78F7  23 C8                       and     ecx, eax
00007FF91DFC78F9  89 8B A0 8A 01 00           mov     [rbx+18AA0h], ecx
00007FF91DFC78FF  8B 83 B0 8A 01 00           mov     eax, [rbx+18AB0h]
00007FF91DFC7905  48 63 C9                    movsxd  rcx, ecx
00007FF91DFC7908  89 84 8B A0 7A 01 00        mov     [rbx+rcx*4+17AA0h], eax
00007FF91DFC790F  8B 83 30 78 01 00           mov     eax, [rbx+17830h]
00007FF91DFC7915  89 83 C0 4A 01 00           mov     [rbx+14AC0h], eax
00007FF91DFC791B  F3 0F 10 83 40 78 01 00     movss   xmm0, dword ptr [rbx+17840h]
00007FF91DFC7923  E9 B9 13 00 00              jmp     loc_7FF91DFC8CE1
00007FF91DFC7928  8B 83 80 61 01 00           mov     eax, [rbx+16180h]
00007FF91DFC792E  F3 0F 10 83 90 4A 01 00     movss   xmm0, dword ptr [rbx+14A90h]
00007FF91DFC7936  89 83 90 61 01 00           mov     [rbx+16190h], eax
00007FF91DFC793C  8B 83 70 61 01 00           mov     eax, [rbx+16170h]
00007FF91DFC7942  89 83 80 61 01 00           mov     [rbx+16180h], eax
00007FF91DFC7948  8B 83 60 61 01 00           mov     eax, [rbx+16160h]
00007FF91DFC794E  89 83 70 61 01 00           mov     [rbx+16170h], eax
00007FF91DFC7954  8B 83 50 61 01 00           mov     eax, [rbx+16150h]
00007FF91DFC795A  89 83 60 61 01 00           mov     [rbx+16160h], eax
00007FF91DFC7960  8B 83 40 61 01 00           mov     eax, [rbx+16140h]
00007FF91DFC7966  89 83 50 61 01 00           mov     [rbx+16150h], eax
00007FF91DFC796C  8B 83 30 61 01 00           mov     eax, [rbx+16130h]
00007FF91DFC7972  89 83 40 61 01 00           mov     [rbx+16140h], eax
00007FF91DFC7978  8B 83 20 61 01 00           mov     eax, [rbx+16120h]
00007FF91DFC797E  89 83 30 61 01 00           mov     [rbx+16130h], eax
00007FF91DFC7984  8B 83 B0 61 01 00           mov     eax, [rbx+161B0h]
00007FF91DFC798A  89 83 C0 61 01 00           mov     [rbx+161C0h], eax
00007FF91DFC7990  8B 83 A0 61 01 00           mov     eax, [rbx+161A0h]
00007FF91DFC7996  89 83 B0 61 01 00           mov     [rbx+161B0h], eax
00007FF91DFC799C  8B 83 E0 61 01 00           mov     eax, [rbx+161E0h]
00007FF91DFC79A2  89 83 F0 61 01 00           mov     [rbx+161F0h], eax
00007FF91DFC79A8  8B 83 D0 61 01 00           mov     eax, [rbx+161D0h]
00007FF91DFC79AE  89 83 E0 61 01 00           mov     [rbx+161E0h], eax
00007FF91DFC79B4  8B 83 00 62 01 00           mov     eax, [rbx+16200h]
00007FF91DFC79BA  89 83 10 62 01 00           mov     [rbx+16210h], eax
00007FF91DFC79C0  8B 83 20 62 01 00           mov     eax, [rbx+16220h]
00007FF91DFC79C6  89 83 30 62 01 00           mov     [rbx+16230h], eax
00007FF91DFC79CC  8B 83 40 62 01 00           mov     eax, [rbx+16240h]
00007FF91DFC79D2  89 83 50 62 01 00           mov     [rbx+16250h], eax
00007FF91DFC79D8  8B 83 70 62 01 00           mov     eax, [rbx+16270h]
00007FF91DFC79DE  89 83 80 62 01 00           mov     [rbx+16280h], eax
00007FF91DFC79E4  8B 83 60 62 01 00           mov     eax, [rbx+16260h]
00007FF91DFC79EA  89 83 70 62 01 00           mov     [rbx+16270h], eax
00007FF91DFC79F0  8B 83 D0 62 01 00           mov     eax, [rbx+162D0h]
00007FF91DFC79F6  89 83 E0 62 01 00           mov     [rbx+162E0h], eax
00007FF91DFC79FC  8B 83 30 63 01 00           mov     eax, [rbx+16330h]
00007FF91DFC7A02  89 83 40 63 01 00           mov     [rbx+16340h], eax
00007FF91DFC7A08  8B 83 20 63 01 00           mov     eax, [rbx+16320h]
00007FF91DFC7A0E  89 83 30 63 01 00           mov     [rbx+16330h], eax
00007FF91DFC7A14  8B 83 10 63 01 00           mov     eax, [rbx+16310h]
00007FF91DFC7A1A  89 83 20 63 01 00           mov     [rbx+16320h], eax
00007FF91DFC7A20  8B 83 00 63 01 00           mov     eax, [rbx+16300h]
00007FF91DFC7A26  89 83 10 63 01 00           mov     [rbx+16310h], eax
00007FF91DFC7A2C  8B 83 F0 62 01 00           mov     eax, [rbx+162F0h]
00007FF91DFC7A32  89 83 00 63 01 00           mov     [rbx+16300h], eax
00007FF91DFC7A38  8B 83 90 63 01 00           mov     eax, [rbx+16390h]
00007FF91DFC7A3E  89 83 A0 63 01 00           mov     [rbx+163A0h], eax
00007FF91DFC7A44  8B 83 80 63 01 00           mov     eax, [rbx+16380h]
00007FF91DFC7A4A  89 83 90 63 01 00           mov     [rbx+16390h], eax
00007FF91DFC7A50  8B 83 70 63 01 00           mov     eax, [rbx+16370h]
00007FF91DFC7A56  89 83 80 63 01 00           mov     [rbx+16380h], eax
00007FF91DFC7A5C  8B 83 60 63 01 00           mov     eax, [rbx+16360h]
00007FF91DFC7A62  89 83 70 63 01 00           mov     [rbx+16370h], eax
00007FF91DFC7A68  8B 83 50 63 01 00           mov     eax, [rbx+16350h]
00007FF91DFC7A6E  89 83 60 63 01 00           mov     [rbx+16360h], eax
00007FF91DFC7A74  F3 0F 11 83 00 61 01 00     movss   dword ptr [rbx+16100h], xmm0
00007FF91DFC7A7C  F3 0F 11 83 10 61 01 00     movss   dword ptr [rbx+16110h], xmm0
00007FF91DFC7A84  F3 0F 10 83 30 62 01 00     movss   xmm0, dword ptr [rbx+16230h]
00007FF91DFC7A8C  F3 0F 58 83 10 62 01 00     addss   xmm0, dword ptr [rbx+16210h]
00007FF91DFC7A94  F3 0F 58 83 10 64 01 00     addss   xmm0, dword ptr [rbx+16410h]
00007FF91DFC7A9C  E8 8F 14 00 00              call    sub_7FF91DFC8F30
00007FF91DFC7AA1  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFC7AA5  F3 44 0F 10 15 12 DD 77 00  movss   xmm10, dword ptr cs:xmmword_7FF91E7457C0
00007FF91DFC7AAE  F3 0F 11 83 20 62 01 00     movss   dword ptr [rbx+16220h], xmm0
00007FF91DFC7AB6  F3 0F 10 8B 40 65 01 00     movss   xmm1, dword ptr [rbx+16540h]
00007FF91DFC7ABE  73 04                       jnb     short loc_7FF91DFC7AC4
00007FF91DFC7AC0  41 0F 57 CA                 xorps   xmm1, xmm10
00007FF91DFC7AC4  F3 0F 10 83 E0 62 01 00     movss   xmm0, dword ptr [rbx+162E0h]
00007FF91DFC7ACC  44 0F 28 C8                 movaps  xmm9, xmm0
00007FF91DFC7AD0  F3 0F 11 8B 00 62 01 00     movss   dword ptr [rbx+16200h], xmm1
00007FF91DFC7AD8  F3 44 0F 59 8B B0 65 01 00  mulss   xmm9, dword ptr [rbx+165B0h]
00007FF91DFC7AE1  41 0F 57 C2                 xorps   xmm0, xmm10
00007FF91DFC7AE5  F3 44 0F 11 8B 50 63 01 00  movss   dword ptr [rbx+16350h], xmm9
00007FF91DFC7AEE  E8 6D 12 00 00              call    sub_7FF91DFC8D60
00007FF91DFC7AF3  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFC7AF6  41 0F 57 C2                 xorps   xmm0, xmm10
00007FF91DFC7AFA  F3 0F 59 BB B0 65 01 00     mulss   xmm7, dword ptr [rbx+165B0h]
00007FF91DFC7B02  F3 0F 11 BB F0 62 01 00     movss   dword ptr [rbx+162F0h], xmm7
00007FF91DFC7B0A  E8 51 12 00 00              call    sub_7FF91DFC8D60
00007FF91DFC7B0F  F3 0F 11 83 D0 62 01 00     movss   dword ptr [rbx+162D0h], xmm0
00007FF91DFC7B17  F3 0F 10 8B E0 65 01 00     movss   xmm1, dword ptr [rbx+165E0h]
00007FF91DFC7B1F  F3 0F 10 93 10 63 01 00     movss   xmm2, dword ptr [rbx+16310h]
00007FF91DFC7B27  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC7B2A  F3 0F 59 83 00 63 01 00     mulss   xmm0, dword ptr [rbx+16300h]
00007FF91DFC7B32  F3 0F 59 8B 60 63 01 00     mulss   xmm1, dword ptr [rbx+16360h]
00007FF91DFC7B3A  F3 44 0F 10 9B D0 65 01 00  movss   xmm11, dword ptr [rbx+165D0h]
00007FF91DFC7B43  41 0F 28 E3                 movaps  xmm4, xmm11
00007FF91DFC7B47  F3 45 0F 59 D9              mulss   xmm11, xmm9
00007FF91DFC7B4C  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFC7B50  F3 0F 10 BB 70 63 01 00     movss   xmm7, dword ptr [rbx+16370h]
00007FF91DFC7B58  F3 44 0F 58 D9              addss   xmm11, xmm1
00007FF91DFC7B5D  F3 0F 10 8B F0 65 01 00     movss   xmm1, dword ptr [rbx+165F0h]
00007FF91DFC7B65  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC7B69  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC7B6C  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC7B70  F3 0F 59 CF                 mulss   xmm1, xmm7
00007FF91DFC7B74  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC7B78  F3 44 0F 58 D9              addss   xmm11, xmm1
00007FF91DFC7B7D  F3 0F 11 A3 00 63 01 00     movss   dword ptr [rbx+16300h], xmm4
00007FF91DFC7B85  F3 44 0F 11 9B 60 63 01 00  movss   dword ptr [rbx+16360h], xmm11
00007FF91DFC7B8E  F3 0F 10 9B 10 66 01 00     movss   xmm3, dword ptr [rbx+16610h]
00007FF91DFC7B96  F3 0F 10 AB 20 66 01 00     movss   xmm5, dword ptr [rbx+16620h]
00007FF91DFC7B9E  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC7BA1  F3 44 0F 10 83 40 66 01 00  movss   xmm8, dword ptr [rbx+16640h]
00007FF91DFC7BAA  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFC7BAD  F3 0F 59 8B 20 63 01 00     mulss   xmm1, dword ptr [rbx+16320h]
00007FF91DFC7BB5  F3 44 0F 10 93 00 66 01 00  movss   xmm10, dword ptr [rbx+16600h]
00007FF91DFC7BBE  F3 0F 59 AB 80 63 01 00     mulss   xmm5, dword ptr [rbx+16380h]
00007FF91DFC7BC6  45 0F 28 CA                 movaps  xmm9, xmm10
00007FF91DFC7BCA  F3 0F 10 B3 30 66 01 00     movss   xmm6, dword ptr [rbx+16630h]
00007FF91DFC7BD2  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC7BD6  F3 44 0F 59 CC              mulss   xmm9, xmm4
00007FF91DFC7BDB  F3 45 0F 59 D3              mulss   xmm10, xmm11
00007FF91DFC7BE0  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFC7BE5  F3 0F 59 DF                 mulss   xmm3, xmm7
00007FF91DFC7BE9  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFC7BEC  F3 0F 59 B3 90 63 01 00     mulss   xmm6, dword ptr [rbx+16390h]
00007FF91DFC7BF4  F3 0F 59 83 30 63 01 00     mulss   xmm0, dword ptr [rbx+16330h]
00007FF91DFC7BFC  F3 44 0F 58 D3              addss   xmm10, xmm3
00007FF91DFC7C01  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFC7C06  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFC7C0A  F3 0F 59 8B 40 63 01 00     mulss   xmm1, dword ptr [rbx+16340h]
00007FF91DFC7C12  F3 44 0F 59 83 A0 63 01 00  mulss   xmm8, dword ptr [rbx+163A0h]
00007FF91DFC7C1B  F3 44 0F 58 D5              addss   xmm10, xmm5
00007FF91DFC7C20  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFC7C25  F3 0F 10 83 20 62 01 00     movss   xmm0, dword ptr [rbx+16220h]
00007FF91DFC7C2D  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFC7C30  0F 54 3D 59 DB 77 00        andps   xmm7, cs:xmmword_7FF91E745790
00007FF91DFC7C37  F3 44 0F 58 D6              addss   xmm10, xmm6
00007FF91DFC7C3C  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFC7C41  F3 45 0F 58 D0              addss   xmm10, xmm8
00007FF91DFC7C46  F3 44 0F 11 8B 20 63 01 00  movss   dword ptr [rbx+16320h], xmm9
00007FF91DFC7C4F  F3 44 0F 11 93 80 63 01 00  movss   dword ptr [rbx+16380h], xmm10
00007FF91DFC7C58  F3 0F 11 BB 90 62 01 00     movss   dword ptr [rbx+16290h], xmm7
00007FF91DFC7C60  F3 0F 58 83 20 64 01 00     addss   xmm0, dword ptr [rbx+16420h]
00007FF91DFC7C68  F3 44 0F 10 83 30 64 01 00  movss   xmm8, dword ptr [rbx+16430h]
00007FF91DFC7C71  E8 BA 12 00 00              call    sub_7FF91DFC8F30
00007FF91DFC7C76  0F 54 05 13 DB 77 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFC7C7D  F3 0F 11 83 A0 62 01 00     movss   dword ptr [rbx+162A0h], xmm0
00007FF91DFC7C85  F3 0F 10 8B 50 65 01 00     movss   xmm1, dword ptr [rbx+16550h]
00007FF91DFC7C8D  F3 0F 10 93 60 65 01 00     movss   xmm2, dword ptr [rbx+16560h]
00007FF91DFC7C95  F3 0F 10 A3 10 61 01 00     movss   xmm4, dword ptr [rbx+16110h]
00007FF91DFC7C9D  F3 41 0F 59 F8              mulss   xmm7, xmm8
00007FF91DFC7CA2  F3 0F 59 F9                 mulss   xmm7, xmm1
00007FF91DFC7CA6  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFC7CAA  F3 0F 11 BB B0 62 01 00     movss   dword ptr [rbx+162B0h], xmm7
00007FF91DFC7CB2  F3 44 0F 59 83 00 64 01 00  mulss   xmm8, dword ptr [rbx+16400h]
00007FF91DFC7CBB  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFC7CC0  F3 44 0F 59 C1              mulss   xmm8, xmm1
00007FF91DFC7CC5  F3 44 0F 58 C2              addss   xmm8, xmm2
00007FF91DFC7CCA  F3 44 0F 11 83 C0 62 01 00  movss   dword ptr [rbx+162C0h], xmm8
00007FF91DFC7CD3  F3 0F 58 A3 00 61 01 00     addss   xmm4, dword ptr [rbx+16100h]
00007FF91DFC7CDB  F3 0F 59 25 29 D3 77 00     mulss   xmm4, cs:dword_7FF91E74500C
00007FF91DFC7CE3  F3 0F 11 A3 20 61 01 00     movss   dword ptr [rbx+16120h], xmm4
00007FF91DFC7CEB  F3 0F 10 9B 50 61 01 00     movss   xmm3, dword ptr [rbx+16150h]
00007FF91DFC7CF3  F3 0F 10 93 30 61 01 00     movss   xmm2, dword ptr [rbx+16130h]
00007FF91DFC7CFB  F3 0F 59 93 B0 64 01 00     mulss   xmm2, dword ptr [rbx+164B0h]
00007FF91DFC7D03  F3 0F 10 83 C0 64 01 00     movss   xmm0, dword ptr [rbx+164C0h]
00007FF91DFC7D0B  F3 0F 59 83 40 61 01 00     mulss   xmm0, dword ptr [rbx+16140h]
00007FF91DFC7D13  F3 0F 10 AB 60 61 01 00     movss   xmm5, dword ptr [rbx+16160h]
00007FF91DFC7D1B  F3 0F 59 A3 A0 64 01 00     mulss   xmm4, dword ptr [rbx+164A0h]
00007FF91DFC7D23  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFC7D26  F3 0F 59 8B E0 64 01 00     mulss   xmm1, dword ptr [rbx+164E0h]
00007FF91DFC7D2E  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC7D32  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC7D35  F3 0F 59 83 D0 64 01 00     mulss   xmm0, dword ptr [rbx+164D0h]
00007FF91DFC7D3D  F3 0F 58 D4                 addss   xmm2, xmm4
00007FF91DFC7D41  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC7D45  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC7D49  F3 0F 11 93 40 61 01 00     movss   dword ptr [rbx+16140h], xmm2
00007FF91DFC7D51  F3 0F 59 9B B0 64 01 00     mulss   xmm3, dword ptr [rbx+164B0h]
00007FF91DFC7D59  F3 0F 59 AB C0 64 01 00     mulss   xmm5, dword ptr [rbx+164C0h]
00007FF91DFC7D61  F3 0F 10 83 80 61 01 00     movss   xmm0, dword ptr [rbx+16180h]
00007FF91DFC7D69  F3 0F 59 83 E0 64 01 00     mulss   xmm0, dword ptr [rbx+164E0h]
00007FF91DFC7D71  F3 0F 59 93 A0 64 01 00     mulss   xmm2, dword ptr [rbx+164A0h]
00007FF91DFC7D79  F3 0F 58 EB                 addss   xmm5, xmm3
00007FF91DFC7D7D  F3 0F 10 9B 70 61 01 00     movss   xmm3, dword ptr [rbx+16170h]
00007FF91DFC7D85  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC7D88  F3 0F 59 8B D0 64 01 00     mulss   xmm1, dword ptr [rbx+164D0h]
00007FF91DFC7D90  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFC7D94  F3 0F 10 93 90 64 01 00     movss   xmm2, dword ptr [rbx+16490h]
00007FF91DFC7D9C  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC7DA0  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFC7DA4  F3 0F 10 8B 80 64 01 00     movss   xmm1, dword ptr [rbx+16480h]
00007FF91DFC7DAC  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFC7DB0  F3 0F 11 AB 60 61 01 00     movss   dword ptr [rbx+16160h], xmm5
00007FF91DFC7DB8  F3 0F 10 83 10 65 01 00     movss   xmm0, dword ptr [rbx+16510h]
00007FF91DFC7DC0  F3 0F 59 83 90 61 01 00     mulss   xmm0, dword ptr [rbx+16190h]
00007FF91DFC7DC8  F3 0F 59 9B 00 65 01 00     mulss   xmm3, dword ptr [rbx+16500h]
00007FF91DFC7DD0  F3 0F 59 AB F0 64 01 00     mulss   xmm5, dword ptr [rbx+164F0h]
00007FF91DFC7DD8  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFC7DDC  F3 0F 10 83 70 62 01 00     movss   xmm0, dword ptr [rbx+16270h]
00007FF91DFC7DE4  F3 0F 58 DD                 addss   xmm3, xmm5
00007FF91DFC7DE8  F3 0F 59 CB                 mulss   xmm1, xmm3
00007FF91DFC7DEC  F3 0F 11 9B 80 61 01 00     movss   dword ptr [rbx+16180h], xmm3
00007FF91DFC7DF4  F3 0F 58 83 70 65 01 00     addss   xmm0, dword ptr [rbx+16570h]
00007FF91DFC7DFC  F3 0F 11 8B 60 76 01 00     movss   dword ptr [rbx+17660h], xmm1
00007FF91DFC7E04  F3 0F 10 8B 80 65 01 00     movss   xmm1, dword ptr [rbx+16580h]
00007FF91DFC7E0C  F3 0F 5D C8                 minss   xmm1, xmm0
00007FF91DFC7E10  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFC7E14  F3 0F 11 8B 60 62 01 00     movss   dword ptr [rbx+16260h], xmm1
00007FF91DFC7E1C  F3 0F 5C 8B 50 62 01 00     subss   xmm1, dword ptr [rbx+16250h]
00007FF91DFC7E24  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFC7E28  73 0A                       jnb     short loc_7FF91DFC7E34
00007FF91DFC7E2A  F3 0F 10 83 A0 65 01 00     movss   xmm0, dword ptr [rbx+165A0h]
00007FF91DFC7E32  EB 08                       jmp     short loc_7FF91DFC7E3C
00007FF91DFC7E34  F3 0F 10 83 90 65 01 00     movss   xmm0, dword ptr [rbx+16590h]
00007FF91DFC7E3C  F3 0F 58 83 80 62 01 00     addss   xmm0, dword ptr [rbx+16280h]
00007FF91DFC7E44  F3 0F 10 93 F0 63 01 00     movss   xmm2, dword ptr [rbx+163F0h]
00007FF91DFC7E4C  F3 0F 10 9B 50 62 01 00     movss   xmm3, dword ptr [rbx+16250h]
00007FF91DFC7E54  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFC7E57  F3 0F 5C CB                 subss   xmm1, xmm3
00007FF91DFC7E5B  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFC7E5F  76 04                       jbe     short loc_7FF91DFC7E65
00007FF91DFC7E61  44 0F 5A F8                 cvtps2pd xmm15, xmm0
00007FF91DFC7E65  F3 0F 59 8B 70 64 01 00     mulss   xmm1, dword ptr [rbx+16470h]
00007FF91DFC7E6D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC7E70  F2 41 0F 5A C7              cvtsd2ss xmm0, xmm15
00007FF91DFC7E75  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFC7E79  41 0F 2F C4                 comiss  xmm0, xmm12
00007FF91DFC7E7D  72 09                       jb      short loc_7FF91DFC7E88
00007FF91DFC7E7F  44 0F 28 E0                 movaps  xmm12, xmm0
00007FF91DFC7E83  F3 45 0F 5D E6              minss   xmm12, xmm14
00007FF91DFC7E88  F3 44 0F 59 A3 90 64 01 00  mulss   xmm12, dword ptr [rbx+16490h]
00007FF91DFC7E91  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC7E94  F3 0F 5C C3                 subss   xmm0, xmm3
00007FF91DFC7E98  F3 44 0F 11 A3 70 62 01 00  movss   dword ptr [rbx+16270h], xmm12
00007FF91DFC7EA1  41 0F 2E C5                 ucomiss xmm0, xmm13
00007FF91DFC7EA5  74 03                       jz      short loc_7FF91DFC7EAA
00007FF91DFC7EA7  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFC7EAA  F3 0F 11 93 40 62 01 00     movss   dword ptr [rbx+16240h], xmm2
00007FF91DFC7EB2  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFC7EB5  F3 0F 58 93 B0 62 01 00     addss   xmm2, dword ptr [rbx+162B0h]
00007FF91DFC7EBD  8B 83 50 76 01 00           mov     eax, [rbx+17650h]
00007FF91DFC7EC3  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC7EC6  F3 0F 59 15 D2 2D 62 00     mulss   xmm2, cs:dword_7FF91E5EACA0
00007FF91DFC7ECE  F3 0F 59 05 E2 2D 62 00     mulss   xmm0, cs:dword_7FF91E5EACB8
00007FF91DFC7ED6  0F 5A CA                    cvtps2pd xmm1, xmm2
00007FF91DFC7ED9  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC7EDD  2B C2                       sub     eax, edx
00007FF91DFC7EDF  48 63 C8                    movsxd  rcx, eax
00007FF91DFC7EE2  48 63 83 54 76 01 00        movsxd  rax, dword ptr [rbx+17654h]
00007FF91DFC7EE9  48 FF C1                    inc     rcx
00007FF91DFC7EEC  48 FF C8                    dec     rax
00007FF91DFC7EEF  48 23 C8                    and     rcx, rax
00007FF91DFC7EF2  8B 84 8B 50 66 01 00        mov     eax, [rbx+rcx*4+16650h]
00007FF91DFC7EF9  89 83 70 76 01 00           mov     [rbx+17670h], eax
00007FF91DFC7EFF  8B 83 50 76 01 00           mov     eax, [rbx+17650h]
00007FF91DFC7F05  2B C2                       sub     eax, edx
00007FF91DFC7F07  48 63 C8                    movsxd  rcx, eax
00007FF91DFC7F0A  48 63 83 54 76 01 00        movsxd  rax, dword ptr [rbx+17654h]
00007FF91DFC7F11  48 83 C1 02                 add     rcx, 2
00007FF91DFC7F15  48 FF C8                    dec     rax
00007FF91DFC7F18  48 23 C8                    and     rcx, rax
00007FF91DFC7F1B  8B 84 8B 50 66 01 00        mov     eax, [rbx+rcx*4+16650h]
00007FF91DFC7F22  89 83 74 76 01 00           mov     [rbx+17674h], eax
00007FF91DFC7F28  F3 0F 2C C2                 cvttss2si eax, xmm2
00007FF91DFC7F2C  66 0F 6E C0                 movd    xmm0, eax
00007FF91DFC7F30  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00007FF91DFC7F34  F2 0F 5C C8                 subsd   xmm1, xmm0
00007FF91DFC7F38  66 0F 5A D1                 cvtpd2ps xmm2, xmm1
00007FF91DFC7F3C  F3 0F 11 93 78 76 01 00     movss   dword ptr [rbx+17678h], xmm2
00007FF91DFC7F44  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC7F47  F3 0F 59 83 74 76 01 00     mulss   xmm0, dword ptr [rbx+17674h]
00007FF91DFC7F4F  8B 83 50 76 01 00           mov     eax, [rbx+17650h]
00007FF91DFC7F55  F3 0F 58 A3 C0 62 01 00     addss   xmm4, dword ptr [rbx+162C0h]
00007FF91DFC7F5D  F3 44 0F 10 8B 70 76 01 00  movss   xmm9, dword ptr [rbx+17670h]
00007FF91DFC7F66  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFC7F6B  F3 0F 5C C2                 subss   xmm0, xmm2
00007FF91DFC7F6F  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFC7F74  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC7F77  F3 0F 59 05 39 2D 62 00     mulss   xmm0, cs:dword_7FF91E5EACB8
00007FF91DFC7F7F  F3 0F 59 25 19 2D 62 00     mulss   xmm4, cs:dword_7FF91E5EACA0
00007FF91DFC7F87  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC7F8B  0F 5A CC                    cvtps2pd xmm1, xmm4
00007FF91DFC7F8E  2B C2                       sub     eax, edx
00007FF91DFC7F90  48 63 C8                    movsxd  rcx, eax
00007FF91DFC7F93  48 63 83 54 76 01 00        movsxd  rax, dword ptr [rbx+17654h]
00007FF91DFC7F9A  48 FF C1                    inc     rcx
00007FF91DFC7F9D  48 FF C8                    dec     rax
00007FF91DFC7FA0  48 23 C8                    and     rcx, rax
00007FF91DFC7FA3  8B 84 8B 50 66 01 00        mov     eax, [rbx+rcx*4+16650h]
00007FF91DFC7FAA  89 83 80 76 01 00           mov     [rbx+17680h], eax
00007FF91DFC7FB0  8B 83 50 76 01 00           mov     eax, [rbx+17650h]
00007FF91DFC7FB6  2B C2                       sub     eax, edx
00007FF91DFC7FB8  48 63 C8                    movsxd  rcx, eax
00007FF91DFC7FBB  48 63 83 54 76 01 00        movsxd  rax, dword ptr [rbx+17654h]
00007FF91DFC7FC2  48 83 C1 02                 add     rcx, 2
00007FF91DFC7FC6  48 FF C8                    dec     rax
00007FF91DFC7FC9  48 23 C8                    and     rcx, rax
00007FF91DFC7FCC  8B 84 8B 50 66 01 00        mov     eax, [rbx+rcx*4+16650h]
00007FF91DFC7FD3  89 83 84 76 01 00           mov     [rbx+17684h], eax
00007FF91DFC7FD9  F3 0F 2C C4                 cvttss2si eax, xmm4
00007FF91DFC7FDD  66 0F 6E C0                 movd    xmm0, eax
00007FF91DFC7FE1  F3 0F E6 C0                 cvtdq2pd xmm0, xmm0
00007FF91DFC7FE5  F2 0F 5C C8                 subsd   xmm1, xmm0
00007FF91DFC7FE9  66 0F 5A D1                 cvtpd2ps xmm2, xmm1
00007FF91DFC7FED  F3 0F 11 93 88 76 01 00     movss   dword ptr [rbx+17688h], xmm2
00007FF91DFC7FF5  44 0F 28 C2                 movaps  xmm8, xmm2
00007FF91DFC7FF9  F3 0F 10 83 80 76 01 00     movss   xmm0, dword ptr [rbx+17680h]
00007FF91DFC8001  F3 44 0F 59 83 84 76 01 00  mulss   xmm8, dword ptr [rbx+17684h]
00007FF91DFC800A  F3 0F 10 9B 30 65 01 00     movss   xmm3, dword ptr [rbx+16530h]
00007FF91DFC8012  F3 0F 10 8B B0 61 01 00     movss   xmm1, dword ptr [rbx+161B0h]
00007FF91DFC801A  F3 0F 10 B3 C0 61 01 00     movss   xmm6, dword ptr [rbx+161C0h]
00007FF91DFC8022  F3 0F 10 A3 E0 61 01 00     movss   xmm4, dword ptr [rbx+161E0h]
00007FF91DFC802A  F3 0F 10 BB F0 61 01 00     movss   xmm7, dword ptr [rbx+161F0h]
00007FF91DFC8032  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFC8036  F3 44 0F 5C C2              subss   xmm8, xmm2
00007FF91DFC803B  F3 0F 10 93 20 65 01 00     movss   xmm2, dword ptr [rbx+16520h]
00007FF91DFC8043  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFC8048  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC804B  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC804F  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFC8053  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFC8057  F3 0F 58 DF                 addss   xmm3, xmm7
00007FF91DFC805B  F3 44 0F 5C C8              subss   xmm9, xmm0
00007FF91DFC8060  F3 44 0F 5C C3              subss   xmm8, xmm3
00007FF91DFC8065  F3 44 0F 59 CA              mulss   xmm9, xmm2
00007FF91DFC806A  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFC806F  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFC8074  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFC8079  F3 44 0F 11 8B A0 61 01 00  movss   dword ptr [rbx+161A0h], xmm9
00007FF91DFC8082  F3 44 0F 11 83 D0 61 01 00  movss   dword ptr [rbx+161D0h], xmm8
00007FF91DFC808B  F3 0F 10 A3 20 65 01 00     movss   xmm4, dword ptr [rbx+16520h]
00007FF91DFC8093  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFC8096  F3 41 0F 59 E0              mulss   xmm4, xmm8
00007FF91DFC809B  F3 41 0F 59 E9              mulss   xmm5, xmm9
00007FF91DFC80A0  F3 0F 58 E7                 addss   xmm4, xmm7
00007FF91DFC80A4  F3 0F 58 EE                 addss   xmm5, xmm6
00007FF91DFC80A8  F3 0F 11 AB B0 61 01 00     movss   dword ptr [rbx+161B0h], xmm5
00007FF91DFC80B0  F3 0F 11 A3 E0 61 01 00     movss   dword ptr [rbx+161E0h], xmm4
00007FF91DFC80B8  F3 0F 10 8B 40 64 01 00     movss   xmm1, dword ptr [rbx+16440h]
00007FF91DFC80C0  F3 0F 10 B3 C0 65 01 00     movss   xmm6, dword ptr [rbx+165C0h]
00007FF91DFC80C8  F3 0F 10 BB 80 62 01 00     movss   xmm7, dword ptr [rbx+16280h]
00007FF91DFC80D0  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFC80D3  F3 0F 58 83 A0 62 01 00     addss   xmm0, dword ptr [rbx+162A0h]
00007FF91DFC80DB  F3 0F 58 B3 90 62 01 00     addss   xmm6, dword ptr [rbx+16290h]
00007FF91DFC80E3  F3 0F 10 93 00 61 01 00     movss   xmm2, dword ptr [rbx+16100h]
00007FF91DFC80EB  F3 0F 59 83 20 63 01 00     mulss   xmm0, dword ptr [rbx+16320h]
00007FF91DFC80F3  F3 0F 59 B3 80 63 01 00     mulss   xmm6, dword ptr [rbx+16380h]
00007FF91DFC80FB  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC80FF  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFC8103  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC8107  F3 0F 10 83 60 64 01 00     movss   xmm0, dword ptr [rbx+16460h]
00007FF91DFC810F  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFC8113  F3 0F 10 A3 50 64 01 00     movss   xmm4, dword ptr [rbx+16450h]
00007FF91DFC811B  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFC811F  F3 0F 59 FD                 mulss   xmm7, xmm5
00007FF91DFC8123  F3 0F 10 AB 10 61 01 00     movss   xmm5, dword ptr [rbx+16110h]
00007FF91DFC812B  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFC812F  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFC8133  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC8136  F3 0F 11 B3 B0 63 01 00     movss   dword ptr [rbx+163B0h], xmm6
00007FF91DFC813E  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC8142  F3 0F 11 BB C0 63 01 00     movss   dword ptr [rbx+163C0h], xmm7
00007FF91DFC814A  F3 0F 10 9B 80 64 01 00     movss   xmm3, dword ptr [rbx+16480h]
00007FF91DFC8152  F3 44 0F 5C F3              subss   xmm14, xmm3
00007FF91DFC8157  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFC815B  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC815E  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFC8162  41 0F 28 C6                 movaps  xmm0, xmm14
00007FF91DFC8166  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFC816A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC816E  F3 44 0F 59 F5              mulss   xmm14, xmm5
00007FF91DFC8173  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC8177  F3 41 0F 58 DE              addss   xmm3, xmm14
00007FF91DFC817C  F3 0F 58 8B B0 63 01 00     addss   xmm1, dword ptr [rbx+163B0h]
00007FF91DFC8184  F3 0F 58 DF                 addss   xmm3, xmm7
00007FF91DFC8188  F3 0F 11 8B D0 63 01 00     movss   dword ptr [rbx+163D0h], xmm1
00007FF91DFC8190  F3 0F 11 9B E0 63 01 00     movss   dword ptr [rbx+163E0h], xmm3
00007FF91DFC8198  8B 8B 54 76 01 00           mov     ecx, [rbx+17654h]
00007FF91DFC819E  8B 83 50 76 01 00           mov     eax, [rbx+17650h]
00007FF91DFC81A4  FF C9                       dec     ecx
00007FF91DFC81A6  FF C8                       dec     eax
00007FF91DFC81A8  23 C8                       and     ecx, eax
00007FF91DFC81AA  89 8B 50 76 01 00           mov     [rbx+17650h], ecx
00007FF91DFC81B0  8B 83 60 76 01 00           mov     eax, [rbx+17660h]
00007FF91DFC81B6  48 63 C9                    movsxd  rcx, ecx
00007FF91DFC81B9  89 84 8B 50 66 01 00        mov     [rbx+rcx*4+16650h], eax
00007FF91DFC81C0  8B 83 D0 63 01 00           mov     eax, [rbx+163D0h]
00007FF91DFC81C6  89 83 C0 4A 01 00           mov     [rbx+14AC0h], eax
00007FF91DFC81CC  F3 0F 10 83 E0 63 01 00     movss   xmm0, dword ptr [rbx+163E0h]
00007FF91DFC81D4  E9 08 0B 00 00              jmp     loc_7FF91DFC8CE1
00007FF91DFC81D9  F3 0F 10 93 90 4A 01 00     movss   xmm2, dword ptr [rbx+14A90h]
00007FF91DFC81E1  8B 83 50 4C 01 00           mov     eax, [rbx+14C50h]
00007FF91DFC81E7  89 83 60 4C 01 00           mov     [rbx+14C60h], eax
00007FF91DFC81ED  8B 83 40 4C 01 00           mov     eax, [rbx+14C40h]
00007FF91DFC81F3  89 83 50 4C 01 00           mov     [rbx+14C50h], eax
00007FF91DFC81F9  8B 83 30 4C 01 00           mov     eax, [rbx+14C30h]
00007FF91DFC81FF  89 83 40 4C 01 00           mov     [rbx+14C40h], eax
00007FF91DFC8205  8B 83 20 4C 01 00           mov     eax, [rbx+14C20h]
00007FF91DFC820B  89 83 30 4C 01 00           mov     [rbx+14C30h], eax
00007FF91DFC8211  8B 83 10 4C 01 00           mov     eax, [rbx+14C10h]
00007FF91DFC8217  89 83 20 4C 01 00           mov     [rbx+14C20h], eax
00007FF91DFC821D  8B 83 00 4C 01 00           mov     eax, [rbx+14C00h]
00007FF91DFC8223  89 83 10 4C 01 00           mov     [rbx+14C10h], eax
00007FF91DFC8229  8B 83 F0 4B 01 00           mov     eax, [rbx+14BF0h]
00007FF91DFC822F  89 83 00 4C 01 00           mov     [rbx+14C00h], eax
00007FF91DFC8235  8B 83 E0 4B 01 00           mov     eax, [rbx+14BE0h]
00007FF91DFC823B  89 83 F0 4B 01 00           mov     [rbx+14BF0h], eax
00007FF91DFC8241  8B 83 70 4C 01 00           mov     eax, [rbx+14C70h]
00007FF91DFC8247  89 83 80 4C 01 00           mov     [rbx+14C80h], eax
00007FF91DFC824D  8B 83 50 4E 01 00           mov     eax, [rbx+14E50h]
00007FF91DFC8253  89 83 60 4E 01 00           mov     [rbx+14E60h], eax
00007FF91DFC8259  8B 83 70 4E 01 00           mov     eax, [rbx+14E70h]
00007FF91DFC825F  89 83 80 4E 01 00           mov     [rbx+14E80h], eax
00007FF91DFC8265  8B 83 90 4E 01 00           mov     eax, [rbx+14E90h]
00007FF91DFC826B  89 83 A0 4E 01 00           mov     [rbx+14EA0h], eax
00007FF91DFC8271  8B 83 B0 4E 01 00           mov     eax, [rbx+14EB0h]
00007FF91DFC8277  89 83 C0 4E 01 00           mov     [rbx+14EC0h], eax
00007FF91DFC827D  8B 83 D0 4E 01 00           mov     eax, [rbx+14ED0h]
00007FF91DFC8283  89 83 E0 4E 01 00           mov     [rbx+14EE0h], eax
00007FF91DFC8289  F3 0F 11 93 A0 4B 01 00     movss   dword ptr [rbx+14BA0h], xmm2
00007FF91DFC8291  F3 0F 11 93 B0 4B 01 00     movss   dword ptr [rbx+14BB0h], xmm2
00007FF91DFC8299  F3 0F 58 D2                 addss   xmm2, xmm2
00007FF91DFC829D  F3 0F 10 8B 90 4C 01 00     movss   xmm1, dword ptr [rbx+14C90h]
00007FF91DFC82A5  F3 0F 10 BB 70 4D 01 00     movss   xmm7, dword ptr [rbx+14D70h]
00007FF91DFC82AD  0F 28 F1                    movaps  xmm6, xmm1
00007FF91DFC82B0  F3 0F 10 A3 F0 4B 01 00     movss   xmm4, dword ptr [rbx+14BF0h]
00007FF91DFC82B8  0F 28 E9                    movaps  xmm5, xmm1
00007FF91DFC82BB  F3 0F 59 AB 50 4D 01 00     mulss   xmm5, dword ptr [rbx+14D50h]
00007FF91DFC82C3  F3 0F 59 93 D0 4C 01 00     mulss   xmm2, dword ptr [rbx+14CD0h]
00007FF91DFC82CB  F3 44 0F 10 83 40 4E 01 00  movss   xmm8, dword ptr [rbx+14E40h]
00007FF91DFC82D4  F3 44 0F 58 83 80 4C 01 00  addss   xmm8, dword ptr [rbx+14C80h]
00007FF91DFC82DD  F3 0F 58 AB 40 4D 01 00     addss   xmm5, dword ptr [rbx+14D40h]
00007FF91DFC82E5  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFC82E9  F3 44 0F 5D 83 C0 4C 01 00  minss   xmm8, dword ptr [rbx+14CC0h]
00007FF91DFC82F2  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFC82F5  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFC82F9  F3 0F 59 83 60 4D 01 00     mulss   xmm0, dword ptr [rbx+14D60h]
00007FF91DFC8301  F3 0F 11 93 E0 4B 01 00     movss   dword ptr [rbx+14BE0h], xmm2
00007FF91DFC8309  F3 0F 59 A3 F0 4C 01 00     mulss   xmm4, dword ptr [rbx+14CF0h]
00007FF91DFC8311  F3 0F 59 93 E0 4C 01 00     mulss   xmm2, dword ptr [rbx+14CE0h]
00007FF91DFC8319  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC831D  F3 0F 10 9B 00 4C 01 00     movss   xmm3, dword ptr [rbx+14C00h]
00007FF91DFC8325  F3 0F 10 8B 10 4C 01 00     movss   xmm1, dword ptr [rbx+14C10h]
00007FF91DFC832D  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC8330  F3 44 0F 11 83 70 4C 01 00  movss   dword ptr [rbx+14C70h], xmm8
00007FF91DFC8339  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFC833D  F3 0F 59 83 00 4D 01 00     mulss   xmm0, dword ptr [rbx+14D00h]
00007FF91DFC8345  F3 0F 59 8B 30 4D 01 00     mulss   xmm1, dword ptr [rbx+14D30h]
00007FF91DFC834D  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC8351  F3 0F 59 FE                 mulss   xmm7, xmm6
00007FF91DFC8355  F3 0F 58 FD                 addss   xmm7, xmm5
00007FF91DFC8359  F3 0F 11 A3 F0 4B 01 00     movss   dword ptr [rbx+14BF0h], xmm4
00007FF91DFC8361  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC8364  F3 0F 59 83 10 4D 01 00     mulss   xmm0, dword ptr [rbx+14D10h]
00007FF91DFC836C  F3 0F 59 9B 20 4D 01 00     mulss   xmm3, dword ptr [rbx+14D20h]
00007FF91DFC8374  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFC8378  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFC837C  F3 0F 11 9B 00 4C 01 00     movss   dword ptr [rbx+14C00h], xmm3
00007FF91DFC8384  F3 0F 58 BB 80 4D 01 00     addss   xmm7, dword ptr [rbx+14D80h]
00007FF91DFC838C  F3 0F 10 93 30 4C 01 00     movss   xmm2, dword ptr [rbx+14C30h]
00007FF91DFC8394  F3 0F 59 A3 90 4D 01 00     mulss   xmm4, dword ptr [rbx+14D90h]
00007FF91DFC839C  F3 0F 10 8B B0 4C 01 00     movss   xmm1, dword ptr [rbx+14CB0h]
00007FF91DFC83A4  F3 0F 59 FB                 mulss   xmm7, xmm3
00007FF91DFC83A8  F3 0F 58 FC                 addss   xmm7, xmm4
00007FF91DFC83AC  F3 0F 5C FA                 subss   xmm7, xmm2
00007FF91DFC83B0  F3 0F 11 BB 10 4C 01 00     movss   dword ptr [rbx+14C10h], xmm7
00007FF91DFC83B8  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFC83BB  F3 0F 59 83 A0 4D 01 00     mulss   xmm0, dword ptr [rbx+14DA0h]
00007FF91DFC83C3  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFC83C7  F3 0F 11 83 20 4C 01 00     movss   dword ptr [rbx+14C20h], xmm0
00007FF91DFC83CF  F3 44 0F 59 83 B0 4D 01 00  mulss   xmm8, dword ptr [rbx+14DB0h]
00007FF91DFC83D8  F3 44 0F 59 05 9B 28 62 00  mulss   xmm8, cs:dword_7FF91E5EAC7C
00007FF91DFC83E1  F3 0F 10 A3 F0 4B 01 00     movss   xmm4, dword ptr [rbx+14BF0h]
00007FF91DFC83E9  F3 0F 59 CF                 mulss   xmm1, xmm7
00007FF91DFC83ED  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFC83F2  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFC83F6  F3 0F 11 93 50 4E 01 00     movss   dword ptr [rbx+14E50h], xmm2
00007FF91DFC83FE  F3 0F 10 9B 20 4F 01 00     movss   xmm3, dword ptr [rbx+14F20h]
00007FF91DFC8406  F3 0F 10 8B 60 4E 01 00     movss   xmm1, dword ptr [rbx+14E60h]
00007FF91DFC840E  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFC8412  41 0F 2F D4                 comiss  xmm2, xmm12
00007FF91DFC8416  73 06                       jnb     short loc_7FF91DFC841E
00007FF91DFC8418  41 0F 28 D4                 movaps  xmm2, xmm12
00007FF91DFC841C  EB 05                       jmp     short loc_7FF91DFC8423
00007FF91DFC841E  F3 41 0F 5D D6              minss   xmm2, xmm14
00007FF91DFC8423  F3 44 0F 59 83 10 4F 01 00  mulss   xmm8, dword ptr [rbx+14F10h]
00007FF91DFC842C  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC842F  F3 0F 59 83 00 4F 01 00     mulss   xmm0, dword ptr [rbx+14F00h]
00007FF91DFC8437  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFC843C  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC843F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC8443  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC8447  F3 0F 59 93 30 4F 01 00     mulss   xmm2, dword ptr [rbx+14F30h]
00007FF91DFC844F  F3 0F 59 83 40 4F 01 00     mulss   xmm0, dword ptr [rbx+14F40h]
00007FF91DFC8457  F3 44 0F 59 C3              mulss   xmm8, xmm3
00007FF91DFC845C  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFC8460  45 0F 2F C4                 comiss  xmm8, xmm12
00007FF91DFC8464  F3 0F 11 83 70 4E 01 00     movss   dword ptr [rbx+14E70h], xmm0
00007FF91DFC846C  73 06                       jnb     short loc_7FF91DFC8474
00007FF91DFC846E  45 0F 28 C4                 movaps  xmm8, xmm12
00007FF91DFC8472  EB 05                       jmp     short loc_7FF91DFC8479
00007FF91DFC8474  F3 45 0F 5D C6              minss   xmm8, xmm14
00007FF91DFC8479  F3 0F 58 8B 50 4E 01 00     addss   xmm1, dword ptr [rbx+14E50h]
00007FF91DFC8481  F3 0F 10 93 60 4E 01 00     movss   xmm2, dword ptr [rbx+14E60h]
00007FF91DFC8489  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFC848D  F3 41 0F 59 C0              mulss   xmm0, xmm8
00007FF91DFC8492  F3 0F 59 8B F0 4E 01 00     mulss   xmm1, dword ptr [rbx+14EF0h]
00007FF91DFC849A  F3 41 0F 59 C0              mulss   xmm0, xmm8
00007FF91DFC849F  F3 44 0F 59 83 30 4F 01 00  mulss   xmm8, dword ptr [rbx+14F30h]
00007FF91DFC84A8  F3 0F 59 83 40 4F 01 00     mulss   xmm0, dword ptr [rbx+14F40h]
00007FF91DFC84B0  F3 0F 59 8B 20 4F 01 00     mulss   xmm1, dword ptr [rbx+14F20h]
00007FF91DFC84B8  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFC84BD  41 0F 2F CC                 comiss  xmm1, xmm12
00007FF91DFC84C1  F3 0F 11 83 90 4E 01 00     movss   dword ptr [rbx+14E90h], xmm0
00007FF91DFC84C9  73 06                       jnb     short loc_7FF91DFC84D1
00007FF91DFC84CB  41 0F 28 CC                 movaps  xmm1, xmm12
00007FF91DFC84CF  EB 05                       jmp     short loc_7FF91DFC84D6
00007FF91DFC84D1  F3 41 0F 5D CE              minss   xmm1, xmm14
00007FF91DFC84D6  F3 0F 10 83 00 4F 01 00     movss   xmm0, dword ptr [rbx+14F00h]
00007FF91DFC84DE  F3 0F 59 83 50 4E 01 00     mulss   xmm0, dword ptr [rbx+14E50h]
00007FF91DFC84E6  F3 0F 59 93 10 4F 01 00     mulss   xmm2, dword ptr [rbx+14F10h]
00007FF91DFC84EE  F3 0F 10 9B 70 4E 01 00     movss   xmm3, dword ptr [rbx+14E70h]
00007FF91DFC84F6  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC84FA  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC84FD  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC8501  F3 0F 59 93 20 4F 01 00     mulss   xmm2, dword ptr [rbx+14F20h]
00007FF91DFC8509  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC850D  41 0F 2F D4                 comiss  xmm2, xmm12
00007FF91DFC8511  F3 0F 59 83 40 4F 01 00     mulss   xmm0, dword ptr [rbx+14F40h]
00007FF91DFC8519  F3 0F 59 8B 30 4F 01 00     mulss   xmm1, dword ptr [rbx+14F30h]
00007FF91DFC8521  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFC8525  F3 0F 11 83 B0 4E 01 00     movss   dword ptr [rbx+14EB0h], xmm0
00007FF91DFC852D  72 09                       jb      short loc_7FF91DFC8538
00007FF91DFC852F  44 0F 28 E2                 movaps  xmm12, xmm2
00007FF91DFC8533  F3 45 0F 5D E6              minss   xmm12, xmm14
00007FF91DFC8538  F3 0F 58 9B E0 4E 01 00     addss   xmm3, dword ptr [rbx+14EE0h]
00007FF91DFC8540  F3 0F 10 83 60 4F 01 00     movss   xmm0, dword ptr [rbx+14F60h]
00007FF91DFC8548  F3 0F 59 83 90 4E 01 00     mulss   xmm0, dword ptr [rbx+14E90h]
00007FF91DFC8550  F3 0F 10 8B C0 4E 01 00     movss   xmm1, dword ptr [rbx+14EC0h]
00007FF91DFC8558  F3 0F 59 9B 50 4F 01 00     mulss   xmm3, dword ptr [rbx+14F50h]
00007FF91DFC8560  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFC8564  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFC8568  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFC856D  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFC8572  F3 44 0F 59 A3 30 4F 01 00  mulss   xmm12, dword ptr [rbx+14F30h]
00007FF91DFC857B  F3 0F 59 83 40 4F 01 00     mulss   xmm0, dword ptr [rbx+14F40h]
00007FF91DFC8583  F3 41 0F 58 C4              addss   xmm0, xmm12
00007FF91DFC8588  F3 0F 11 83 D0 4E 01 00     movss   dword ptr [rbx+14ED0h], xmm0
00007FF91DFC8590  F3 0F 59 8B 60 4F 01 00     mulss   xmm1, dword ptr [rbx+14F60h]
00007FF91DFC8598  F3 0F 58 83 80 4E 01 00     addss   xmm0, dword ptr [rbx+14E80h]
00007FF91DFC85A0  F3 0F 59 A3 D0 4D 01 00     mulss   xmm4, dword ptr [rbx+14DD0h]
00007FF91DFC85A8  F3 0F 10 93 B0 4E 01 00     movss   xmm2, dword ptr [rbx+14EB0h]
00007FF91DFC85B0  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFC85B4  F3 0F 58 93 A0 4E 01 00     addss   xmm2, dword ptr [rbx+14EA0h]
00007FF91DFC85BC  F3 0F 59 83 80 4F 01 00     mulss   xmm0, dword ptr [rbx+14F80h]
00007FF91DFC85C4  F3 0F 59 93 70 4F 01 00     mulss   xmm2, dword ptr [rbx+14F70h]
00007FF91DFC85CC  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC85D0  F3 0F 10 8B 40 4C 01 00     movss   xmm1, dword ptr [rbx+14C40h]
00007FF91DFC85D8  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC85DC  F3 0F 59 93 C0 4D 01 00     mulss   xmm2, dword ptr [rbx+14DC0h]
00007FF91DFC85E4  F3 0F 58 D4                 addss   xmm2, xmm4
00007FF91DFC85E8  F3 0F 11 93 30 4C 01 00     movss   dword ptr [rbx+14C30h], xmm2
00007FF91DFC85F0  F3 0F 59 8B F0 4D 01 00     mulss   xmm1, dword ptr [rbx+14DF0h]
00007FF91DFC85F8  F3 0F 10 9B 50 4C 01 00     movss   xmm3, dword ptr [rbx+14C50h]
00007FF91DFC8600  F3 0F 59 93 E0 4D 01 00     mulss   xmm2, dword ptr [rbx+14DE0h]
00007FF91DFC8608  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC860B  F3 0F 59 83 00 4E 01 00     mulss   xmm0, dword ptr [rbx+14E00h]
00007FF91DFC8613  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC8617  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC861B  F3 0F 11 8B 40 4C 01 00     movss   dword ptr [rbx+14C40h], xmm1
00007FF91DFC8623  F3 0F 59 9B 20 4E 01 00     mulss   xmm3, dword ptr [rbx+14E20h]
00007FF91DFC862B  F3 0F 59 8B 10 4E 01 00     mulss   xmm1, dword ptr [rbx+14E10h]
00007FF91DFC8633  F3 0F 10 83 30 4E 01 00     movss   xmm0, dword ptr [rbx+14E30h]
00007FF91DFC863B  F3 0F 59 83 60 4C 01 00     mulss   xmm0, dword ptr [rbx+14C60h]
00007FF91DFC8643  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFC8647  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFC864B  F3 0F 11 9B 50 4C 01 00     movss   dword ptr [rbx+14C50h], xmm3
00007FF91DFC8653  F3 0F 59 9B A0 4C 01 00     mulss   xmm3, dword ptr [rbx+14CA0h]
00007FF91DFC865B  F3 0F 59 9B B0 4C 01 00     mulss   xmm3, dword ptr [rbx+14CB0h]
00007FF91DFC8663  F3 0F 11 9B C0 4B 01 00     movss   dword ptr [rbx+14BC0h], xmm3
00007FF91DFC866B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC866E  F3 0F 11 9B D0 4B 01 00     movss   dword ptr [rbx+14BD0h], xmm3
00007FF91DFC8676  8B 83 B0 4F 01 00           mov     eax, [rbx+14FB0h]
00007FF91DFC867C  89 83 C0 4F 01 00           mov     [rbx+14FC0h], eax
00007FF91DFC8682  8B 83 A0 4F 01 00           mov     eax, [rbx+14FA0h]
00007FF91DFC8688  89 83 B0 4F 01 00           mov     [rbx+14FB0h], eax
00007FF91DFC868E  8B 83 90 4F 01 00           mov     eax, [rbx+14F90h]
00007FF91DFC8694  89 83 A0 4F 01 00           mov     [rbx+14FA0h], eax
00007FF91DFC869A  F3 0F 11 9B 90 4F 01 00     movss   dword ptr [rbx+14F90h], xmm3
00007FF91DFC86A2  F3 0F 59 83 F0 4F 01 00     mulss   xmm0, dword ptr [rbx+14FF0h]
00007FF91DFC86AA  F3 0F 10 A3 A0 4F 01 00     movss   xmm4, dword ptr [rbx+14FA0h]
00007FF91DFC86B2  F3 0F 10 8B 10 50 01 00     movss   xmm1, dword ptr [rbx+15010h]
00007FF91DFC86BA  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFC86BD  F3 0F 59 8B B0 4F 01 00     mulss   xmm1, dword ptr [rbx+14FB0h]
00007FF91DFC86C5  F3 0F 59 AB 00 50 01 00     mulss   xmm5, dword ptr [rbx+15000h]
00007FF91DFC86CD  F3 0F 59 A3 30 50 01 00     mulss   xmm4, dword ptr [rbx+15030h]
00007FF91DFC86D5  F3 0F 10 B3 E0 4F 01 00     movss   xmm6, dword ptr [rbx+14FE0h]
00007FF91DFC86DD  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC86E1  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFC86E5  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFC86E9  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC86EC  F3 0F 59 83 20 50 01 00     mulss   xmm0, dword ptr [rbx+15020h]
00007FF91DFC86F4  F3 0F 10 8B 40 50 01 00     movss   xmm1, dword ptr [rbx+15040h]
00007FF91DFC86FC  F3 0F 59 8B C0 4F 01 00     mulss   xmm1, dword ptr [rbx+14FC0h]
00007FF91DFC8704  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC8708  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFC870C  76 05                       jbe     short loc_7FF91DFC8713
00007FF91DFC870E  0F 5A C6                    cvtps2pd xmm0, xmm6
00007FF91DFC8711  EB 04                       jmp     short loc_7FF91DFC8717
00007FF91DFC8713  41 0F 28 C7                 movaps  xmm0, xmm15
00007FF91DFC8717  0F 2F 35 A2 CD 77 00        comiss  xmm6, cs:dword_7FF91E7454C0
00007FF91DFC871E  F2 0F 5A C0                 cvtsd2ss xmm0, xmm0
00007FF91DFC8722  F3 0F 11 AB A0 4F 01 00     movss   dword ptr [rbx+14FA0h], xmm5
00007FF91DFC872A  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFC872D  F3 0F 11 A3 B0 4F 01 00     movss   dword ptr [rbx+14FB0h], xmm4
00007FF91DFC8735  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFC8739  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFC873D  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC8741  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFC8744  0F 57 05 75 D0 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFC874B  F3 0F 58 D3                 addss   xmm2, xmm3
00007FF91DFC874F  73 09                       jnb     short loc_7FF91DFC875A
00007FF91DFC8751  45 0F 57 FF                 xorps   xmm15, xmm15
00007FF91DFC8755  F3 44 0F 5A F8              cvtss2sd xmm15, xmm0
00007FF91DFC875A  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFC875E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC8761  F2 41 0F 5A C7              cvtsd2ss xmm0, xmm15
00007FF91DFC8766  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFC8769  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFC876D  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFC8771  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC8775  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFC8779  72 03                       jb      short loc_7FF91DFC877E
00007FF91DFC877B  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFC877E  F3 0F 11 9B D0 4F 01 00     movss   dword ptr [rbx+14FD0h], xmm3
00007FF91DFC8786  F3 0F 11 9B C0 4A 01 00     movss   dword ptr [rbx+14AC0h], xmm3
00007FF91DFC878E  F3 0F 10 83 D0 4F 01 00     movss   xmm0, dword ptr [rbx+14FD0h]
00007FF91DFC8796  E9 46 05 00 00              jmp     loc_7FF91DFC8CE1
00007FF91DFC879B  F3 0F 10 A3 90 4A 01 00     movss   xmm4, dword ptr [rbx+14A90h]
00007FF91DFC87A3  8B 83 F0 50 01 00           mov     eax, [rbx+150F0h]
00007FF91DFC87A9  89 83 00 51 01 00           mov     [rbx+15100h], eax
00007FF91DFC87AF  8B 83 E0 50 01 00           mov     eax, [rbx+150E0h]
00007FF91DFC87B5  89 83 F0 50 01 00           mov     [rbx+150F0h], eax
00007FF91DFC87BB  8B 83 D0 50 01 00           mov     eax, [rbx+150D0h]
00007FF91DFC87C1  89 83 E0 50 01 00           mov     [rbx+150E0h], eax
00007FF91DFC87C7  8B 83 C0 50 01 00           mov     eax, [rbx+150C0h]
00007FF91DFC87CD  89 83 D0 50 01 00           mov     [rbx+150D0h], eax
00007FF91DFC87D3  8B 83 B0 50 01 00           mov     eax, [rbx+150B0h]
00007FF91DFC87D9  89 83 C0 50 01 00           mov     [rbx+150C0h], eax
00007FF91DFC87DF  8B 83 A0 50 01 00           mov     eax, [rbx+150A0h]
00007FF91DFC87E5  89 83 B0 50 01 00           mov     [rbx+150B0h], eax
00007FF91DFC87EB  8B 83 90 50 01 00           mov     eax, [rbx+15090h]
00007FF91DFC87F1  89 83 A0 50 01 00           mov     [rbx+150A0h], eax
00007FF91DFC87F7  8B 83 80 52 01 00           mov     eax, [rbx+15280h]
00007FF91DFC87FD  89 83 90 52 01 00           mov     [rbx+15290h], eax
00007FF91DFC8803  8B 83 A0 52 01 00           mov     eax, [rbx+152A0h]
00007FF91DFC8809  89 83 B0 52 01 00           mov     [rbx+152B0h], eax
00007FF91DFC880F  8B 83 C0 52 01 00           mov     eax, [rbx+152C0h]
00007FF91DFC8815  89 83 D0 52 01 00           mov     [rbx+152D0h], eax
00007FF91DFC881B  8B 83 E0 52 01 00           mov     eax, [rbx+152E0h]
00007FF91DFC8821  89 83 F0 52 01 00           mov     [rbx+152F0h], eax
00007FF91DFC8827  8B 83 00 53 01 00           mov     eax, [rbx+15300h]
00007FF91DFC882D  89 83 10 53 01 00           mov     [rbx+15310h], eax
00007FF91DFC8833  F3 0F 11 A3 50 50 01 00     movss   dword ptr [rbx+15050h], xmm4
00007FF91DFC883B  F3 0F 11 A3 60 50 01 00     movss   dword ptr [rbx+15060h], xmm4
00007FF91DFC8843  F3 0F 58 E4                 addss   xmm4, xmm4
00007FF91DFC8847  F3 0F 10 9B 10 51 01 00     movss   xmm3, dword ptr [rbx+15110h]
00007FF91DFC884F  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFC8852  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC8855  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFC8859  0F 28 EB                    movaps  xmm5, xmm3
00007FF91DFC885C  F3 0F 59 AB 00 52 01 00     mulss   xmm5, dword ptr [rbx+15200h]
00007FF91DFC8864  F3 0F 59 A3 50 51 01 00     mulss   xmm4, dword ptr [rbx+15150h]
00007FF91DFC886C  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC886F  F3 0F 59 83 10 52 01 00     mulss   xmm0, dword ptr [rbx+15210h]
00007FF91DFC8877  F3 0F 58 AB F0 51 01 00     addss   xmm5, dword ptr [rbx+151F0h]
00007FF91DFC887F  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFC8883  F3 0F 59 8B 20 52 01 00     mulss   xmm1, dword ptr [rbx+15220h]
00007FF91DFC888B  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC888F  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFC8892  F3 0F 10 9B A0 50 01 00     movss   xmm3, dword ptr [rbx+150A0h]
00007FF91DFC889A  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFC889E  F2 0F 5F 05 E2 23 62 00     maxsd   xmm0, cs:qword_7FF91E5EAC88
00007FF91DFC88A6  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFC88AA  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFC88AD  F3 0F 59 C9                 mulss   xmm1, xmm1
00007FF91DFC88B1  F3 0F 59 93 A0 51 01 00     mulss   xmm2, dword ptr [rbx+151A0h]
00007FF91DFC88B9  F3 0F 59 8B B0 51 01 00     mulss   xmm1, dword ptr [rbx+151B0h]
00007FF91DFC88C1  F3 0F 58 93 90 51 01 00     addss   xmm2, dword ptr [rbx+15190h]
00007FF91DFC88C9  F3 0F 11 A3 90 50 01 00     movss   dword ptr [rbx+15090h], xmm4
00007FF91DFC88D1  F3 0F 59 9B 70 51 01 00     mulss   xmm3, dword ptr [rbx+15170h]
00007FF91DFC88D9  F3 0F 59 A3 60 51 01 00     mulss   xmm4, dword ptr [rbx+15160h]
00007FF91DFC88E1  F3 0F 10 83 80 51 01 00     movss   xmm0, dword ptr [rbx+15180h]
00007FF91DFC88E9  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC88ED  F3 0F 59 83 B0 50 01 00     mulss   xmm0, dword ptr [rbx+150B0h]
00007FF91DFC88F5  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFC88F9  41 0F 2F D4                 comiss  xmm2, xmm12
00007FF91DFC88FD  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFC8901  73 06                       jnb     short loc_7FF91DFC8909
00007FF91DFC8903  41 0F 28 D4                 movaps  xmm2, xmm12
00007FF91DFC8907  EB 05                       jmp     short loc_7FF91DFC890E
00007FF91DFC8909  F3 41 0F 5D D6              minss   xmm2, xmm14
00007FF91DFC890E  F3 0F 10 83 D0 50 01 00     movss   xmm0, dword ptr [rbx+150D0h]
00007FF91DFC8916  F3 0F 11 9B A0 50 01 00     movss   dword ptr [rbx+150A0h], xmm3
00007FF91DFC891E  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFC8922  F3 0F 59 93 C0 51 01 00     mulss   xmm2, dword ptr [rbx+151C0h]
00007FF91DFC892A  F3 0F 58 93 D0 51 01 00     addss   xmm2, dword ptr [rbx+151D0h]
00007FF91DFC8932  F3 0F 11 9B B0 50 01 00     movss   dword ptr [rbx+150B0h], xmm3
00007FF91DFC893A  F3 0F 10 8B E0 50 01 00     movss   xmm1, dword ptr [rbx+150E0h]
00007FF91DFC8942  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFC8946  F3 0F 59 9B E0 51 01 00     mulss   xmm3, dword ptr [rbx+151E0h]
00007FF91DFC894E  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC8952  F3 0F 11 93 C0 50 01 00     movss   dword ptr [rbx+150C0h], xmm2
00007FF91DFC895A  F3 0F 58 AB 30 52 01 00     addss   xmm5, dword ptr [rbx+15230h]
00007FF91DFC8962  F3 0F 10 B3 30 51 01 00     movss   xmm6, dword ptr [rbx+15130h]
00007FF91DFC896A  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFC896E  F3 0F 5C E9                 subss   xmm5, xmm1
00007FF91DFC8972  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFC8975  F3 0F 59 F5                 mulss   xmm6, xmm5
00007FF91DFC8979  F3 0F 59 83 40 52 01 00     mulss   xmm0, dword ptr [rbx+15240h]
00007FF91DFC8981  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFC8984  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFC8988  F3 0F 11 83 D0 50 01 00     movss   dword ptr [rbx+150D0h], xmm0
00007FF91DFC8990  F3 0F 10 9B F0 50 01 00     movss   xmm3, dword ptr [rbx+150F0h]
00007FF91DFC8998  F3 0F 11 A3 80 52 01 00     movss   dword ptr [rbx+15280h], xmm4
00007FF91DFC89A0  F3 0F 10 83 50 53 01 00     movss   xmm0, dword ptr [rbx+15350h]
00007FF91DFC89A8  F3 0F 10 8B 90 52 01 00     movss   xmm1, dword ptr [rbx+15290h]
00007FF91DFC89B0  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFC89B4  41 0F 2F E4                 comiss  xmm4, xmm12
00007FF91DFC89B8  73 06                       jnb     short loc_7FF91DFC89C0
00007FF91DFC89BA  41 0F 28 E4                 movaps  xmm4, xmm12
00007FF91DFC89BE  EB 05                       jmp     short loc_7FF91DFC89C5
00007FF91DFC89C0  F3 41 0F 5D E6              minss   xmm4, xmm14
00007FF91DFC89C5  F3 0F 59 B3 40 53 01 00     mulss   xmm6, dword ptr [rbx+15340h]
00007FF91DFC89CD  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFC89D0  F3 0F 59 93 30 53 01 00     mulss   xmm2, dword ptr [rbx+15330h]
00007FF91DFC89D8  F3 0F 58 D6                 addss   xmm2, xmm6
00007FF91DFC89DC  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFC89E0  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC89E3  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFC89E7  41 0F 2F D4                 comiss  xmm2, xmm12
00007FF91DFC89EB  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFC89EF  F3 0F 59 A3 60 53 01 00     mulss   xmm4, dword ptr [rbx+15360h]
00007FF91DFC89F7  F3 0F 59 83 70 53 01 00     mulss   xmm0, dword ptr [rbx+15370h]
00007FF91DFC89FF  F3 0F 58 C4                 addss   xmm0, xmm4
00007FF91DFC8A03  F3 0F 11 83 A0 52 01 00     movss   dword ptr [rbx+152A0h], xmm0
00007FF91DFC8A0B  73 06                       jnb     short loc_7FF91DFC8A13
00007FF91DFC8A0D  41 0F 28 D4                 movaps  xmm2, xmm12
00007FF91DFC8A11  EB 05                       jmp     short loc_7FF91DFC8A18
00007FF91DFC8A13  F3 41 0F 5D D6              minss   xmm2, xmm14
00007FF91DFC8A18  F3 0F 58 8B 80 52 01 00     addss   xmm1, dword ptr [rbx+15280h]
00007FF91DFC8A20  F3 0F 10 A3 90 52 01 00     movss   xmm4, dword ptr [rbx+15290h]
00007FF91DFC8A28  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC8A2B  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC8A2F  F3 0F 59 8B 20 53 01 00     mulss   xmm1, dword ptr [rbx+15320h]
00007FF91DFC8A37  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC8A3B  F3 0F 59 93 60 53 01 00     mulss   xmm2, dword ptr [rbx+15360h]
00007FF91DFC8A43  F3 0F 59 83 70 53 01 00     mulss   xmm0, dword ptr [rbx+15370h]
00007FF91DFC8A4B  F3 0F 59 8B 50 53 01 00     mulss   xmm1, dword ptr [rbx+15350h]
00007FF91DFC8A53  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFC8A57  41 0F 2F CC                 comiss  xmm1, xmm12
00007FF91DFC8A5B  F3 0F 11 83 C0 52 01 00     movss   dword ptr [rbx+152C0h], xmm0
00007FF91DFC8A63  73 06                       jnb     short loc_7FF91DFC8A6B
00007FF91DFC8A65  41 0F 28 CC                 movaps  xmm1, xmm12
00007FF91DFC8A69  EB 05                       jmp     short loc_7FF91DFC8A70
00007FF91DFC8A6B  F3 41 0F 5D CE              minss   xmm1, xmm14
00007FF91DFC8A70  F3 0F 10 83 30 53 01 00     movss   xmm0, dword ptr [rbx+15330h]
00007FF91DFC8A78  F3 0F 59 83 80 52 01 00     mulss   xmm0, dword ptr [rbx+15280h]
00007FF91DFC8A80  F3 0F 59 A3 40 53 01 00     mulss   xmm4, dword ptr [rbx+15340h]
00007FF91DFC8A88  F3 0F 10 AB A0 52 01 00     movss   xmm5, dword ptr [rbx+152A0h]
00007FF91DFC8A90  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC8A94  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC8A97  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC8A9B  F3 0F 59 A3 50 53 01 00     mulss   xmm4, dword ptr [rbx+15350h]
00007FF91DFC8AA3  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC8AA7  41 0F 2F E4                 comiss  xmm4, xmm12
00007FF91DFC8AAB  F3 0F 59 83 70 53 01 00     mulss   xmm0, dword ptr [rbx+15370h]
00007FF91DFC8AB3  F3 0F 59 8B 60 53 01 00     mulss   xmm1, dword ptr [rbx+15360h]
00007FF91DFC8ABB  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFC8ABF  F3 0F 11 83 E0 52 01 00     movss   dword ptr [rbx+152E0h], xmm0
00007FF91DFC8AC7  72 09                       jb      short loc_7FF91DFC8AD2
00007FF91DFC8AC9  44 0F 28 E4                 movaps  xmm12, xmm4
00007FF91DFC8ACD  F3 45 0F 5D E6              minss   xmm12, xmm14
00007FF91DFC8AD2  F3 0F 58 AB 10 53 01 00     addss   xmm5, dword ptr [rbx+15310h]
00007FF91DFC8ADA  F3 0F 10 83 90 53 01 00     movss   xmm0, dword ptr [rbx+15390h]
00007FF91DFC8AE2  41 0F 28 D4                 movaps  xmm2, xmm12
00007FF91DFC8AE6  F3 0F 59 83 C0 52 01 00     mulss   xmm0, dword ptr [rbx+152C0h]
00007FF91DFC8AEE  F3 0F 10 8B F0 52 01 00     movss   xmm1, dword ptr [rbx+152F0h]
00007FF91DFC8AF6  F3 0F 59 AB 80 53 01 00     mulss   xmm5, dword ptr [rbx+15380h]
00007FF91DFC8AFE  F3 41 0F 59 D4              mulss   xmm2, xmm12
00007FF91DFC8B03  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC8B07  F3 41 0F 59 D4              mulss   xmm2, xmm12
00007FF91DFC8B0C  F3 44 0F 59 A3 60 53 01 00  mulss   xmm12, dword ptr [rbx+15360h]
00007FF91DFC8B15  F3 0F 59 93 70 53 01 00     mulss   xmm2, dword ptr [rbx+15370h]
00007FF91DFC8B1D  F3 41 0F 58 D4              addss   xmm2, xmm12
00007FF91DFC8B22  F3 0F 11 93 00 53 01 00     movss   dword ptr [rbx+15300h], xmm2
00007FF91DFC8B2A  F3 0F 59 8B 90 53 01 00     mulss   xmm1, dword ptr [rbx+15390h]
00007FF91DFC8B32  F3 0F 58 93 B0 52 01 00     addss   xmm2, dword ptr [rbx+152B0h]
00007FF91DFC8B3A  F3 0F 10 83 E0 52 01 00     movss   xmm0, dword ptr [rbx+152E0h]
00007FF91DFC8B42  F3 0F 58 83 D0 52 01 00     addss   xmm0, dword ptr [rbx+152D0h]
00007FF91DFC8B4A  F3 0F 58 CD                 addss   xmm1, xmm5
00007FF91DFC8B4E  F3 0F 59 93 B0 53 01 00     mulss   xmm2, dword ptr [rbx+153B0h]
00007FF91DFC8B56  F3 0F 59 83 A0 53 01 00     mulss   xmm0, dword ptr [rbx+153A0h]
00007FF91DFC8B5E  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFC8B62  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFC8B66  F3 0F 11 83 E0 50 01 00     movss   dword ptr [rbx+150E0h], xmm0
00007FF91DFC8B6E  F3 0F 59 83 50 52 01 00     mulss   xmm0, dword ptr [rbx+15250h]
00007FF91DFC8B76  F3 0F 59 9B 60 52 01 00     mulss   xmm3, dword ptr [rbx+15260h]
00007FF91DFC8B7E  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFC8B82  F3 0F 10 83 70 52 01 00     movss   xmm0, dword ptr [rbx+15270h]
00007FF91DFC8B8A  F3 0F 59 83 00 51 01 00     mulss   xmm0, dword ptr [rbx+15100h]
00007FF91DFC8B92  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFC8B96  F3 0F 11 9B F0 50 01 00     movss   dword ptr [rbx+150F0h], xmm3
00007FF91DFC8B9E  F3 0F 59 9B 20 51 01 00     mulss   xmm3, dword ptr [rbx+15120h]
00007FF91DFC8BA6  F3 0F 59 9B 30 51 01 00     mulss   xmm3, dword ptr [rbx+15130h]
00007FF91DFC8BAE  F3 0F 11 9B 70 50 01 00     movss   dword ptr [rbx+15070h], xmm3
00007FF91DFC8BB6  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC8BB9  F3 0F 11 9B 80 50 01 00     movss   dword ptr [rbx+15080h], xmm3
00007FF91DFC8BC1  8B 83 E0 53 01 00           mov     eax, [rbx+153E0h]
00007FF91DFC8BC7  89 83 F0 53 01 00           mov     [rbx+153F0h], eax
00007FF91DFC8BCD  8B 83 D0 53 01 00           mov     eax, [rbx+153D0h]
00007FF91DFC8BD3  89 83 E0 53 01 00           mov     [rbx+153E0h], eax
00007FF91DFC8BD9  8B 83 C0 53 01 00           mov     eax, [rbx+153C0h]
00007FF91DFC8BDF  89 83 D0 53 01 00           mov     [rbx+153D0h], eax
00007FF91DFC8BE5  F3 0F 11 9B C0 53 01 00     movss   dword ptr [rbx+153C0h], xmm3
00007FF91DFC8BED  F3 0F 59 83 20 54 01 00     mulss   xmm0, dword ptr [rbx+15420h]
00007FF91DFC8BF5  F3 0F 10 93 D0 53 01 00     movss   xmm2, dword ptr [rbx+153D0h]
00007FF91DFC8BFD  F3 0F 10 8B 40 54 01 00     movss   xmm1, dword ptr [rbx+15440h]
00007FF91DFC8C05  0F 28 EA                    movaps  xmm5, xmm2
00007FF91DFC8C08  F3 0F 59 8B E0 53 01 00     mulss   xmm1, dword ptr [rbx+153E0h]
00007FF91DFC8C10  F3 0F 59 AB 30 54 01 00     mulss   xmm5, dword ptr [rbx+15430h]
00007FF91DFC8C18  F3 0F 59 93 60 54 01 00     mulss   xmm2, dword ptr [rbx+15460h]
00007FF91DFC8C20  F3 0F 10 B3 10 54 01 00     movss   xmm6, dword ptr [rbx+15410h]
00007FF91DFC8C28  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFC8C2C  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFC8C30  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFC8C34  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC8C37  F3 0F 59 83 50 54 01 00     mulss   xmm0, dword ptr [rbx+15450h]
00007FF91DFC8C3F  F3 0F 10 8B 70 54 01 00     movss   xmm1, dword ptr [rbx+15470h]
00007FF91DFC8C47  F3 0F 59 8B F0 53 01 00     mulss   xmm1, dword ptr [rbx+153F0h]
00007FF91DFC8C4F  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC8C53  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC8C57  76 05                       jbe     short loc_7FF91DFC8C5E
00007FF91DFC8C59  0F 5A C6                    cvtps2pd xmm0, xmm6
00007FF91DFC8C5C  EB 04                       jmp     short loc_7FF91DFC8C62
00007FF91DFC8C5E  41 0F 28 C7                 movaps  xmm0, xmm15
00007FF91DFC8C62  0F 2F 35 57 C8 77 00        comiss  xmm6, cs:dword_7FF91E7454C0
00007FF91DFC8C69  F2 0F 5A C0                 cvtsd2ss xmm0, xmm0
00007FF91DFC8C6D  F3 0F 11 AB D0 53 01 00     movss   dword ptr [rbx+153D0h], xmm5
00007FF91DFC8C75  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFC8C78  F3 0F 11 93 E0 53 01 00     movss   dword ptr [rbx+153E0h], xmm2
00007FF91DFC8C80  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFC8C84  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFC8C88  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFC8C8C  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFC8C8F  0F 57 05 2A CB 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFC8C96  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFC8C9A  73 09                       jnb     short loc_7FF91DFC8CA5
00007FF91DFC8C9C  45 0F 57 FF                 xorps   xmm15, xmm15
00007FF91DFC8CA0  F3 44 0F 5A F8              cvtss2sd xmm15, xmm0
00007FF91DFC8CA5  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFC8CA9  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC8CAC  F2 41 0F 5A C7              cvtsd2ss xmm0, xmm15
00007FF91DFC8CB1  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFC8CB4  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFC8CB8  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFC8CBC  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC8CC0  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFC8CC4  72 03                       jb      short loc_7FF91DFC8CC9
00007FF91DFC8CC6  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFC8CC9  F3 0F 11 9B 00 54 01 00     movss   dword ptr [rbx+15400h], xmm3
00007FF91DFC8CD1  F3 0F 11 9B C0 4A 01 00     movss   dword ptr [rbx+14AC0h], xmm3
00007FF91DFC8CD9  F3 0F 10 83 00 54 01 00     movss   xmm0, dword ptr [rbx+15400h]
00007FF91DFC8CE1  F3 0F 11 83 E0 4A 01 00     movss   dword ptr [rbx+14AE0h], xmm0
00007FF91DFC8CE9  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
00007FF91DFC8CF1  F3 0F 10 83 90 8B 01 00     movss   xmm0, dword ptr [rbx+18B90h]
00007FF91DFC8CF9  48 8B 07                    mov     rax, [rdi]
00007FF91DFC8CFC  F3 0F 58 C0                 addss   xmm0, xmm0
00007FF91DFC8D00  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
00007FF91DFC8D05  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
00007FF91DFC8D0A  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
00007FF91DFC8D0F  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
00007FF91DFC8D14  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
00007FF91DFC8D19  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
00007FF91DFC8D1E  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
00007FF91DFC8D23  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
00007FF91DFC8D28  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
00007FF91DFC8D2E  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
00007FF91DFC8D34  F3 0F 11 00                 movss   dword ptr [rax], xmm0
00007FF91DFC8D38  F3 0F 10 8B A0 8B 01 00     movss   xmm1, dword ptr [rbx+18BA0h]
00007FF91DFC8D40  48 8B 47 08                 mov     rax, [rdi+8]
00007FF91DFC8D44  F3 0F 58 C9                 addss   xmm1, xmm1
00007FF91DFC8D48  49 8B 5B 18                 mov     rbx, [r11+18h]
00007FF91DFC8D4C  F3 0F 11 08                 movss   dword ptr [rax], xmm1
00007FF91DFC8D50  49 8B E3                    mov     rsp, r11
00007FF91DFC8D53  5F                          pop     rdi
00007FF91DFC8D54  C3                          retn
