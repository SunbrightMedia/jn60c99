; cand2_mod_dco_35C710  rva 0x35C710  320 bytes  (from the checksummed binary)
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
35C76F  488b5c2440           mov rbx, qword ptr [rsp + 0x40]
35C774  4883c430             add rsp, 0x30
35C778  5f                   pop rdi
35C779  e912490600           jmp 0x1803c1090
35C77E  cc                   int3 
35C77F  cc                   int3 
35C780  4883ec38             sub rsp, 0x38
35C784  48634134             movsxd rax, dword ptr [rcx + 0x34]
35C788  448b8160080000       mov r8d, dword ptr [rcx + 0x860]
35C78F  f30f105c8138         movss xmm3, dword ptr [rcx + rax*4 + 0x38]
35C795  f30f595930           mulss xmm3, dword ptr [rcx + 0x30]
35C79A  8b4110               mov eax, dword ptr [rcx + 0x10]
35C79D  488b4908             mov rcx, qword ptr [rcx + 8]
35C7A1  85d2                 test edx, edx
35C7A3  7514                 jne 0x18035c7b9
35C7A5  89542428             mov dword ptr [rsp + 0x28], edx
35C7A9  89542420             mov dword ptr [rsp + 0x20], edx
35C7AD  8bd0                 mov edx, eax
35C7AF  e81c490600           call 0x1803c10d0
35C7B4  4883c438             add rsp, 0x38
35C7B8  c3                   ret 
35C7B9  8bd0                 mov edx, eax
35C7BB  4883c438             add rsp, 0x38
35C7BF  e9cc480600           jmp 0x1803c1090
35C7C4  cc                   int3 
35C7C5  cc                   int3 
35C7C6  cc                   int3 
35C7C7  cc                   int3 
35C7C8  cc                   int3 
35C7C9  cc                   int3 
35C7CA  cc                   int3 
35C7CB  cc                   int3 
35C7CC  cc                   int3 
35C7CD  cc                   int3 
35C7CE  cc                   int3 
35C7CF  cc                   int3 
35C7D0  4883ec38             sub rsp, 0x38
35C7D4  4863813c040000       movsxd rax, dword ptr [rcx + 0x43c]
35C7DB  448b81a8080000       mov r8d, dword ptr [rcx + 0x8a8]
35C7E2  f30f109c8140040000   movss xmm3, dword ptr [rcx + rax*4 + 0x440]
35C7EB  f30f599938040000     mulss xmm3, dword ptr [rcx + 0x438]
35C7F3  8b4110               mov eax, dword ptr [rcx + 0x10]
35C7F6  488b4908             mov rcx, qword ptr [rcx + 8]
35C7FA  85d2                 test edx, edx
35C7FC  7514                 jne 0x18035c812
35C7FE  89542428             mov dword ptr [rsp + 0x28], edx
35C802  89542420             mov dword ptr [rsp + 0x20], edx
35C806  8bd0                 mov edx, eax
35C808  e8c3480600           call 0x1803c10d0
35C80D  4883c438             add rsp, 0x38
35C811  c3                   ret 
35C812  8bd0                 mov edx, eax
35C814  4883c438             add rsp, 0x38
35C818  e973480600           jmp 0x1803c1090
35C81D  cc                   int3 
35C81E  cc                   int3 
35C81F  cc                   int3 
35C820  c20000               ret 0
35C823  cc                   int3 
35C824  cc                   int3 
35C825  cc                   int3 
35C826  cc                   int3 
35C827  cc                   int3 
35C828  cc                   int3 
35C829  cc                   int3 
35C82A  cc                   int3 
35C82B  cc                   int3 
35C82C  cc                   int3 
35C82D  cc                   int3 
35C82E  cc                   int3 
35C82F  cc                   int3 
35C830  c20000               ret 0
35C833  cc                   int3 
35C834  cc                   int3 
35C835  cc                   int3 
35C836  cc                   int3 
35C837  cc                   int3 
35C838  cc                   int3 
35C839  cc                   int3 
35C83A  cc                   int3 
35C83B  cc                   int3 
35C83C  cc                   int3 
35C83D  cc                   int3 
35C83E  cc                   int3 
35C83F  cc                   int3 
35C840  488d0559c36200       lea rax, [rip + 0x62c359]
35C847  48895108             mov qword ptr [rcx + 8], rdx
35C84B  488901               mov qword ptr [rcx], rax

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
