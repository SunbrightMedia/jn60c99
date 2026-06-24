; __security_check_cookie @ rva 0x675D20

00007FF91E2D5D20  48 3B 0D D1 F1 61 00        cmp     rcx, cs:__security_cookie
00007FF91E2D5D27  F2 75 12                    bnd jnz short ReportFailure
00007FF91E2D5D2A  48 C1 C1 10                 rol     rcx, 10h
00007FF91E2D5D2E  66 F7 C1 FF FF              test    cx, 0FFFFh
00007FF91E2D5D33  F2 75 02                    bnd jnz short RestoreRcx
00007FF91E2D5D36  F2 C3                       bnd retn
00007FF91E2D5D38  48 C1 C9 10                 ror     rcx, 10h; StackCookie
00007FF91E2D5D3C  E9 6F 05 00 00              jmp     __report_gsfailure
