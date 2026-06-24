; sub_7FF91DF5B530 @ rva 0x2FB530

00007FF91DF5B530  40 53                       push    rbx
00007FF91DF5B532  48 83 EC 40                 sub     rsp, 40h
00007FF91DF5B536  85 D2                       test    edx, edx
00007FF91DF5B538  89 54 24 20                 mov     dword ptr [rsp+48h+var_28], edx
00007FF91DF5B53C  48 8D 51 08                 lea     rdx, [rcx+8]
00007FF91DF5B540  4C 89 44 24 30              mov     [rsp+48h+var_18], r8
00007FF91DF5B545  48 8D 05 04 CB 64 00        lea     rax, off_7FF91E5A8050
00007FF91DF5B54C  C6 44 24 38 01              mov     [rsp+48h+var_10], 1
00007FF91DF5B551  48 89 44 24 28              mov     qword ptr [rsp+48h+var_28+8], rax
00007FF91DF5B556  0F 95 44 24 24              setnz   byte ptr [rsp+48h+var_28+4]
00007FF91DF5B55B  48 8D 05 1E E1 63 00        lea     rax, ??_7exception@std@@6B@; const std::exception::`vftable'
00007FF91DF5B562  48 8B D9                    mov     rbx, rcx
00007FF91DF5B565  48 89 01                    mov     [rcx], rax
00007FF91DF5B568  33 C0                       xor     eax, eax
00007FF91DF5B56A  48 89 02                    mov     [rdx], rax
00007FF91DF5B56D  48 8D 4C 24 30              lea     rcx, [rsp+48h+var_18]
00007FF91DF5B572  48 89 42 08                 mov     [rdx+8], rax
00007FF91DF5B576  E8 D9 40 3B 00              call    __std_exception_copy
00007FF91DF5B57B  0F 10 44 24 20              movups  xmm0, [rsp+48h+var_28]
00007FF91DF5B580  48 8D 05 21 CB 64 00        lea     rax, ??_7thread_exception@boost@@6B@; const boost::thread_exception::`vftable'
00007FF91DF5B587  0F 11 43 18                 movups  xmmword ptr [rbx+18h], xmm0
00007FF91DF5B58B  48 C7 43 38 00 00 00 00     mov     qword ptr [rbx+38h], 0
00007FF91DF5B593  48 C7 43 40 0F 00 00 00     mov     qword ptr [rbx+40h], 0Fh
00007FF91DF5B59B  C6 43 28 00                 mov     byte ptr [rbx+28h], 0
00007FF91DF5B59F  48 89 03                    mov     [rbx], rax
00007FF91DF5B5A2  48 8B C3                    mov     rax, rbx
00007FF91DF5B5A5  48 83 C4 40                 add     rsp, 40h
00007FF91DF5B5A9  5B                          pop     rbx
00007FF91DF5B5AA  C3                          retn
