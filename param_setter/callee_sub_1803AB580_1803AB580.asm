; sub_1803AB580 @ 0x1803AB580 (RVA 0x3AB580) size=0xAF

00000001803AB580  48 89 5C 24 08              mov     [rsp+arg_0], rbx
00000001803AB585  48 89 74 24 10              mov     [rsp+arg_8], rsi
00000001803AB58A  48 89 7C 24 18              mov     [rsp+arg_10], rdi
00000001803AB58F  41 56                       push    r14
00000001803AB591  48 83 EC 20                 sub     rsp, 20h
00000001803AB595  48 8B D9                    mov     rbx, rcx
00000001803AB598  49 8B F1                    mov     rsi, r9
00000001803AB59B  48 8B 09                    mov     rcx, [rcx]
00000001803AB59E  4D 8B F0                    mov     r14, r8
00000001803AB5A1  48 8B FA                    mov     rdi, rdx
00000001803AB5A4  48 85 C9                    test    rcx, rcx
00000001803AB5A7  74 50                       jz      short loc_1803AB5F9
00000001803AB5A9  4C 8B 53 10                 mov     r10, [rbx+10h]
00000001803AB5AD  48 B8 67 66 66 66 66 66 66 66  mov     rax, 6666666666666667h
00000001803AB5B7  4C 2B D1                    sub     r10, rcx
00000001803AB5BA  49 F7 EA                    imul    r10
00000001803AB5BD  48 C1 FA 04                 sar     rdx, 4
00000001803AB5C1  48 8B C2                    mov     rax, rdx
00000001803AB5C4  48 C1 E8 3F                 shr     rax, 3Fh
00000001803AB5C8  48 03 D0                    add     rdx, rax
00000001803AB5CB  48 8D 14 92                 lea     rdx, [rdx+rdx*4]
00000001803AB5CF  48 C1 E2 03                 shl     rdx, 3
00000001803AB5D3  48 81 FA 00 10 00 00        cmp     rdx, 1000h
00000001803AB5DA  72 18                       jb      short loc_1803AB5F4
00000001803AB5DC  4C 8B 41 F8                 mov     r8, [rcx-8]
00000001803AB5E0  48 83 C2 27                 add     rdx, 27h ; '''
00000001803AB5E4  49 2B C8                    sub     rcx, r8
00000001803AB5E7  48 8D 41 F8                 lea     rax, [rcx-8]
00000001803AB5EB  48 83 F8 1F                 cmp     rax, 1Fh
00000001803AB5EF  77 39                       ja      short loc_1803AB62A
00000001803AB5F1  49 8B C8                    mov     rcx, r8; Block
00000001803AB5F4  E8 6F 9C 2C 00              call    j_j_free
00000001803AB5F9  48 89 3B                    mov     [rbx], rdi
00000001803AB5FC  4B 8D 04 B6                 lea     rax, [r14+r14*4]
00000001803AB600  48 8D 0C C7                 lea     rcx, [rdi+rax*8]
00000001803AB604  48 89 4B 08                 mov     [rbx+8], rcx
00000001803AB608  48 8D 04 B6                 lea     rax, [rsi+rsi*4]
00000001803AB60C  48 8B 74 24 38              mov     rsi, [rsp+28h+arg_8]
00000001803AB611  48 8D 0C C7                 lea     rcx, [rdi+rax*8]
00000001803AB615  48 8B 7C 24 40              mov     rdi, [rsp+28h+arg_10]
00000001803AB61A  48 89 4B 10                 mov     [rbx+10h], rcx
00000001803AB61E  48 8B 5C 24 30              mov     rbx, [rsp+28h+arg_0]
00000001803AB623  48 83 C4 20                 add     rsp, 20h
00000001803AB627  41 5E                       pop     r14
00000001803AB629  C3                          retn
00000001803AB62A  E8 3D 0C 31 00              call    _invalid_parameter_noinfo_noreturn
