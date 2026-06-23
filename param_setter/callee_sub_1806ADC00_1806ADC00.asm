; sub_1806ADC00 @ 0x1806ADC00 (RVA 0x6ADC00) size=0x425

00000001806ADC00  4C 8B D9                    mov     r11, rcx
00000001806ADC03  4C 8B D2                    mov     r10, rdx
00000001806ADC06  49 83 F8 10                 cmp     r8, 10h; switch 17 cases
00000001806ADC0A  76 64                       jbe     short loc_1806ADC70
00000001806ADC0C  49 83 F8 20                 cmp     r8, 20h ; ' '; jumptable 00000001806ADC85 default case
00000001806ADC10  76 3E                       jbe     short loc_1806ADC50
00000001806ADC12  48 2B D1                    sub     rdx, rcx
00000001806ADC15  73 0D                       jnb     short loc_1806ADC24
00000001806ADC17  4B 8D 04 10                 lea     rax, [r8+r10]
00000001806ADC1B  48 3B C8                    cmp     rcx, rax
00000001806ADC1E  0F 82 2C 03 00 00           jb      loc_1806ADF50
00000001806ADC24  49 81 F8 80 00 00 00        cmp     r8, 80h
00000001806ADC2B  0F 86 5F 02 00 00           jbe     loc_1806ADE90
00000001806ADC31  0F BA 25 17 87 60 00 01     bt      cs:dword_180CB6350, 1
00000001806ADC39  0F 83 A1 01 00 00           jnb     loc_1806ADDE0
00000001806ADC3F  EB 9F                       jmp     short sub_1806ADBE0
00000001806ADC41  66 66 66 66 66 66 66 0F 1F 84 00 00 00 00 00  align 10h
00000001806ADC50  0F 10 02                    movups  xmm0, xmmword ptr [rdx]
00000001806ADC53  42 0F 10 4C 02 F0           movups  xmm1, xmmword ptr [rdx+r8-10h]
00000001806ADC59  0F 11 01                    movups  xmmword ptr [rcx], xmm0
00000001806ADC5C  42 0F 11 4C 01 F0           movups  xmmword ptr [rcx+r8-10h], xmm1
00000001806ADC62  48 8B C1                    mov     rax, rcx
00000001806ADC65  C3                          retn
00000001806ADC66  66 66 0F 1F 84 00 00 00 00 00  align 10h
00000001806ADC70  48 8B C1                    mov     rax, rcx
00000001806ADC73  4C 8D 0D 86 23 95 FF        lea     r9, cs:180000000h
00000001806ADC7A  43 8B 8C 81 87 DC 6A 00     mov     ecx, ds:(jpt_1806ADC85 - 180000000h)[r9+r8*4]
00000001806ADC82  49 03 C9                    add     rcx, r9
00000001806ADC85  FF E1                       jmp     rcx; switch jump
00000001806ADC87  D0 DC 6A 00 EF DC 6A 00 D1 DC 6A 00 DF DC 6A 00 18 DD 6A 00 20 DD 6A 00 30 DD 6A 00 40 DD 6A 00 D8 DC 6A 00 70 DD 6A 00 80 DD 6A 00 00 DD 6A 00 90 DD 6A 00 58 DD 6A 00 A0 DD 6A 00 C0 DD 6A 00 F5 DC 6A 00  dd offset locret_1806ADCD0 - 180000000h; jump table for switch statement
00000001806ADCCB  0F 1F 44 00 00              align 10h
00000001806ADCD0  C3                          retn; jumptable 00000001806ADC85 case 0
00000001806ADCD1  0F B7 0A                    movzx   ecx, word ptr [rdx]; jumptable 00000001806ADC85 case 2
00000001806ADCD4  66 89 08                    mov     [rax], cx
00000001806ADCD7  C3                          retn
00000001806ADCD8  48 8B 0A                    mov     rcx, [rdx]; jumptable 00000001806ADC85 case 8
00000001806ADCDB  48 89 08                    mov     [rax], rcx
00000001806ADCDE  C3                          retn
00000001806ADCDF  0F B7 0A                    movzx   ecx, word ptr [rdx]; jumptable 00000001806ADC85 case 3
00000001806ADCE2  44 0F B6 42 02              movzx   r8d, byte ptr [rdx+2]
00000001806ADCE7  66 89 08                    mov     [rax], cx
00000001806ADCEA  44 88 40 02                 mov     [rax+2], r8b
00000001806ADCEE  C3                          retn
00000001806ADCEF  0F B6 0A                    movzx   ecx, byte ptr [rdx]; jumptable 00000001806ADC85 case 1
00000001806ADCF2  88 08                       mov     [rax], cl
00000001806ADCF4  C3                          retn
00000001806ADCF5  F3 0F 6F 02                 movdqu  xmm0, xmmword ptr [rdx]; jumptable 00000001806ADC85 case 16
00000001806ADCF9  F3 0F 7F 00                 movdqu  xmmword ptr [rax], xmm0
00000001806ADCFD  C3                          retn
00000001806ADCFE  66 90                       align 20h
00000001806ADD00  4C 8B 02                    mov     r8, [rdx]; jumptable 00000001806ADC85 case 11
00000001806ADD03  0F B7 4A 08                 movzx   ecx, word ptr [rdx+8]
00000001806ADD07  44 0F B6 4A 0A              movzx   r9d, byte ptr [rdx+0Ah]
00000001806ADD0C  4C 89 00                    mov     [rax], r8
00000001806ADD0F  66 89 48 08                 mov     [rax+8], cx
00000001806ADD13  44 88 48 0A                 mov     [rax+0Ah], r9b
00000001806ADD17  C3                          retn
00000001806ADD18  8B 0A                       mov     ecx, [rdx]; jumptable 00000001806ADC85 case 4
00000001806ADD1A  89 08                       mov     [rax], ecx
00000001806ADD1C  C3                          retn
00000001806ADD1D  0F 1F 00                    align 20h
00000001806ADD20  8B 0A                       mov     ecx, [rdx]; jumptable 00000001806ADC85 case 5
00000001806ADD22  44 0F B6 42 04              movzx   r8d, byte ptr [rdx+4]
00000001806ADD27  89 08                       mov     [rax], ecx
00000001806ADD29  44 88 40 04                 mov     [rax+4], r8b
00000001806ADD2D  C3                          retn
00000001806ADD2E  66 90                       align 10h
00000001806ADD30  8B 0A                       mov     ecx, [rdx]; jumptable 00000001806ADC85 case 6
00000001806ADD32  44 0F B7 42 04              movzx   r8d, word ptr [rdx+4]
00000001806ADD37  89 08                       mov     [rax], ecx
00000001806ADD39  66 44 89 40 04              mov     [rax+4], r8w
00000001806ADD3E  C3                          retn
00000001806ADD3F  90                          align 20h
00000001806ADD40  8B 0A                       mov     ecx, [rdx]; jumptable 00000001806ADC85 case 7
00000001806ADD42  44 0F B7 42 04              movzx   r8d, word ptr [rdx+4]
00000001806ADD47  44 0F B6 4A 06              movzx   r9d, byte ptr [rdx+6]
00000001806ADD4C  89 08                       mov     [rax], ecx
00000001806ADD4E  66 44 89 40 04              mov     [rax+4], r8w
00000001806ADD53  44 88 48 06                 mov     [rax+6], r9b
00000001806ADD57  C3                          retn
00000001806ADD58  4C 8B 02                    mov     r8, [rdx]; jumptable 00000001806ADC85 case 13
00000001806ADD5B  8B 4A 08                    mov     ecx, [rdx+8]
00000001806ADD5E  44 0F B6 4A 0C              movzx   r9d, byte ptr [rdx+0Ch]
00000001806ADD63  4C 89 00                    mov     [rax], r8
00000001806ADD66  89 48 08                    mov     [rax+8], ecx
00000001806ADD69  44 88 48 0C                 mov     [rax+0Ch], r9b
00000001806ADD6D  C3                          retn
00000001806ADD6E  66 90                       align 10h
00000001806ADD70  4C 8B 02                    mov     r8, [rdx]; jumptable 00000001806ADC85 case 9
00000001806ADD73  0F B6 4A 08                 movzx   ecx, byte ptr [rdx+8]
00000001806ADD77  4C 89 00                    mov     [rax], r8
00000001806ADD7A  88 48 08                    mov     [rax+8], cl
00000001806ADD7D  C3                          retn
00000001806ADD7E  66 90                       align 20h
00000001806ADD80  4C 8B 02                    mov     r8, [rdx]; jumptable 00000001806ADC85 case 10
00000001806ADD83  0F B7 4A 08                 movzx   ecx, word ptr [rdx+8]
00000001806ADD87  4C 89 00                    mov     [rax], r8
00000001806ADD8A  66 89 48 08                 mov     [rax+8], cx
00000001806ADD8E  C3                          retn
00000001806ADD8F  90                          align 10h
00000001806ADD90  4C 8B 02                    mov     r8, [rdx]; jumptable 00000001806ADC85 case 12
00000001806ADD93  8B 4A 08                    mov     ecx, [rdx+8]
00000001806ADD96  4C 89 00                    mov     [rax], r8
00000001806ADD99  89 48 08                    mov     [rax+8], ecx
00000001806ADD9C  C3                          retn
00000001806ADD9D  0F 1F 00                    align 20h
00000001806ADDA0  4C 8B 02                    mov     r8, [rdx]; jumptable 00000001806ADC85 case 14
00000001806ADDA3  8B 4A 08                    mov     ecx, [rdx+8]
00000001806ADDA6  44 0F B7 4A 0C              movzx   r9d, word ptr [rdx+0Ch]
00000001806ADDAB  4C 89 00                    mov     [rax], r8
00000001806ADDAE  89 48 08                    mov     [rax+8], ecx
00000001806ADDB1  66 44 89 48 0C              mov     [rax+0Ch], r9w
00000001806ADDB6  C3                          retn
00000001806ADDB7  66 0F 1F 84 00 00 00 00 00  align 20h
00000001806ADDC0  4C 8B 02                    mov     r8, [rdx]; jumptable 00000001806ADC85 case 15
00000001806ADDC3  8B 4A 08                    mov     ecx, [rdx+8]
00000001806ADDC6  44 0F B7 4A 0C              movzx   r9d, word ptr [rdx+0Ch]
00000001806ADDCB  44 0F B6 52 0E              movzx   r10d, byte ptr [rdx+0Eh]
00000001806ADDD0  4C 89 00                    mov     [rax], r8
00000001806ADDD3  89 48 08                    mov     [rax+8], ecx
00000001806ADDD6  66 44 89 48 0C              mov     [rax+0Ch], r9w
00000001806ADDDB  44 88 50 0E                 mov     [rax+0Eh], r10b
00000001806ADDDF  C3                          retn
00000001806ADDE0  0F 10 04 11                 movups  xmm0, xmmword ptr [rcx+rdx]
00000001806ADDE4  4C 03 C1                    add     r8, rcx
00000001806ADDE7  48 83 C1 10                 add     rcx, 10h
00000001806ADDEB  41 F6 C3 0F                 test    r11b, 0Fh
00000001806ADDEF  74 13                       jz      short loc_1806ADE04
00000001806ADDF1  0F 28 C8                    movaps  xmm1, xmm0
00000001806ADDF4  48 83 E1 F0                 and     rcx, 0FFFFFFFFFFFFFFF0h
00000001806ADDF8  0F 10 04 11                 movups  xmm0, xmmword ptr [rcx+rdx]
00000001806ADDFC  48 83 C1 10                 add     rcx, 10h
00000001806ADE00  41 0F 11 0B                 movups  xmmword ptr [r11], xmm1
00000001806ADE04  4C 2B C1                    sub     r8, rcx
00000001806ADE07  4D 8B C8                    mov     r9, r8
00000001806ADE0A  49 C1 E9 07                 shr     r9, 7
00000001806ADE0E  0F 84 88 00 00 00           jz      loc_1806ADE9C
00000001806ADE14  0F 29 41 F0                 movaps  xmmword ptr [rcx-10h], xmm0
00000001806ADE18  4C 3B 0D F9 70 5E 00        cmp     r9, cs:qword_180C94F18
00000001806ADE1F  76 17                       jbe     short loc_1806ADE38
00000001806ADE21  E9 C2 00 00 00              jmp     loc_1806ADEE8
00000001806ADE26  66 66 0F 1F 84 00 00 00 00 00  align 10h
00000001806ADE30  0F 29 41 E0                 movaps  xmmword ptr [rcx-20h], xmm0
00000001806ADE34  0F 29 49 F0                 movaps  xmmword ptr [rcx-10h], xmm1
00000001806ADE38  0F 10 04 11                 movups  xmm0, xmmword ptr [rcx+rdx]
00000001806ADE3C  0F 10 4C 11 10              movups  xmm1, xmmword ptr [rcx+rdx+10h]
00000001806ADE41  48 81 C1 80 00 00 00        add     rcx, 80h
00000001806ADE48  0F 29 41 80                 movaps  xmmword ptr [rcx-80h], xmm0
00000001806ADE4C  0F 29 49 90                 movaps  xmmword ptr [rcx-70h], xmm1
00000001806ADE50  0F 10 44 11 A0              movups  xmm0, xmmword ptr [rcx+rdx-60h]
00000001806ADE55  0F 10 4C 11 B0              movups  xmm1, xmmword ptr [rcx+rdx-50h]
00000001806ADE5A  49 FF C9                    dec     r9
00000001806ADE5D  0F 29 41 A0                 movaps  xmmword ptr [rcx-60h], xmm0
00000001806ADE61  0F 29 49 B0                 movaps  xmmword ptr [rcx-50h], xmm1
00000001806ADE65  0F 10 44 11 C0              movups  xmm0, xmmword ptr [rcx+rdx-40h]
00000001806ADE6A  0F 10 4C 11 D0              movups  xmm1, xmmword ptr [rcx+rdx-30h]
00000001806ADE6F  0F 29 41 C0                 movaps  xmmword ptr [rcx-40h], xmm0
00000001806ADE73  0F 29 49 D0                 movaps  xmmword ptr [rcx-30h], xmm1
00000001806ADE77  0F 10 44 11 E0              movups  xmm0, xmmword ptr [rcx+rdx-20h]
00000001806ADE7C  0F 10 4C 11 F0              movups  xmm1, xmmword ptr [rcx+rdx-10h]
00000001806ADE81  75 AD                       jnz     short loc_1806ADE30
00000001806ADE83  0F 29 41 E0                 movaps  xmmword ptr [rcx-20h], xmm0
00000001806ADE87  49 83 E0 7F                 and     r8, 7Fh
00000001806ADE8B  0F 28 C1                    movaps  xmm0, xmm1
00000001806ADE8E  EB 0C                       jmp     short loc_1806ADE9C
00000001806ADE90  0F 10 04 11                 movups  xmm0, xmmword ptr [rcx+rdx]
00000001806ADE94  48 83 C1 10                 add     rcx, 10h
00000001806ADE98  49 83 E8 10                 sub     r8, 10h
00000001806ADE9C  4D 8B C8                    mov     r9, r8
00000001806ADE9F  49 C1 E9 04                 shr     r9, 4
00000001806ADEA3  74 1C                       jz      short loc_1806ADEC1
00000001806ADEA5  66 66 66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
00000001806ADEB0  0F 11 41 F0                 movups  xmmword ptr [rcx-10h], xmm0
00000001806ADEB4  0F 10 04 11                 movups  xmm0, xmmword ptr [rcx+rdx]
00000001806ADEB8  48 83 C1 10                 add     rcx, 10h
00000001806ADEBC  49 FF C9                    dec     r9
00000001806ADEBF  75 EF                       jnz     short loc_1806ADEB0
00000001806ADEC1  49 83 E0 0F                 and     r8, 0Fh
00000001806ADEC5  74 0D                       jz      short loc_1806ADED4
00000001806ADEC7  4A 8D 04 01                 lea     rax, [rcx+r8]
00000001806ADECB  0F 10 4C 10 F0              movups  xmm1, xmmword ptr [rax+rdx-10h]
00000001806ADED0  0F 11 48 F0                 movups  xmmword ptr [rax-10h], xmm1
00000001806ADED4  0F 11 41 F0                 movups  xmmword ptr [rcx-10h], xmm0
00000001806ADED8  49 8B C3                    mov     rax, r11
00000001806ADEDB  C3                          retn
00000001806ADEDC  0F 1F 40 00                 align 20h
00000001806ADEE0  0F 2B 41 E0                 movntps xmmword ptr [rcx-20h], xmm0
00000001806ADEE4  0F 2B 49 F0                 movntps xmmword ptr [rcx-10h], xmm1
00000001806ADEE8  0F 18 84 11 00 02 00 00     prefetchnta byte ptr [rcx+rdx+200h]
00000001806ADEF0  0F 10 04 11                 movups  xmm0, xmmword ptr [rcx+rdx]
00000001806ADEF4  0F 10 4C 11 10              movups  xmm1, xmmword ptr [rcx+rdx+10h]
00000001806ADEF9  48 81 C1 80 00 00 00        add     rcx, 80h
00000001806ADF00  0F 2B 41 80                 movntps xmmword ptr [rcx-80h], xmm0
00000001806ADF04  0F 2B 49 90                 movntps xmmword ptr [rcx-70h], xmm1
00000001806ADF08  0F 10 44 11 A0              movups  xmm0, xmmword ptr [rcx+rdx-60h]
00000001806ADF0D  0F 10 4C 11 B0              movups  xmm1, xmmword ptr [rcx+rdx-50h]
00000001806ADF12  49 FF C9                    dec     r9
00000001806ADF15  0F 2B 41 A0                 movntps xmmword ptr [rcx-60h], xmm0
00000001806ADF19  0F 2B 49 B0                 movntps xmmword ptr [rcx-50h], xmm1
00000001806ADF1D  0F 10 44 11 C0              movups  xmm0, xmmword ptr [rcx+rdx-40h]
00000001806ADF22  0F 10 4C 11 D0              movups  xmm1, xmmword ptr [rcx+rdx-30h]
00000001806ADF27  0F 18 84 11 40 02 00 00     prefetchnta byte ptr [rcx+rdx+240h]
00000001806ADF2F  0F 2B 41 C0                 movntps xmmword ptr [rcx-40h], xmm0
00000001806ADF33  0F 2B 49 D0                 movntps xmmword ptr [rcx-30h], xmm1
00000001806ADF37  0F 10 44 11 E0              movups  xmm0, xmmword ptr [rcx+rdx-20h]
00000001806ADF3C  0F 10 4C 11 F0              movups  xmm1, xmmword ptr [rcx+rdx-10h]
00000001806ADF41  75 9D                       jnz     short loc_1806ADEE0
00000001806ADF43  0F AE F8                    sfence
00000001806ADF46  E9 38 FF FF FF              jmp     loc_1806ADE83
00000001806ADF4B  0F 1F 44 00 00              align 10h
00000001806ADF50  49 03 C8                    add     rcx, r8
00000001806ADF53  0F 10 44 11 F0              movups  xmm0, xmmword ptr [rcx+rdx-10h]
00000001806ADF58  48 83 E9 10                 sub     rcx, 10h
00000001806ADF5C  49 83 E8 10                 sub     r8, 10h
00000001806ADF60  F6 C1 0F                    test    cl, 0Fh
00000001806ADF63  74 17                       jz      short loc_1806ADF7C
00000001806ADF65  48 8B C1                    mov     rax, rcx
00000001806ADF68  48 83 E1 F0                 and     rcx, 0FFFFFFFFFFFFFFF0h
00000001806ADF6C  0F 10 C8                    movups  xmm1, xmm0
00000001806ADF6F  0F 10 04 11                 movups  xmm0, xmmword ptr [rcx+rdx]
00000001806ADF73  0F 11 08                    movups  xmmword ptr [rax], xmm1
00000001806ADF76  4C 8B C1                    mov     r8, rcx
00000001806ADF79  4D 2B C3                    sub     r8, r11
00000001806ADF7C  4D 8B C8                    mov     r9, r8
00000001806ADF7F  49 C1 E9 07                 shr     r9, 7
00000001806ADF83  74 68                       jz      short loc_1806ADFED
00000001806ADF85  0F 29 01                    movaps  xmmword ptr [rcx], xmm0
00000001806ADF88  EB 0D                       jmp     short loc_1806ADF97
00000001806ADF8A  66 0F 1F 44 00 00           align 10h
00000001806ADF90  0F 29 41 10                 movaps  xmmword ptr [rcx+10h], xmm0
00000001806ADF94  0F 29 09                    movaps  xmmword ptr [rcx], xmm1
00000001806ADF97  0F 10 44 11 F0              movups  xmm0, xmmword ptr [rcx+rdx-10h]
00000001806ADF9C  0F 10 4C 11 E0              movups  xmm1, xmmword ptr [rcx+rdx-20h]
00000001806ADFA1  48 81 E9 80 00 00 00        sub     rcx, 80h
00000001806ADFA8  0F 29 41 70                 movaps  xmmword ptr [rcx+70h], xmm0
00000001806ADFAC  0F 29 49 60                 movaps  xmmword ptr [rcx+60h], xmm1
00000001806ADFB0  0F 10 44 11 50              movups  xmm0, xmmword ptr [rcx+rdx+50h]
00000001806ADFB5  0F 10 4C 11 40              movups  xmm1, xmmword ptr [rcx+rdx+40h]
00000001806ADFBA  49 FF C9                    dec     r9
00000001806ADFBD  0F 29 41 50                 movaps  xmmword ptr [rcx+50h], xmm0
00000001806ADFC1  0F 29 49 40                 movaps  xmmword ptr [rcx+40h], xmm1
00000001806ADFC5  0F 10 44 11 30              movups  xmm0, xmmword ptr [rcx+rdx+30h]
00000001806ADFCA  0F 10 4C 11 20              movups  xmm1, xmmword ptr [rcx+rdx+20h]
00000001806ADFCF  0F 29 41 30                 movaps  xmmword ptr [rcx+30h], xmm0
00000001806ADFD3  0F 29 49 20                 movaps  xmmword ptr [rcx+20h], xmm1
00000001806ADFD7  0F 10 44 11 10              movups  xmm0, xmmword ptr [rcx+rdx+10h]
00000001806ADFDC  0F 10 0C 11                 movups  xmm1, xmmword ptr [rcx+rdx]
00000001806ADFE0  75 AE                       jnz     short loc_1806ADF90
00000001806ADFE2  0F 29 41 10                 movaps  xmmword ptr [rcx+10h], xmm0
00000001806ADFE6  49 83 E0 7F                 and     r8, 7Fh
00000001806ADFEA  0F 28 C1                    movaps  xmm0, xmm1
00000001806ADFED  4D 8B C8                    mov     r9, r8
00000001806ADFF0  49 C1 E9 04                 shr     r9, 4
00000001806ADFF4  74 1A                       jz      short loc_1806AE010
00000001806ADFF6  66 66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
00000001806AE000  0F 11 01                    movups  xmmword ptr [rcx], xmm0
00000001806AE003  48 83 E9 10                 sub     rcx, 10h
00000001806AE007  0F 10 04 11                 movups  xmm0, xmmword ptr [rcx+rdx]
00000001806AE00B  49 FF C9                    dec     r9
00000001806AE00E  75 F0                       jnz     short loc_1806AE000
00000001806AE010  49 83 E0 0F                 and     r8, 0Fh
00000001806AE014  74 08                       jz      short loc_1806AE01E
00000001806AE016  41 0F 10 0A                 movups  xmm1, xmmword ptr [r10]
00000001806AE01A  41 0F 11 0B                 movups  xmmword ptr [r11], xmm1
00000001806AE01E  0F 11 01                    movups  xmmword ptr [rcx], xmm0
00000001806AE021  49 8B C3                    mov     rax, r11
00000001806AE024  C3                          retn
