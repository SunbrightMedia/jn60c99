; cand6_ratelaw_356D00  rva 0x356D00  288 bytes  (from the checksummed binary)
356D00  418bd8               mov ebx, r8d
356D03  e878f6ffff           call 0x180356380
356D08  448bc3               mov r8d, ebx
356D0B  488d0db6a09500       lea rcx, [rip + 0x95a0b6]
356D12  ba02000000           mov edx, 2
356D17  0f28f0               movaps xmm6, xmm0
356D1A  e861f6ffff           call 0x180356380
356D1F  448bc3               mov r8d, ebx
356D22  488d0d9fa09500       lea rcx, [rip + 0x95a09f]
356D29  ba03000000           mov edx, 3
356D2E  440f28c8             movaps xmm9, xmm0
356D32  e849f6ffff           call 0x180356380
356D37  8b8734040000         mov eax, dword ptr [rdi + 0x434]
356D3D  0f28f8               movaps xmm7, xmm0
356D40  f30f583d6ce37800     addss xmm7, dword ptr [rip + 0x78e36c]
356D48  3d00770100           cmp eax, 0x17700
356D4D  7413                 je 0x180356d62
356D4F  f30f5935d5126300     mulss xmm6, dword ptr [rip + 0x6312d5]
356D57  660f6ec0             movd xmm0, eax
356D5B  0f5bc0               cvtdq2ps xmm0, xmm0
356D5E  f30f5ef0             divss xmm6, xmm0
356D62  448b8758040000       mov r8d, dword ptr [rdi + 0x458]
356D69  33db                 xor ebx, ebx
356D6B  8b5714               mov edx, dword ptr [rdi + 0x14]
356D6E  0f28de               movaps xmm3, xmm6
356D71  488b4f08             mov rcx, qword ptr [rdi + 8]
356D75  85f6                 test esi, esi
356D77  750f                 jne 0x180356d88
356D79  895c2428             mov dword ptr [rsp + 0x28], ebx
356D7D  895c2420             mov dword ptr [rsp + 0x20], ebx
356D81  e84aa30600           call 0x1803c10d0
356D86  eb05                 jmp 0x180356d8d
356D88  e803a30600           call 0x1803c1090
356D8D  448b875c040000       mov r8d, dword ptr [rdi + 0x45c]
356D94  8b5714               mov edx, dword ptr [rdi + 0x14]
356D97  488b4f08             mov rcx, qword ptr [rdi + 8]
356D9B  f30f101d11e37800     movss xmm3, dword ptr [rip + 0x78e311]
356DA3  85f6                 test esi, esi
356DA5  750f                 jne 0x180356db6
356DA7  895c2428             mov dword ptr [rsp + 0x28], ebx
356DAB  895c2420             mov dword ptr [rsp + 0x20], ebx
356DAF  e81ca30600           call 0x1803c10d0
356DB4  eb05                 jmp 0x180356dbb
356DB6  e8d5a20600           call 0x1803c1090
356DBB  448b8760040000       mov r8d, dword ptr [rdi + 0x460]
356DC2  410f28d9             movaps xmm3, xmm9
356DC6  8b5714               mov edx, dword ptr [rdi + 0x14]
356DC9  488b4f08             mov rcx, qword ptr [rdi + 8]
356DCD  85f6                 test esi, esi
356DCF  750f                 jne 0x180356de0
356DD1  895c2428             mov dword ptr [rsp + 0x28], ebx
356DD5  895c2420             mov dword ptr [rsp + 0x20], ebx
356DD9  e8f2a20600           call 0x1803c10d0
356DDE  eb05                 jmp 0x180356de5
356DE0  e8aba20600           call 0x1803c1090
356DE5  448b8764040000       mov r8d, dword ptr [rdi + 0x464]
356DEC  0f28df               movaps xmm3, xmm7
356DEF  8b5714               mov edx, dword ptr [rdi + 0x14]
356DF2  488b4f08             mov rcx, qword ptr [rdi + 8]
356DF6  85f6                 test esi, esi
356DF8  750f                 jne 0x180356e09
356DFA  895c2428             mov dword ptr [rsp + 0x28], ebx
356DFE  895c2420             mov dword ptr [rsp + 0x20], ebx
356E02  e8c9a20600           call 0x1803c10d0
356E07  eb05                 jmp 0x180356e0e
356E09  e882a20600           call 0x1803c1090
356E0E  488b5c2470           mov rbx, qword ptr [rsp + 0x70]
356E13  488b742478           mov rsi, qword ptr [rsp + 0x78]
356E18  0f28742450           movaps xmm6, xmmword ptr [rsp + 0x50]

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
