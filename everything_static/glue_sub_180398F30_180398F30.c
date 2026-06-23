// sub_180398F30 @ 0x180398F30 (RVA 0x398F30)

void __fastcall sub_180398F30(__int64 a1, int a2, _DWORD **a3)
{
  int v4; // eax

  if ( *(_BYTE *)(a1 + 20) )
  {
    v4 = *(_DWORD *)(a1 + 11022344);
    if ( v4 <= 0 )
    {
      **a3 = 0;
      *a3[1] = 0;
      switch ( a2 )
      {
        case 0:
          sub_180369070(a1, a3);
          sub_1803C24A0(a1);
          break;
        case 1:
          sub_18036CE00(a1, a3);
          sub_1803C24A0(a1);
          break;
        case 2:
          sub_180370B90(a1, a3);
          sub_1803C24A0(a1);
          break;
        case 3:
          sub_180374900(a1, a3);
          sub_1803C24A0(a1);
          break;
        case 4:
          sub_180378690(a1, a3);
          sub_1803C24A0(a1);
          break;
        case 5:
          sub_18037C420(a1, a3);
          sub_1803C24A0(a1);
          break;
        case 6:
          sub_180380190(a1, a3);
          sub_1803C24A0(a1);
          break;
        case 7:
          sub_180383F20(a1, a3);
          goto LABEL_13;
        default:
LABEL_13:
          sub_1803C24A0(a1);
          break;
      }
    }
    else
    {
      *(_DWORD *)(a1 + 11022344) = v4 - 1;
      **a3 = 0;
      *a3[1] = 0;
      sub_1803C24A0(a1);
    }
  }
}

