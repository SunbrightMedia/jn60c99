; sub_180368F90 @ 0x180368F90 (RVA 0x368F90)

0000000180368F90  48 83 EC 28                 sub     rsp, 28h
0000000180368F94  0F 2F 05 19 C1 77 00        comiss  xmm0, cs:dword_180AE50B4
0000000180368F9B  76 1D                       jbe     short loc_180368FBA
0000000180368F9D  F3 0F 58 05 0F C1 77 00     addss   xmm0, cs:dword_180AE50B4; X
0000000180368FA5  F3 0F 10 0D 3B C2 77 00     movss   xmm1, cs:flt_180AE51E8; Y
0000000180368FAD  E8 26 65 38 00              call    fmodf
0000000180368FB2  F3 0F 5C 05 FA C0 77 00     subss   xmm0, cs:dword_180AE50B4
0000000180368FBA  48 83 C4 28                 add     rsp, 28h
0000000180368FBE  C3                          retn
