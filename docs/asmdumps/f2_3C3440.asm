; f2_3C3440  rva 0x3C3440  384 bytes  (from the checksummed binary)
3C3440  c681c500000001       mov byte ptr [rcx + 0xc5], 1
3C3447  e944bdffff           jmp 0x1803bf190
3C344C  cc                   int3 
3C344D  cc                   int3 
3C344E  cc                   int3 
3C344F  cc                   int3 
3C3450  8891ce0f0000         mov byte ptr [rcx + 0xfce], dl
3C3456  8891e00f0000         mov byte ptr [rcx + 0xfe0], dl
3C345C  e94fafffff           jmp 0x1803be3b0
3C3461  cc                   int3 
3C3462  cc                   int3 
3C3463  cc                   int3 
3C3464  cc                   int3 
3C3465  cc                   int3 
3C3466  cc                   int3 
3C3467  cc                   int3 
3C3468  cc                   int3 
3C3469  cc                   int3 
3C346A  cc                   int3 
3C346B  cc                   int3 
3C346C  cc                   int3 
3C346D  cc                   int3 
3C346E  cc                   int3 
3C346F  cc                   int3 
3C3470  e99bfbffff           jmp 0x1803c3010
3C3475  cc                   int3 
3C3476  cc                   int3 
3C3477  cc                   int3 
3C3478  cc                   int3 
3C3479  cc                   int3 
3C347A  cc                   int3 
3C347B  cc                   int3 
3C347C  cc                   int3 
3C347D  cc                   int3 
3C347E  cc                   int3 
3C347F  cc                   int3 
3C3480  8891d30f0000         mov byte ptr [rcx + 0xfd3], dl
3C3486  c3                   ret 
3C3487  cc                   int3 
3C3488  cc                   int3 
3C3489  cc                   int3 
3C348A  cc                   int3 
3C348B  cc                   int3 
3C348C  cc                   int3 
3C348D  cc                   int3 
3C348E  cc                   int3 
3C348F  cc                   int3 
3C3490  e90bc8ffff           jmp 0x1803bfca0
3C3495  cc                   int3 
3C3496  cc                   int3 
3C3497  cc                   int3 
3C3498  cc                   int3 
3C3499  cc                   int3 
3C349A  cc                   int3 
3C349B  cc                   int3 
3C349C  cc                   int3 
3C349D  cc                   int3 
3C349E  cc                   int3 
3C349F  cc                   int3 
3C34A0  e91bbfffff           jmp 0x1803bf3c0
3C34A5  cc                   int3 
3C34A6  cc                   int3 
3C34A7  cc                   int3 
3C34A8  cc                   int3 
3C34A9  cc                   int3 
3C34AA  cc                   int3 
3C34AB  cc                   int3 
3C34AC  cc                   int3 
3C34AD  cc                   int3 
3C34AE  cc                   int3 
3C34AF  cc                   int3 
3C34B0  8991880d0000         mov dword ptr [rcx + 0xd88], edx
3C34B6  c681840d000001       mov byte ptr [rcx + 0xd84], 1
3C34BD  c3                   ret 
3C34BE  cc                   int3 
3C34BF  cc                   int3 
3C34C0  b804000000           mov eax, 4
3C34C5  3bd0                 cmp edx, eax
3C34C7  0f4ec2               cmovle eax, edx
3C34CA  bafcffffff           mov edx, 0xfffffffc
3C34CF  3bc2                 cmp eax, edx
3C34D1  0f4cc2               cmovl eax, edx
3C34D4  0081d20f0000         add byte ptr [rcx + 0xfd2], al
3C34DA  0fbe91d20f0000       movsx edx, byte ptr [rcx + 0xfd2]
3C34E1  e97ac9ffff           jmp 0x1803bfe60
3C34E6  cc                   int3 
3C34E7  cc                   int3 
3C34E8  cc                   int3 
3C34E9  cc                   int3 
3C34EA  cc                   int3 
3C34EB  cc                   int3 
3C34EC  cc                   int3 
3C34ED  cc                   int3 
3C34EE  cc                   int3 
3C34EF  cc                   int3 
3C34F0  4883ec38             sub rsp, 0x38
3C34F4  488b05fd198d00       mov rax, qword ptr [rip + 0x8d19fd]
3C34FB  4833c4               xor rax, rsp
3C34FE  4889442428           mov qword ptr [rsp + 0x28], rax
3C3503  4533c9               xor r9d, r9d
3C3506  c744242000020401     mov dword ptr [rsp + 0x20], 0x1040200
3C350E  85d2                 test edx, edx
3C3510  66c74424240305       mov word ptr [rsp + 0x24], 0x503
3C3517  418bc1               mov eax, r9d
3C351A  0f49c2               cmovns eax, edx
3C351D  ba05000000           mov edx, 5
3C3522  83f806               cmp eax, 6
3C3525  0f4dc2               cmovge eax, edx
3C3528  4898                 cdqe 
3C352A  0fb6540420           movzx edx, byte ptr [rsp + rax + 0x20]
3C352F  4403c2               add r8d, edx
3C3532  410fb6c0             movzx eax, r8b
3C3536  440fb681d10f0000     movzx r8d, byte ptr [rcx + 0xfd1]
3C353E  440f49c8             cmovns r9d, eax
3C3542  410fb6d1             movzx edx, r9b
3C3546  8891cf0f0000         mov byte ptr [rcx + 0xfcf], dl
3C354C  e87fbeffff           call 0x1803bf3d0
3C3551  488b4c2428           mov rcx, qword ptr [rsp + 0x28]
3C3556  4833cc               xor rcx, rsp
3C3559  e8c2272b00           call 0x180675d20
3C355E  4883c438             add rsp, 0x38
3C3562  c3                   ret 
3C3563  cc                   int3 
3C3564  cc                   int3 
3C3565  cc                   int3 
3C3566  cc                   int3 
3C3567  cc                   int3 
3C3568  cc                   int3 
3C3569  cc                   int3 
3C356A  cc                   int3 
3C356B  cc                   int3 
3C356C  cc                   int3 
3C356D  cc                   int3 
3C356E  cc                   int3 
3C356F  cc                   int3 
3C3570  8891e00f0000         mov byte ptr [rcx + 0xfe0], dl
3C3576  e935aeffff           jmp 0x1803be3b0
3C357B  cc                   int3 
3C357C  cc                   int3 
3C357D  cc                   int3 
3C357E  cc                   int3 
3C357F  cc                   int3 
3C3580  488b89d80f0000       mov rcx, qword ptr [rcx + 0xfd8]
3C3587  41b040               mov r8b, 0x40
3C358A  488b01               mov rax, qword ptr [rcx]
3C358D  48ff6010             jmp qword ptr [rax + 0x10]
3C3591  cc                   int3 
3C3592  cc                   int3 
3C3593  cc                   int3 
3C3594  cc                   int3 
3C3595  cc                   int3 
3C3596  cc                   int3 
3C3597  cc                   int3 
3C3598  cc                   int3 
3C3599  cc                   int3 
3C359A  cc                   int3 
3C359B  cc                   int3 
3C359C  cc                   int3 
3C359D  cc                   int3 
3C359E  cc                   int3 
3C359F  cc                   int3 
3C35A0  48895c2408           mov qword ptr [rsp + 8], rbx
3C35A5  57                   push rdi
3C35A6  440fb699d40f0000     movzx r11d, byte ptr [rcx + 0xfd4]
3C35AE  488bd9               mov rbx, rcx
3C35B1  410fb6c0             movzx eax, r8b
3C35B5  8bfa                 mov edi, edx
3C35B7  41ba7f000000         mov r10d, 0x7f
3C35BD  458bc2               mov r8d, r10d

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
