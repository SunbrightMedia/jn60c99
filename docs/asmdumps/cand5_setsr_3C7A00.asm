; cand5_setsr_3C7A00  rva 0x3C7A00  512 bytes  (from the checksummed binary)
3C7A00  90                   nop 
3C7A01  e8bae1ffff           call 0x1803c5bc0
3C7A06  90                   nop 
3C7A07  488bc8               mov rcx, rax
3C7A0A  e8b1dcffff           call 0x1803c56c0
3C7A0F  90                   nop 
3C7A10  e857482f00           call 0x1806bc26c
3C7A15  cc                   int3 
3C7A16  e845caf7ff           call 0x180344460
3C7A1B  cc                   int3 
3C7A1C  cc                   int3 
3C7A1D  cc                   int3 
3C7A1E  cc                   int3 
3C7A1F  cc                   int3 
3C7A20  4056                 push rsi
3C7A22  4883ec30             sub rsp, 0x30
3C7A26  0f29742420           movaps xmmword ptr [rsp + 0x20], xmm6
3C7A2B  488bf1               mov rsi, rcx
3C7A2E  0f28f1               movaps xmm6, xmm1
3C7A31  0f2e7108             ucomiss xmm6, dword ptr [rcx + 8]
3C7A35  0f848e000000         je 0x1803c7ac9
3C7A3B  0f57c0               xorps xmm0, xmm0
3C7A3E  48895c2440           mov qword ptr [rsp + 0x40], rbx
3C7A43  f30f5ac6             cvtss2sd xmm0, xmm6
3C7A47  48896c2448           mov qword ptr [rsp + 0x48], rbp
3C7A4C  48897c2450           mov qword ptr [rsp + 0x50], rdi
3C7A51  e8faa50200           call 0x1803f2050
3C7A56  660f2f05d2da7100     comisd xmm0, xmmword ptr [rip + 0x71dad2]
3C7A5E  7307                 jae 0x1803c7a67
3C7A60  bf01000080           mov edi, 0x80000001
3C7A65  eb13                 jmp 0x1803c7a7a
3C7A67  660f2f0561d97100     comisd xmm0, xmmword ptr [rip + 0x71d961]
3C7A6F  f20f2cf8             cvttsd2si edi, xmm0
3C7A73  7605                 jbe 0x1803c7a7a
3C7A75  bfffffff7f           mov edi, 0x7fffffff
3C7A7A  488d5e60             lea rbx, [rsi + 0x60]
3C7A7E  bd09000000           mov ebp, 9
3C7A83  488b0b               mov rcx, qword ptr [rbx]
3C7A86  488b01               mov rax, qword ptr [rcx]
3C7A89  ff5018               call qword ptr [rax + 0x18]
3C7A8C  488b0b               mov rcx, qword ptr [rbx]
3C7A8F  8bd7                 mov edx, edi
3C7A91  e8ea4effff           call 0x1803bc980
3C7A96  488b4bf0             mov rcx, qword ptr [rbx - 0x10]
3C7A9A  0f28ce               movaps xmm1, xmm6
3C7A9D  e8ceacffff           call 0x1803c2770
3C7AA2  488b0b               mov rcx, qword ptr [rbx]
3C7AA5  488b01               mov rax, qword ptr [rcx]
3C7AA8  ff5028               call qword ptr [rax + 0x28]
3C7AAB  488d5b40             lea rbx, [rbx + 0x40]
3C7AAF  4883ed01             sub rbp, 1
3C7AB3  75ce                 jne 0x1803c7a83
3C7AB5  488b7c2450           mov rdi, qword ptr [rsp + 0x50]
3C7ABA  488b6c2448           mov rbp, qword ptr [rsp + 0x48]
3C7ABF  488b5c2440           mov rbx, qword ptr [rsp + 0x40]
3C7AC4  f30f117608           movss dword ptr [rsi + 8], xmm6
3C7AC9  0f28742420           movaps xmm6, xmmword ptr [rsp + 0x20]
3C7ACE  4883c430             add rsp, 0x30
3C7AD2  5e                   pop rsi
3C7AD3  c3                   ret 
3C7AD4  cc                   int3 
3C7AD5  cc                   int3 
3C7AD6  cc                   int3 
3C7AD7  cc                   int3 
3C7AD8  cc                   int3 
3C7AD9  cc                   int3 
3C7ADA  cc                   int3 
3C7ADB  cc                   int3 
3C7ADC  cc                   int3 
3C7ADD  cc                   int3 
3C7ADE  cc                   int3 
3C7ADF  cc                   int3 
3C7AE0  4057                 push rdi
3C7AE2  4156                 push r14
3C7AE4  4157                 push r15
3C7AE6  4883ec30             sub rsp, 0x30
3C7AEA  48c7442420feffffff   mov qword ptr [rsp + 0x20], 0xfffffffffffffffe
3C7AF3  48895c2450           mov qword ptr [rsp + 0x50], rbx
3C7AF8  48896c2458           mov qword ptr [rsp + 0x58], rbp
3C7AFD  4889742460           mov qword ptr [rsp + 0x60], rsi
3C7B02  418bf0               mov esi, r8d
3C7B05  4c8bf1               mov r14, rcx
3C7B08  81fa0ec0ff0f         cmp edx, 0xfffc00e
3C7B0E  7546                 jne 0x1803c7b56
3C7B10  4883c140             add rcx, 0x40
3C7B14  e88737f8ff           call 0x18034b2a0
3C7B19  41897638             mov dword ptr [r14 + 0x38], esi
3C7B1D  b800000080           mov eax, 0x80000000
3C7B22  f0410fc14640         lock xadd dword ptr [r14 + 0x40], eax
3C7B28  0fbae01e             bt eax, 0x1e
3C7B2C  7223                 jb 0x1803c7b51
3C7B2E  3d00000080           cmp eax, 0x80000000
3C7B33  7e1c                 jle 0x1803c7b51
3C7B35  f0410fba6e401e       lock bts dword ptr [r14 + 0x40], 0x1e
3C7B3C  7213                 jb 0x1803c7b51
3C7B3E  498d4e40             lea rcx, [r14 + 0x40]
3C7B42  e8e9ecf3ff           call 0x180306830
3C7B47  488bc8               mov rcx, rax
3C7B4A  ff15a0cc5600         call qword ptr [rip + 0x56cca0]
3C7B50  90                   nop 
3C7B51  e958010000           jmp 0x1803c7cae
3C7B56  4c8b05bb928e00       mov r8, qword ptr [rip + 0x8e92bb]
3C7B5D  498bc0               mov rax, r8
3C7B60  498b4808             mov rcx, qword ptr [r8 + 8]
3C7B64  80791900             cmp byte ptr [rcx + 0x19], 0
3C7B68  7527                 jne 0x1803c7b91
3C7B6A  660f1f440000         nop word ptr [rax + rax]
3C7B70  39511c               cmp dword ptr [rcx + 0x1c], edx
3C7B73  7d06                 jge 0x1803c7b7b
3C7B75  488b4910             mov rcx, qword ptr [rcx + 0x10]
3C7B79  eb06                 jmp 0x1803c7b81
3C7B7B  488bc1               mov rax, rcx
3C7B7E  488b09               mov rcx, qword ptr [rcx]
3C7B81  80791900             cmp byte ptr [rcx + 0x19], 0
3C7B85  74e9                 je 0x1803c7b70
3C7B87  493bc0               cmp rax, r8
3C7B8A  7405                 je 0x1803c7b91
3C7B8C  3b501c               cmp edx, dword ptr [rax + 0x1c]
3C7B8F  7d03                 jge 0x1803c7b94
3C7B91  498bc0               mov rax, r8
3C7B94  493bc0               cmp rax, r8
3C7B97  0f8411010000         je 0x1803c7cae
3C7B9D  8b5820               mov ebx, dword ptr [rax + 0x20]
3C7BA0  4981c688000000       add r14, 0x88
3C7BA7  bd09000000           mov ebp, 9
3C7BAC  4c8d3d4d84c3ff       lea r15, [rip - 0x3c7bb3]
3C7BB3  8bfe                 mov edi, esi
3C7BB5  81fb99020000         cmp ebx, 0x299
3C7BBB  7f20                 jg 0x1803c7bdd
3C7BBD  0f84a9000000         je 0x1803c7c6c
3C7BC3  83fb14               cmp ebx, 0x14
3C7BC6  0f84a0000000         je 0x1803c7c6c
3C7BCC  83fb16               cmp ebx, 0x16
3C7BCF  0f859a000000         jne 0x1803c7c6f
3C7BD5  8d7ef4               lea edi, [rsi - 0xc]
3C7BD8  e992000000           jmp 0x1803c7c6f
3C7BDD  8d833dfdffff         lea eax, [rbx - 0x2c3]
3C7BE3  3da4000000           cmp eax, 0xa4
3C7BE8  0f8781000000         ja 0x1803c7c6f
3C7BEE  4898                 cdqe 
3C7BF0  410fb68407f07c3c00   movzx eax, byte ptr [r15 + rax + 0x3c7cf0]

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
; 3C7A31  ucomiss xmm6, dword ptr [rcx + 8] ; je   unordered: IS taken  C's x == y is NOT equivalent
; 3C7A56  comisd xmm0, xmmword ptr [rip + 0x71dad2] ; jae   unordered: NOT taken  C must be !(x >= y)   <== RISK
; 3C7A67  comisd xmm0, xmmword ptr [rip + 0x71d961] -> no branch within 5 insns
