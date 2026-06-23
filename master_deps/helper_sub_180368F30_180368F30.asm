; sub_180368F30 @ 0x180368F30 (RVA 0x368F30)

0000000180368F30  48 83 EC 38                 sub     rsp, 38h
0000000180368F34  0F 29 74 24 20              movaps  [rsp+38h+var_18], xmm6
0000000180368F39  F3 0F 10 35 73 C1 77 00     movss   xmm6, cs:dword_180AE50B4
0000000180368F41  0F 2F C6                    comiss  xmm0, xmm6
0000000180368F44  76 1F                       jbe     short loc_180368F65
0000000180368F46  F3 0F 10 0D 9A C2 77 00     movss   xmm1, cs:flt_180AE51E8; Y
0000000180368F4E  F3 0F 58 C6                 addss   xmm0, xmm6; X
0000000180368F52  E8 81 65 38 00              call    fmodf
0000000180368F57  F3 0F 5C C6                 subss   xmm0, xmm6
0000000180368F5B  0F 28 74 24 20              movaps  xmm6, [rsp+38h+var_18]
0000000180368F60  48 83 C4 38                 add     rsp, 38h
0000000180368F64  C3                          retn
0000000180368F65  0F 2F 05 78 C5 77 00        comiss  xmm0, cs:dword_180AE54E4
0000000180368F6C  73 15                       jnb     short loc_180368F83
0000000180368F6E  F3 0F 10 0D 72 C2 77 00     movss   xmm1, cs:flt_180AE51E8; Y
0000000180368F76  F3 0F 5C C6                 subss   xmm0, xmm6; X
0000000180368F7A  E8 59 65 38 00              call    fmodf
0000000180368F7F  F3 0F 58 C6                 addss   xmm0, xmm6
0000000180368F83  0F 28 74 24 20              movaps  xmm6, [rsp+38h+var_18]
0000000180368F88  48 83 C4 38                 add     rsp, 38h
0000000180368F8C  C3                          retn
