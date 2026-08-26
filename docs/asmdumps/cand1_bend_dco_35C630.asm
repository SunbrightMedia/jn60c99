; cand1_bend_dco_35C630  rva 0x35C630  320 bytes  (from the checksummed binary)
35C630  48895c2408           mov qword ptr [rsp + 8], rbx
35C635  57                   push rdi
35C636  4883ec40             sub rsp, 0x40
35C63A  448b4120             mov r8d, dword ptr [rcx + 0x20]
35C63E  8bfa                 mov edi, edx
35C640  488bd9               mov rbx, rcx
35C643  0f29742430           movaps xmmword ptr [rsp + 0x30], xmm6
35C648  ba16000000           mov edx, 0x16
35C64D  488d0d74479500       lea rcx, [rip + 0x954774]
35C654  e8279dffff           call 0x180356380
35C659  837b2400             cmp dword ptr [rbx + 0x24], 0
35C65D  0f28f0               movaps xmm6, xmm0
35C660  741a                 je 0x18035c67c
35C662  448b4318             mov r8d, dword ptr [rbx + 0x18]
35C666  488d0d5b479500       lea rcx, [rip + 0x95475b]
35C66D  ba04000000           mov edx, 4
35C672  e8099dffff           call 0x180356380
35C677  0f28c8               movaps xmm1, xmm0
35C67A  eb03                 jmp 0x18035c67f
35C67C  0f57c9               xorps xmm1, xmm1
35C67F  8b4b1c               mov ecx, dword ptr [rbx + 0x1c]
35C682  83e901               sub ecx, 1
35C685  7428                 je 0x18035c6af
35C687  83e901               sub ecx, 1
35C68A  7419                 je 0x18035c6a5
35C68C  83f901               cmp ecx, 1
35C68F  740a                 je 0x18035c69b
35C691  f30f10051b8a7800     movss xmm0, dword ptr [rip + 0x788a1b]
35C699  eb1c                 jmp 0x18035c6b7
35C69B  f30f10052d8c7800     movss xmm0, dword ptr [rip + 0x788c2d]
35C6A3  eb12                 jmp 0x18035c6b7
35C6A5  f30f1005c38b7800     movss xmm0, dword ptr [rip + 0x788bc3]
35C6AD  eb08                 jmp 0x18035c6b7
35C6AF  f30f1005318b7800     movss xmm0, dword ptr [rip + 0x788b31]
35C6B7  448b836c080000       mov r8d, dword ptr [rbx + 0x86c]
35C6BE  8b5310               mov edx, dword ptr [rbx + 0x10]
35C6C1  488b4b08             mov rcx, qword ptr [rbx + 8]
35C6C5  f30f59f1             mulss xmm6, xmm1
35C6C9  f30f59f0             mulss xmm6, xmm0
35C6CD  0f28de               movaps xmm3, xmm6
35C6D0  85ff                 test edi, edi
35C6D2  751f                 jne 0x18035c6f3
35C6D4  33c0                 xor eax, eax
35C6D6  89442428             mov dword ptr [rsp + 0x28], eax
35C6DA  89442420             mov dword ptr [rsp + 0x20], eax
35C6DE  e8ed490600           call 0x1803c10d0
35C6E3  488b5c2450           mov rbx, qword ptr [rsp + 0x50]
35C6E8  0f28742430           movaps xmm6, xmmword ptr [rsp + 0x30]
35C6ED  4883c440             add rsp, 0x40
35C6F1  5f                   pop rdi
35C6F2  c3                   ret 
35C6F3  488b5c2450           mov rbx, qword ptr [rsp + 0x50]
35C6F8  0f28742430           movaps xmm6, xmmword ptr [rsp + 0x30]
35C6FD  4883c440             add rsp, 0x40
35C701  5f                   pop rdi
35C702  e989490600           jmp 0x1803c1090
35C707  cc                   int3 
35C708  cc                   int3 
35C709  cc                   int3 
35C70A  cc                   int3 
35C70B  cc                   int3 
35C70C  cc                   int3 
35C70D  cc                   int3 
35C70E  cc                   int3 
35C70F  cc                   int3 
35C710  48895c2408           mov qword ptr [rsp + 8], rbx
35C715  57                   push rdi
35C716  4883ec30             sub rsp, 0x30
35C71A  448b4128             mov r8d, dword ptr [rcx + 0x28]
35C71E  8bfa                 mov edi, edx
35C720  488bd9               mov rbx, rcx
35C723  ba16000000           mov edx, 0x16
35C728  488d0d99469500       lea rcx, [rip + 0x954699]
35C72F  e84c9cffff           call 0x180356380
35C734  448b8374080000       mov r8d, dword ptr [rbx + 0x874]
35C73B  0f28d8               movaps xmm3, xmm0
35C73E  660f6e432c           movd xmm0, dword ptr [rbx + 0x2c]
35C743  8b5310               mov edx, dword ptr [rbx + 0x10]
35C746  488b4b08             mov rcx, qword ptr [rbx + 8]
35C74A  0f5bc0               cvtdq2ps xmm0, xmm0
35C74D  f30f59d8             mulss xmm3, xmm0
35C751  85ff                 test edi, edi
35C753  751a                 jne 0x18035c76f
35C755  33c0                 xor eax, eax
35C757  89442428             mov dword ptr [rsp + 0x28], eax
35C75B  89442420             mov dword ptr [rsp + 0x20], eax
35C75F  e86c490600           call 0x1803c10d0
35C764  488b5c2440           mov rbx, qword ptr [rsp + 0x40]
35C769  4883c430             add rsp, 0x30
35C76D  5f                   pop rdi
35C76E  c3                   ret 

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
