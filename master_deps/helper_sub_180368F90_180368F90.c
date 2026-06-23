// sub_180368F90 @ 0x180368F90 (RVA 0x368F90)

float __fastcall sub_180368F90(float result)
{
  if ( result > 1.0 )
    return fmodf(result + 1.0, 2.0) - 1.0;
  return result;
}

