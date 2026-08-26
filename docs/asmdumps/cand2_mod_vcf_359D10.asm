; cand2_mod_vcf_359D10  rva 0x359D10  320 bytes  (from the checksummed binary)
359D10  48895c2408           mov qword ptr [rsp + 8], rbx
359D15  57                   push rdi
359D16  4883ec30             sub rsp, 0x30
359D1A  448b4128             mov r8d, dword ptr [rcx + 0x28]
359D1E  8bfa                 mov edi, edx
359D20  488bd9               mov rbx, rcx
359D23  ba16000000           mov edx, 0x16
359D28  488d0d99709500       lea rcx, [rip + 0x957099]
359D2F  e84cc6ffff           call 0x180356380
359D34  448b8368080000       mov r8d, dword ptr [rbx + 0x868]
359D3B  0f28d8               movaps xmm3, xmm0
359D3E  660f6e432c           movd xmm0, dword ptr [rbx + 0x2c]
359D43  8b5310               mov edx, dword ptr [rbx + 0x10]
359D46  488b4b08             mov rcx, qword ptr [rbx + 8]
359D4A  0f5bc0               cvtdq2ps xmm0, xmm0
359D4D  f30f59d8             mulss xmm3, xmm0
359D51  f30f591dffb57800     mulss xmm3, dword ptr [rip + 0x78b5ff]
359D59  85ff                 test edi, edi
359D5B  751a                 jne 0x180359d77
359D5D  33c0                 xor eax, eax
359D5F  89442428             mov dword ptr [rsp + 0x28], eax
359D63  89442420             mov dword ptr [rsp + 0x20], eax
359D67  e864730600           call 0x1803c10d0
359D6C  488b5c2440           mov rbx, qword ptr [rsp + 0x40]
359D71  4883c430             add rsp, 0x30
359D75  5f                   pop rdi
359D76  c3                   ret 
359D77  488b5c2440           mov rbx, qword ptr [rsp + 0x40]
359D7C  4883c430             add rsp, 0x30
359D80  5f                   pop rdi
359D81  e90a730600           jmp 0x1803c1090
359D86  cc                   int3 
359D87  cc                   int3 
359D88  cc                   int3 
359D89  cc                   int3 
359D8A  cc                   int3 
359D8B  cc                   int3 
359D8C  cc                   int3 
359D8D  cc                   int3 
359D8E  cc                   int3 
359D8F  cc                   int3 
359D90  4883ec38             sub rsp, 0x38
359D94  4863813c040000       movsxd rax, dword ptr [rcx + 0x43c]
359D9B  660f6e9938040000     movd xmm3, dword ptr [rcx + 0x438]
359DA3  448b8198080000       mov r8d, dword ptr [rcx + 0x898]
359DAA  0f5bdb               cvtdq2ps xmm3, xmm3
359DAD  f30f599c8140040000   mulss xmm3, dword ptr [rcx + rax*4 + 0x440]
359DB6  8b4110               mov eax, dword ptr [rcx + 0x10]
359DB9  488b4908             mov rcx, qword ptr [rcx + 8]
359DBD  85d2                 test edx, edx
359DBF  7514                 jne 0x180359dd5
359DC1  89542428             mov dword ptr [rsp + 0x28], edx
359DC5  89542420             mov dword ptr [rsp + 0x20], edx
359DC9  8bd0                 mov edx, eax
359DCB  e800730600           call 0x1803c10d0
359DD0  4883c438             add rsp, 0x38
359DD4  c3                   ret 
359DD5  8bd0                 mov edx, eax
359DD7  4883c438             add rsp, 0x38
359DDB  e9b0720600           jmp 0x1803c1090
359DE0  4053                 push rbx
359DE2  4883ec20             sub rsp, 0x20
359DE6  488bd9               mov rbx, rcx
359DE9  ba34000000           mov edx, 0x34
359DEE  488d0dd36f9500       lea rcx, [rip + 0x956fd3]
359DF5  e886c5ffff           call 0x180356380
359DFA  448b8354080000       mov r8d, dword ptr [rbx + 0x854]
359E01  0f28d8               movaps xmm3, xmm0
359E04  8b5310               mov edx, dword ptr [rbx + 0x10]
359E07  488b4b08             mov rcx, qword ptr [rbx + 8]
359E0B  4883c420             add rsp, 0x20
359E0F  5b                   pop rbx
359E10  e9db720600           jmp 0x1803c10f0
359E15  cc                   int3 
359E16  cc                   int3 
359E17  cc                   int3 
359E18  cc                   int3 
359E19  cc                   int3 
359E1A  cc                   int3 
359E1B  cc                   int3 
359E1C  cc                   int3 
359E1D  cc                   int3 
359E1E  cc                   int3 
359E1F  cc                   int3 
359E20  4053                 push rbx
359E22  4883ec20             sub rsp, 0x20
359E26  488bd9               mov rbx, rcx
359E29  ba34000000           mov edx, 0x34
359E2E  488d0d936f9500       lea rcx, [rip + 0x956f93]
359E35  e846c5ffff           call 0x180356380
359E3A  448b8344080000       mov r8d, dword ptr [rbx + 0x844]
359E41  0f28d8               movaps xmm3, xmm0
359E44  8b5310               mov edx, dword ptr [rbx + 0x10]
359E47  488b4b08             mov rcx, qword ptr [rbx + 8]
359E4B  4883c420             add rsp, 0x20
359E4F  5b                   pop rbx

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
