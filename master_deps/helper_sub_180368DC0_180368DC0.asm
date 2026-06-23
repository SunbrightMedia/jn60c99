; sub_180368DC0 @ 0x180368DC0 (RVA 0x368DC0)

0000000180368DC0  48 83 EC 68                 sub     rsp, 68h
0000000180368DC4  0F 29 74 24 50              movaps  [rsp+68h+var_18], xmm6
0000000180368DC9  0F 29 7C 24 40              movaps  [rsp+68h+var_28], xmm7
0000000180368DCE  44 0F 29 44 24 30           movaps  [rsp+68h+var_38], xmm8
0000000180368DD4  44 0F 29 4C 24 20           movaps  [rsp+68h+var_48], xmm9
0000000180368DDA  44 0F 29 54 24 10           movaps  [rsp+68h+var_58], xmm10
0000000180368DE0  44 0F 29 1C 24              movaps  [rsp+68h+var_68], xmm11
0000000180368DE5  44 0F 28 D8                 movaps  xmm11, xmm0
0000000180368DE9  F2 44 0F 5F 1D B6 1E 62 00  maxsd   xmm11, cs:qword_18098ACA8
0000000180368DF2  F2 44 0F 5D 1D 95 1E 62 00  minsd   xmm11, cs:qword_18098AC90
0000000180368DFB  41 0F 28 CB                 movaps  xmm1, xmm11
0000000180368DFF  41 0F 28 C3                 movaps  xmm0, xmm11
0000000180368E03  F2 0F 58 05 5D C4 77 00     addsd   xmm0, cs:qword_180AE5268
0000000180368E0B  F2 41 0F 59 CB              mulsd   xmm1, xmm11
0000000180368E10  F2 0F 2C C0                 cvttsd2si eax, xmm0
0000000180368E14  0F 28 D1                    movaps  xmm2, xmm1
0000000180368E17  41 0F 28 C3                 movaps  xmm0, xmm11
0000000180368E1B  48 63 C8                    movsxd  rcx, eax
0000000180368E1E  F2 41 0F 59 D3              mulsd   xmm2, xmm11
0000000180368E23  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
0000000180368E2A  0F 28 DA                    movaps  xmm3, xmm2
0000000180368E2D  F2 41 0F 59 DB              mulsd   xmm3, xmm11
0000000180368E32  48 8D 0D A7 06 62 00        lea     rcx, unk_1809894E0
0000000180368E39  48 03 C1                    add     rax, rcx
0000000180368E3C  0F 28 E3                    movaps  xmm4, xmm3
0000000180368E3F  F2 41 0F 59 E3              mulsd   xmm4, xmm11
0000000180368E44  F2 0F 59 40 10              mulsd   xmm0, qword ptr [rax+10h]
0000000180368E49  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
0000000180368E4E  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
0000000180368E53  0F 28 EC                    movaps  xmm5, xmm4
0000000180368E56  F2 0F 58 00                 addsd   xmm0, qword ptr [rax]
0000000180368E5A  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
0000000180368E5F  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
0000000180368E64  F2 0F 58 C1                 addsd   xmm0, xmm1
0000000180368E68  F2 41 0F 59 EB              mulsd   xmm5, xmm11
0000000180368E6D  F2 0F 58 C2                 addsd   xmm0, xmm2
0000000180368E71  0F 28 F5                    movaps  xmm6, xmm5
0000000180368E74  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
0000000180368E79  F2 41 0F 59 F3              mulsd   xmm6, xmm11
0000000180368E7E  F2 0F 58 C3                 addsd   xmm0, xmm3
0000000180368E82  0F 28 FE                    movaps  xmm7, xmm6
0000000180368E85  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
0000000180368E8A  F2 0F 58 C4                 addsd   xmm0, xmm4
0000000180368E8E  F2 41 0F 59 FB              mulsd   xmm7, xmm11
0000000180368E93  F2 0F 58 C5                 addsd   xmm0, xmm5
0000000180368E97  44 0F 28 C7                 movaps  xmm8, xmm7
0000000180368E9B  F2 0F 59 B8 80 00 00 00     mulsd   xmm7, qword ptr [rax+80h]
0000000180368EA3  F2 45 0F 59 C3              mulsd   xmm8, xmm11
0000000180368EA8  F2 0F 58 C6                 addsd   xmm0, xmm6
0000000180368EAC  0F 28 74 24 50              movaps  xmm6, [rsp+68h+var_18]
0000000180368EB1  45 0F 28 C8                 movaps  xmm9, xmm8
0000000180368EB5  F2 44 0F 59 80 90 00 00 00  mulsd   xmm8, qword ptr [rax+90h]
0000000180368EBE  F2 0F 58 C7                 addsd   xmm0, xmm7
0000000180368EC2  F2 45 0F 59 CB              mulsd   xmm9, xmm11
0000000180368EC7  0F 28 7C 24 40              movaps  xmm7, [rsp+68h+var_28]
0000000180368ECC  45 0F 28 D1                 movaps  xmm10, xmm9
0000000180368ED0  F2 41 0F 58 C0              addsd   xmm0, xmm8
0000000180368ED5  F2 44 0F 59 88 A0 00 00 00  mulsd   xmm9, qword ptr [rax+0A0h]
0000000180368EDE  44 0F 28 44 24 30           movaps  xmm8, [rsp+68h+var_38]
0000000180368EE4  F2 45 0F 59 D3              mulsd   xmm10, xmm11
0000000180368EE9  F2 41 0F 58 C1              addsd   xmm0, xmm9
0000000180368EEE  44 0F 28 4C 24 20           movaps  xmm9, [rsp+68h+var_48]
0000000180368EF4  41 0F 28 CA                 movaps  xmm1, xmm10
0000000180368EF8  F2 45 0F 59 D3              mulsd   xmm10, xmm11
0000000180368EFD  F2 0F 59 88 B0 00 00 00     mulsd   xmm1, qword ptr [rax+0B0h]
0000000180368F05  44 0F 28 1C 24              movaps  xmm11, [rsp+68h+var_68]
0000000180368F0A  F2 44 0F 59 90 C0 00 00 00  mulsd   xmm10, qword ptr [rax+0C0h]
0000000180368F13  F2 0F 58 C1                 addsd   xmm0, xmm1
0000000180368F17  F2 41 0F 58 C2              addsd   xmm0, xmm10
0000000180368F1C  44 0F 28 54 24 10           movaps  xmm10, [rsp+68h+var_58]
0000000180368F22  48 83 C4 68                 add     rsp, 68h
0000000180368F26  C3                          retn
