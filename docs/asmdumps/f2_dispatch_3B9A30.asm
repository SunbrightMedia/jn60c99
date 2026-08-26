; f2_dispatch_3B9A30  rva 0x3B9A30  512 bytes  (from the checksummed binary)
3B9A30  48895c2408           mov qword ptr [rsp + 8], rbx
3B9A35  57                   push rdi
3B9A36  4883ec20             sub rsp, 0x20
3B9A3A  418bf9               mov edi, r9d
3B9A3D  458bc8               mov r9d, r8d
3B9A40  488bd9               mov rbx, rcx
3B9A43  81fa38010000         cmp edx, 0x138
3B9A49  0f8fc9020000         jg 0x1803b9d18
3B9A4F  0f84a3020000         je 0x1803b9cf8
3B9A55  83c2ec               add edx, -0x14
3B9A58  81faea000000         cmp edx, 0xea
3B9A5E  0f8767170000         ja 0x1803bb1cb
3B9A64  4863c2               movsxd rax, edx
3B9A67  488d159265c4ff       lea rdx, [rip - 0x3b9a6e]
3B9A6E  0fb6840224b23b00     movzx eax, byte ptr [rdx + rax + 0x3bb224]
3B9A76  8b8c82d8b13b00       mov ecx, dword ptr [rdx + rax*4 + 0x3bb1d8]
3B9A7D  4803ca               add rcx, rdx
3B9A80  ffe1                 jmp rcx
3B9A82  488b03               mov rax, qword ptr [rbx]
3B9A85  448bc7               mov r8d, edi
3B9A88  418bd1               mov edx, r9d
3B9A8B  488bcb               mov rcx, rbx
3B9A8E  ff90d8050000         call qword ptr [rax + 0x5d8]
3B9A94  89bbb4030000         mov dword ptr [rbx + 0x3b4], edi
3B9A9A  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9A9F  4883c420             add rsp, 0x20
3B9AA3  5f                   pop rdi
3B9AA4  c3                   ret 
3B9AA5  488b03               mov rax, qword ptr [rbx]
3B9AA8  448bc7               mov r8d, edi
3B9AAB  418bd1               mov edx, r9d
3B9AAE  488bcb               mov rcx, rbx
3B9AB1  ff90e0050000         call qword ptr [rax + 0x5e0]
3B9AB7  89bbb8030000         mov dword ptr [rbx + 0x3b8], edi
3B9ABD  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9AC2  4883c420             add rsp, 0x20
3B9AC6  5f                   pop rdi
3B9AC7  c3                   ret 
3B9AC8  488b03               mov rax, qword ptr [rbx]
3B9ACB  448bc7               mov r8d, edi
3B9ACE  418bd1               mov edx, r9d
3B9AD1  488bcb               mov rcx, rbx
3B9AD4  ff90e8050000         call qword ptr [rax + 0x5e8]
3B9ADA  89bbbc030000         mov dword ptr [rbx + 0x3bc], edi
3B9AE0  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9AE5  4883c420             add rsp, 0x20
3B9AE9  5f                   pop rdi
3B9AEA  c3                   ret 
3B9AEB  488b03               mov rax, qword ptr [rbx]
3B9AEE  448bc7               mov r8d, edi
3B9AF1  418bd1               mov edx, r9d
3B9AF4  488bcb               mov rcx, rbx
3B9AF7  ff90f0050000         call qword ptr [rax + 0x5f0]
3B9AFD  89bbc0030000         mov dword ptr [rbx + 0x3c0], edi
3B9B03  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9B08  4883c420             add rsp, 0x20
3B9B0C  5f                   pop rdi
3B9B0D  c3                   ret 
3B9B0E  488b03               mov rax, qword ptr [rbx]
3B9B11  448bc7               mov r8d, edi
3B9B14  418bd1               mov edx, r9d
3B9B17  488bcb               mov rcx, rbx
3B9B1A  ff90f8050000         call qword ptr [rax + 0x5f8]
3B9B20  89bbc4030000         mov dword ptr [rbx + 0x3c4], edi
3B9B26  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9B2B  4883c420             add rsp, 0x20
3B9B2F  5f                   pop rdi
3B9B30  c3                   ret 
3B9B31  488b03               mov rax, qword ptr [rbx]
3B9B34  448bc7               mov r8d, edi
3B9B37  418bd1               mov edx, r9d
3B9B3A  488bcb               mov rcx, rbx
3B9B3D  ff9000060000         call qword ptr [rax + 0x600]
3B9B43  89bbc8030000         mov dword ptr [rbx + 0x3c8], edi
3B9B49  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9B4E  4883c420             add rsp, 0x20
3B9B52  5f                   pop rdi
3B9B53  c3                   ret 
3B9B54  488b03               mov rax, qword ptr [rbx]
3B9B57  448bc7               mov r8d, edi
3B9B5A  418bd1               mov edx, r9d
3B9B5D  488bcb               mov rcx, rbx
3B9B60  ff9008060000         call qword ptr [rax + 0x608]
3B9B66  89bbcc030000         mov dword ptr [rbx + 0x3cc], edi
3B9B6C  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9B71  4883c420             add rsp, 0x20
3B9B75  5f                   pop rdi
3B9B76  c3                   ret 
3B9B77  488b03               mov rax, qword ptr [rbx]
3B9B7A  448bc7               mov r8d, edi
3B9B7D  418bd1               mov edx, r9d
3B9B80  488bcb               mov rcx, rbx
3B9B83  ff9010060000         call qword ptr [rax + 0x610]
3B9B89  89bbd0030000         mov dword ptr [rbx + 0x3d0], edi
3B9B8F  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9B94  4883c420             add rsp, 0x20
3B9B98  5f                   pop rdi
3B9B99  c3                   ret 
3B9B9A  488b03               mov rax, qword ptr [rbx]
3B9B9D  448bc7               mov r8d, edi
3B9BA0  418bd1               mov edx, r9d
3B9BA3  488bcb               mov rcx, rbx
3B9BA6  ff9018060000         call qword ptr [rax + 0x618]
3B9BAC  89bbd4030000         mov dword ptr [rbx + 0x3d4], edi
3B9BB2  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9BB7  4883c420             add rsp, 0x20
3B9BBB  5f                   pop rdi
3B9BBC  c3                   ret 
3B9BBD  488b03               mov rax, qword ptr [rbx]
3B9BC0  448bc7               mov r8d, edi
3B9BC3  418bd1               mov edx, r9d
3B9BC6  488bcb               mov rcx, rbx
3B9BC9  ff9020060000         call qword ptr [rax + 0x620]
3B9BCF  89bbd8030000         mov dword ptr [rbx + 0x3d8], edi
3B9BD5  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9BDA  4883c420             add rsp, 0x20
3B9BDE  5f                   pop rdi
3B9BDF  c3                   ret 
3B9BE0  488b03               mov rax, qword ptr [rbx]
3B9BE3  448bc7               mov r8d, edi
3B9BE6  418bd1               mov edx, r9d
3B9BE9  488bcb               mov rcx, rbx
3B9BEC  ff9028060000         call qword ptr [rax + 0x628]
3B9BF2  89bbdc030000         mov dword ptr [rbx + 0x3dc], edi
3B9BF8  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9BFD  4883c420             add rsp, 0x20
3B9C01  5f                   pop rdi
3B9C02  c3                   ret 
3B9C03  488b03               mov rax, qword ptr [rbx]
3B9C06  448bc7               mov r8d, edi
3B9C09  418bd1               mov edx, r9d
3B9C0C  488bcb               mov rcx, rbx
3B9C0F  ff9030060000         call qword ptr [rax + 0x630]
3B9C15  89bbe0030000         mov dword ptr [rbx + 0x3e0], edi
3B9C1B  488b5c2430           mov rbx, qword ptr [rsp + 0x30]
3B9C20  4883c420             add rsp, 0x20
3B9C24  5f                   pop rdi
3B9C25  c3                   ret 
3B9C26  488b03               mov rax, qword ptr [rbx]
3B9C29  448bc7               mov r8d, edi
3B9C2C  418bd1               mov edx, r9d

; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----
