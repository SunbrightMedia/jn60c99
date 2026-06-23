// _set_errno_from_matherr  @ 0x1807147A0  (RVA 0x7147A0)
// prototype: 
// callees: 0x1806EC87C, 0x1807147A0

int *__fastcall set_errno_from_matherr(int a1)
{
  int *result; // rax

  if ( a1 == 1 )
  {
    result = errno();
    *result = 33;
  }
  else
  {
    result = (int *)(unsigned int)(a1 - 2);
    if ( (unsigned int)result <= 1 )
    {
      result = errno();
      *result = 34;
    }
  }
  return result;
}

