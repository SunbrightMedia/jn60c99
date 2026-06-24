; sub_7FF91DF5B610 @ rva 0x2FB610

00007FF91DF5B610  40 53                       push    rbx
00007FF91DF5B612  48 83 EC 40                 sub     rsp, 40h
00007FF91DF5B616  48 8D 51 08                 lea     rdx, [rcx+8]
00007FF91DF5B61A  C7 44 24 20 0B 00 00 00     mov     dword ptr [rsp+48h+var_28], 0Bh
00007FF91DF5B622  48 8D 05 27 CA 64 00        lea     rax, off_7FF91E5A8050
00007FF91DF5B629  C6 44 24 24 01              mov     byte ptr [rsp+48h+var_28+4], 1
00007FF91DF5B62E  48 89 44 24 28              mov     qword ptr [rsp+48h+var_28+8], rax
00007FF91DF5B633  48 8B D9                    mov     rbx, rcx
00007FF91DF5B636  48 8D 05 43 E0 63 00        lea     rax, ??_7exception@std@@6B@; const std::exception::`vftable'
00007FF91DF5B63D  C6 44 24 38 01              mov     [rsp+48h+var_10], 1
00007FF91DF5B642  48 89 01                    mov     [rcx], rax
00007FF91DF5B645  33 C0                       xor     eax, eax
00007FF91DF5B647  48 89 02                    mov     [rdx], rax
00007FF91DF5B64A  48 8D 4C 24 30              lea     rcx, [rsp+48h+var_18]
00007FF91DF5B64F  48 89 42 08                 mov     [rdx+8], rax
00007FF91DF5B653  48 8D 05 76 CA 64 00        lea     rax, aBoostThreadRes; "boost::thread_resource_error"
00007FF91DF5B65A  48 89 44 24 30              mov     [rsp+48h+var_18], rax
00007FF91DF5B65F  E8 F0 3F 3B 00              call    __std_exception_copy
00007FF91DF5B664  0F 10 44 24 20              movups  xmm0, [rsp+48h+var_28]
00007FF91DF5B669  48 8D 05 50 CA 64 00        lea     rax, ??_7thread_resource_error@boost@@6B@; const boost::thread_resource_error::`vftable'
00007FF91DF5B670  0F 11 43 18                 movups  xmmword ptr [rbx+18h], xmm0
00007FF91DF5B674  48 C7 43 38 00 00 00 00     mov     qword ptr [rbx+38h], 0
00007FF91DF5B67C  48 C7 43 40 0F 00 00 00     mov     qword ptr [rbx+40h], 0Fh
00007FF91DF5B684  C6 43 28 00                 mov     byte ptr [rbx+28h], 0
00007FF91DF5B688  48 89 03                    mov     [rbx], rax
00007FF91DF5B68B  48 8B C3                    mov     rax, rbx
00007FF91DF5B68E  48 83 C4 40                 add     rsp, 40h
00007FF91DF5B692  5B                          pop     rbx
00007FF91DF5B693  C3                          retn
