; sub_7FF91E025BC0 @ rva 0x3C5BC0

00007FF91E025BC0  40 53                       push    rbx
00007FF91E025BC2  48 83 EC 20                 sub     rsp, 20h
00007FF91E025BC6  48 8B D9                    mov     rbx, rcx
00007FF91E025BC9  E8 62 59 F3 FF              call    sub_7FF91DF5B530
00007FF91E025BCE  48 8D 05 EB 95 61 00        lea     rax, ??_7lock_error@boost@@6B@; const boost::lock_error::`vftable'
00007FF91E025BD5  48 89 03                    mov     [rbx], rax
00007FF91E025BD8  48 8B C3                    mov     rax, rbx
00007FF91E025BDB  48 83 C4 20                 add     rsp, 20h
00007FF91E025BDF  5B                          pop     rbx
00007FF91E025BE0  C3                          retn
