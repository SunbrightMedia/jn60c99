; setsr_container_3BC980  rva 0x3BC980  384 bytes  (from the checksummed binary)
3BC980  48895c2408           mov qword ptr [rsp + 8], rbx
3BC985  48896c2410           mov qword ptr [rsp + 0x10], rbp
3BC98A  4889742418           mov qword ptr [rsp + 0x18], rsi
3BC98F  57                   push rdi
3BC990  4154                 push r12
3BC992  4155                 push r13
3BC994  4156                 push r14
3BC996  4157                 push r15
3BC998  4883ec20             sub rsp, 0x20
3BC99C  4863b14c060000       movsxd rsi, dword ptr [rcx + 0x64c]
3BC9A3  8bfa                 mov edi, edx
3BC9A5  488be9               mov rbp, rcx
3BC9A8  3bb150060000         cmp esi, dword ptr [rcx + 0x650]
3BC9AE  7f6d                 jg 0x1803bca1d
3BC9B0  488d5e01             lea rbx, [rsi + 1]
3BC9B4  48c1e304             shl rbx, 4
3BC9B8  4803d9               add rbx, rcx
3BC9BB  0f1f440000           nop dword ptr [rax + rax]
3BC9C0  488b8b00010000       mov rcx, qword ptr [rbx + 0x100]
3BC9C7  4885c9               test rcx, rcx
3BC9CA  7408                 je 0x1803bc9d4
3BC9CC  488b01               mov rax, qword ptr [rcx]
3BC9CF  8bd7                 mov edx, edi
3BC9D1  ff5078               call qword ptr [rax + 0x78]
3BC9D4  488b0b               mov rcx, qword ptr [rbx]
3BC9D7  4885c9               test rcx, rcx
3BC9DA  740b                 je 0x1803bc9e7
3BC9DC  488b01               mov rax, qword ptr [rcx]
3BC9DF  8bd7                 mov edx, edi
3BC9E1  ff90a0000000         call qword ptr [rax + 0xa0]
3BC9E7  488b8b80000000       mov rcx, qword ptr [rbx + 0x80]
3BC9EE  4885c9               test rcx, rcx
3BC9F1  7408                 je 0x1803bc9fb
3BC9F3  488b01               mov rax, qword ptr [rcx]
3BC9F6  8bd7                 mov edx, edi
3BC9F8  ff5060               call qword ptr [rax + 0x60]
3BC9FB  488b8b80020000       mov rcx, qword ptr [rbx + 0x280]
3BCA02  4885c9               test rcx, rcx
3BCA05  7408                 je 0x1803bca0f
3BCA07  488b01               mov rax, qword ptr [rcx]
3BCA0A  8bd7                 mov edx, edi
3BCA0C  ff5068               call qword ptr [rax + 0x68]
3BCA0F  ffc6                 inc esi
3BCA11  4883c310             add rbx, 0x10
3BCA15  3bb550060000         cmp esi, dword ptr [rbp + 0x650]
3BCA1B  7ea3                 jle 0x1803bc9c0
3BCA1D  488b8d90030000       mov rcx, qword ptr [rbp + 0x390]
3BCA24  4885c9               test rcx, rcx
3BCA27  7408                 je 0x1803bca31
3BCA29  488b01               mov rax, qword ptr [rcx]
3BCA2C  8bd7                 mov edx, edi
3BCA2E  ff5040               call qword ptr [rax + 0x40]
3BCA31  488b8da0030000       mov rcx, qword ptr [rbp + 0x3a0]
3BCA38  4885c9               test rcx, rcx
3BCA3B  7408                 je 0x1803bca45
3BCA3D  488b01               mov rax, qword ptr [rcx]
3BCA40  8bd7                 mov edx, edi
3BCA42  ff5038               call qword ptr [rax + 0x38]
3BCA45  488b85801a0000       mov rax, qword ptr [rbp + 0x1a80]
3BCA4C  488d8d801a0000       lea rcx, [rbp + 0x1a80]
3BCA53  8bd7                 mov edx, edi
3BCA55  ff90b0000000         call qword ptr [rax + 0xb0]
3BCA5B  488b85401b0000       mov rax, qword ptr [rbp + 0x1b40]
3BCA62  488d8d401b0000       lea rcx, [rbp + 0x1b40]
3BCA69  8bd7                 mov edx, edi
3BCA6B  ff90b0000000         call qword ptr [rax + 0xb0]
3BCA71  488b85101c0000       mov rax, qword ptr [rbp + 0x1c10]
3BCA78  488d8d101c0000       lea rcx, [rbp + 0x1c10]
3BCA7F  8bd7                 mov edx, edi
3BCA81  ff90c8000000         call qword ptr [rax + 0xc8]
3BCA87  488b85e81c0000       mov rax, qword ptr [rbp + 0x1ce8]
3BCA8E  488d8de81c0000       lea rcx, [rbp + 0x1ce8]
3BCA95  8bd7                 mov edx, edi
3BCA97  ff90c8000000         call qword ptr [rax + 0xc8]
3BCA9D  488b85c01d0000       mov rax, qword ptr [rbp + 0x1dc0]
3BCAA4  488d8dc01d0000       lea rcx, [rbp + 0x1dc0]
3BCAAB  8bd7                 mov edx, edi
3BCAAD  ff90c8000000         call qword ptr [rax + 0xc8]
3BCAB3  488b85901e0000       mov rax, qword ptr [rbp + 0x1e90]
3BCABA  488d8d901e0000       lea rcx, [rbp + 0x1e90]
3BCAC1  8bd7                 mov edx, edi
3BCAC3  ff9040010000         call qword ptr [rax + 0x140]
3BCAC9  488d8df01f0000       lea rcx, [rbp + 0x1ff0]
3BCAD0  8bd7                 mov edx, edi
3BCAD2  488b01               mov rax, qword ptr [rcx]
3BCAD5  ff5010               call qword ptr [rax + 0x10]
3BCAD8  486385c8050000       movsxd rax, dword ptr [rbp + 0x5c8]
3BCADF  83f805               cmp eax, 5
3BCAE2  0f8795000000         ja 0x1803bcb7d
3BCAE8  488d0d1135c4ff       lea rcx, [rip - 0x3bcaef]
3BCAEF  8b94819ccb3b00       mov edx, dword ptr [rcx + rax*4 + 0x3bcb9c]
3BCAF6  4803d1               add rdx, rcx
3BCAF9  ffe2                 jmp rdx

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
