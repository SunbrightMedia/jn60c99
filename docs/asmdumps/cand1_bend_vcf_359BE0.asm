; cand1_bend_vcf_359BE0  rva 0x359BE0  320 bytes  (from the checksummed binary)
359BE0  48895c2408           mov qword ptr [rsp + 8], rbx
359BE5  57                   push rdi
359BE6  4883ec40             sub rsp, 0x40
359BEA  448b4120             mov r8d, dword ptr [rcx + 0x20]
359BEE  8bfa                 mov edi, edx
359BF0  488bd9               mov rbx, rcx
359BF3  0f29742430           movaps xmmword ptr [rsp + 0x30], xmm6
359BF8  ba16000000           mov edx, 0x16
359BFD  488d0dc4719500       lea rcx, [rip + 0x9571c4]
359C04  e877c7ffff           call 0x180356380
359C09  837b2400             cmp dword ptr [rbx + 0x24], 0
359C0D  0f28f0               movaps xmm6, xmm0
359C10  741a                 je 0x180359c2c
359C12  448b4318             mov r8d, dword ptr [rbx + 0x18]
359C16  488d0dab719500       lea rcx, [rip + 0x9571ab]
359C1D  ba04000000           mov edx, 4
359C22  e859c7ffff           call 0x180356380
359C27  0f28c8               movaps xmm1, xmm0
359C2A  eb03                 jmp 0x180359c2f
359C2C  0f57c9               xorps xmm1, xmm1
359C2F  8b4b1c               mov ecx, dword ptr [rbx + 0x1c]
359C32  83e901               sub ecx, 1
359C35  7428                 je 0x180359c5f
359C37  83e901               sub ecx, 1
359C3A  7419                 je 0x180359c55
359C3C  83f901               cmp ecx, 1
359C3F  740a                 je 0x180359c4b
359C41  f30f10056bb47800     movss xmm0, dword ptr [rip + 0x78b46b]
359C49  eb1c                 jmp 0x180359c67
359C4B  f30f10057db67800     movss xmm0, dword ptr [rip + 0x78b67d]
359C53  eb12                 jmp 0x180359c67
359C55  f30f100513b67800     movss xmm0, dword ptr [rip + 0x78b613]
359C5D  eb08                 jmp 0x180359c67
359C5F  f30f100581b57800     movss xmm0, dword ptr [rip + 0x78b581]
359C67  448b8360080000       mov r8d, dword ptr [rbx + 0x860]
359C6E  8b5310               mov edx, dword ptr [rbx + 0x10]
359C71  488b4b08             mov rcx, qword ptr [rbx + 8]
359C75  f30f59f1             mulss xmm6, xmm1
359C79  f30f59f0             mulss xmm6, xmm0
359C7D  0f28de               movaps xmm3, xmm6
359C80  85ff                 test edi, edi
359C82  751f                 jne 0x180359ca3
359C84  33c0                 xor eax, eax
359C86  89442428             mov dword ptr [rsp + 0x28], eax
359C8A  89442420             mov dword ptr [rsp + 0x20], eax
359C8E  e83d740600           call 0x1803c10d0
359C93  488b5c2450           mov rbx, qword ptr [rsp + 0x50]
359C98  0f28742430           movaps xmm6, xmmword ptr [rsp + 0x30]
359C9D  4883c440             add rsp, 0x40
359CA1  5f                   pop rdi
359CA2  c3                   ret 
359CA3  488b5c2450           mov rbx, qword ptr [rsp + 0x50]
359CA8  0f28742430           movaps xmm6, xmmword ptr [rsp + 0x30]
359CAD  4883c440             add rsp, 0x40
359CB1  5f                   pop rdi
359CB2  e9d9730600           jmp 0x1803c1090
359CB7  cc                   int3 
359CB8  cc                   int3 
359CB9  cc                   int3 
359CBA  cc                   int3 
359CBB  cc                   int3 
359CBC  cc                   int3 
359CBD  cc                   int3 
359CBE  cc                   int3 
359CBF  cc                   int3 
359CC0  4883ec38             sub rsp, 0x38
359CC4  48634134             movsxd rax, dword ptr [rcx + 0x34]
359CC8  448b8194080000       mov r8d, dword ptr [rcx + 0x894]
359CCF  f30f105c8138         movss xmm3, dword ptr [rcx + rax*4 + 0x38]
359CD5  f30f595930           mulss xmm3, dword ptr [rcx + 0x30]
359CDA  8b4110               mov eax, dword ptr [rcx + 0x10]
359CDD  488b4908             mov rcx, qword ptr [rcx + 8]
359CE1  85d2                 test edx, edx
359CE3  7514                 jne 0x180359cf9
359CE5  89542428             mov dword ptr [rsp + 0x28], edx
359CE9  89542420             mov dword ptr [rsp + 0x20], edx
359CED  8bd0                 mov edx, eax
359CEF  e8dc730600           call 0x1803c10d0
359CF4  4883c438             add rsp, 0x38
359CF8  c3                   ret 
359CF9  8bd0                 mov edx, eax
359CFB  4883c438             add rsp, 0x38
359CFF  e98c730600           jmp 0x1803c1090
359D04  cc                   int3 
359D05  cc                   int3 
359D06  cc                   int3 
359D07  cc                   int3 
359D08  cc                   int3 
359D09  cc                   int3 
359D0A  cc                   int3 
359D0B  cc                   int3 
359D0C  cc                   int3 
359D0D  cc                   int3 
359D0E  cc                   int3 
359D0F  cc                   int3 
359D10  48895c2408           mov qword ptr [rsp + 8], rbx
359D15  57                   push rdi
359D16  4883ec30             sub rsp, 0x30
359D1A  448b4128             mov r8d, dword ptr [rcx + 0x28]
359D1E  8bfa                 mov edi, edx

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
