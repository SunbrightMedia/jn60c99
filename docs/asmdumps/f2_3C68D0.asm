; f2_3C68D0  rva 0x3C68D0  384 bytes  (from the checksummed binary)
3C68D0  488bc4               mov rax, rsp
3C68D3  55                   push rbp
3C68D4  4154                 push r12
3C68D6  4155                 push r13
3C68D8  4156                 push r14
3C68DA  4157                 push r15
3C68DC  488d68a1             lea rbp, [rax - 0x5f]
3C68E0  4881ec00010000       sub rsp, 0x100
3C68E7  48c74587feffffff     mov qword ptr [rbp - 0x79], 0xfffffffffffffffe
3C68EF  48895810             mov qword ptr [rax + 0x10], rbx
3C68F3  48897018             mov qword ptr [rax + 0x18], rsi
3C68F7  48897820             mov qword ptr [rax + 0x20], rdi
3C68FB  488b05f6e58c00       mov rax, qword ptr [rip + 0x8ce5f6]
3C6902  4833c4               xor rax, rsp
3C6905  48894527             mov qword ptr [rbp + 0x27], rax
3C6909  4c8be1               mov r12, rcx
3C690C  48894c2430           mov qword ptr [rsp + 0x30], rcx
3C6911  c744242800000000     mov dword ptr [rsp + 0x28], 0
3C6919  488d7178             lea rsi, [rcx + 0x78]
3C691D  41bf09000000         mov r15d, 9
3C6923  b91030a800           mov ecx, 0xa83010
3C6928  e8ffe82a00           call 0x18067522c
3C692D  4889442420           mov qword ptr [rsp + 0x20], rax
3C6932  4885c0               test rax, rax
3C6935  7410                 je 0x1803c6947
3C6937  f3410f104c2408       movss xmm1, dword ptr [r12 + 8]
3C693E  488bc8               mov rcx, rax
3C6941  e8aa17fcff           call 0x1803880f0
3C6946  90                   nop 
3C6947  488b5ed8             mov rbx, qword ptr [rsi - 0x28]
3C694B  488946d8             mov qword ptr [rsi - 0x28], rax
3C694F  4885db               test rbx, rbx
3C6952  7415                 je 0x1803c6969
3C6954  488bcb               mov rcx, rbx
3C6957  e814f5ffff           call 0x1803c5e70
3C695C  ba1030a800           mov edx, 0xa83010
3C6961  488bcb               mov rcx, rbx
3C6964  e8ffe82a00           call 0x180675268
3C6969  b908000000           mov ecx, 8
3C696E  e8b9e82a00           call 0x18067522c
3C6973  4889458f             mov qword ptr [rbp - 0x71], rax
3C6977  4885c0               test rax, rax
3C697A  740d                 je 0x1803c6989
3C697C  488b56d8             mov rdx, qword ptr [rsi - 0x28]
3C6980  488bc8               mov rcx, rax
3C6983  e878a6ffff           call 0x1803c1000
3C6988  90                   nop 
3C6989  488b4ee0             mov rcx, qword ptr [rsi - 0x20]
3C698D  488946e0             mov qword ptr [rsi - 0x20], rax
3C6991  4885c9               test rcx, rcx
3C6994  740a                 je 0x1803c69a0
3C6996  ba08000000           mov edx, 8
3C699B  e8c8e82a00           call 0x180675268
3C69A0  b948200000           mov ecx, 0x2048
3C69A5  e882e82a00           call 0x18067522c
3C69AA  48894597             mov qword ptr [rbp - 0x69], rax
3C69AE  4885c0               test rax, rax
3C69B1  7413                 je 0x1803c69c6
3C69B3  4c8b4ee0             mov r9, qword ptr [rsi - 0x20]
3C69B7  33d2                 xor edx, edx
3C69B9  448d4207             lea r8d, [rdx + 7]
3C69BD  488bc8               mov rcx, rax
3C69C0  e85bc9feff           call 0x1803b3320
3C69C5  90                   nop 
3C69C6  488b5ee8             mov rbx, qword ptr [rsi - 0x18]
3C69CA  488946e8             mov qword ptr [rsi - 0x18], rax
3C69CE  4885db               test rbx, rbx
3C69D1  7415                 je 0x1803c69e8
3C69D3  488bcb               mov rcx, rbx
3C69D6  e8e5d8feff           call 0x1803b42c0
3C69DB  ba48200000           mov edx, 0x2048
3C69E0  488bcb               mov rcx, rbx
3C69E3  e880e82a00           call 0x180675268
3C69E8  b9b0000000           mov ecx, 0xb0
3C69ED  e83ae82a00           call 0x18067522c
3C69F2  4889459f             mov qword ptr [rbp - 0x61], rax
3C69F6  4885c0               test rax, rax
3C69F9  7413                 je 0x1803c6a0e
3C69FB  41b808000000         mov r8d, 8
3C6A01  488b56e8             mov rdx, qword ptr [rsi - 0x18]
3C6A05  488bc8               mov rcx, rax
3C6A08  e8c3eff8ff           call 0x1803559d0
3C6A0D  90                   nop 
3C6A0E  488b4ef0             mov rcx, qword ptr [rsi - 0x10]
3C6A12  488946f0             mov qword ptr [rsi - 0x10], rax
3C6A16  4885c9               test rcx, rcx
3C6A19  740a                 je 0x1803c6a25
3C6A1B  bab0000000           mov edx, 0xb0
3C6A20  e843e82a00           call 0x180675268
3C6A25  b9f00f0000           mov ecx, 0xff0
3C6A2A  e8fde72a00           call 0x18067522c
3C6A2F  488945a7             mov qword ptr [rbp - 0x59], rax
3C6A33  4885c0               test rax, rax
3C6A36  740d                 je 0x1803c6a45
3C6A38  488b56f0             mov rdx, qword ptr [rsi - 0x10]
3C6A3C  488bc8               mov rcx, rax
3C6A3F  e8dcc4ffff           call 0x1803c2f20
3C6A44  90                   nop 
3C6A45  488b4ef8             mov rcx, qword ptr [rsi - 8]
3C6A49  488946f8             mov qword ptr [rsi - 8], rax
3C6A4D  4885c9               test rcx, rcx

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
