; sub_7FF91DF58C90 @ rva 0x2F8C90

00007FF91DF58C90  48 81 EC B8 00 00 00        sub     rsp, 0B8h
00007FF91DF58C97  48 8B D1                    mov     rdx, rcx
00007FF91DF58C9A  48 8D 4C 24 20              lea     rcx, [rsp+0B8h+pExceptionObject]
00007FF91DF58C9F  E8 5C B1 FF FF              call    sub_7FF91DF53E00
00007FF91DF58CA4  48 8D 15 B5 33 94 00        lea     rdx, __TI10?AU?$wrapexcept@Vthread_resource_error@boost@@@boost@@; pThrowInfo
00007FF91DF58CAB  48 8D 4C 24 20              lea     rcx, [rsp+0B8h+pExceptionObject]; pExceptionObject
00007FF91DF58CB0  E8 73 53 3B 00              call    _CxxThrowException
00007FF91DF58CB5  CC                          db 0CCh
