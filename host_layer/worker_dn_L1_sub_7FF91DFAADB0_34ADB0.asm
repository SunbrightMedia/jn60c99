; sub_7FF91DFAADB0 @ rva 0x34ADB0

00007FF91DFAADB0  0F AE 5C 24 08              stmxcsr [rsp+arg_0]
00007FF91DFAADB5  8B 44 24 08                 mov     eax, [rsp+arg_0]
00007FF91DFAADB9  0F BA F0 0F                 btr     eax, 0Fh
00007FF91DFAADBD  0B 01                       or      eax, [rcx]
00007FF91DFAADBF  89 44 24 08                 mov     [rsp+arg_0], eax
00007FF91DFAADC3  0F AE 54 24 08              ldmxcsr [rsp+arg_0]
00007FF91DFAADC8  0F AE 5C 24 08              stmxcsr [rsp+arg_0]
00007FF91DFAADCD  8B 44 24 08                 mov     eax, [rsp+arg_0]
00007FF91DFAADD1  83 E0 BF                    and     eax, 0FFFFFFBFh
00007FF91DFAADD4  0B 41 04                    or      eax, [rcx+4]
00007FF91DFAADD7  89 44 24 08                 mov     [rsp+arg_0], eax
00007FF91DFAADDB  0F AE 54 24 08              ldmxcsr [rsp+arg_0]
00007FF91DFAADE0  C3                          retn
