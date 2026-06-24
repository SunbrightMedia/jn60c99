; sub_7FF91E022E00 @ rva 0x3C2E00

00007FF91E022E00  80 79 1C 00                 cmp     byte ptr [rcx+1Ch], 0
00007FF91E022E04  74 57                       jz      short loc_7FF91E022E5D
00007FF91E022E06  FF 41 24                    inc     dword ptr [rcx+24h]
00007FF91E022E09  8B 41 24                    mov     eax, [rcx+24h]
00007FF91E022E0C  3B 41 20                    cmp     eax, [rcx+20h]
00007FF91E022E0F  7C 3A                       jl      short loc_7FF91E022E4B
00007FF91E022E11  F3 0F 10 41 08              movss   xmm0, dword ptr [rcx+8]
00007FF91E022E16  33 D2                       xor     edx, edx
00007FF91E022E18  F3 0F 58 41 0C              addss   xmm0, dword ptr [rcx+0Ch]
00007FF91E022E1D  48 8B 01                    mov     rax, [rcx]
00007FF91E022E20  89 51 24                    mov     [rcx+24h], edx
00007FF91E022E23  F3 0F 11 41 0C              movss   dword ptr [rcx+0Ch], xmm0
00007FF91E022E28  F3 0F 58 41 10              addss   xmm0, dword ptr [rcx+10h]
00007FF91E022E2D  F3 0F 11 00                 movss   dword ptr [rax], xmm0
00007FF91E022E31  0F 57 C0                    xorps   xmm0, xmm0
00007FF91E022E34  0F 2F 41 08                 comiss  xmm0, dword ptr [rcx+8]
00007FF91E022E38  48 8B 01                    mov     rax, [rcx]
00007FF91E022E3B  F3 0F 10 10                 movss   xmm2, dword ptr [rax]
00007FF91E022E3F  F3 0F 10 49 14              movss   xmm1, dword ptr [rcx+14h]
00007FF91E022E44  73 08                       jnb     short loc_7FF91E022E4E
00007FF91E022E46  0F 2F D1                    comiss  xmm2, xmm1
00007FF91E022E49  73 08                       jnb     short loc_7FF91E022E53
00007FF91E022E4B  B0 01                       mov     al, 1
00007FF91E022E4D  C3                          retn
00007FF91E022E4E  0F 2F D1                    comiss  xmm2, xmm1
00007FF91E022E51  77 F8                       ja      short loc_7FF91E022E4B
00007FF91E022E53  F3 0F 11 08                 movss   dword ptr [rax], xmm1
00007FF91E022E57  89 51 0C                    mov     [rcx+0Ch], edx
00007FF91E022E5A  88 51 1C                    mov     [rcx+1Ch], dl
00007FF91E022E5D  32 C0                       xor     al, al
00007FF91E022E5F  C3                          retn
