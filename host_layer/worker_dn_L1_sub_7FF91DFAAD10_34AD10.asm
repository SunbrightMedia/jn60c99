; sub_7FF91DFAAD10 @ rva 0x34AD10

00007FF91DFAAD10  0F AE 5C 24 08              stmxcsr [rsp+arg_0]
00007FF91DFAAD15  8B 44 24 08                 mov     eax, [rsp+arg_0]
00007FF91DFAAD19  25 00 80 00 00              and     eax, 8000h
00007FF91DFAAD1E  89 01                       mov     [rcx], eax
00007FF91DFAAD20  0F AE 5C 24 08              stmxcsr [rsp+arg_0]
00007FF91DFAAD25  8B 44 24 08                 mov     eax, [rsp+arg_0]
00007FF91DFAAD29  83 E0 40                    and     eax, 40h
00007FF91DFAAD2C  89 41 04                    mov     [rcx+4], eax
00007FF91DFAAD2F  0F AE 5C 24 08              stmxcsr [rsp+arg_0]
00007FF91DFAAD34  8B 44 24 08                 mov     eax, [rsp+arg_0]
00007FF91DFAAD38  0F BA E8 0F                 bts     eax, 0Fh
00007FF91DFAAD3C  89 44 24 08                 mov     [rsp+arg_0], eax
00007FF91DFAAD40  0F AE 54 24 08              ldmxcsr [rsp+arg_0]
00007FF91DFAAD45  0F AE 5C 24 08              stmxcsr [rsp+arg_0]
00007FF91DFAAD4A  8B 44 24 08                 mov     eax, [rsp+arg_0]
00007FF91DFAAD4E  83 C8 40                    or      eax, 40h
00007FF91DFAAD51  89 44 24 08                 mov     [rsp+arg_0], eax
00007FF91DFAAD55  48 8B C1                    mov     rax, rcx
00007FF91DFAAD58  0F AE 54 24 08              ldmxcsr [rsp+arg_0]
00007FF91DFAAD5D  C3                          retn
