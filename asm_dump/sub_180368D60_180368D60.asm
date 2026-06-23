; sub_180368D60  @ 0x180368D60  (RVA 0x368D60)
; prototype: float __fastcall(float)

0000000180368D60  F3 0F 59 05 3C 1F 62 00         mulss   xmm0, cs:dword_18098ACA4
0000000180368D68  F3 0F 2C D0                     cvttss2si edx, xmm0
0000000180368D6C  85 D2                           test    edx, edx
0000000180368D6E  75 07                           jnz     short loc_180368D77
0000000180368D70  BA 01 00 00 00                  mov     edx, 1
0000000180368D75  EB 20                           jmp     short loc_180368D97
0000000180368D77  8B C2                           mov     eax, edx
0000000180368D79  25 00 00 20 00                  and     eax, 200000h
0000000180368D7E  0F BA E2 17                     bt      edx, 17h
0000000180368D82  73 08                           jnb     short loc_180368D8C
0000000180368D84  85 C0                           test    eax, eax
0000000180368D86  75 08                           jnz     short loc_180368D90
0000000180368D88  03 D2                           add     edx, edx
0000000180368D8A  EB 0B                           jmp     short loc_180368D97
0000000180368D8C  85 C0                           test    eax, eax
0000000180368D8E  75 F8                           jnz     short loc_180368D88
0000000180368D90  8D 14 55 01 00 00 00            lea     edx, ds:1[rdx*2]
0000000180368D97  8B C2                           mov     eax, edx
0000000180368D99  8B CA                           mov     ecx, edx
0000000180368D9B  25 FF FF FF 00                  and     eax, 0FFFFFFh
0000000180368DA0  81 CA 00 00 00 FF               or      edx, 0FF000000h
0000000180368DA6  81 E1 00 00 00 01               and     ecx, 1000000h
0000000180368DAC  0F 44 D0                        cmovz   edx, eax
0000000180368DAF  66 0F 6E C2                     movd    xmm0, edx
0000000180368DB3  0F 5B C0                        cvtdq2ps xmm0, xmm0
0000000180368DB6  F3 0F 59 05 B2 1E 62 00         mulss   xmm0, cs:dword_18098AC70
0000000180368DBE  C3                              retn
