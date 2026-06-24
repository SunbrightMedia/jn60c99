; sub_7FF91E025410 @ rva 0x3C5410

00007FF91E025410  48 8B C4                    mov     rax, rsp
00007FF91E025413  55                          push    rbp
00007FF91E025414  57                          push    rdi
00007FF91E025415  41 54                       push    r12
00007FF91E025417  41 56                       push    r14
00007FF91E025419  41 57                       push    r15
00007FF91E02541B  48 8D 68 A1                 lea     rbp, [rax-5Fh]
00007FF91E02541F  48 81 EC C0 00 00 00        sub     rsp, 0C0h
00007FF91E025426  48 C7 45 9F FE FF FF FF     mov     [rbp+57h+var_B8], 0FFFFFFFFFFFFFFFEh
00007FF91E02542E  48 89 58 18                 mov     [rax+18h], rbx
00007FF91E025432  48 89 70 20                 mov     [rax+20h], rsi
00007FF91E025436  48 8B 05 BB FA 8C 00        mov     rax, cs:__security_cookie
00007FF91E02543D  48 33 C4                    xor     rax, rsp
00007FF91E025440  48 89 45 27                 mov     [rbp+57h+var_30], rax
00007FF91E025444  48 8B DA                    mov     rbx, rdx
00007FF91E025447  48 8B F9                    mov     rdi, rcx
00007FF91E02544A  48 89 4D A7                 mov     [rbp+57h+var_B0], rcx
00007FF91E02544E  45 33 F6                    xor     r14d, r14d
00007FF91E025451  44 89 75 97                 mov     [rbp+57h+var_C0], r14d
00007FF91E025455  4C 8D 25 24 42 57 00        lea     r12, ??_7exception@std@@6B@; const std::exception::`vftable'
00007FF91E02545C  4C 89 65 B7                 mov     [rbp+57h+var_A0], r12
00007FF91E025460  33 C0                       xor     eax, eax
00007FF91E025462  48 89 45 BF                 mov     [rbp+57h+var_98], rax
00007FF91E025466  48 89 45 C7                 mov     [rbp+57h+var_90], rax
00007FF91E02546A  48 8D 4A 08                 lea     rcx, [rdx+8]
00007FF91E02546E  48 8D 55 BF                 lea     rdx, [rbp+57h+var_98]
00007FF91E025472  E8 DD A1 2E 00              call    __std_exception_copy
00007FF91E025477  90                          nop
00007FF91E025478  4C 8D 3D 11 2C 58 00        lea     r15, ??_7system_error@system@boost@@6B@; const boost::system::system_error::`vftable'
00007FF91E02547F  4C 89 7D B7                 mov     [rbp+57h+var_A0], r15
00007FF91E025483  0F 10 43 18                 movups  xmm0, xmmword ptr [rbx+18h]
00007FF91E025487  0F 11 45 CF                 movups  [rbp+57h+var_88], xmm0
00007FF91E02548B  48 8D 53 28                 lea     rdx, [rbx+28h]
00007FF91E02548F  48 8D 4D DF                 lea     rcx, [rbp+57h+var_78]
00007FF91E025493  E8 B8 26 CF FF              call    sub_7FF91DD17B50
00007FF91E025498  90                          nop
00007FF91E025499  0F 57 C0                    xorps   xmm0, xmm0
00007FF91E02549C  66 0F 7F 45 07              movdqa  [rbp+57h+var_50], xmm0
00007FF91E0254A1  4C 89 75 17                 mov     [rbp+57h+var_40], r14
00007FF91E0254A5  C7 45 1F FF FF FF FF        mov     [rbp+57h+var_38], 0FFFFFFFFh
00007FF91E0254AC  48 8D 35 D5 9E 61 00        lea     rsi, ??_7?$error_info_injector@Vlock_error@boost@@@exception_detail@boost@@6B@; const boost::exception_detail::error_info_injector<boost::lock_error>::`vftable'
00007FF91E0254B3  48 89 75 B7                 mov     [rbp+57h+var_A0], rsi
00007FF91E0254B7  48 8D 05 E2 9E 61 00        lea     rax, ??_7?$error_info_injector@Vlock_error@boost@@@exception_detail@boost@@6B@_0; const boost::exception_detail::error_info_injector<boost::lock_error>::`vftable'
00007FF91E0254BE  48 89 45 FF                 mov     [rbp+57h+var_58], rax
00007FF91E0254C2  48 8D 05 77 9F 61 00        lea     rax, unk_7FF91E63F440
00007FF91E0254C9  48 89 47 70                 mov     [rdi+70h], rax
00007FF91E0254CD  48 8D 05 FC 05 58 00        lea     rax, ??_7clone_base@exception_detail@boost@@6B@; const boost::exception_detail::clone_base::`vftable'
00007FF91E0254D4  48 89 87 80 00 00 00        mov     [rdi+80h], rax
00007FF91E0254DB  C7 45 97 06 00 00 00        mov     [rbp+57h+var_C0], 6
00007FF91E0254E2  48 8D 55 B7                 lea     rdx, [rbp+57h+var_A0]
00007FF91E0254E6  48 8B CF                    mov     rcx, rdi
00007FF91E0254E9  E8 92 02 00 00              call    sub_7FF91E025780
00007FF91E0254EE  90                          nop
00007FF91E0254EF  48 8D 05 BA 9E 61 00        lea     rax, ??_7?$clone_impl@U?$error_info_injector@Vlock_error@boost@@@exception_detail@boost@@@exception_detail@boost@@6B@; const boost::exception_detail::clone_impl<boost::exception_detail::error_info_injector<boost::lock_error>>::`vftable'
00007FF91E0254F6  48 89 07                    mov     [rdi], rax
00007FF91E0254F9  48 8D 05 C8 9E 61 00        lea     rax, ??_7?$clone_impl@U?$error_info_injector@Vlock_error@boost@@@exception_detail@boost@@@exception_detail@boost@@6B@_0; const boost::exception_detail::clone_impl<boost::exception_detail::error_info_injector<boost::lock_error>>::`vftable'
00007FF91E025500  48 89 47 48                 mov     [rdi+48h], rax
00007FF91E025504  48 8B 47 70                 mov     rax, [rdi+70h]
00007FF91E025508  48 63 48 04                 movsxd  rcx, dword ptr [rax+4]
00007FF91E02550C  48 8D 05 C5 9E 61 00        lea     rax, ??_7?$clone_impl@U?$error_info_injector@Vlock_error@boost@@@exception_detail@boost@@@exception_detail@boost@@6B@_1; const boost::exception_detail::clone_impl<boost::exception_detail::error_info_injector<boost::lock_error>>::`vftable'
00007FF91E025513  48 89 44 39 70              mov     [rcx+rdi+70h], rax
00007FF91E025518  48 8B 47 70                 mov     rax, [rdi+70h]
00007FF91E02551C  48 63 48 04                 movsxd  rcx, dword ptr [rax+4]
00007FF91E025520  8D 51 F0                    lea     edx, [rcx-10h]
00007FF91E025523  89 54 39 6C                 mov     [rcx+rdi+6Ch], edx
00007FF91E025527  48 8D 55 FF                 lea     rdx, [rbp+57h+var_58]
00007FF91E02552B  48 8D 4F 48                 lea     rcx, [rdi+48h]
00007FF91E02552F  E8 9C EA F3 FF              call    sub_7FF91DF63FD0
00007FF91E025534  90                          nop
00007FF91E025535  48 8D 05 C4 9E 61 00        lea     rax, ??_7?$wrapexcept@Vlock_error@boost@@@boost@@6B@; const boost::wrapexcept<boost::lock_error>::`vftable'
00007FF91E02553C  48 89 07                    mov     [rdi], rax
00007FF91E02553F  48 8D 05 D2 9E 61 00        lea     rax, ??_7?$wrapexcept@Vlock_error@boost@@@boost@@6B@_0; const boost::wrapexcept<boost::lock_error>::`vftable'
00007FF91E025546  48 89 47 48                 mov     [rdi+48h], rax
00007FF91E02554A  48 8B 47 70                 mov     rax, [rdi+70h]
00007FF91E02554E  48 63 48 04                 movsxd  rcx, dword ptr [rax+4]
00007FF91E025552  48 8D 05 CF 9E 61 00        lea     rax, ??_7?$wrapexcept@Vlock_error@boost@@@boost@@6B@_1; const boost::wrapexcept<boost::lock_error>::`vftable'
00007FF91E025559  48 89 44 39 70              mov     [rcx+rdi+70h], rax
00007FF91E02555E  48 8B 47 70                 mov     rax, [rdi+70h]
00007FF91E025562  48 63 48 04                 movsxd  rcx, dword ptr [rax+4]
00007FF91E025566  8D 51 F0                    lea     edx, [rcx-10h]
00007FF91E025569  89 54 39 6C                 mov     [rcx+rdi+6Ch], edx
00007FF91E02556D  48 89 75 B7                 mov     [rbp+57h+var_A0], rsi
00007FF91E025571  48 8D 05 20 29 58 00        lea     rax, ??_7exception@boost@@6B@; const boost::exception::`vftable'
00007FF91E025578  48 89 45 FF                 mov     [rbp+57h+var_58], rax
00007FF91E02557C  48 8B 4D 07                 mov     rcx, qword ptr [rbp+57h+var_50]
00007FF91E025580  48 85 C9                    test    rcx, rcx
00007FF91E025583  74 14                       jz      short loc_7FF91E025599
00007FF91E025585  48 8B 01                    mov     rax, [rcx]
00007FF91E025588  FF 50 20                    call    qword ptr [rax+20h]
00007FF91E02558B  48 8B 4D 07                 mov     rcx, qword ptr [rbp+57h+var_50]
00007FF91E02558F  84 C0                       test    al, al
00007FF91E025591  49 0F 45 CE                 cmovnz  rcx, r14
00007FF91E025595  48 89 4D 07                 mov     qword ptr [rbp+57h+var_50], rcx
00007FF91E025599  4C 89 7D B7                 mov     [rbp+57h+var_A0], r15
00007FF91E02559D  48 8B 55 F7                 mov     rdx, [rbp+57h+var_60]
00007FF91E0255A1  48 83 FA 10                 cmp     rdx, 10h
00007FF91E0255A5  72 2D                       jb      short loc_7FF91E0255D4
00007FF91E0255A7  48 FF C2                    inc     rdx
00007FF91E0255AA  48 8B 4D DF                 mov     rcx, [rbp+57h+var_78]
00007FF91E0255AE  48 8B C1                    mov     rax, rcx
00007FF91E0255B1  48 81 FA 00 10 00 00        cmp     rdx, 1000h
00007FF91E0255B8  72 15                       jb      short loc_7FF91E0255CF
00007FF91E0255BA  48 83 C2 27                 add     rdx, 27h ; '''
00007FF91E0255BE  48 8B 49 F8                 mov     rcx, [rcx-8]; Block
00007FF91E0255C2  48 2B C1                    sub     rax, rcx
00007FF91E0255C5  48 83 C0 F8                 add     rax, 0FFFFFFFFFFFFFFF8h
00007FF91E0255C9  48 83 F8 1F                 cmp     rax, 1Fh
00007FF91E0255CD  77 4D                       ja      short loc_7FF91E02561C
00007FF91E0255CF  E8 94 FC 2A 00              call    j_j_free
00007FF91E0255D4  4C 89 75 EF                 mov     [rbp+57h+var_68], r14
00007FF91E0255D8  48 C7 45 F7 0F 00 00 00     mov     [rbp+57h+var_60], 0Fh
00007FF91E0255E0  C6 45 DF 00                 mov     byte ptr [rbp+57h+var_78], 0
00007FF91E0255E4  4C 89 65 B7                 mov     [rbp+57h+var_A0], r12
00007FF91E0255E8  48 8D 4D BF                 lea     rcx, [rbp+57h+var_98]
00007FF91E0255EC  E8 F3 A0 2E 00              call    __std_exception_destroy
00007FF91E0255F1  48 8B C7                    mov     rax, rdi
00007FF91E0255F4  48 8B 4D 27                 mov     rcx, [rbp+57h+var_30]
00007FF91E0255F8  48 33 CC                    xor     rcx, rsp; StackCookie
00007FF91E0255FB  E8 20 07 2B 00              call    __security_check_cookie
00007FF91E025600  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0E0h+var_20]
00007FF91E025608  49 8B 5B 40                 mov     rbx, [r11+40h]
00007FF91E02560C  49 8B 73 48                 mov     rsi, [r11+48h]
00007FF91E025610  49 8B E3                    mov     rsp, r11
00007FF91E025613  41 5F                       pop     r15
00007FF91E025615  41 5E                       pop     r14
00007FF91E025617  41 5C                       pop     r12
00007FF91E025619  5F                          pop     rdi
00007FF91E02561A  5D                          pop     rbp
00007FF91E02561B  C3                          retn
00007FF91E02561C  E8 4B 6C 2F 00              call    _invalid_parameter_noinfo_noreturn
00007FF91E025621  CC                          db 0CCh
