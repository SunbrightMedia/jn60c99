; sub_1803C2E00 @ 0x1803C2E00 (RVA 0x3C2E00) size=0x60

00000001803C2E00  80 79 1C 00                 cmp     byte ptr [rcx+1Ch], 0
00000001803C2E04  74 57                       jz      short loc_1803C2E5D
00000001803C2E06  FF 41 24                    inc     dword ptr [rcx+24h]
00000001803C2E09  8B 41 24                    mov     eax, [rcx+24h]
00000001803C2E0C  3B 41 20                    cmp     eax, [rcx+20h]
00000001803C2E0F  7C 3A                       jl      short loc_1803C2E4B
00000001803C2E11  F3 0F 10 41 08              movss   xmm0, dword ptr [rcx+8]
00000001803C2E16  33 D2                       xor     edx, edx
00000001803C2E18  F3 0F 58 41 0C              addss   xmm0, dword ptr [rcx+0Ch]
00000001803C2E1D  48 8B 01                    mov     rax, [rcx]
00000001803C2E20  89 51 24                    mov     [rcx+24h], edx
00000001803C2E23  F3 0F 11 41 0C              movss   dword ptr [rcx+0Ch], xmm0
00000001803C2E28  F3 0F 58 41 10              addss   xmm0, dword ptr [rcx+10h]
00000001803C2E2D  F3 0F 11 00                 movss   dword ptr [rax], xmm0
00000001803C2E31  0F 57 C0                    xorps   xmm0, xmm0
00000001803C2E34  0F 2F 41 08                 comiss  xmm0, dword ptr [rcx+8]
00000001803C2E38  48 8B 01                    mov     rax, [rcx]
00000001803C2E3B  F3 0F 10 10                 movss   xmm2, dword ptr [rax]
00000001803C2E3F  F3 0F 10 49 14              movss   xmm1, dword ptr [rcx+14h]
00000001803C2E44  73 08                       jnb     short loc_1803C2E4E
00000001803C2E46  0F 2F D1                    comiss  xmm2, xmm1
00000001803C2E49  73 08                       jnb     short loc_1803C2E53
00000001803C2E4B  B0 01                       mov     al, 1
00000001803C2E4D  C3                          retn
00000001803C2E4E  0F 2F D1                    comiss  xmm2, xmm1
00000001803C2E51  77 F8                       ja      short loc_1803C2E4B
00000001803C2E53  F3 0F 11 08                 movss   dword ptr [rax], xmm1
00000001803C2E57  89 51 0C                    mov     [rcx+0Ch], edx
00000001803C2E5A  88 51 1C                    mov     [rcx+1Ch], dl
00000001803C2E5D  32 C0                       xor     al, al
00000001803C2E5F  C3                          retn
