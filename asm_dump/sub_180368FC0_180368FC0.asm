; sub_180368FC0  @ 0x180368FC0  (RVA 0x368FC0)
; prototype: __m128 __fastcall(double)

0000000180368FC0  48 83 EC 48                     sub     rsp, 48h
0000000180368FC4  0F 29 74 24 30                  movaps  [rsp+48h+var_18], xmm6
0000000180368FC9  F3 0F 10 35 17 C2 77 00         movss   xmm6, cs:flt_180AE51E8
0000000180368FD1  0F 29 7C 24 20                  movaps  [rsp+48h+var_28], xmm7
0000000180368FD6  F3 0F 10 3D D6 C0 77 00         movss   xmm7, cs:dword_180AE50B4
0000000180368FDE  0F 2F C7                        comiss  xmm0, xmm7
0000000180368FE1  76 12                           jbe     short loc_180368FF5
0000000180368FE3  F3 0F 58 C7                     addss   xmm0, xmm7; X
0000000180368FE7  0F 28 CE                        movaps  xmm1, xmm6; Y
0000000180368FEA  E8 E9 64 38 00                  call    fmodf
0000000180368FEF  F3 0F 5C C7                     subss   xmm0, xmm7
0000000180368FF3  EB 19                           jmp     short loc_18036900E
0000000180368FF5  0F 2F 05 E8 C4 77 00            comiss  xmm0, cs:dword_180AE54E4
0000000180368FFC  73 10                           jnb     short loc_18036900E
0000000180368FFE  F3 0F 5C C7                     subss   xmm0, xmm7; X
0000000180369002  0F 28 CE                        movaps  xmm1, xmm6; Y
0000000180369005  E8 CE 64 38 00                  call    fmodf
000000018036900A  F3 0F 58 C7                     addss   xmm0, xmm7
000000018036900E  0F 2F 05 C3 C4 77 00            comiss  xmm0, cs:dword_180AE54D8
0000000180369015  0F 28 C8                        movaps  xmm1, xmm0
0000000180369018  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036901C  73 1B                           jnb     short loc_180369039
000000018036901E  F3 0F 10 05 D2 C4 77 00         movss   xmm0, cs:dword_180AE54F8
0000000180369026  F3 0F 5C C1                     subss   xmm0, xmm1
000000018036902A  0F 28 74 24 30                  movaps  xmm6, [rsp+48h+var_18]
000000018036902F  0F 28 7C 24 20                  movaps  xmm7, [rsp+48h+var_28]
0000000180369034  48 83 C4 48                     add     rsp, 48h
0000000180369038  C3                              retn
0000000180369039  0F 2F 05 CC BF 77 00            comiss  xmm0, cs:dword_180AE500C
0000000180369040  76 16                           jbe     short loc_180369058
0000000180369042  F3 0F 5C F1                     subss   xmm6, xmm1
0000000180369046  0F 28 C6                        movaps  xmm0, xmm6
0000000180369049  0F 28 74 24 30                  movaps  xmm6, [rsp+48h+var_18]
000000018036904E  0F 28 7C 24 20                  movaps  xmm7, [rsp+48h+var_28]
0000000180369053  48 83 C4 48                     add     rsp, 48h
0000000180369057  C3                              retn
0000000180369058  0F 28 74 24 30                  movaps  xmm6, [rsp+48h+var_18]
000000018036905D  0F 28 C1                        movaps  xmm0, xmm1
0000000180369060  0F 28 7C 24 20                  movaps  xmm7, [rsp+48h+var_28]
0000000180369065  48 83 C4 48                     add     rsp, 48h
0000000180369069  C3                              retn
