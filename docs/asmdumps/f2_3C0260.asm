; f2_3C0260  rva 0x3C0260  384 bytes  (from the checksummed binary)
3C0260  4053                 push rbx
3C0262  55                   push rbp
3C0263  56                   push rsi
3C0264  57                   push rdi
3C0265  4155                 push r13
3C0267  4883ec20             sub rsp, 0x20
3C026B  488bd9               mov rbx, rcx
3C026E  4533c0               xor r8d, r8d
3C0271  8b89f00b0000         mov ecx, dword ptr [rcx + 0xbf0]
3C0277  ffc1                 inc ecx
3C0279  0fbe83ef0b0000       movsx eax, byte ptr [rbx + 0xbef]
3C0280  898bf00b0000         mov dword ptr [rbx + 0xbf0], ecx
3C0286  3bc8                 cmp ecx, eax
3C0288  7c10                 jl 0x1803c029a
3C028A  ff4334               inc dword ptr [rbx + 0x34]
3C028D  418bc8               mov ecx, r8d
3C0290  ff4338               inc dword ptr [rbx + 0x38]
3C0293  448983f00b0000       mov dword ptr [rbx + 0xbf0], r8d
3C029A  4863d1               movsxd rdx, ecx
3C029D  4c8dabe4030000       lea r13, [rbx + 0x3e4]
3C02A4  488db324030000       lea rsi, [rbx + 0x324]
3C02AB  bfffffffff           mov edi, 0xffffffff
3C02B0  418be8               mov ebp, r8d
3C02B3  488d0452             lea rax, [rdx + rdx*2]
3C02B7  48c1e206             shl rdx, 6
3C02BB  0fb78c4362020000     movzx ecx, word ptr [rbx + rax*2 + 0x262]
3C02C3  4c03ea               add r13, rdx
3C02C6  018be80b0000         add dword ptr [rbx + 0xbe8], ecx
3C02CC  443883ee0b0000       cmp byte ptr [rbx + 0xbee], r8b
3C02D3  0f8ef8010000         jle 0x1803c04d1
3C02D9  4c89642450           mov qword ptr [rsp + 0x50], r12
3C02DE  4c89742458           mov qword ptr [rsp + 0x58], r14
3C02E3  4c897c2460           mov qword ptr [rsp + 0x60], r15
3C02E8  0f1f840000000000     nop dword ptr [rax + rax]
3C02F0  450fb66500           movzx r12d, byte ptr [r13]
3C02F5  8bc7                 mov eax, edi
3C02F7  4183e47f             and r12d, 0x7f
3C02FB  0f84a8010000         je 0x1803c04a9
3C0301  837b100b             cmp dword ptr [rbx + 0x10], 0xb
3C0305  7c0d                 jl 0x1803c0314
3C0307  0fb63e               movzx edi, byte ptr [rsi]
3C030A  3bc7                 cmp eax, edi
3C030C  0f4df8               cmovge edi, eax
3C030F  e995010000           jmp 0x1803c04a9
3C0314  83bbf80c000000       cmp dword ptr [rbx + 0xcf8], 0
3C031B  0f8488010000         je 0x1803c04a9
3C0321  8bd5                 mov edx, ebp
3C0323  488bcb               mov rcx, rbx
3C0326  ff93980d0000         call qword ptr [rbx + 0xd98]
3C032C  4c63f8               movsxd r15, eax
3C032F  85c0                 test eax, eax
3C0331  0f8872010000         js 0x1803c04a9
3C0337  410fb68c1ffc0c0000   movzx ecx, byte ptr [r15 + rbx + 0xcfc]
3C0340  4d8bf7               mov r14, r15
3C0343  81f980000000         cmp ecx, 0x80
3C0349  7345                 jae 0x1803c0390
3C034B  3bcd                 cmp ecx, ebp
3C034D  0f8c56010000         jl 0x1803c04a9
3C0353  4883c143             add rcx, 0x43
3C0357  488d0449             lea rax, [rcx + rcx*2]
3C035B  0fb6548302           movzx edx, byte ptr [rbx + rax*4 + 2]
3C0360  4c8d3483             lea r14, [rbx + rax*4]
3C0364  81fa80000000         cmp edx, 0x80
3C036A  7321                 jae 0x1803c038d
3C036C  488b03               mov rax, qword ptr [rbx]
3C036F  41b840000000         mov r8d, 0x40
3C0375  488bcb               mov rcx, rbx
3C0378  ff5008               call qword ptr [rax + 8]
3C037B  490fbe4603           movsx rax, byte ptr [r14 + 3]
3C0380  c68418fc0c000080     mov byte ptr [rax + rbx + 0xcfc], 0x80
3C0388  41c6460280           mov byte ptr [r14 + 2], 0x80
3C038D  4d8bf7               mov r14, r15
3C0390  0fb65602             movzx edx, byte ptr [rsi + 2]
3C0394  81fa80000000         cmp edx, 0x80
3C039A  7320                 jae 0x1803c03bc
3C039C  488b03               mov rax, qword ptr [rbx]
3C039F  41b840000000         mov r8d, 0x40
3C03A5  488bcb               mov rcx, rbx
3C03A8  ff5008               call qword ptr [rax + 8]
3C03AB  480fbe4603           movsx rax, byte ptr [rsi + 3]
3C03B0  c68418fc0c000080     mov byte ptr [rax + rbx + 0xcfc], 0x80
3C03B8  c6460280             mov byte ptr [rsi + 2], 0x80
3C03BC  80bb8c0d000000       cmp byte ptr [rbx + 0xd8c], 0
3C03C3  743b                 je 0x1803c0400
3C03C5  8b8b940d0000         mov ecx, dword ptr [rbx + 0xd94]
3C03CB  85c9                 test ecx, ecx
3C03CD  7431                 je 0x1803c0400
3C03CF  8b83900d0000         mov eax, dword ptr [rbx + 0xd90]
3C03D5  c6838c0d000000       mov byte ptr [rbx + 0xd8c], 0
3C03DC  7810                 js 0x1803c03ee
3C03DE  ffc0                 inc eax

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
