; cand6_ratelaw_362D40  rva 0x362D40  288 bytes  (from the checksummed binary)
362D40  c3                   ret 
362D41  cc                   int3 
362D42  cc                   int3 
362D43  cc                   int3 
362D44  cc                   int3 
362D45  cc                   int3 
362D46  cc                   int3 
362D47  cc                   int3 
362D48  cc                   int3 
362D49  cc                   int3 
362D4A  cc                   int3 
362D4B  cc                   int3 
362D4C  cc                   int3 
362D4D  cc                   int3 
362D4E  cc                   int3 
362D4F  cc                   int3 
362D50  48895c2408           mov qword ptr [rsp + 8], rbx
362D55  4889742410           mov qword ptr [rsp + 0x10], rsi
362D5A  57                   push rdi
362D5B  4883ec30             sub rsp, 0x30
362D5F  8bf2                 mov esi, edx
362D61  488bd9               mov rbx, rcx
362D64  ba3c000000           mov edx, 0x3c
362D69  488d0d58e09400       lea rcx, [rip + 0x94e058]
362D70  418bf8               mov edi, r8d
362D73  e80836ffff           call 0x180356380
362D78  8b434c               mov eax, dword ptr [rbx + 0x4c]
362D7B  3d00770100           cmp eax, 0x17700
362D80  7413                 je 0x180362d95
362D82  f30f5905a2526200     mulss xmm0, dword ptr [rip + 0x6252a2]
362D8A  660f6ec8             movd xmm1, eax
362D8E  0f5bc9               cvtdq2ps xmm1, xmm1
362D91  f30f5ec1             divss xmm0, xmm1
362D95  448b4374             mov r8d, dword ptr [rbx + 0x74]
362D99  0f28d8               movaps xmm3, xmm0
362D9C  8b535c               mov edx, dword ptr [rbx + 0x5c]
362D9F  488b4b08             mov rcx, qword ptr [rbx + 8]
362DA3  85f6                 test esi, esi
362DA5  7522                 jne 0x180362dc9
362DA7  33c0                 xor eax, eax
362DA9  89442428             mov dword ptr [rsp + 0x28], eax
362DAD  89442420             mov dword ptr [rsp + 0x20], eax
362DB1  e81ae30500           call 0x1803c10d0
362DB6  897b2c               mov dword ptr [rbx + 0x2c], edi
362DB9  488b5c2440           mov rbx, qword ptr [rsp + 0x40]
362DBE  488b742448           mov rsi, qword ptr [rsp + 0x48]
362DC3  4883c430             add rsp, 0x30
362DC7  5f                   pop rdi
362DC8  c3                   ret 
362DC9  e8c2e20500           call 0x1803c1090
362DCE  488b742448           mov rsi, qword ptr [rsp + 0x48]
362DD3  897b2c               mov dword ptr [rbx + 0x2c], edi
362DD6  488b5c2440           mov rbx, qword ptr [rsp + 0x40]
362DDB  4883c430             add rsp, 0x30
362DDF  5f                   pop rdi
362DE0  c3                   ret 
362DE1  cc                   int3 
362DE2  cc                   int3 
362DE3  cc                   int3 
362DE4  cc                   int3 
362DE5  cc                   int3 
362DE6  cc                   int3 
362DE7  cc                   int3 
362DE8  cc                   int3 
362DE9  cc                   int3 
362DEA  cc                   int3 
362DEB  cc                   int3 
362DEC  cc                   int3 
362DED  cc                   int3 
362DEE  cc                   int3 
362DEF  cc                   int3 
362DF0  48895c2410           mov qword ptr [rsp + 0x10], rbx
362DF5  4889742420           mov qword ptr [rsp + 0x20], rsi
362DFA  57                   push rdi
362DFB  4881ec80000000       sub rsp, 0x80
362E02  0f29742470           movaps xmmword ptr [rsp + 0x70], xmm6
362E07  0f297c2460           movaps xmmword ptr [rsp + 0x60], xmm7
362E0C  488b05e5209300       mov rax, qword ptr [rip + 0x9320e5]
362E13  4833c4               xor rax, rsp
362E16  4889442458           mov qword ptr [rsp + 0x58], rax
362E1B  0f2805fe287800       movaps xmm0, xmmword ptr [rip + 0x7828fe]
362E22  33f6                 xor esi, esi
362E24  0f280da5666200       movaps xmm1, xmmword ptr [rip + 0x6266a5]
362E2B  4585c0               test r8d, r8d
362E2E  488bd9               mov rbx, rcx
362E31  8bc6                 mov eax, esi
362E33  410f49c0             cmovns eax, r8d
362E37  b902000000           mov ecx, 2
362E3C  3bc1                 cmp eax, ecx
362E3E  418bf8               mov edi, r8d
362E41  0f11442430           movups xmmword ptr [rsp + 0x30], xmm0
362E46  0f4fc1               cmovg eax, ecx
362E49  448b839c000000       mov r8d, dword ptr [rbx + 0x9c]
362E50  f30f100570666200     movss xmm0, dword ptr [rip + 0x626670]
362E58  85d2                 test edx, edx
362E5A  488b4b08             mov rcx, qword ptr [rbx + 8]

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
