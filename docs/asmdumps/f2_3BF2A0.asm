; f2_3BF2A0  rva 0x3BF2A0  384 bytes  (from the checksummed binary)
3BF2A0  4c63ca               movsxd r9, edx
3BF2A3  4180bc09780c000000   cmp byte ptr [r9 + rcx + 0xc78], 0
3BF2AC  0f8401010000         je 0x1803bf3b3
3BF2B2  80b9a10d000000       cmp byte ptr [rcx + 0xda1], 0
3BF2B9  7551                 jne 0x1803bf30c
3BF2BB  4c6381f80c0000       movsxd r8, dword ptr [rcx + 0xcf8]
3BF2C2  41baffffffff         mov r10d, 0xffffffff
3BF2C8  418d40ff             lea eax, [r8 - 1]
3BF2CC  8981f80c0000         mov dword ptr [rcx + 0xcf8], eax
3BF2D2  498bc0               mov rax, r8
3BF2D5  4883e801             sub rax, 1
3BF2D9  7865                 js 0x1803bf340
3BF2DB  488d91f80b0000       lea rdx, [rcx + 0xbf8]
3BF2E2  49c7c008f4ffff       mov r8, 0xfffffffffffff408
3BF2E9  4803d0               add rdx, rax
3BF2EC  4c2bc1               sub r8, rcx
3BF2EF  90                   nop 
3BF2F0  0fbe02               movsx eax, byte ptr [rdx]
3BF2F3  448812               mov byte ptr [rdx], r10b
3BF2F6  448bd0               mov r10d, eax
3BF2F9  413bc1               cmp eax, r9d
3BF2FC  7442                 je 0x1803bf340
3BF2FE  48ffca               dec rdx
3BF301  498d0410             lea rax, [r8 + rdx]
3BF305  4885c0               test rax, rax
3BF308  79e6                 jns 0x1803bf2f0
3BF30A  eb34                 jmp 0x1803bf340
3BF30C  4533c0               xor r8d, r8d
3BF30F  33d2                 xor edx, edx
3BF311  0fbe8411f80b0000     movsx eax, byte ptr [rcx + rdx + 0xbf8]
3BF319  413bc1               cmp eax, r9d
3BF31C  7411                 je 0x1803bf32f
3BF31E  41ffc0               inc r8d
3BF321  48ffc2               inc rdx
3BF324  4881fa80000000       cmp rdx, 0x80
3BF32B  7ce4                 jl 0x1803bf311
3BF32D  eb11                 jmp 0x1803bf340
3BF32F  4963c0               movsxd rax, r8d
3BF332  c68408f80b0000ff     mov byte ptr [rax + rcx + 0xbf8], 0xff
3BF33A  ff89f80c0000         dec dword ptr [rcx + 0xcf8]
3BF340  41c68409780c000000   mov byte ptr [r9 + rcx + 0xc78], 0
3BF349  486391f80c0000       movsxd rdx, dword ptr [rcx + 0xcf8]
3BF350  85d2                 test edx, edx
3BF352  7e0b                 jle 0x1803bf35f
3BF354  440fb6840af70b0000   movzx r8d, byte ptr [rdx + rcx + 0xbf7]
3BF35D  eb03                 jmp 0x1803bf362
3BF35F  41b0ff               mov r8b, 0xff
3BF362  4488817c0d0000       mov byte ptr [rcx + 0xd7c], r8b
3BF369  85d2                 test edx, edx
3BF36B  7f46                 jg 0x1803bf3b3
3BF36D  c781880d000000000000 mov dword ptr [rcx + 0xd88], 0
3BF377  c781900d000000000000 mov dword ptr [rcx + 0xd90], 0
3BF381  c6818c0d000000       mov byte ptr [rcx + 0xd8c], 0
3BF388  7529                 jne 0x1803bf3b3
3BF38A  6683b95002000000     cmp word ptr [rcx + 0x250], 0
3BF392  751f                 jne 0x1803bf3b3
3BF394  83b9cc00000000       cmp dword ptr [rcx + 0xcc], 0
3BF39B  7516                 jne 0x1803bf3b3
3BF39D  8b412c               mov eax, dword ptr [rcx + 0x2c]
3BF3A0  ffc8                 dec eax
3BF3A2  83f802               cmp eax, 2
3BF3A5  770c                 ja 0x1803bf3b3
3BF3A7  c7412c00000000       mov dword ptr [rcx + 0x2c], 0
3BF3AE  e9eddfffff           jmp 0x1803bd3a0
3BF3B3  c3                   ret 
3BF3B4  cc                   int3 
3BF3B5  cc                   int3 
3BF3B6  cc                   int3 
3BF3B7  cc                   int3 
3BF3B8  cc                   int3 
3BF3B9  cc                   int3 
3BF3BA  cc                   int3 
3BF3BB  cc                   int3 
3BF3BC  cc                   int3 
3BF3BD  cc                   int3 
3BF3BE  cc                   int3 
3BF3BF  cc                   int3 
3BF3C0  448b4110             mov r8d, dword ptr [rcx + 0x10]
3BF3C4  e907000000           jmp 0x1803bf3d0
3BF3C9  cc                   int3 
3BF3CA  cc                   int3 
3BF3CB  cc                   int3 
3BF3CC  cc                   int3 
3BF3CD  cc                   int3 
3BF3CE  cc                   int3 
3BF3CF  cc                   int3 
3BF3D0  48895c2408           mov qword ptr [rsp + 8], rbx
3BF3D5  48896c2410           mov qword ptr [rsp + 0x10], rbp
3BF3DA  4889742418           mov qword ptr [rsp + 0x18], rsi
3BF3DF  57                   push rdi
3BF3E0  4156                 push r14
3BF3E2  4157                 push r15
3BF3E4  4533d2               xor r10d, r10d
3BF3E7  4c8d9962020000       lea r11, [rcx + 0x262]
3BF3EE  85d2                 test edx, edx
3BF3F0  b809000000           mov eax, 9
3BF3F5  458bca               mov r9d, r10d
3BF3F8  bb01000000           mov ebx, 1
3BF3FD  440f49ca             cmovns r9d, edx
3BF401  4183f90a             cmp r9d, 0xa
3BF405  440f4dc8             cmovge r9d, eax
3BF409  448d7b63             lea r15d, [rbx + 0x63]
3BF40D  4489490c             mov dword ptr [rcx + 0xc], r9d
3BF411  4585c0               test r8d, r8d
3BF414  450f49d0             cmovns r10d, r8d
3BF418  4c8d05e10bc4ff       lea r8, [rip - 0x3bf41f]

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
