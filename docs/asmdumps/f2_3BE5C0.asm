; f2_3BE5C0  rva 0x3BE5C0  768 bytes  (from the checksummed binary)
3BE5C0  48895c2408           mov qword ptr [rsp + 8], rbx
3BE5C5  486399f80c0000       movsxd rbx, dword ptr [rcx + 0xcf8]
3BE5CC  4c8bc1               mov r8, rcx
3BE5CF  0fbe81ee0b0000       movsx eax, byte ptr [rcx + 0xbee]
3BE5D6  8bd3                 mov edx, ebx
3BE5D8  448b91940d0000       mov r10d, dword ptr [rcx + 0xd94]
3BE5DF  b900000000           mov ecx, 0
3BE5E4  41ffc2               inc r10d
3BE5E7  440fafd3             imul r10d, ebx
3BE5EB  41ffca               dec r10d
3BE5EE  2bd0                 sub edx, eax
3BE5F0  8bc1                 mov eax, ecx
3BE5F2  0f49c2               cmovns eax, edx
3BE5F5  41394038             cmp dword ptr [r8 + 0x38], eax
3BE5F9  7e04                 jle 0x1803be5ff
3BE5FB  41894838             mov dword ptr [r8 + 0x38], ecx
3BE5FF  450fb698840d0000     movzx r11d, byte ptr [r8 + 0xd84]
3BE607  4584db               test r11b, r11b
3BE60A  7516                 jne 0x1803be622
3BE60C  418988880d0000       mov dword ptr [r8 + 0xd88], ecx
3BE613  448bc9               mov r9d, ecx
3BE616  41c680850d000001     mov byte ptr [r8 + 0xd85], 1
3BE61E  8bc1                 mov eax, ecx
3BE620  eb0a                 jmp 0x1803be62c
3BE622  458b88880d0000       mov r9d, dword ptr [r8 + 0xd88]
3BE629  418bc1               mov eax, r9d
3BE62C  453bca               cmp r9d, r10d
3BE62F  7e13                 jle 0x1803be644
3BE631  448d48ff             lea r9d, [rax - 1]
3BE635  418bc1               mov eax, r9d
3BE638  453bca               cmp r9d, r10d
3BE63B  7ff4                 jg 0x1803be631
3BE63D  418980880d0000       mov dword ptr [r8 + 0xd88], eax
3BE644  4585c9               test r9d, r9d
3BE647  790a                 jns 0x1803be653
3BE649  418988880d0000       mov dword ptr [r8 + 0xd88], ecx
3BE650  448bc9               mov r9d, ecx
3BE653  418bc1               mov eax, r9d
3BE656  99                   cdq 
3BE657  f7fb                 idiv ebx
3BE659  4863ca               movsxd rcx, edx
3BE65C  420fbe9401f80b0000   movsx edx, byte ptr [rcx + r8 + 0xbf8]
3BE665  418980900d0000       mov dword ptr [r8 + 0xd90], eax
3BE66C  85d2                 test edx, edx
3BE66E  7909                 jns 0x1803be679
3BE670  420fbe9403f70b0000   movsx edx, byte ptr [rbx + r8 + 0xbf7]
3BE679  4584db               test r11b, r11b
3BE67C  7508                 jne 0x1803be686
3BE67E  41c680840d000001     mov byte ptr [r8 + 0xd84], 1
3BE686  4180b8850d000000     cmp byte ptr [r8 + 0xd85], 0
3BE68E  41c6808c0d000000     mov byte ptr [r8 + 0xd8c], 0
3BE696  7420                 je 0x1803be6b8
3BE698  418d4901             lea ecx, [r9 + 1]
3BE69C  8bc2                 mov eax, edx
3BE69E  418988880d0000       mov dword ptr [r8 + 0xd88], ecx
3BE6A5  413bca               cmp ecx, r10d
3BE6A8  7c27                 jl 0x1803be6d1
3BE6AA  41c680850d000000     mov byte ptr [r8 + 0xd85], 0
3BE6B2  488b5c2408           mov rbx, qword ptr [rsp + 8]
3BE6B7  c3                   ret 
3BE6B8  418d41ff             lea eax, [r9 - 1]
3BE6BC  418980880d0000       mov dword ptr [r8 + 0xd88], eax
3BE6C3  85c0                 test eax, eax
3BE6C5  8bc2                 mov eax, edx
3BE6C7  7f08                 jg 0x1803be6d1
3BE6C9  41c680850d000001     mov byte ptr [r8 + 0xd85], 1
3BE6D1  488b5c2408           mov rbx, qword ptr [rsp + 8]
3BE6D6  c3                   ret 
3BE6D7  cc                   int3 
3BE6D8  cc                   int3 
3BE6D9  cc                   int3 
3BE6DA  cc                   int3 
3BE6DB  cc                   int3 
3BE6DC  cc                   int3 
3BE6DD  cc                   int3 
3BE6DE  cc                   int3 
3BE6DF  cc                   int3 
3BE6E0  0fbe81ee0b0000       movsx eax, byte ptr [rcx + 0xbee]
3BE6E7  4c8bc1               mov r8, rcx
3BE6EA  4c6389f80c0000       movsxd r9, dword ptr [rcx + 0xcf8]
3BE6F1  b900000000           mov ecx, 0
3BE6F6  418bd1               mov edx, r9d
3BE6F9  2bd0                 sub edx, eax
3BE6FB  8bc1                 mov eax, ecx
3BE6FD  0f49c2               cmovns eax, edx
3BE700  41394038             cmp dword ptr [r8 + 0x38], eax
3BE704  7e04                 jle 0x1803be70a
3BE706  41894838             mov dword ptr [r8 + 0x38], ecx
3BE70A  418b90880d0000       mov edx, dword ptr [r8 + 0xd88]
3BE711  418d41ff             lea eax, [r9 - 1]
3BE715  3bd0                 cmp edx, eax
3BE717  7e11                 jle 0x1803be72a
3BE719  418988880d0000       mov dword ptr [r8 + 0xd88], ecx
3BE720  8bd1                 mov edx, ecx
3BE722  41c6808c0d000001     mov byte ptr [r8 + 0xd8c], 1
3BE72A  85d2                 test edx, edx
3BE72C  7909                 jns 0x1803be737
3BE72E  418988880d0000       mov dword ptr [r8 + 0xd88], ecx
3BE735  8bd1                 mov edx, ecx
3BE737  450fb690840d0000     movzx r10d, byte ptr [r8 + 0xd84]
3BE73F  4584d2               test r10b, r10b
3BE742  7409                 je 0x1803be74d
3BE744  418bc9               mov ecx, r9d
3BE747  2bca                 sub ecx, edx
3BE749  ffc9                 dec ecx
3BE74B  eb09                 jmp 0x1803be756
3BE74D  418988880d0000       mov dword ptr [r8 + 0xd88], ecx
3BE754  8bd1                 mov edx, ecx
3BE756  4863c1               movsxd rax, ecx
3BE759  420fbe8400f80b0000   movsx eax, byte ptr [rax + r8 + 0xbf8]
3BE762  85c0                 test eax, eax
3BE764  7909                 jns 0x1803be76f
3BE766  430fbe8401f70b0000   movsx eax, byte ptr [r9 + r8 + 0xbf7]
3BE76F  4584d2               test r10b, r10b
3BE772  7508                 jne 0x1803be77c
3BE774  41c680840d000001     mov byte ptr [r8 + 0xd84], 1
3BE77C  8d4a01               lea ecx, [rdx + 1]
3BE77F  418988880d0000       mov dword ptr [r8 + 0xd88], ecx
3BE786  c3                   ret 
3BE787  cc                   int3 
3BE788  cc                   int3 
3BE789  cc                   int3 
3BE78A  cc                   int3 
3BE78B  cc                   int3 
3BE78C  cc                   int3 
3BE78D  cc                   int3 
3BE78E  cc                   int3 
3BE78F  cc                   int3 
3BE790  4c6389f80c0000       movsxd r9, dword ptr [rcx + 0xcf8]
3BE797  41b800000000         mov r8d, 0
3BE79D  440fbe99ee0b0000     movsx r11d, byte ptr [rcx + 0xbee]
3BE7A5  418bc1               mov eax, r9d
3BE7A8  448b5138             mov r10d, dword ptr [rcx + 0x38]
3BE7AC  412bc3               sub eax, r11d
3BE7AF  440f49c0             cmovns r8d, eax
3BE7B3  453bd0               cmp r10d, r8d
3BE7B6  7e0a                 jle 0x1803be7c2
3BE7B8  c7413800000000       mov dword ptr [rcx + 0x38], 0
3BE7BF  4533d2               xor r10d, r10d
3BE7C2  418d43ff             lea eax, [r11 - 1]
3BE7C6  3bd0                 cmp edx, eax
3BE7C8  7506                 jne 0x1803be7d0
3BE7CA  418d51ff             lea edx, [r9 - 1]
3BE7CE  eb0a                 jmp 0x1803be7da
3BE7D0  85d2                 test edx, edx
3BE7D2  7406                 je 0x1803be7da
3BE7D4  452bc2               sub r8d, r10d
3BE7D7  4103d0               add edx, r8d
3BE7DA  4863c2               movsxd rax, edx
3BE7DD  0fbe8408f80b0000     movsx eax, byte ptr [rax + rcx + 0xbf8]
3BE7E5  85c0                 test eax, eax
3BE7E7  7909                 jns 0x1803be7f2
3BE7E9  410fbe8409f70b0000   movsx eax, byte ptr [r9 + rcx + 0xbf7]
3BE7F2  c3                   ret 
3BE7F3  cc                   int3 
3BE7F4  cc                   int3 
3BE7F5  cc                   int3 
3BE7F6  cc                   int3 
3BE7F7  cc                   int3 
3BE7F8  cc                   int3 
3BE7F9  cc                   int3 
3BE7FA  cc                   int3 
3BE7FB  cc                   int3 
3BE7FC  cc                   int3 
3BE7FD  cc                   int3 
3BE7FE  cc                   int3 
3BE7FF  cc                   int3 
3BE800  0fbe81ee0b0000       movsx eax, byte ptr [rcx + 0xbee]
3BE807  4c6389f80c0000       movsxd r9, dword ptr [rcx + 0xcf8]
3BE80E  458bc1               mov r8d, r9d
3BE811  442bc0               sub r8d, eax
3BE814  b800000000           mov eax, 0
3BE819  410f49c0             cmovns eax, r8d
3BE81D  448b4138             mov r8d, dword ptr [rcx + 0x38]
3BE821  443bc0               cmp r8d, eax
3BE824  7e0a                 jle 0x1803be830
3BE826  c7413800000000       mov dword ptr [rcx + 0x38], 0
3BE82D  4533c0               xor r8d, r8d
3BE830  412bc0               sub eax, r8d
3BE833  03c2                 add eax, edx
3BE835  4898                 cdqe 
3BE837  0fbe8408f80b0000     movsx eax, byte ptr [rax + rcx + 0xbf8]
3BE83F  85c0                 test eax, eax
3BE841  7909                 jns 0x1803be84c
3BE843  410fbe8409f70b0000   movsx eax, byte ptr [r9 + rcx + 0xbf7]
3BE84C  c3                   ret 
3BE84D  cc                   int3 
3BE84E  cc                   int3 
3BE84F  cc                   int3 
3BE850  48895c2408           mov qword ptr [rsp + 8], rbx
3BE855  486399f80c0000       movsxd rbx, dword ptr [rcx + 0xcf8]
3BE85C  4c8bc9               mov r9, rcx
3BE85F  0fbe81ee0b0000       movsx eax, byte ptr [rcx + 0xbee]
3BE866  8bd3                 mov edx, ebx
3BE868  448b91940d0000       mov r10d, dword ptr [rcx + 0xd94]
3BE86F  b900000000           mov ecx, 0
3BE874  41ffc2               inc r10d
3BE877  440fafd3             imul r10d, ebx
3BE87B  41ffca               dec r10d
3BE87E  2bd0                 sub edx, eax
3BE880  8bc1                 mov eax, ecx
3BE882  0f49c2               cmovns eax, edx
3BE885  41394138             cmp dword ptr [r9 + 0x38], eax
3BE889  7e04                 jle 0x1803be88f
3BE88B  41894938             mov dword ptr [r9 + 0x38], ecx
3BE88F  450fb699840d0000     movzx r11d, byte ptr [r9 + 0xd84]
3BE897  4584db               test r11b, r11b
3BE89A  750f                 jne 0x1803be8ab
3BE89C  458991880d0000       mov dword ptr [r9 + 0xd88], r10d
3BE8A3  458bc2               mov r8d, r10d
3BE8A6  418bc2               mov eax, r10d
3BE8A9  eb0a                 jmp 0x1803be8b5
3BE8AB  458b81880d0000       mov r8d, dword ptr [r9 + 0xd88]
3BE8B2  418bc0               mov eax, r8d
3BE8B5  453bc2               cmp r8d, r10d
3BE8B8  7e19                 jle 0x1803be8d3
3BE8BA  660f1f440000         nop word ptr [rax + rax]

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
