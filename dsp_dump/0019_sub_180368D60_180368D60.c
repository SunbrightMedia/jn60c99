// sub_180368D60  @ 0x180368D60  (RVA 0x368D60)
// prototype: float(void)
// callees: 0x180368D60
// constants/globals referenced:
//   0x18098ACA4 [.rdata] dword_18098ACA4  u32=1266679808  f32=16777216.0  f64=6.258229774e-315
//   0x18098AC70 [.rdata] dword_18098AC70  u32=864026624  f32=5.960464477539063e-08  f64=3.493706737605413e-30

float __fastcall sub_180368D60(float a1)
{
  int v1; // edx
  int v2; // edx
  int v3; // eax
  int v4; // ecx
  int v5; // eax
  signed int v6; // edx

  v1 = (int)(float)(a1 * 16777216.0);
  if ( !v1 )
  {
    v2 = 1;
    goto LABEL_8;
  }
  v3 = v1 & 0x200000;
  if ( (v1 & 0x800000) != 0 )
  {
    if ( !v3 )
    {
LABEL_5:
      v2 = 2 * v1;
      goto LABEL_8;
    }
  }
  else if ( v3 )
  {
    goto LABEL_5;
  }
  v2 = 2 * v1 + 1;
LABEL_8:
  v4 = v2;
  v5 = v2 & 0xFFFFFF;
  v6 = v2 | 0xFF000000;
  if ( (v4 & 0x1000000) == 0 )
    v6 = v5;
  return (float)v6 * 0.000000059604645;
}

