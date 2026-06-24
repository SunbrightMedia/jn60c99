// sub_7FF91DFF8F30 @ rva 0x398F30

void __fastcall sub_7FF91DFF8F30(__int64 a1, int a2, _DWORD **a3)
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
          sub_7FF91DFC9070(a1, a3);
          sub_7FF91E0224A0((_QWORD *)a1);
          break;
        case 1:
          sub_7FF91DFCCE00(a1, a3);
          sub_7FF91E0224A0((_QWORD *)a1);
          break;
        case 2:
          sub_7FF91DFD0B90(a1, a3);
          sub_7FF91E0224A0((_QWORD *)a1);
          break;
        case 3:
          sub_7FF91DFD4900(a1, a3);
          sub_7FF91E0224A0((_QWORD *)a1);
          break;
        case 4:
          sub_7FF91DFD8690(a1, a3);
          sub_7FF91E0224A0((_QWORD *)a1);
          break;
        case 5:
          sub_7FF91DFDC420(a1, a3);
          sub_7FF91E0224A0((_QWORD *)a1);
          break;
        case 6:
          sub_7FF91DFE0190(a1, a3);
          sub_7FF91E0224A0((_QWORD *)a1);
          break;
        case 7:
          sub_7FF91DFE3F20(a1, a3);
          goto LABEL_13;
        default:
LABEL_13:
          sub_7FF91E0224A0((_QWORD *)a1);
          break;
      }
    }
    else
    {
      *(_DWORD *)(a1 + 11022344) = v4 - 1;
      **a3 = 0;
      *a3[1] = 0;
      sub_7FF91E0224A0((_QWORD *)a1);
    }
  }
}

