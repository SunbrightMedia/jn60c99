; cand3_gate_setter_35CC30  rva 0x35CC30  192 bytes  (from the checksummed binary)
35CC30  4585c0               test r8d, r8d
35CC33  7505                 jne 0x18035cc3a
35CC35  0f57db               xorps xmm3, xmm3
35CC38  eb08                 jmp 0x18035cc42
35CC3A  f30f101d72847800     movss xmm3, dword ptr [rip + 0x788472]
35CC42  448b4170             mov r8d, dword ptr [rcx + 0x70]
35CC46  8b5110               mov edx, dword ptr [rcx + 0x10]
35CC49  488b4908             mov rcx, qword ptr [rcx + 8]
35CC4D  e99e440600           jmp 0x1803c10f0
35CC52  cc                   int3 
35CC53  cc                   int3 
35CC54  cc                   int3 
35CC55  cc                   int3 
35CC56  cc                   int3 
35CC57  cc                   int3 
35CC58  cc                   int3 
35CC59  cc                   int3 
35CC5A  cc                   int3 
35CC5B  cc                   int3 
35CC5C  cc                   int3 
35CC5D  cc                   int3 
35CC5E  cc                   int3 
35CC5F  cc                   int3 
35CC60  8b415c               mov eax, dword ptr [rcx + 0x5c]
35CC63  41b90c000000         mov r9d, 0xc
35CC69  4c8b5150             mov r10, qword ptr [rcx + 0x50]
35CC6D  442bc8               sub r9d, eax
35CC70  448bda               mov r11d, edx
35CC73  33d2                 xor edx, edx
35CC75  85c0                 test eax, eax
35CC77  440f4eca             cmovle r9d, edx
35CC7B  83795807             cmp dword ptr [rcx + 0x58], 7
35CC7F  7505                 jne 0x18035cc86
35CC81  0f57c9               xorps xmm1, xmm1
35CC84  eb2c                 jmp 0x18035ccb2
35CC86  41b815000000         mov r8d, 0x15
35CC8C  442bc0               sub r8d, eax
35CC8F  b8abaaaa2a           mov eax, 0x2aaaaaab
35CC94  41f7e8               imul r8d
35CC97  d1fa                 sar edx, 1
35CC99  8bca                 mov ecx, edx
35CC9B  c1e91f               shr ecx, 0x1f
35CC9E  03d1                 add edx, ecx
35CCA0  8d0c52               lea ecx, [rdx + rdx*2]
35CCA3  c1e102               shl ecx, 2
35CCA6  442bc1               sub r8d, ecx
35CCA9  4963c8               movsxd rcx, r8d
35CCAC  f3410f100c8a         movss xmm1, dword ptr [r10 + rcx*4]
35CCB2  438d0c19             lea ecx, [r9 + r11]
35CCB6  b8abaaaa2a           mov eax, 0x2aaaaaab
35CCBB  f7e9                 imul ecx
35CCBD  d1fa                 sar edx, 1
35CCBF  8bc2                 mov eax, edx
35CCC1  c1e81f               shr eax, 0x1f
35CCC4  03d0                 add edx, eax
35CCC6  8d0452               lea eax, [rdx + rdx*2]
35CCC9  c1e002               shl eax, 2
35CCCC  2bc8                 sub ecx, eax
35CCCE  4863c1               movsxd rax, ecx
35CCD1  f3410f100482         movss xmm0, dword ptr [r10 + rax*4]
35CCD7  f30f5cc1             subss xmm0, xmm1
35CCDB  c3                   ret 
35CCDC  cc                   int3 
35CCDD  cc                   int3 
35CCDE  cc                   int3 
35CCDF  cc                   int3 
35CCE0  48895c2408           mov qword ptr [rsp + 8], rbx
35CCE5  4889742410           mov qword ptr [rsp + 0x10], rsi
35CCEA  57                   push rdi
35CCEB  4883ec20             sub rsp, 0x20

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
