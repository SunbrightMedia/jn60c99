; f2_3B0650  rva 0x3B0650  512 bytes  (from the checksummed binary)
3B0650  418bc0               mov eax, r8d
3B0653  4c8bc9               mov r9, rcx
3B0656  85d2                 test edx, edx
3B0658  7540                 jne 0x1803b069a
3B065A  448b81fc040000       mov r8d, dword ptr [rcx + 0x4fc]
3B0661  85c0                 test eax, eax
3B0663  7426                 je 0x1803b068b
3B0665  7e0a                 jle 0x1803b0671
3B0667  b9ff000000           mov ecx, 0xff
3B066C  412bc8               sub ecx, r8d
3B066F  eb03                 jmp 0x1803b0674
3B0671  418bc8               mov ecx, r8d
3B0674  0fafc8               imul ecx, eax
3B0677  b81f85eb51           mov eax, 0x51eb851f
3B067C  f7e9                 imul ecx
3B067E  c1fa05               sar edx, 5
3B0681  8bc2                 mov eax, edx
3B0683  c1e81f               shr eax, 0x1f
3B0686  03d0                 add edx, eax
3B0688  4403c2               add r8d, edx
3B068B  498b01               mov rax, qword ptr [r9]
3B068E  33d2                 xor edx, edx
3B0690  498bc9               mov rcx, r9
3B0693  48ffa068080000       jmp qword ptr [rax + 0x868]
3B069A  c3                   ret 
3B069B  cc                   int3 
3B069C  cc                   int3 
3B069D  cc                   int3 
3B069E  cc                   int3 
3B069F  cc                   int3 
3B06A0  418bc0               mov eax, r8d
3B06A3  4c8bc9               mov r9, rcx
3B06A6  85d2                 test edx, edx
3B06A8  7540                 jne 0x1803b06ea
3B06AA  448b81dc040000       mov r8d, dword ptr [rcx + 0x4dc]
3B06B1  85c0                 test eax, eax
3B06B3  7426                 je 0x1803b06db
3B06B5  7e0a                 jle 0x1803b06c1
3B06B7  b9ff000000           mov ecx, 0xff
3B06BC  412bc8               sub ecx, r8d
3B06BF  eb03                 jmp 0x1803b06c4
3B06C1  418bc8               mov ecx, r8d
3B06C4  0fafc8               imul ecx, eax
3B06C7  b81f85eb51           mov eax, 0x51eb851f
3B06CC  f7e9                 imul ecx
3B06CE  c1fa05               sar edx, 5
3B06D1  8bc2                 mov eax, edx
3B06D3  c1e81f               shr eax, 0x1f
3B06D6  03d0                 add edx, eax
3B06D8  4403c2               add r8d, edx
3B06DB  498b01               mov rax, qword ptr [r9]
3B06DE  33d2                 xor edx, edx
3B06E0  498bc9               mov rcx, r9
3B06E3  48ffa028080000       jmp qword ptr [rax + 0x828]
3B06EA  c3                   ret 
3B06EB  cc                   int3 
3B06EC  cc                   int3 
3B06ED  cc                   int3 
3B06EE  cc                   int3 
3B06EF  cc                   int3 
3B06F0  418bc0               mov eax, r8d
3B06F3  4c8bc9               mov r9, rcx
3B06F6  85d2                 test edx, edx
3B06F8  7540                 jne 0x1803b073a
3B06FA  448b8140050000       mov r8d, dword ptr [rcx + 0x540]
3B0701  85c0                 test eax, eax
3B0703  7426                 je 0x1803b072b
3B0705  7e0a                 jle 0x1803b0711
3B0707  b9ff000000           mov ecx, 0xff
3B070C  412bc8               sub ecx, r8d
3B070F  eb03                 jmp 0x1803b0714
3B0711  418bc8               mov ecx, r8d
3B0714  0fafc8               imul ecx, eax
3B0717  b81f85eb51           mov eax, 0x51eb851f
3B071C  f7e9                 imul ecx
3B071E  c1fa05               sar edx, 5
3B0721  8bc2                 mov eax, edx
3B0723  c1e81f               shr eax, 0x1f
3B0726  03d0                 add edx, eax
3B0728  4403c2               add r8d, edx
3B072B  498b01               mov rax, qword ptr [r9]
3B072E  33d2                 xor edx, edx
3B0730  498bc9               mov rcx, r9
3B0733  48ffa0f0080000       jmp qword ptr [rax + 0x8f0]
3B073A  c3                   ret 
3B073B  cc                   int3 
3B073C  cc                   int3 
3B073D  cc                   int3 
3B073E  cc                   int3 
3B073F  cc                   int3 
3B0740  418bc0               mov eax, r8d
3B0743  4c8bc9               mov r9, rcx
3B0746  85d2                 test edx, edx
3B0748  7540                 jne 0x1803b078a
3B074A  448b8130050000       mov r8d, dword ptr [rcx + 0x530]
3B0751  85c0                 test eax, eax
3B0753  7426                 je 0x1803b077b
3B0755  7e0a                 jle 0x1803b0761
3B0757  b9ff000000           mov ecx, 0xff
3B075C  412bc8               sub ecx, r8d
3B075F  eb03                 jmp 0x1803b0764
3B0761  418bc8               mov ecx, r8d
3B0764  0fafc8               imul ecx, eax
3B0767  b81f85eb51           mov eax, 0x51eb851f
3B076C  f7e9                 imul ecx
3B076E  c1fa05               sar edx, 5
3B0771  8bc2                 mov eax, edx
3B0773  c1e81f               shr eax, 0x1f
3B0776  03d0                 add edx, eax
3B0778  4403c2               add r8d, edx
3B077B  498b01               mov rax, qword ptr [r9]
3B077E  33d2                 xor edx, edx
3B0780  498bc9               mov rcx, r9
3B0783  48ffa0d0080000       jmp qword ptr [rax + 0x8d0]
3B078A  c3                   ret 
3B078B  cc                   int3 
3B078C  cc                   int3 
3B078D  cc                   int3 
3B078E  cc                   int3 
3B078F  cc                   int3 
3B0790  c20000               ret 0
3B0793  cc                   int3 
3B0794  cc                   int3 
3B0795  cc                   int3 
3B0796  cc                   int3 
3B0797  cc                   int3 
3B0798  cc                   int3 
3B0799  cc                   int3 
3B079A  cc                   int3 
3B079B  cc                   int3 
3B079C  cc                   int3 
3B079D  cc                   int3 
3B079E  cc                   int3 
3B079F  cc                   int3 
3B07A0  8991a0050000         mov dword ptr [rcx + 0x5a0], edx
3B07A6  c3                   ret 
3B07A7  cc                   int3 
3B07A8  cc                   int3 
3B07A9  cc                   int3 
3B07AA  cc                   int3 
3B07AB  cc                   int3 
3B07AC  cc                   int3 
3B07AD  cc                   int3 
3B07AE  cc                   int3 
3B07AF  cc                   int3 
3B07B0  89919c050000         mov dword ptr [rcx + 0x59c], edx
3B07B6  c3                   ret 
3B07B7  cc                   int3 
3B07B8  cc                   int3 
3B07B9  cc                   int3 
3B07BA  cc                   int3 
3B07BB  cc                   int3 
3B07BC  cc                   int3 
3B07BD  cc                   int3 
3B07BE  cc                   int3 
3B07BF  cc                   int3 
3B07C0  8991a4050000         mov dword ptr [rcx + 0x5a4], edx
3B07C6  c3                   ret 
3B07C7  cc                   int3 
3B07C8  cc                   int3 
3B07C9  cc                   int3 
3B07CA  cc                   int3 
3B07CB  cc                   int3 
3B07CC  cc                   int3 
3B07CD  cc                   int3 
3B07CE  cc                   int3 
3B07CF  cc                   int3 
3B07D0  89914c050000         mov dword ptr [rcx + 0x54c], edx
3B07D6  c3                   ret 
3B07D7  cc                   int3 
3B07D8  cc                   int3 
3B07D9  cc                   int3 
3B07DA  cc                   int3 
3B07DB  cc                   int3 
3B07DC  cc                   int3 
3B07DD  cc                   int3 
3B07DE  cc                   int3 
3B07DF  cc                   int3 
3B07E0  8991ac050000         mov dword ptr [rcx + 0x5ac], edx
3B07E6  c3                   ret 
3B07E7  cc                   int3 
3B07E8  cc                   int3 
3B07E9  cc                   int3 
3B07EA  cc                   int3 
3B07EB  cc                   int3 
3B07EC  cc                   int3 
3B07ED  cc                   int3 
3B07EE  cc                   int3 
3B07EF  cc                   int3 
3B07F0  8991a8050000         mov dword ptr [rcx + 0x5a8], edx
3B07F6  c3                   ret 
3B07F7  cc                   int3 
3B07F8  cc                   int3 
3B07F9  cc                   int3 
3B07FA  cc                   int3 
3B07FB  cc                   int3 
3B07FC  cc                   int3 
3B07FD  cc                   int3 
3B07FE  cc                   int3 
3B07FF  cc                   int3 
3B0800  899108060000         mov dword ptr [rcx + 0x608], edx
3B0806  c3                   ret 
3B0807  cc                   int3 
3B0808  cc                   int3 
3B0809  cc                   int3 
3B080A  cc                   int3 
3B080B  cc                   int3 
3B080C  cc                   int3 
3B080D  cc                   int3 
3B080E  cc                   int3 
3B080F  cc                   int3 
3B0810  899114060000         mov dword ptr [rcx + 0x614], edx
3B0816  c3                   ret 
3B0817  cc                   int3 
3B0818  cc                   int3 
3B0819  cc                   int3 
3B081A  cc                   int3 
3B081B  cc                   int3 
3B081C  cc                   int3 
3B081D  cc                   int3 
3B081E  cc                   int3 
3B081F  cc                   int3 
3B0820  899118060000         mov dword ptr [rcx + 0x618], edx
3B0826  c3                   ret 
3B0827  cc                   int3 
3B0828  cc                   int3 
3B0829  cc                   int3 
3B082A  cc                   int3 
3B082B  cc                   int3 
3B082C  cc                   int3 
3B082D  cc                   int3 
3B082E  cc                   int3 
3B082F  cc                   int3 
3B0830  899110060000         mov dword ptr [rcx + 0x610], edx
3B0836  c3                   ret 
3B0837  cc                   int3 
3B0838  cc                   int3 
3B0839  cc                   int3 
3B083A  cc                   int3 
3B083B  cc                   int3 
3B083C  cc                   int3 
3B083D  cc                   int3 
3B083E  cc                   int3 
3B083F  cc                   int3 
3B0840  89910c060000         mov dword ptr [rcx + 0x60c], edx
3B0846  c3                   ret 
3B0847  cc                   int3 
3B0848  cc                   int3 
3B0849  cc                   int3 
3B084A  cc                   int3 
3B084B  cc                   int3 
3B084C  cc                   int3 
3B084D  cc                   int3 
3B084E  cc                   int3 
3B084F  cc                   int3 

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
