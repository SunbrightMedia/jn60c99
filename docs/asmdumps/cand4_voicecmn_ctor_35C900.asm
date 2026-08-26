; cand4_voicecmn_ctor_35C900  rva 0x35C900  320 bytes  (from the checksummed binary)
35C900  50                   push rax
35C901  83fa06               cmp edx, 6
35C904  0f87a8020000         ja 0x18035cbb2
35C90A  4863c2               movsxd rax, edx
35C90D  488d15ec36caff       lea rdx, [rip - 0x35c914]
35C914  8b8c8208cc3500       mov ecx, dword ptr [rdx + rax*4 + 0x35cc08]
35C91B  4803ca               add rcx, rdx
35C91E  ffe1                 jmp rcx
35C920  41c741606f000000     mov dword ptr [r9 + 0x60], 0x6f
35C928  498bc1               mov rax, r9
35C92B  41c7416470000000     mov dword ptr [r9 + 0x64], 0x70
35C933  41c7416873000000     mov dword ptr [r9 + 0x68], 0x73
35C93B  41c7416c74000000     mov dword ptr [r9 + 0x6c], 0x74
35C943  41c741786e000000     mov dword ptr [r9 + 0x78], 0x6e
35C94B  41c74170a0030000     mov dword ptr [r9 + 0x70], 0x3a0
35C953  41c74174a1030000     mov dword ptr [r9 + 0x74], 0x3a1
35C95B  41c7417c75000000     mov dword ptr [r9 + 0x7c], 0x75
35C963  41c7818400000071000000 mov dword ptr [r9 + 0x84], 0x71
35C96E  41c7818800000072000000 mov dword ptr [r9 + 0x88], 0x72
35C979  45894110             mov dword ptr [r9 + 0x10], r8d
35C97D  c3                   ret 
35C97E  41c74160dd000000     mov dword ptr [r9 + 0x60], 0xdd
35C986  498bc1               mov rax, r9
35C989  41c74164de000000     mov dword ptr [r9 + 0x64], 0xde
35C991  41c74168e1000000     mov dword ptr [r9 + 0x68], 0xe1
35C999  41c7416ce2000000     mov dword ptr [r9 + 0x6c], 0xe2
35C9A1  41c74178dc000000     mov dword ptr [r9 + 0x78], 0xdc
35C9A9  41c74170a2030000     mov dword ptr [r9 + 0x70], 0x3a2
35C9B1  41c74174a3030000     mov dword ptr [r9 + 0x74], 0x3a3
35C9B9  41c7417ce3000000     mov dword ptr [r9 + 0x7c], 0xe3
35C9C1  41c78184000000df000000 mov dword ptr [r9 + 0x84], 0xdf
35C9CC  41c78188000000e0000000 mov dword ptr [r9 + 0x88], 0xe0
35C9D7  45894110             mov dword ptr [r9 + 0x10], r8d
35C9DB  c3                   ret 
35C9DC  41c741604b010000     mov dword ptr [r9 + 0x60], 0x14b
35C9E4  498bc1               mov rax, r9
35C9E7  41c741644c010000     mov dword ptr [r9 + 0x64], 0x14c
35C9EF  41c741684f010000     mov dword ptr [r9 + 0x68], 0x14f
35C9F7  41c7416c50010000     mov dword ptr [r9 + 0x6c], 0x150
35C9FF  41c741784a010000     mov dword ptr [r9 + 0x78], 0x14a
35CA07  41c74170a4030000     mov dword ptr [r9 + 0x70], 0x3a4
35CA0F  41c74174a5030000     mov dword ptr [r9 + 0x74], 0x3a5
35CA17  41c7417c51010000     mov dword ptr [r9 + 0x7c], 0x151
35CA1F  41c781840000004d010000 mov dword ptr [r9 + 0x84], 0x14d
35CA2A  41c781880000004e010000 mov dword ptr [r9 + 0x88], 0x14e
35CA35  45894110             mov dword ptr [r9 + 0x10], r8d
35CA39  c3                   ret 

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
