; f2_3B9990  rva 0x3B9990  384 bytes  (from the checksummed binary)
3B9990  85d2                 test edx, edx
3B9992  7533                 jne 0x1803b99c7
3B9994  57                   push rdi
3B9995  4883ec20             sub rsp, 0x20
3B9999  8b91f8040000         mov edx, dword ptr [rcx + 0x4f8]
3B999F  488bf9               mov rdi, rcx
3B99A2  48895c2430           mov qword ptr [rsp + 0x30], rbx
3B99A7  488b19               mov rbx, qword ptr [rcx]
3B99AA  e8517effff           call 0x1803b1800
3B99AF  448bc0               mov r8d, eax
3B99B2  33d2                 xor edx, edx
3B99B4  488bcf               mov rcx, rdi
3B99B7  ff9360080000         call qword ptr [rbx + 0x860]
3B99BD  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B99C2  4883c420             add rsp, 0x20
3B99C6  5f                   pop rdi
3B99C7  c3                   ret 
3B99C8  cc                   int3 
3B99C9  cc                   int3 
3B99CA  cc                   int3 
3B99CB  cc                   int3 
3B99CC  cc                   int3 
3B99CD  cc                   int3 
3B99CE  cc                   int3 
3B99CF  cc                   int3 
3B99D0  48895c2408           mov qword ptr [rsp + 8], rbx
3B99D5  4889742410           mov qword ptr [rsp + 0x10], rsi
3B99DA  57                   push rdi
3B99DB  4883ec20             sub rsp, 0x20
3B99DF  418bd8               mov ebx, r8d
3B99E2  8bfa                 mov edi, edx
3B99E4  488bf1               mov rsi, rcx
3B99E7  e83478ffff           call 0x1803b1220
3B99EC  488b06               mov rax, qword ptr [rsi]
3B99EF  8bd7                 mov edx, edi
3B99F1  448b863c050000       mov r8d, dword ptr [rsi + 0x53c]
3B99F8  488bce               mov rcx, rsi
3B99FB  899e50050000         mov dword ptr [rsi + 0x550], ebx
3B9A01  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9A06  488b742438           mov rsi, qword ptr [rsp + 0x38]
3B9A0B  4883c420             add rsp, 0x20
3B9A0F  5f                   pop rdi
3B9A10  48ffa0e8080000       jmp qword ptr [rax + 0x8e8]
3B9A17  cc                   int3 
3B9A18  cc                   int3 
3B9A19  cc                   int3 
3B9A1A  cc                   int3 
3B9A1B  cc                   int3 
3B9A1C  cc                   int3 
3B9A1D  cc                   int3 
3B9A1E  cc                   int3 
3B9A1F  cc                   int3 
3B9A20  c20000               ret 0
3B9A23  cc                   int3 
3B9A24  cc                   int3 
3B9A25  cc                   int3 
3B9A26  cc                   int3 
3B9A27  cc                   int3 
3B9A28  cc                   int3 
3B9A29  cc                   int3 
3B9A2A  cc                   int3 
3B9A2B  cc                   int3 
3B9A2C  cc                   int3 
3B9A2D  cc                   int3 
3B9A2E  cc                   int3 
3B9A2F  cc                   int3 
3B9A30  48895c2408           mov qword ptr [rsp + 8], rbx
3B9A35  57                   push rdi
3B9A36  4883ec20             sub rsp, 0x20
3B9A3A  418bf9               mov edi, r9d
3B9A3D  458bc8               mov r9d, r8d
3B9A40  488bd9               mov rbx, rcx
3B9A43  81fa38010000         cmp edx, 0x138
3B9A49  0f8fc9020000         jg 0x1803b9d18
3B9A4F  0f84a3020000         je 0x1803b9cf8
3B9A55  83c2ec               add edx, -0x14
3B9A58  81faea000000         cmp edx, 0xea
3B9A5E  0f8767170000         ja 0x1803bb1cb
3B9A64  4863c2               movsxd rax, edx
3B9A67  488d159265c4ff       lea rdx, [rip - 0x3b9a6e]
3B9A6E  0fb6840224b23b00     movzx eax, byte ptr [rdx + rax + 0x3bb224]
3B9A76  8b8c82d8b13b00       mov ecx, dword ptr [rdx + rax*4 + 0x3bb1d8]
3B9A7D  4803ca               add rcx, rdx
3B9A80  ffe1                 jmp rcx
3B9A82  488b03               mov rax, qword ptr [rbx]
3B9A85  448bc7               mov r8d, edi
3B9A88  418bd1               mov edx, r9d
3B9A8B  488bcb               mov rcx, rbx
3B9A8E  ff90d8050000         call qword ptr [rax + 0x5d8]
3B9A94  89bbb4030000         mov dword ptr [rbx + 0x3b4], edi
3B9A9A  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9A9F  4883c420             add rsp, 0x20
3B9AA3  5f                   pop rdi
3B9AA4  c3                   ret 
3B9AA5  488b03               mov rax, qword ptr [rbx]
3B9AA8  448bc7               mov r8d, edi
3B9AAB  418bd1               mov edx, r9d
3B9AAE  488bcb               mov rcx, rbx
3B9AB1  ff90e0050000         call qword ptr [rax + 0x5e0]
3B9AB7  89bbb8030000         mov dword ptr [rbx + 0x3b8], edi
3B9ABD  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9AC2  4883c420             add rsp, 0x20
3B9AC6  5f                   pop rdi
3B9AC7  c3                   ret 
3B9AC8  488b03               mov rax, qword ptr [rbx]
3B9ACB  448bc7               mov r8d, edi
3B9ACE  418bd1               mov edx, r9d
3B9AD1  488bcb               mov rcx, rbx
3B9AD4  ff90e8050000         call qword ptr [rax + 0x5e8]
3B9ADA  89bbbc030000         mov dword ptr [rbx + 0x3bc], edi
3B9AE0  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9AE5  4883c420             add rsp, 0x20
3B9AE9  5f                   pop rdi
3B9AEA  c3                   ret 
3B9AEB  488b03               mov rax, qword ptr [rbx]
3B9AEE  448bc7               mov r8d, edi
3B9AF1  418bd1               mov edx, r9d
3B9AF4  488bcb               mov rcx, rbx
3B9AF7  ff90f0050000         call qword ptr [rax + 0x5f0]
3B9AFD  89bbc0030000         mov dword ptr [rbx + 0x3c0], edi
3B9B03  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9B08  4883c420             add rsp, 0x20
3B9B0C  5f                   pop rdi
3B9B0D  c3                   ret 

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
