; sub_7FF91DFAB2A0 @ rva 0x34B2A0

00007FF91DFAB2A0  40 57                       push    rdi
00007FF91DFAB2A2  48 83 EC 20                 sub     rsp, 20h
00007FF91DFAB2A6  F0 0F BA 29 1F              lock bts dword ptr [rcx], 1Fh
00007FF91DFAB2AB  48 8B F9                    mov     rdi, rcx
00007FF91DFAB2AE  0F 83 9B 00 00 00           jnb     loc_7FF91DFAB34F
00007FF91DFAB2B4  8B 11                       mov     edx, [rcx]
00007FF91DFAB2B6  48 89 5C 24 30              mov     [rsp+28h+arg_0], rbx
00007FF91DFAB2BB  0F 1F 44 00 00              nop     dword ptr [rax+rax+00h]
00007FF91DFAB2C0  8B CA                       mov     ecx, edx
00007FF91DFAB2C2  8D 5A 01                    lea     ebx, [rdx+1]
00007FF91DFAB2C5  8B C2                       mov     eax, edx
00007FF91DFAB2C7  C1 E9 1F                    shr     ecx, 1Fh
00007FF91DFAB2CA  0D 00 00 00 80              or      eax, 80000000h
00007FF91DFAB2CF  84 C9                       test    cl, cl
00007FF91DFAB2D1  0F 44 D8                    cmovz   ebx, eax
00007FF91DFAB2D4  8B C2                       mov     eax, edx
00007FF91DFAB2D6  F0 0F B1 1F                 lock cmpxchg [rdi], ebx
00007FF91DFAB2DA  74 04                       jz      short loc_7FF91DFAB2E0
00007FF91DFAB2DC  8B D0                       mov     edx, eax
00007FF91DFAB2DE  EB E0                       jmp     short loc_7FF91DFAB2C0
00007FF91DFAB2E0  84 C9                       test    cl, cl
00007FF91DFAB2E2  0F 44 DA                    cmovz   ebx, edx
00007FF91DFAB2E5  85 DB                       test    ebx, ebx
00007FF91DFAB2E7  79 61                       jns     short loc_7FF91DFAB34A
00007FF91DFAB2E9  48 8B CF                    mov     rcx, rdi
00007FF91DFAB2EC  48 89 74 24 38              mov     [rsp+28h+arg_8], rsi
00007FF91DFAB2F1  E8 3A B5 FB FF              call    sub_7FF91DF66830
00007FF91DFAB2F6  48 8B F0                    mov     rsi, rax
00007FF91DFAB2F9  0F 1F 80 00 00 00 00        nop     dword ptr [rax+00000000h]
00007FF91DFAB300  45 33 C0                    xor     r8d, r8d; bAlertable
00007FF91DFAB303  BA FF FF FF FF              mov     edx, 0FFFFFFFFh; dwMilliseconds
00007FF91DFAB308  48 8B CE                    mov     rcx, rsi; hHandle
00007FF91DFAB30B  FF 15 27 96 5E 00           call    cs:__imp_WaitForSingleObjectEx
00007FF91DFAB311  85 C0                       test    eax, eax
00007FF91DFAB313  75 2C                       jnz     short loc_7FF91DFAB341
00007FF91DFAB315  81 E3 FF FF FF 3F           and     ebx, 3FFFFFFFh
00007FF91DFAB31B  0F BA EB 1E                 bts     ebx, 1Eh
00007FF91DFAB31F  90                          nop
00007FF91DFAB320  85 DB                       test    ebx, ebx
00007FF91DFAB322  79 04                       jns     short loc_7FF91DFAB328
00007FF91DFAB324  8B CB                       mov     ecx, ebx
00007FF91DFAB326  EB 09                       jmp     short loc_7FF91DFAB331
00007FF91DFAB328  8D 4B FF                    lea     ecx, [rbx-1]
00007FF91DFAB32B  81 C9 00 00 00 80           or      ecx, 80000000h
00007FF91DFAB331  0F BA F1 1E                 btr     ecx, 1Eh
00007FF91DFAB335  8B C3                       mov     eax, ebx
00007FF91DFAB337  F0 0F B1 0F                 lock cmpxchg [rdi], ecx
00007FF91DFAB33B  74 04                       jz      short loc_7FF91DFAB341
00007FF91DFAB33D  8B D8                       mov     ebx, eax
00007FF91DFAB33F  EB DF                       jmp     short loc_7FF91DFAB320
00007FF91DFAB341  85 DB                       test    ebx, ebx
00007FF91DFAB343  78 BB                       js      short loc_7FF91DFAB300
00007FF91DFAB345  48 8B 74 24 38              mov     rsi, [rsp+28h+arg_8]
00007FF91DFAB34A  48 8B 5C 24 30              mov     rbx, [rsp+28h+arg_0]
00007FF91DFAB34F  48 83 C4 20                 add     rsp, 20h
00007FF91DFAB353  5F                          pop     rdi
00007FF91DFAB354  C3                          retn
