// sub_1803C52E0  @ 0x1803C52E0  (RVA 0x3C52E0)
// prototype: 
// callees: 0x1803C52E0, 0x1803C5CF0, 0x1803C8120, 0x1803C8390, 0x1803C86A0, 0x1803C87E0, 0x180675268, 0x18067E6B0
// constants/globals referenced:
//   0x1809347D0 [.idata] __imp_CloseHandle  u32=4294967295  f32=nan  f64=nan
//   0x180934938 [.idata] __imp_WaitForSingleObjectEx  u32=4294967295  f32=nan  f64=nan

// Hidden C++ exception states: #wind=4
__int64 __fastcall sub_1803C52E0(__int64 a1, __int64 a2, __int64 a3)
{
  __int64 *v6; // rax
  __int64 v7; // rdi
  HANDLE *v8; // rbx
  char *v9; // rcx
  char v10; // si
  unsigned __int8 v11; // bl
  _QWORD v13[3]; // [rsp+28h] [rbp-40h] BYREF
  char v14; // [rsp+40h] [rbp-28h]
  void *Block; // [rsp+70h] [rbp+8h] BYREF

  v13[2] = a2;
  v14 = 0;
  v6 = (__int64 *)sub_1803C8120(a1, &Block);
  v7 = *v6;
  v13[0] = *v6;
  *v6 = 0;
  v13[1] = a1;
  v8 = (HANDLE *)Block;
  if ( Block )
  {
    if ( _InterlockedExchangeAdd((volatile signed __int32 *)Block + 6, 0xFFFFFFFF) == 1 && v8 )
    {
      v9 = (char *)v8[1];
      if ( (unsigned __int64)(v9 - 1) <= 0xFFFFFFFFFFFFFFFDuLL )
        CloseHandle(v9);
      if ( (char *)*v8 - 1 <= (char *)0xFFFFFFFFFFFFFFFDLL )
        CloseHandle(*v8);
      j_j_free(v8);
    }
    v7 = v13[0];
  }
  sub_1803C87E0(a2);
  v10 = 1;
  v14 = 1;
  while ( (unsigned __int8)sub_18067E6B0(*(_QWORD *)v7, a3) )
  {
    if ( !WaitForSingleObjectEx(*(HANDLE *)(v7 + 8), 0, 0) )
    {
      sub_1803C86A0(v13);
      sub_1803C8390(a2);
      v10 = 0;
      v14 = 0;
      v11 = 1;
      goto LABEL_15;
    }
  }
  v11 = 0;
LABEL_15:
  sub_1803C86A0(v13);
  sub_1803C5CF0(v13);
  if ( v10 )
    sub_1803C8390(a2);
  return v11;
}

