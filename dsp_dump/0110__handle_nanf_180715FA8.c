// _handle_nanf  @ 0x180715FA8  (RVA 0x715FA8)
// prototype: float __fastcall(_QWORD, _QWORD, _QWORD, _QWORD)
// callees: 

float __fastcall handle_nanf(int a1)
{
  float result; // xmm0_4

  LODWORD(result) = a1 | 0x400000;
  return result;
}

