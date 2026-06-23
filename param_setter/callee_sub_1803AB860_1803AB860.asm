; sub_1803AB860 @ 0x1803AB860 (RVA 0x3AB860) size=0x74

00000001803AB860  48 83 EC 28                 sub     rsp, 28h
00000001803AB864  48 8D 04 92                 lea     rax, [rdx+rdx*4]
00000001803AB868  48 B9 66 66 66 66 66 66 66 06  mov     rcx, 666666666666666h
00000001803AB872  48 C1 E0 03                 shl     rax, 3
00000001803AB876  49 C7 C0 FF FF FF FF        mov     r8, 0FFFFFFFFFFFFFFFFh
00000001803AB87D  48 3B D1                    cmp     rdx, rcx
00000001803AB880  76 05                       jbe     short loc_1803AB887
00000001803AB882  49 8B C0                    mov     rax, r8
00000001803AB885  EB 08                       jmp     short loc_1803AB88F
00000001803AB887  48 3D 00 10 00 00           cmp     rax, 1000h
00000001803AB88D  72 29                       jb      short loc_1803AB8B8
00000001803AB88F  48 8D 48 27                 lea     rcx, [rax+27h]
00000001803AB893  48 3B C8                    cmp     rcx, rax
00000001803AB896  49 0F 46 C8                 cmovbe  rcx, r8; Size
00000001803AB89A  E8 8D 99 2C 00              call    ??2@YAPEAX_K@Z; operator new(unsigned __int64)
00000001803AB89F  48 8B C8                    mov     rcx, rax
00000001803AB8A2  48 85 C0                    test    rax, rax
00000001803AB8A5  74 27                       jz      short loc_1803AB8CE
00000001803AB8A7  48 83 C0 27                 add     rax, 27h ; '''
00000001803AB8AB  48 83 E0 E0                 and     rax, 0FFFFFFFFFFFFFFE0h
00000001803AB8AF  48 89 48 F8                 mov     [rax-8], rcx
00000001803AB8B3  48 83 C4 28                 add     rsp, 28h
00000001803AB8B7  C3                          retn
00000001803AB8B8  48 85 C0                    test    rax, rax
00000001803AB8BB  74 0C                       jz      short loc_1803AB8C9
00000001803AB8BD  48 8B C8                    mov     rcx, rax; Size
00000001803AB8C0  48 83 C4 28                 add     rsp, 28h
00000001803AB8C4  E9 63 99 2C 00              jmp     ??2@YAPEAX_K@Z; operator new(unsigned __int64)
00000001803AB8C9  48 83 C4 28                 add     rsp, 28h
00000001803AB8CD  C3                          retn
00000001803AB8CE  E8 99 09 31 00              call    _invalid_parameter_noinfo_noreturn
00000001803AB8D3  CC                          db 0CCh
