// ?free_crt_array_internal@@YAXQEAPEBX_K@Z  @ 0x180719AC0  (RVA 0x719AC0)
// prototype: void __fastcall(const void **const, unsigned __int64)
// callees: 0x18070FB50, 0x180719AC0

void __fastcall free_crt_array_internal(void **a1, __int64 a2)
{
  __int64 v2; // rdi
  void **v3; // rbx
  __int64 v4; // rsi

  v2 = 0;
  v3 = a1;
  v4 = a2 & 0x1FFFFFFFFFFFFFFFLL;
  if ( a1 > &a1[a2] )
    v4 = 0;
  if ( v4 )
  {
    do
    {
      free_base(*v3);
      ++v2;
      ++v3;
    }
    while ( v2 != v4 );
  }
}

