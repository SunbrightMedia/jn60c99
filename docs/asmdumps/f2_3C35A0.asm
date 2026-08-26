; f2_3C35A0  rva 0x3C35A0  384 bytes  (from the checksummed binary)
3C35A0  48895c2408           mov qword ptr [rsp + 8], rbx
3C35A5  57                   push rdi
3C35A6  440fb699d40f0000     movzx r11d, byte ptr [rcx + 0xfd4]
3C35AE  488bd9               mov rbx, rcx
3C35B1  410fb6c0             movzx eax, r8b
3C35B5  8bfa                 mov edi, edx
3C35B7  41ba7f000000         mov r10d, 0x7f
3C35BD  458bc2               mov r8d, r10d
3C35C0  442bc0               sub r8d, eax
3C35C3  0fb681d30f0000       movzx eax, byte ptr [rcx + 0xfd3]
3C35CA  440fafc0             imul r8d, eax
3C35CE  b81f85eb51           mov eax, 0x51eb851f
3C35D3  41f7e8               imul r8d
3C35D6  c1fa05               sar edx, 5
3C35D9  8bc2                 mov eax, edx
3C35DB  c1e81f               shr eax, 0x1f
3C35DE  03d0                 add edx, eax
3C35E0  410fb6c1             movzx eax, r9b
3C35E4  442ad2               sub r10b, dl
3C35E7  4584db               test r11b, r11b
3C35EA  410fb6ca             movzx ecx, r10b
3C35EE  440f44d8             cmove r11d, eax
3C35F2  410fb6c3             movzx eax, r11b
3C35F6  0fafc8               imul ecx, eax
3C35F9  b811080402           mov eax, 0x2040811
3C35FE  f7e1                 mul ecx
3C3600  b801000000           mov eax, 1
3C3605  2bca                 sub ecx, edx
3C3607  d1e9                 shr ecx, 1
3C3609  03ca                 add ecx, edx
3C360B  400fb6d7             movzx edx, dil
3C360F  c1e906               shr ecx, 6
3C3612  440fb6c1             movzx r8d, cl
3C3616  84c9                 test cl, cl
3C3618  488b8bd80f0000       mov rcx, qword ptr [rbx + 0xfd8]
3C361F  440f44c0             cmove r8d, eax
3C3623  488b01               mov rax, qword ptr [rcx]
3C3626  488b5c2410           mov rbx, qword ptr [rsp + 0x10]
3C362B  5f                   pop rdi
3C362C  48ff6018             jmp qword ptr [rax + 0x18]
3C3630  48895c2408           mov qword ptr [rsp + 8], rbx
3C3635  48896c2410           mov qword ptr [rsp + 0x10], rbp
3C363A  4889742418           mov qword ptr [rsp + 0x18], rsi
3C363F  48897c2420           mov qword ptr [rsp + 0x20], rdi
3C3644  4154                 push r12
3C3646  4156                 push r14
3C3648  4157                 push r15
3C364A  4883ec20             sub rsp, 0x20
3C364E  4c8be1               mov r12, rcx
3C3651  48c70100000000       mov qword ptr [rcx], 0
3C3658  c7410900000000       mov dword ptr [rcx + 9], 0
3C365F  4d8bf8               mov r15, r8
3C3662  4883c110             add rcx, 0x10
3C3666  4c8bf2               mov r14, rdx
3C3669  e8720f0000           call 0x1803c45e0
3C366E  498d8c2414020000     lea rcx, [r12 + 0x214]
3C3676  e8650f0000           call 0x1803c45e0
3C367B  498d8c2418040000     lea rcx, [r12 + 0x418]
3C3683  e8e8100000           call 0x1803c4770
3C3688  498d8c2498040000     lea rcx, [r12 + 0x498]
3C3690  e8db100000           call 0x1803c4770
3C3695  498d4c2410           lea rcx, [r12 + 0x10]
3C369A  4d89b42418050000     mov qword ptr [r12 + 0x518], r14
3C36A2  4d89bc2420050000     mov qword ptr [r12 + 0x520], r15
3C36AA  e801100000           call 0x1803c46b0
3C36AF  498d8c2414020000     lea rcx, [r12 + 0x214]
3C36B7  e8f40f0000           call 0x1803c46b0
3C36BC  498d8c2418040000     lea rcx, [r12 + 0x418]
3C36C4  e867110000           call 0x1803c4830
3C36C9  498d8c2498040000     lea rcx, [r12 + 0x498]
3C36D1  e85a110000           call 0x1803c4830
3C36D6  498d8c2429050000     lea rcx, [r12 + 0x529]
3C36DE  ba02000000           mov edx, 2
3C36E3  498d8424ac050000     lea rax, [r12 + 0x5ac]
3C36EB  0f1f440000           nop dword ptr [rax + rax]
3C36F0  c641ff00             mov byte ptr [rcx - 1], 0
3C36F4  c740fcffffffff       mov dword ptr [rax - 4], 0xffffffff
3C36FB  c60100               mov byte ptr [rcx], 0
3C36FE  c700ffffffff         mov dword ptr [rax], 0xffffffff
3C3704  c6410100             mov byte ptr [rcx + 1], 0
3C3708  c74004ffffffff       mov dword ptr [rax + 4], 0xffffffff
3C370F  c6410200             mov byte ptr [rcx + 2], 0
3C3713  c74008ffffffff       mov dword ptr [rax + 8], 0xffffffff
3C371A  c6410300             mov byte ptr [rcx + 3], 0

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
