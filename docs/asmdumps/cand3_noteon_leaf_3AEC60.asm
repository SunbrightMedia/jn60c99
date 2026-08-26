; cand3_noteon_leaf_3AEC60  rva 0x3AEC60  320 bytes  (from the checksummed binary)
3AEC60  48895c2408           mov qword ptr [rsp + 8], rbx
3AEC65  4889742410           mov qword ptr [rsp + 0x10], rsi
3AEC6A  57                   push rdi
3AEC6B  4883ec20             sub rsp, 0x20
3AEC6F  418bf0               mov esi, r8d
3AEC72  8bfa                 mov edi, edx
3AEC74  488bd9               mov rbx, rcx
3AEC77  4585c0               test r8d, r8d
3AEC7A  7426                 je 0x1803aeca2
3AEC7C  83b95406000000       cmp dword ptr [rcx + 0x654], 0
3AEC83  7538                 jne 0x1803aecbd
3AEC85  488b8910010000       mov rcx, qword ptr [rcx + 0x110]
3AEC8C  4885c9               test rcx, rcx
3AEC8F  742c                 je 0x1803aecbd
3AEC91  488b01               mov rax, qword ptr [rcx]
3AEC94  41b801000000         mov r8d, 1
3AEC9A  ff9080000000         call qword ptr [rax + 0x80]
3AECA0  eb1b                 jmp 0x1803aecbd
3AECA2  488b8910010000       mov rcx, qword ptr [rcx + 0x110]
3AECA9  4885c9               test rcx, rcx
3AECAC  740f                 je 0x1803aecbd
3AECAE  488b01               mov rax, qword ptr [rcx]
3AECB1  41b801000000         mov r8d, 1
3AECB7  ff9088000000         call qword ptr [rax + 0x88]
3AECBD  4533c9               xor r9d, r9d
3AECC0  448bc6               mov r8d, esi
3AECC3  8bd7                 mov edx, edi
3AECC5  488bcb               mov rcx, rbx
3AECC8  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3AECCD  488b742438           mov rsi, qword ptr [rsp + 0x38]
3AECD2  4883c420             add rsp, 0x20
3AECD6  5f                   pop rdi
3AECD7  e9d42e0000           jmp 0x1803b1bb0
3AECDC  cc                   int3 
3AECDD  cc                   int3 
3AECDE  cc                   int3 
3AECDF  cc                   int3 
3AECE0  48895c2408           mov qword ptr [rsp + 8], rbx
3AECE5  4889742410           mov qword ptr [rsp + 0x10], rsi
3AECEA  57                   push rdi
3AECEB  4883ec20             sub rsp, 0x20
3AECEF  418bf0               mov esi, r8d
3AECF2  8bfa                 mov edi, edx
3AECF4  488bd9               mov rbx, rcx
3AECF7  4585c0               test r8d, r8d
3AECFA  7426                 je 0x1803aed22
3AECFC  83b95806000000       cmp dword ptr [rcx + 0x658], 0
3AED03  7538                 jne 0x1803aed3d
3AED05  488b8920010000       mov rcx, qword ptr [rcx + 0x120]
3AED0C  4885c9               test rcx, rcx
3AED0F  742c                 je 0x1803aed3d
3AED11  488b01               mov rax, qword ptr [rcx]
3AED14  41b801000000         mov r8d, 1
3AED1A  ff9080000000         call qword ptr [rax + 0x80]
3AED20  eb1b                 jmp 0x1803aed3d
3AED22  488b8920010000       mov rcx, qword ptr [rcx + 0x120]
3AED29  4885c9               test rcx, rcx
3AED2C  740f                 je 0x1803aed3d
3AED2E  488b01               mov rax, qword ptr [rcx]
3AED31  41b801000000         mov r8d, 1
3AED37  ff9088000000         call qword ptr [rax + 0x88]
3AED3D  41b901000000         mov r9d, 1
3AED43  448bc6               mov r8d, esi
3AED46  8bd7                 mov edx, edi
3AED48  488bcb               mov rcx, rbx
3AED4B  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3AED50  488b742438           mov rsi, qword ptr [rsp + 0x38]
3AED55  4883c420             add rsp, 0x20
3AED59  5f                   pop rdi
3AED5A  e9512e0000           jmp 0x1803b1bb0
3AED5F  cc                   int3 
3AED60  48895c2408           mov qword ptr [rsp + 8], rbx
3AED65  4889742410           mov qword ptr [rsp + 0x10], rsi
3AED6A  57                   push rdi
3AED6B  4883ec20             sub rsp, 0x20
3AED6F  418bf0               mov esi, r8d
3AED72  8bfa                 mov edi, edx
3AED74  488bd9               mov rbx, rcx
3AED77  4585c0               test r8d, r8d
3AED7A  7426                 je 0x1803aeda2
3AED7C  83b95c06000000       cmp dword ptr [rcx + 0x65c], 0
3AED83  7538                 jne 0x1803aedbd
3AED85  488b8930010000       mov rcx, qword ptr [rcx + 0x130]
3AED8C  4885c9               test rcx, rcx
3AED8F  742c                 je 0x1803aedbd
3AED91  488b01               mov rax, qword ptr [rcx]
3AED94  41b801000000         mov r8d, 1
3AED9A  ff9080000000         call qword ptr [rax + 0x80]

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
