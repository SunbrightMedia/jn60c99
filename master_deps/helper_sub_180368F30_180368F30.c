// sub_180368F30 @ 0x180368F30 (RVA 0x368F30)

float __fastcall sub_180368F30(float result)
{
  if ( result > 1.0 )
    return fmodf(result + 1.0, 2.0) - 1.0;
  if ( result < -1.0 )
    return fmodf(result - 1.0, 2.0) + 1.0;
  return result;
}

