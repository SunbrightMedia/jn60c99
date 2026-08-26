; f2_3BEFC0  rva 0x3BEFC0  384 bytes  (from the checksummed binary)
3BEFC0  4c6389f80c0000       movsxd r9, dword ptr [rcx + 0xcf8]
3BEFC7  4533d2               xor r10d, r10d
3BEFCA  0fbe81ee0b0000       movsx eax, byte ptr [rcx + 0xbee]
3BEFD1  418bd1               mov edx, r9d
3BEFD4  2bd0                 sub edx, eax
3BEFD6  4c8bc1               mov r8, rcx
3BEFD9  395138               cmp dword ptr [rcx + 0x38], edx
3BEFDC  7e04                 jle 0x1803befe2
3BEFDE  44895138             mov dword ptr [rcx + 0x38], r10d
3BEFE2  8b89880d0000         mov ecx, dword ptr [rcx + 0xd88]
3BEFE8  418d41ff             lea eax, [r9 - 1]
3BEFEC  3bc8                 cmp ecx, eax
3BEFEE  7e12                 jle 0x1803bf002
3BEFF0  458990880d0000       mov dword ptr [r8 + 0xd88], r10d
3BEFF7  418bca               mov ecx, r10d
3BEFFA  41c6808c0d000001     mov byte ptr [r8 + 0xd8c], 1
3BF002  85c9                 test ecx, ecx
3BF004  790a                 jns 0x1803bf010
3BF006  458990880d0000       mov dword ptr [r8 + 0xd88], r10d
3BF00D  418bca               mov ecx, r10d
3BF010  410fb690840d0000     movzx edx, byte ptr [r8 + 0xd84]
3BF018  84d2                 test dl, dl
3BF01A  750a                 jne 0x1803bf026
3BF01C  458990880d0000       mov dword ptr [r8 + 0xd88], r10d
3BF023  418bca               mov ecx, r10d
3BF026  4863c1               movsxd rax, ecx
3BF029  420fbe8400f80b0000   movsx eax, byte ptr [rax + r8 + 0xbf8]
3BF032  85c0                 test eax, eax
3BF034  7909                 jns 0x1803bf03f
3BF036  430fbe8401f70b0000   movsx eax, byte ptr [r9 + r8 + 0xbf7]
3BF03F  84d2                 test dl, dl
3BF041  7508                 jne 0x1803bf04b
3BF043  41c680840d000001     mov byte ptr [r8 + 0xd84], 1
3BF04B  ffc1                 inc ecx
3BF04D  418988880d0000       mov dword ptr [r8 + 0xd88], ecx
3BF054  c3                   ret 
3BF055  cc                   int3 
3BF056  cc                   int3 
3BF057  cc                   int3 
3BF058  cc                   int3 
3BF059  cc                   int3 
3BF05A  cc                   int3 
3BF05B  cc                   int3 
3BF05C  cc                   int3 
3BF05D  cc                   int3 
3BF05E  cc                   int3 
3BF05F  cc                   int3 
3BF060  4c6389f80c0000       movsxd r9, dword ptr [rcx + 0xcf8]
3BF067  440fbe91ee0b0000     movsx r10d, byte ptr [rcx + 0xbee]
3BF06F  418bc1               mov eax, r9d
3BF072  448b4138             mov r8d, dword ptr [rcx + 0x38]
3BF076  412bc2               sub eax, r10d
3BF079  443bc0               cmp r8d, eax
3BF07C  7e07                 jle 0x1803bf085
3BF07E  4533c0               xor r8d, r8d
3BF081  44894138             mov dword ptr [rcx + 0x38], r8d
3BF085  418d42ff             lea eax, [r10 - 1]
3BF089  3bd0                 cmp edx, eax
3BF08B  7506                 jne 0x1803bf093
3BF08D  418d51ff             lea edx, [r9 - 1]
3BF091  eb07                 jmp 0x1803bf09a
3BF093  85d2                 test edx, edx
3BF095  7403                 je 0x1803bf09a
3BF097  4103d0               add edx, r8d
3BF09A  4863c2               movsxd rax, edx
3BF09D  0fbe8408f80b0000     movsx eax, byte ptr [rax + rcx + 0xbf8]
3BF0A5  85c0                 test eax, eax
3BF0A7  7909                 jns 0x1803bf0b2
3BF0A9  410fbe8409f70b0000   movsx eax, byte ptr [r9 + rcx + 0xbf7]
3BF0B2  c3                   ret 
3BF0B3  cc                   int3 
3BF0B4  cc                   int3 
3BF0B5  cc                   int3 
3BF0B6  cc                   int3 
3BF0B7  cc                   int3 
3BF0B8  cc                   int3 
3BF0B9  cc                   int3 
3BF0BA  cc                   int3 
3BF0BB  cc                   int3 
3BF0BC  cc                   int3 
3BF0BD  cc                   int3 
3BF0BE  cc                   int3 
3BF0BF  cc                   int3 
3BF0C0  4c6391f80c0000       movsxd r10, dword ptr [rcx + 0xcf8]
3BF0C7  4c8bc9               mov r9, rcx
3BF0CA  8b4938               mov ecx, dword ptr [rcx + 0x38]
3BF0CD  458bc2               mov r8d, r10d
3BF0D0  410fbe81ee0b0000     movsx eax, byte ptr [r9 + 0xbee]
3BF0D8  442bc0               sub r8d, eax
3BF0DB  413bc8               cmp ecx, r8d
3BF0DE  7e06                 jle 0x1803bf0e6
3BF0E0  33c9                 xor ecx, ecx
3BF0E2  41894938             mov dword ptr [r9 + 0x38], ecx
3BF0E6  8d0411               lea eax, [rcx + rdx]
3BF0E9  4863c8               movsxd rcx, eax
3BF0EC  420fbe8409f80b0000   movsx eax, byte ptr [rcx + r9 + 0xbf8]
3BF0F5  85c0                 test eax, eax
3BF0F7  7909                 jns 0x1803bf102
3BF0F9  430fbe840af70b0000   movsx eax, byte ptr [r10 + r9 + 0xbf7]
3BF102  c3                   ret 
3BF103  cc                   int3 
3BF104  cc                   int3 
3BF105  cc                   int3 
3BF106  cc                   int3 
3BF107  cc                   int3 
3BF108  cc                   int3 
3BF109  cc                   int3 
3BF10A  cc                   int3 
3BF10B  cc                   int3 
3BF10C  cc                   int3 
3BF10D  cc                   int3 
3BF10E  cc                   int3 
3BF10F  cc                   int3 
3BF110  4053                 push rbx
3BF112  4883ec20             sub rsp, 0x20
3BF116  4863c2               movsxd rax, edx
3BF119  488bd9               mov rbx, rcx
3BF11C  41b8ff7f0000         mov r8d, 0x7fff
3BF122  488d0c41             lea rcx, [rcx + rax*2]
3BF126  0fb781d0000000       movzx eax, word ptr [rcx + 0xd0]
3BF12D  664123c0             and ax, r8w
3BF131  7506                 jne 0x1803bf139
3BF133  4883c420             add rsp, 0x20
3BF137  5b                   pop rbx
3BF138  c3                   ret 
3BF139  66ffc8               dec ax

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
