; sub_7FF91E027400 @ rva 0x3C7400

00007FF91E027400  40 55                       push    rbp
00007FF91E027402  56                          push    rsi
00007FF91E027403  57                          push    rdi
00007FF91E027404  41 54                       push    r12
00007FF91E027406  41 55                       push    r13
00007FF91E027408  41 56                       push    r14
00007FF91E02740A  41 57                       push    r15
00007FF91E02740C  48 8D 6C 24 90              lea     rbp, [rsp-70h]
00007FF91E027411  48 81 EC 70 01 00 00        sub     rsp, 170h
00007FF91E027418  48 C7 45 80 FE FF FF FF     mov     [rbp+0A0h+var_120], 0FFFFFFFFFFFFFFFEh
00007FF91E027420  48 89 9C 24 B8 01 00 00     mov     [rsp+1A0h+arg_8], rbx
00007FF91E027428  48 8B 05 C9 DA 8C 00        mov     rax, cs:__security_cookie
00007FF91E02742F  48 33 C4                    xor     rax, rsp
00007FF91E027432  48 89 45 60                 mov     [rbp+0A0h+var_40], rax
00007FF91E027436  4C 89 4C 24 48              mov     [rsp+1A0h+var_158], r9
00007FF91E02743B  4C 8B F9                    mov     r15, rcx
00007FF91E02743E  48 89 4C 24 28              mov     [rsp+1A0h+var_178], rcx
00007FF91E027443  48 83 C1 40                 add     rcx, 40h ; '@'
00007FF91E027447  48 89 4C 24 40              mov     [rsp+1A0h+var_160], rcx
00007FF91E02744C  E8 4F 3E F8 FF              call    sub_7FF91DFAB2A0
00007FF91E027451  90                          nop
00007FF91E027452  33 DB                       xor     ebx, ebx
00007FF91E027454  8B C3                       mov     eax, ebx
00007FF91E027456  89 5C 24 20                 mov     [rsp+1A0h+var_180], ebx
00007FF91E02745A  48 63 B5 D8 00 00 00        movsxd  rsi, [rbp+0A0h+arg_28]
00007FF91E027461  49 8D 9F 90 02 00 00        lea     rbx, [r15+290h]
00007FF91E027468  49 8D 4F 68                 lea     rcx, [r15+68h]
00007FF91E02746C  48 89 4C 24 38              mov     [rsp+1A0h+var_168], rcx
00007FF91E027471  4D 8D AF B8 04 00 00        lea     r13, [r15+4B8h]
00007FF91E027478  0F 1F 84 00 00 00 00 00     nop     dword ptr [rax+rax+00000000h]
00007FF91E027480  4D 8D 75 E8                 lea     r14, [r13-18h]
00007FF91E027484  4C 8B E3                    mov     r12, rbx
00007FF91E027487  48 98                       cdqe
00007FF91E027489  48 8D 0C 40                 lea     rcx, [rax+rax*2]
00007FF91E02748D  48 C1 E1 04                 shl     rcx, 4
00007FF91E027491  49 8D BF 90 02 00 00        lea     rdi, [r15+290h]
00007FF91E027498  48 03 F9                    add     rdi, rcx
00007FF91E02749B  41 BF 02 00 00 00           mov     r15d, 2
00007FF91E0274A1  4C 8B C7                    mov     r8, rdi
00007FF91E0274A4  48 8B D6                    mov     rdx, rsi
00007FF91E0274A7  48 8B CF                    mov     rcx, rdi
00007FF91E0274AA  E8 81 C3 F7 FF              call    sub_7FF91DFA3830
00007FF91E0274AF  49 8B 04 24                 mov     rax, [r12]
00007FF91E0274B3  49 89 06                    mov     [r14], rax
00007FF91E0274B6  48 83 C7 18                 add     rdi, 18h
00007FF91E0274BA  49 83 C4 18                 add     r12, 18h
00007FF91E0274BE  4D 8D 76 08                 lea     r14, [r14+8]
00007FF91E0274C2  49 83 EF 01                 sub     r15, 1
00007FF91E0274C6  75 D9                       jnz     short loc_7FF91E0274A1
00007FF91E0274C8  8B 85 D8 00 00 00           mov     eax, [rbp+0A0h+arg_28]
00007FF91E0274CE  41 89 45 F8                 mov     [r13-8], eax
00007FF91E0274D2  48 8B 7C 24 38              mov     rdi, [rsp+1A0h+var_168]
00007FF91E0274D7  48 8B 3F                    mov     rdi, [rdi]
00007FF91E0274DA  4C 8B 7C 24 28              mov     r15, [rsp+1A0h+var_178]
00007FF91E0274DF  45 8B 77 38                 mov     r14d, [r15+38h]
00007FF91E0274E3  48 8B 07                    mov     rax, [rdi]
00007FF91E0274E6  48 8B CF                    mov     rcx, rdi
00007FF91E0274E9  FF 90 88 00 00 00           call    qword ptr [rax+88h]
00007FF91E0274EF  41 3B C6                    cmp     eax, r14d
00007FF91E0274F2  74 0F                       jz      short loc_7FF91E027503
00007FF91E0274F4  48 8B 07                    mov     rax, [rdi]
00007FF91E0274F7  41 8B D6                    mov     edx, r14d
00007FF91E0274FA  48 8B CF                    mov     rcx, rdi
00007FF91E0274FD  FF 90 80 00 00 00           call    qword ptr [rax+80h]
00007FF91E027503  44 8B B5 D8 00 00 00        mov     r14d, [rbp+0A0h+arg_28]
00007FF91E02750A  41 8B D6                    mov     edx, r14d
00007FF91E02750D  48 8B CF                    mov     rcx, rdi
00007FF91E027510  E8 9B E5 F8 FF              call    sub_7FF91DFB5AB0
00007FF91E027515  8B 44 24 20                 mov     eax, [rsp+1A0h+var_180]
00007FF91E027519  41 3B 47 38                 cmp     eax, [r15+38h]
00007FF91E02751D  7D 52                       jge     short loc_7FF91E027571
00007FF91E02751F  49 8B CD                    mov     rcx, r13
00007FF91E027522  E8 79 3D F8 FF              call    sub_7FF91DFAB2A0
00007FF91E027527  41 C7 45 FC 01 00 00 00     mov     dword ptr [r13-4], 1
00007FF91E02752F  49 8D 4D 10                 lea     rcx, [r13+10h]
00007FF91E027533  E8 08 0F 00 00              call    sub_7FF91E028440
00007FF91E027538  90                          nop
00007FF91E027539  B8 00 00 00 80              mov     eax, 80000000h
00007FF91E02753E  F0 41 0F C1 45 00           lock xadd [r13+0], eax
00007FF91E027544  0F BA E0 1E                 bt      eax, 1Eh
00007FF91E027548  72 22                       jb      short loc_7FF91E02756C
00007FF91E02754A  3D 00 00 00 80              cmp     eax, 80000000h
00007FF91E02754F  7E 1B                       jle     short loc_7FF91E02756C
00007FF91E027551  F0 41 0F BA 6D 00 1E        lock bts dword ptr [r13+0], 1Eh
00007FF91E027558  72 12                       jb      short loc_7FF91E02756C
00007FF91E02755A  49 8B CD                    mov     rcx, r13
00007FF91E02755D  E8 CE F2 F3 FF              call    sub_7FF91DF66830
00007FF91E027562  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E027565  FF 15 85 D2 56 00           call    cs:__imp_SetEvent
00007FF91E02756B  90                          nop
00007FF91E02756C  E9 7B 01 00 00              jmp     loc_7FF91E0276EC
00007FF91E027571  45 33 C0                    xor     r8d, r8d
00007FF91E027574  45 8B F8                    mov     r15d, r8d
00007FF91E027577  66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
00007FF91E027580  48 8B 53 08                 mov     rdx, [rbx+8]
00007FF91E027584  48 8B 3B                    mov     rdi, [rbx]
00007FF91E027587  4C 8B CA                    mov     r9, rdx
00007FF91E02758A  4C 2B CF                    sub     r9, rdi
00007FF91E02758D  49 C1 F9 02                 sar     r9, 2
00007FF91E027591  48 8B 4B 10                 mov     rcx, [rbx+10h]
00007FF91E027595  48 2B CF                    sub     rcx, rdi
00007FF91E027598  48 C1 F9 02                 sar     rcx, 2
00007FF91E02759C  48 3B F1                    cmp     rsi, rcx
00007FF91E02759F  0F 86 C5 00 00 00           jbe     loc_7FF91E02766A
00007FF91E0275A5  49 B9 FF FF FF FF FF FF FF 3F  mov     r9, 3FFFFFFFFFFFFFFFh
00007FF91E0275AF  49 3B F1                    cmp     rsi, r9
00007FF91E0275B2  0F 87 33 04 00 00           ja      loc_7FF91E0279EB
00007FF91E0275B8  48 8B D1                    mov     rdx, rcx
00007FF91E0275BB  48 D1 EA                    shr     rdx, 1
00007FF91E0275BE  49 8B C1                    mov     rax, r9
00007FF91E0275C1  48 2B C2                    sub     rax, rdx
00007FF91E0275C4  48 3B C8                    cmp     rcx, rax
00007FF91E0275C7  76 05                       jbe     short loc_7FF91E0275CE
00007FF91E0275C9  4C 8B F6                    mov     r14, rsi
00007FF91E0275CC  EB 0B                       jmp     short loc_7FF91E0275D9
00007FF91E0275CE  4C 8D 34 0A                 lea     r14, [rdx+rcx]
00007FF91E0275D2  4C 3B F6                    cmp     r14, rsi
00007FF91E0275D5  4C 0F 42 F6                 cmovb   r14, rsi
00007FF91E0275D9  48 85 FF                    test    rdi, rdi
00007FF91E0275DC  74 42                       jz      short loc_7FF91E027620
00007FF91E0275DE  48 8D 14 8D 00 00 00 00     lea     rdx, ds:0[rcx*4]
00007FF91E0275E6  48 81 FA 00 10 00 00        cmp     rdx, 1000h
00007FF91E0275ED  72 1C                       jb      short loc_7FF91E02760B
00007FF91E0275EF  48 83 C2 27                 add     rdx, 27h ; '''
00007FF91E0275F3  48 8B 4F F8                 mov     rcx, [rdi-8]
00007FF91E0275F7  48 2B F9                    sub     rdi, rcx
00007FF91E0275FA  48 8D 47 F8                 lea     rax, [rdi-8]
00007FF91E0275FE  48 83 F8 1F                 cmp     rax, 1Fh
00007FF91E027602  0F 87 08 04 00 00           ja      loc_7FF91E027A10
00007FF91E027608  48 8B F9                    mov     rdi, rcx
00007FF91E02760B  48 8B CF                    mov     rcx, rdi; Block
00007FF91E02760E  E8 55 DC 2A 00              call    j_j_free
00007FF91E027613  45 33 C0                    xor     r8d, r8d
00007FF91E027616  49 B9 FF FF FF FF FF FF FF 3F  mov     r9, 3FFFFFFFFFFFFFFFh
00007FF91E027620  4C 89 03                    mov     [rbx], r8
00007FF91E027623  4C 89 43 08                 mov     [rbx+8], r8
00007FF91E027627  4C 89 43 10                 mov     [rbx+10h], r8
00007FF91E02762B  4D 85 F6                    test    r14, r14
00007FF91E02762E  74 26                       jz      short loc_7FF91E027656
00007FF91E027630  4D 3B F1                    cmp     r14, r9
00007FF91E027633  0F 87 DD 03 00 00           ja      loc_7FF91E027A16
00007FF91E027639  49 8B D6                    mov     rdx, r14
00007FF91E02763C  48 8B CB                    mov     rcx, rbx
00007FF91E02763F  E8 3C CE F7 FF              call    sub_7FF91DFA4480
00007FF91E027644  48 89 03                    mov     [rbx], rax
00007FF91E027647  48 89 43 08                 mov     [rbx+8], rax
00007FF91E02764B  48 8B 03                    mov     rax, [rbx]
00007FF91E02764E  4A 8D 0C B0                 lea     rcx, [rax+r14*4]
00007FF91E027652  48 89 4B 10                 mov     [rbx+10h], rcx
00007FF91E027656  48 8B 13                    mov     rdx, [rbx]
00007FF91E027659  48 85 F6                    test    rsi, rsi
00007FF91E02765C  74 67                       jz      short loc_7FF91E0276C5
00007FF91E02765E  48 8B FA                    mov     rdi, rdx
00007FF91E027661  48 8B CE                    mov     rcx, rsi
00007FF91E027664  48 8D 14 B2                 lea     rdx, [rdx+rsi*4]
00007FF91E027668  EB 57                       jmp     short loc_7FF91E0276C1
00007FF91E02766A  49 3B F1                    cmp     rsi, r9
00007FF91E02766D  76 36                       jbe     short loc_7FF91E0276A5
00007FF91E02766F  48 8B CA                    mov     rcx, rdx
00007FF91E027672  48 2B CF                    sub     rcx, rdi
00007FF91E027675  48 83 C1 03                 add     rcx, 3
00007FF91E027679  48 C1 E9 02                 shr     rcx, 2
00007FF91E02767D  48 3B FA                    cmp     rdi, rdx
00007FF91E027680  49 0F 47 C8                 cmova   rcx, r8
00007FF91E027684  48 85 C9                    test    rcx, rcx
00007FF91E027687  74 08                       jz      short loc_7FF91E027691
00007FF91E027689  33 C0                       xor     eax, eax
00007FF91E02768B  F3 AB                       rep stosd
00007FF91E02768D  48 8B 53 08                 mov     rdx, [rbx+8]
00007FF91E027691  4C 8B C6                    mov     r8, rsi
00007FF91E027694  4D 2B C1                    sub     r8, r9
00007FF91E027697  74 2C                       jz      short loc_7FF91E0276C5
00007FF91E027699  48 8B FA                    mov     rdi, rdx
00007FF91E02769C  49 8B C8                    mov     rcx, r8
00007FF91E02769F  4A 8D 14 82                 lea     rdx, [rdx+r8*4]
00007FF91E0276A3  EB 1C                       jmp     short loc_7FF91E0276C1
00007FF91E0276A5  48 8D 14 B7                 lea     rdx, [rdi+rsi*4]
00007FF91E0276A9  48 8D 0C B5 03 00 00 00     lea     rcx, ds:3[rsi*4]
00007FF91E0276B1  48 C1 E9 02                 shr     rcx, 2
00007FF91E0276B5  48 3B FA                    cmp     rdi, rdx
00007FF91E0276B8  49 0F 47 C8                 cmova   rcx, r8
00007FF91E0276BC  48 85 C9                    test    rcx, rcx
00007FF91E0276BF  74 04                       jz      short loc_7FF91E0276C5
00007FF91E0276C1  33 C0                       xor     eax, eax
00007FF91E0276C3  F3 AB                       rep stosd
00007FF91E0276C5  48 89 53 08                 mov     [rbx+8], rdx
00007FF91E0276C9  49 FF C7                    inc     r15
00007FF91E0276CC  48 83 C3 18                 add     rbx, 18h
00007FF91E0276D0  49 83 FF 02                 cmp     r15, 2
00007FF91E0276D4  41 B8 00 00 00 00           mov     r8d, 0
00007FF91E0276DA  0F 8C A0 FE FF FF           jl      loc_7FF91E027580
00007FF91E0276E0  4C 8B 7C 24 28              mov     r15, [rsp+1A0h+var_178]
00007FF91E0276E5  44 8B B5 D8 00 00 00        mov     r14d, [rbp+0A0h+arg_28]
00007FF91E0276EC  8B 44 24 20                 mov     eax, [rsp+1A0h+var_180]
00007FF91E0276F0  FF C0                       inc     eax
00007FF91E0276F2  89 44 24 20                 mov     [rsp+1A0h+var_180], eax
00007FF91E0276F6  49 83 ED 80                 sub     r13, 0FFFFFFFFFFFFFF80h
00007FF91E0276FA  48 83 44 24 38 40           add     [rsp+1A0h+var_168], 40h ; '@'
00007FF91E027700  49 8B DC                    mov     rbx, r12
00007FF91E027703  83 F8 08                    cmp     eax, 8
00007FF91E027706  0F 8C 74 FD FF FF           jl      loc_7FF91E027480
00007FF91E02770C  49 8D 8F 38 04 00 00        lea     rcx, [r15+438h]
00007FF91E027713  48 89 4C 24 50              mov     [rsp+1A0h+var_150], rcx
00007FF91E027718  C6 44 24 58 00              mov     [rsp+1A0h+var_148], 0
00007FF91E02771D  48 85 C9                    test    rcx, rcx
00007FF91E027720  0F 84 CB 02 00 00           jz      loc_7FF91E0279F1
00007FF91E027726  E8 75 3B F8 FF              call    sub_7FF91DFAB2A0
00007FF91E02772B  B1 01                       mov     cl, 1
00007FF91E02772D  88 4C 24 58                 mov     [rsp+1A0h+var_148], cl
00007FF91E027731  41 8B 47 38                 mov     eax, [r15+38h]
00007FF91E027735  41 39 87 30 04 00 00        cmp     [r15+430h], eax
00007FF91E02773C  7D 3F                       jge     short loc_7FF91E02777D
00007FF91E02773E  48 BB FF FF FF FF FF FF FF 7F  mov     rbx, 7FFFFFFFFFFFFFFFh
00007FF91E027748  0F 1F 84 00 00 00 00 00     nop     dword ptr [rax+rax+00000000h]
00007FF91E027750  48 89 5C 24 60              mov     [rsp+1A0h+var_140], rbx
00007FF91E027755  4C 8D 44 24 60              lea     r8, [rsp+1A0h+var_140]
00007FF91E02775A  48 8D 54 24 50              lea     rdx, [rsp+1A0h+var_150]
00007FF91E02775F  49 8D 8F 48 04 00 00        lea     rcx, [r15+448h]
00007FF91E027766  E8 75 DB FF FF              call    sub_7FF91E0252E0
00007FF91E02776B  41 8B 47 38                 mov     eax, [r15+38h]
00007FF91E02776F  41 39 87 30 04 00 00        cmp     [r15+430h], eax
00007FF91E027776  7C D8                       jl      short loc_7FF91E027750
00007FF91E027778  0F B6 4C 24 58              movzx   ecx, [rsp+1A0h+var_148]
00007FF91E02777D  33 DB                       xor     ebx, ebx
00007FF91E02777F  41 89 9F 30 04 00 00        mov     [r15+430h], ebx
00007FF91E027786  84 C9                       test    cl, cl
00007FF91E027788  74 31                       jz      short loc_7FF91E0277BB
00007FF91E02778A  48 8B 4C 24 50              mov     rcx, [rsp+1A0h+var_150]
00007FF91E02778F  B8 00 00 00 80              mov     eax, 80000000h
00007FF91E027794  F0 0F C1 01                 lock xadd [rcx], eax
00007FF91E027798  0F BA E0 1E                 bt      eax, 1Eh
00007FF91E02779C  72 1D                       jb      short loc_7FF91E0277BB
00007FF91E02779E  3D 00 00 00 80              cmp     eax, 80000000h
00007FF91E0277A3  7E 16                       jle     short loc_7FF91E0277BB
00007FF91E0277A5  F0 0F BA 29 1E              lock bts dword ptr [rcx], 1Eh
00007FF91E0277AA  72 0F                       jb      short loc_7FF91E0277BB
00007FF91E0277AC  E8 7F F0 F3 FF              call    sub_7FF91DF66830
00007FF91E0277B1  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E0277B4  FF 15 36 D0 56 00           call    cs:__imp_SetEvent
00007FF91E0277BA  90                          nop
00007FF91E0277BB  B9 00 00 00 80              mov     ecx, 80000000h
00007FF91E0277C0  48 8B 44 24 40              mov     rax, [rsp+1A0h+var_160]
00007FF91E0277C5  F0 0F C1 08                 lock xadd [rax], ecx
00007FF91E0277C9  0F BA E1 1E                 bt      ecx, 1Eh
00007FF91E0277CD  72 28                       jb      short loc_7FF91E0277F7
00007FF91E0277CF  81 F9 00 00 00 80           cmp     ecx, 80000000h
00007FF91E0277D5  7E 20                       jle     short loc_7FF91E0277F7
00007FF91E0277D7  48 8B 44 24 40              mov     rax, [rsp+1A0h+var_160]
00007FF91E0277DC  F0 0F BA 28 1E              lock bts dword ptr [rax], 1Eh
00007FF91E0277E1  72 14                       jb      short loc_7FF91E0277F7
00007FF91E0277E3  48 8B 4C 24 40              mov     rcx, [rsp+1A0h+var_160]
00007FF91E0277E8  E8 43 F0 F3 FF              call    sub_7FF91DF66830
00007FF91E0277ED  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E0277F0  FF 15 FA CF 56 00           call    cs:__imp_SetEvent
00007FF91E0277F6  90                          nop
00007FF91E0277F7  4C 8B 64 24 48              mov     r12, [rsp+1A0h+var_158]
00007FF91E0277FC  45 85 F6                    test    r14d, r14d
00007FF91E0277FF  7E 7A                       jle     short loc_7FF91E02787B
00007FF91E027801  4C 8B 6C 24 28              mov     r13, [rsp+1A0h+var_178]
00007FF91E027806  66 66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
00007FF91E027810  48 8D 55 E8                 lea     rdx, [rbp+0A0h+var_B8]
00007FF91E027814  49 8D BF A8 02 00 00        lea     rdi, [r15+2A8h]
00007FF91E02781B  41 B8 08 00 00 00           mov     r8d, 8
00007FF91E027821  48 8B 4F E8                 mov     rcx, [rdi-18h]
00007FF91E027825  48 03 CB                    add     rcx, rbx
00007FF91E027828  48 89 4A F8                 mov     [rdx-8], rcx
00007FF91E02782C  48 8B 0F                    mov     rcx, [rdi]
00007FF91E02782F  48 03 CB                    add     rcx, rbx
00007FF91E027832  48 89 0A                    mov     [rdx], rcx
00007FF91E027835  48 8D 7F 30                 lea     rdi, [rdi+30h]
00007FF91E027839  48 8D 52 10                 lea     rdx, [rdx+10h]
00007FF91E02783D  49 83 E8 01                 sub     r8, 1
00007FF91E027841  75 DE                       jnz     short loc_7FF91E027821
00007FF91E027843  49 8B 0C 24                 mov     rcx, [r12]
00007FF91E027847  48 03 CB                    add     rcx, rbx
00007FF91E02784A  48 89 4C 24 70              mov     [rsp+1A0h+var_130], rcx
00007FF91E02784F  49 8B 4C 24 08              mov     rcx, [r12+8]
00007FF91E027854  48 03 CB                    add     rcx, rbx
00007FF91E027857  48 89 4C 24 78              mov     [rsp+1A0h+var_128], rcx
00007FF91E02785C  4C 8D 44 24 70              lea     r8, [rsp+1A0h+var_130]
00007FF91E027861  48 8D 55 E0                 lea     rdx, [rbp+0A0h+var_C0]
00007FF91E027865  49 8B 8D 50 02 00 00        mov     rcx, [r13+250h]
00007FF91E02786C  E8 4F 16 FD FF              call    sub_7FF91DFF8EC0
00007FF91E027871  48 83 C3 04                 add     rbx, 4
00007FF91E027875  49 83 EE 01                 sub     r14, 1
00007FF91E027879  75 95                       jnz     short loc_7FF91E027810
00007FF91E02787B  48 C7 44 24 30 00 00 00 00  mov     [rsp+1A0h+var_170], 0
00007FF91E027884  45 33 FF                    xor     r15d, r15d
00007FF91E027887  45 8B C7                    mov     r8d, r15d
00007FF91E02788A  48 8D 54 24 30              lea     rdx, [rsp+1A0h+var_170]
00007FF91E02788F  F3 0F 10 25 F9 DE 71 00     movss   xmm4, dword ptr cs:xmmword_7FF91E745790
00007FF91E027897  49 8B FF                    mov     rdi, r15
00007FF91E02789A  48 83 FE 04                 cmp     rsi, 4
00007FF91E02789E  7C 7A                       jl      short loc_7FF91E02791A
00007FF91E0278A0  F3 0F 10 0A                 movss   xmm1, dword ptr [rdx]
00007FF91E0278A4  4B 8B 04 C4                 mov     rax, [r12+r8*8]
00007FF91E0278A8  48 83 C0 08                 add     rax, 8
00007FF91E0278AC  48 8D 4E FC                 lea     rcx, [rsi-4]
00007FF91E0278B0  48 C1 E9 02                 shr     rcx, 2
00007FF91E0278B4  48 FF C1                    inc     rcx
00007FF91E0278B7  48 8D 3C 8D 00 00 00 00     lea     rdi, ds:0[rcx*4]
00007FF91E0278BF  90                          nop
00007FF91E0278C0  0F 28 C1                    movaps  xmm0, xmm1
00007FF91E0278C3  F3 0F 10 48 F8              movss   xmm1, dword ptr [rax-8]
00007FF91E0278C8  0F 54 CC                    andps   xmm1, xmm4
00007FF91E0278CB  0F 28 D1                    movaps  xmm2, xmm1
00007FF91E0278CE  F3 0F 5F D0                 maxss   xmm2, xmm0
00007FF91E0278D2  F3 0F 10 58 FC              movss   xmm3, dword ptr [rax-4]
00007FF91E0278D7  0F 54 DC                    andps   xmm3, xmm4
00007FF91E0278DA  F3 0F 5F C8                 maxss   xmm1, xmm0
00007FF91E0278DE  0F 2F D3                    comiss  xmm2, xmm3
00007FF91E0278E1  73 06                       jnb     short loc_7FF91E0278E9
00007FF91E0278E3  0F 28 D3                    movaps  xmm2, xmm3
00007FF91E0278E6  0F 28 CB                    movaps  xmm1, xmm3
00007FF91E0278E9  F3 0F 10 00                 movss   xmm0, dword ptr [rax]
00007FF91E0278ED  0F 54 C4                    andps   xmm0, xmm4
00007FF91E0278F0  0F 2F D0                    comiss  xmm2, xmm0
00007FF91E0278F3  73 03                       jnb     short loc_7FF91E0278F8
00007FF91E0278F5  0F 28 C8                    movaps  xmm1, xmm0
00007FF91E0278F8  F3 0F 10 58 04              movss   xmm3, dword ptr [rax+4]
00007FF91E0278FD  0F 54 DC                    andps   xmm3, xmm4
00007FF91E027900  F3 0F 5F D0                 maxss   xmm2, xmm0
00007FF91E027904  0F 2F D3                    comiss  xmm2, xmm3
00007FF91E027907  73 03                       jnb     short loc_7FF91E02790C
00007FF91E027909  0F 28 CB                    movaps  xmm1, xmm3
00007FF91E02790C  48 83 C0 10                 add     rax, 10h
00007FF91E027910  48 83 E9 01                 sub     rcx, 1
00007FF91E027914  75 AA                       jnz     short loc_7FF91E0278C0
00007FF91E027916  F3 0F 11 0A                 movss   dword ptr [rdx], xmm1
00007FF91E02791A  48 3B FE                    cmp     rdi, rsi
00007FF91E02791D  7D 2E                       jge     short loc_7FF91E02794D
00007FF91E02791F  F3 0F 10 0A                 movss   xmm1, dword ptr [rdx]
00007FF91E027923  4B 8B 04 C4                 mov     rax, [r12+r8*8]
00007FF91E027927  48 8D 0C B8                 lea     rcx, [rax+rdi*4]
00007FF91E02792B  48 8B C6                    mov     rax, rsi
00007FF91E02792E  48 2B C7                    sub     rax, rdi
00007FF91E027931  F3 0F 10 01                 movss   xmm0, dword ptr [rcx]
00007FF91E027935  0F 54 C4                    andps   xmm0, xmm4
00007FF91E027938  F3 0F 5F C1                 maxss   xmm0, xmm1
00007FF91E02793C  0F 28 C8                    movaps  xmm1, xmm0
00007FF91E02793F  48 8D 49 04                 lea     rcx, [rcx+4]
00007FF91E027943  48 83 E8 01                 sub     rax, 1
00007FF91E027947  75 E8                       jnz     short loc_7FF91E027931
00007FF91E027949  F3 0F 11 02                 movss   dword ptr [rdx], xmm0
00007FF91E02794D  49 FF C0                    inc     r8
00007FF91E027950  48 83 C2 04                 add     rdx, 4
00007FF91E027954  49 83 F8 02                 cmp     r8, 2
00007FF91E027958  0F 8C 39 FF FF FF           jl      loc_7FF91E027897
00007FF91E02795E  4C 8B 7C 24 28              mov     r15, [rsp+1A0h+var_178]
00007FF91E027963  49 8D 4F 10                 lea     rcx, [r15+10h]
00007FF91E027967  E8 34 39 F8 FF              call    sub_7FF91DFAB2A0
00007FF91E02796C  F3 0F 10 44 24 30           movss   xmm0, dword ptr [rsp+1A0h+var_170]
00007FF91E027972  F3 41 0F 5F 47 20           maxss   xmm0, dword ptr [r15+20h]
00007FF91E027978  F3 41 0F 11 47 20           movss   dword ptr [r15+20h], xmm0
00007FF91E02797E  F3 41 0F 10 4F 24           movss   xmm1, dword ptr [r15+24h]
00007FF91E027984  F3 0F 5F 4C 24 34           maxss   xmm1, dword ptr [rsp+1A0h+var_170+4]
00007FF91E02798A  F3 41 0F 11 4F 24           movss   dword ptr [r15+24h], xmm1
00007FF91E027990  B8 00 00 00 80              mov     eax, 80000000h
00007FF91E027995  F0 41 0F C1 47 10           lock xadd [r15+10h], eax
00007FF91E02799B  0F BA E0 1E                 bt      eax, 1Eh
00007FF91E02799F  72 23                       jb      short loc_7FF91E0279C4
00007FF91E0279A1  3D 00 00 00 80              cmp     eax, 80000000h
00007FF91E0279A6  7E 1C                       jle     short loc_7FF91E0279C4
00007FF91E0279A8  F0 41 0F BA 6F 10 1E        lock bts dword ptr [r15+10h], 1Eh
00007FF91E0279AF  72 13                       jb      short loc_7FF91E0279C4
00007FF91E0279B1  49 8D 4F 10                 lea     rcx, [r15+10h]
00007FF91E0279B5  E8 76 EE F3 FF              call    sub_7FF91DF66830
00007FF91E0279BA  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E0279BD  FF 15 2D CE 56 00           call    cs:__imp_SetEvent
00007FF91E0279C3  90                          nop
00007FF91E0279C4  48 8B 4D 60                 mov     rcx, [rbp+0A0h+var_40]
00007FF91E0279C8  48 33 CC                    xor     rcx, rsp; StackCookie
00007FF91E0279CB  E8 50 E3 2A 00              call    __security_check_cookie
00007FF91E0279D0  48 8B 9C 24 B8 01 00 00     mov     rbx, [rsp+1A0h+arg_8]
00007FF91E0279D8  48 81 C4 70 01 00 00        add     rsp, 170h
00007FF91E0279DF  41 5F                       pop     r15
00007FF91E0279E1  41 5E                       pop     r14
00007FF91E0279E3  41 5D                       pop     r13
00007FF91E0279E5  41 5C                       pop     r12
00007FF91E0279E7  5F                          pop     rdi
00007FF91E0279E8  5E                          pop     rsi
00007FF91E0279E9  5D                          pop     rbp
00007FF91E0279EA  C3                          retn
00007FF91E0279EB  E8 70 CA F7 FF              call    ?_Xlen@?$vector@PEAXV?$allocator@PEAX@std@@@std@@IEBAXXZ_83; std::vector<void *>::_Xlen(void)
00007FF91E0279F0  90                          db 90h
00007FF91E0279F1  4C 8D 05 10 79 61 00        lea     r8, aBoostUniqueLoc; "boost unique_lock has no mutex"
00007FF91E0279F8  BA 01 00 00 00              mov     edx, 1
00007FF91E0279FD  48 8D 4D 90                 lea     rcx, [rbp+0A0h+var_110]
00007FF91E027A01  E8 BA E1 FF FF              call    sub_7FF91E025BC0
00007FF91E027A06  90                          nop
00007FF91E027A07  48 8B C8                    mov     rcx, rax
00007FF91E027A0A  E8 B1 DC FF FF              call    sub_7FF91E0256C0
00007FF91E027A0F  90                          align 10h
00007FF91E027A10  E8 57 48 2F 00              call    _invalid_parameter_noinfo_noreturn
00007FF91E027A15  CC                          align 2
00007FF91E027A16  E8 45 CA F7 FF              call    ?_Xlen@?$vector@PEAXV?$allocator@PEAX@std@@@std@@IEBAXXZ_83; std::vector<void *>::_Xlen(void)
00007FF91E027A1B  CC                          db 0CCh
