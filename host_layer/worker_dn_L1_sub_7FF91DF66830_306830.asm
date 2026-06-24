; sub_7FF91DF66830 @ rva 0x306830

00007FF91DF66830  40 53                       push    rbx
00007FF91DF66832  48 81 EC 90 00 00 00        sub     rsp, 90h
00007FF91DF66839  48 C7 44 24 20 FE FF FF FF  mov     [rsp+98h+var_78], 0FFFFFFFFFFFFFFFEh
00007FF91DF66842  48 8B 05 AF E6 98 00        mov     rax, cs:__security_cookie
00007FF91DF66849  48 33 C4                    xor     rax, rsp
00007FF91DF6684C  48 89 84 24 80 00 00 00     mov     [rsp+98h+var_18], rax
00007FF91DF66854  48 8B D9                    mov     rbx, rcx
00007FF91DF66857  48 8B 41 08                 mov     rax, [rcx+8]
00007FF91DF6685B  48 85 C0                    test    rax, rax
00007FF91DF6685E  75 33                       jnz     short loc_7FF91DF66893
00007FF91DF66860  45 33 C9                    xor     r9d, r9d; lpName
00007FF91DF66863  45 33 C0                    xor     r8d, r8d; bInitialState
00007FF91DF66866  33 D2                       xor     edx, edx; bManualReset
00007FF91DF66868  33 C9                       xor     ecx, ecx; lpEventAttributes
00007FF91DF6686A  FF 15 88 DF 62 00           call    cs:__imp_CreateEventA
00007FF91DF66870  48 8B C8                    mov     rcx, rax; hObject
00007FF91DF66873  48 85 C0                    test    rax, rax
00007FF91DF66876  74 34                       jz      short loc_7FF91DF668AC
00007FF91DF66878  33 C0                       xor     eax, eax
00007FF91DF6687A  F0 48 0F B1 4B 08           lock cmpxchg [rbx+8], rcx
00007FF91DF66880  48 8B D8                    mov     rbx, rax
00007FF91DF66883  74 0B                       jz      short loc_7FF91DF66890
00007FF91DF66885  FF 15 45 DF 62 00           call    cs:__imp_CloseHandle
00007FF91DF6688B  48 8B C3                    mov     rax, rbx
00007FF91DF6688E  EB 03                       jmp     short loc_7FF91DF66893
00007FF91DF66890  48 8B C1                    mov     rax, rcx
00007FF91DF66893  48 8B 8C 24 80 00 00 00     mov     rcx, [rsp+98h+var_18]
00007FF91DF6689B  48 33 CC                    xor     rcx, rsp; StackCookie
00007FF91DF6689E  E8 7D F4 36 00              call    __security_check_cookie
00007FF91DF668A3  48 81 C4 90 00 00 00        add     rsp, 90h
00007FF91DF668AA  5B                          pop     rbx
00007FF91DF668AB  C3                          retn
00007FF91DF668AC  48 8D 4C 24 30              lea     rcx, [rsp+98h+var_68]
00007FF91DF668B1  E8 5A 4D FF FF              call    sub_7FF91DF5B610
00007FF91DF668B6  90                          nop
00007FF91DF668B7  48 8B C8                    mov     rcx, rax
00007FF91DF668BA  E8 D1 23 FF FF              call    sub_7FF91DF58C90
00007FF91DF668BF  CC                          align 20h
