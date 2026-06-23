// sub_18035DE50  @ 0x18035DE50  (RVA 0x35DE50)  floats=21
// .rdata float constants referenced by this function:
//   0x180988F9C  dword_180988F9C = 1.4144271612167358
//   0x180988FA4  dword_180988FA4 = -0.4478282928466797
//   0x180988FA8  dword_180988FA8 = -0.6126852631568909
//   0x180988FB0  xmmword_180988FB0 = -0.880770206451416
//   0x180988FC0  xmmword_180988FC0 = -0.7243985533714294
//   0x180988FD0  xmmword_180988FD0 = -0.4956410825252533
//   0x180988FE0  xmmword_180988FE0 = 1.8390960693359375
//   0x180988FF0  xmmword_180988FF0 = 1.6010522842407227
//   0x180989000  xmmword_180989000 = 1.0746136903762817
//   0x180989010  xmmword_180989010 = 0.3598254919052124
//   0x180989020  xmmword_180989020 = 0.0
//   0x180989030  xmmword_180989030 = 0.0
//   0x180989040  xmmword_180989040 = 0.0
//   0x180989050  xmmword_180989050 = -0.44444698095321655
//   0x180989080  xmmword_180989080 = 0.23638145625591278
//   0x1809890A0  xmmword_1809890A0 = 0.04461168497800827
//   0x1809890B0  xmmword_1809890B0 = 0.007571428082883358
//   0x1809890C0  xmmword_1809890C0 = 0.5514053106307983
//   0x1809890D0  xmmword_1809890D0 = 0.0
//   0x1809890E0  xmmword_1809890E0 = 0.0
//   0x180AE50B4  dword_180AE50B4 = 1.0

double __fastcall sub_18035DE50(__int64 a1, int a2, int a3)
{
  int v6; // r9d
  __int64 v7; // r8
  __int64 v8; // rdx
  __int64 v9; // rcx
  int v10; // r9d
  __int64 v11; // r8
  __int64 v12; // rdx
  __int64 v13; // rcx
  __int64 v14; // r8
  int v15; // eax
  __int64 v16; // rdx
  __int64 v17; // rcx
  int v18; // r9d
  int v19; // r9d
  int v20; // r9d
  int v21; // r9d
  int v22; // r9d
  __int64 v23; // r8
  __int64 v24; // rdx
  __int64 v25; // rcx

  *(_DWORD *)(a1 + 32) = a3;
  sub_180356380((__int64)&unk_180CB0DC8, 64, a3);
  v7 = *(unsigned int *)(a1 + 128);
  v8 = *(unsigned int *)(a1 + 96);
  v9 = *(_QWORD *)(a1 + 8);
  if ( a2 )
    sub_1803C1090(v9, v8, v7);
  else
    sub_1803C10D0(v9, v8, v7, v6, 0);
  v11 = *(unsigned int *)(a1 + 132);
  v12 = *(unsigned int *)(a1 + 96);
  v13 = *(_QWORD *)(a1 + 8);
  if ( a2 )
    sub_1803C1090(v13, v12, v11);
  else
    sub_1803C10D0(v13, v12, v11, v10, 0);
  v14 = *(unsigned int *)(a1 + 188);
  v15 = 0;
  v16 = *(unsigned int *)(a1 + 96);
  if ( a3 >= 0 )
    v15 = a3;
  if ( v15 > 13 )
    v15 = 13;
  v17 = *(_QWORD *)(a1 + 8);
  if ( a2 )
  {
    sub_1803C1090(v17, v16, v14);
    sub_1803C1090(*(_QWORD *)(a1 + 8), *(unsigned int *)(a1 + 96), *(unsigned int *)(a1 + 192));
    sub_1803C1090(*(_QWORD *)(a1 + 8), *(unsigned int *)(a1 + 96), *(unsigned int *)(a1 + 196));
    sub_1803C1090(*(_QWORD *)(a1 + 8), *(unsigned int *)(a1 + 96), *(unsigned int *)(a1 + 200));
    sub_1803C1090(*(_QWORD *)(a1 + 8), *(unsigned int *)(a1 + 96), *(unsigned int *)(a1 + 204));
  }
  else
  {
    sub_1803C10D0(v17, v16, v14, 5 * v15, 0);
    sub_1803C10D0(*(_QWORD *)(a1 + 8), *(_DWORD *)(a1 + 96), *(_DWORD *)(a1 + 192), v18, 0);
    sub_1803C10D0(*(_QWORD *)(a1 + 8), *(_DWORD *)(a1 + 96), *(_DWORD *)(a1 + 196), v19, 0);
    sub_1803C10D0(*(_QWORD *)(a1 + 8), *(_DWORD *)(a1 + 96), *(_DWORD *)(a1 + 200), v20, 0);
    sub_1803C10D0(*(_QWORD *)(a1 + 8), *(_DWORD *)(a1 + 96), *(_DWORD *)(a1 + 204), v21, 0);
  }
  v23 = *(unsigned int *)(a1 + 208);
  v24 = *(unsigned int *)(a1 + 96);
  v25 = *(_QWORD *)(a1 + 8);
  if ( a2 )
    return sub_1803C1090(v25, v24, v23);
  else
    return sub_1803C10D0(v25, v24, v23, v22, 0);
}

