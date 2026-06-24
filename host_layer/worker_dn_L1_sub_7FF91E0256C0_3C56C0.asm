; sub_7FF91E0256C0 @ rva 0x3C56C0

00007FF91E0256C0  48 81 EC B8 00 00 00        sub     rsp, 0B8h
00007FF91E0256C7  48 8B D1                    mov     rdx, rcx
00007FF91E0256CA  48 8D 4C 24 20              lea     rcx, [rsp+0B8h+pExceptionObject]
00007FF91E0256CF  E8 3C FD FF FF              call    sub_7FF91E025410
00007FF91E0256D4  48 8D 15 BD 71 87 00        lea     rdx, __TI10?AU?$wrapexcept@Vlock_error@boost@@@boost@@; pThrowInfo
00007FF91E0256DB  48 8D 4C 24 20              lea     rcx, [rsp+0B8h+pExceptionObject]; pExceptionObject
00007FF91E0256E0  E8 43 89 2E 00              call    _CxxThrowException
00007FF91E0256E5  CC                          db 0CCh
