; cand5_round_helper_3F2050  rva 0x3F2050  192 bytes  (from the checksummed binary)
3F2050  0f57c9               xorps xmm1, xmm1
3F2053  660f2fc8             comisd xmm1, xmm0
3F2057  760d                 jbe 0x1803f2066
3F2059  f20f5c05f7306f00     subsd xmm0, qword ptr [rip + 0x6f30f7]
3F2061  e976203000           jmp 0x1806f40dc
3F2066  f20f5805ea306f00     addsd xmm0, qword ptr [rip + 0x6f30ea]
3F206E  e92d213000           jmp 0x1806f41a0
3F2073  cc                   int3 
3F2074  cc                   int3 
3F2075  cc                   int3 
3F2076  cc                   int3 
3F2077  cc                   int3 
3F2078  cc                   int3 
3F2079  cc                   int3 
3F207A  cc                   int3 
3F207B  cc                   int3 
3F207C  cc                   int3 
3F207D  cc                   int3 
3F207E  cc                   int3 
3F207F  cc                   int3 
3F2080  4055                 push rbp
3F2082  56                   push rsi
3F2083  57                   push rdi
3F2084  4154                 push r12
3F2086  4155                 push r13
3F2088  4156                 push r14
3F208A  4157                 push r15
3F208C  488dac2440feffff     lea rbp, [rsp - 0x1c0]
3F2094  4881ecc0020000       sub rsp, 0x2c0
3F209B  48c74570feffffff     mov qword ptr [rbp + 0x70], 0xfffffffffffffffe
3F20A3  48899c2410030000     mov qword ptr [rsp + 0x310], rbx
3F20AB  488b05462e8a00       mov rax, qword ptr [rip + 0x8a2e46]
3F20B2  4833c4               xor rax, rsp
3F20B5  488985b0010000       mov qword ptr [rbp + 0x1b0], rax
3F20BC  488bf2               mov rsi, rdx
3F20BF  488bd9               mov rbx, rcx
3F20C2  4533ff               xor r15d, r15d
3F20C5  44897c2420           mov dword ptr [rsp + 0x20], r15d
3F20CA  4c8d252fdfc0ff       lea r12, [rip - 0x3f20d1]
3F20D1  498d842498c59300     lea rax, [r12 + 0x93c598]
3F20D9  4889442460           mov qword ptr [rsp + 0x60], rax
3F20DE  c744242001000000     mov dword ptr [rsp + 0x20], 1
3F20E6  488d057ba45400       lea rax, [rip + 0x54a47b]
3F20ED  48894510             mov qword ptr [rbp + 0x10], rax
3F20F1  c7450c98000000       mov dword ptr [rbp + 0xc], 0x98
3F20F8  4c897c2468           mov qword ptr [rsp + 0x68], r15
3F20FD  4533c0               xor r8d, r8d
3F2100  488d542470           lea rdx, [rsp + 0x70]
3F2105  488d4d10             lea rcx, [rbp + 0x10]
3F2109  e8223cd0ff           call 0x1800f5d30
3F210E  90                   nop 

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
; 3F2053  comisd xmm1, xmm0 ; jbe   unordered: IS taken  C's x <= y is correct
