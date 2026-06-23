// strcpy_s_0  @ 0x1806F4B60  (RVA 0x6F4B60)
// prototype: errno_t __cdecl(char *Destination, rsize_t SizeInBytes, const char *Source)
// callees: 0x1806BC24C, 0x1806EC87C, 0x1806F4B60

errno_t __cdecl strcpy_s_0(char *Destination, rsize_t SizeInBytes, const char *Source)
{
  errno_t v3; // ebx
  int *v4; // rax
  char *v6; // r9
  signed __int64 v7; // r8
  char v8; // al

  v3 = 0;
  if ( !Destination || !SizeInBytes )
    goto LABEL_5;
  if ( !Source )
  {
    *Destination = 0;
LABEL_5:
    v4 = errno();
    v3 = 22;
LABEL_6:
    *v4 = v3;
    invalid_parameter_noinfo();
    return v3;
  }
  v6 = Destination;
  v7 = Source - Destination;
  do
  {
    v8 = v6[v7];
    *v6++ = v8;
    if ( !v8 )
      break;
    --SizeInBytes;
  }
  while ( SizeInBytes );
  if ( !SizeInBytes )
  {
    *Destination = 0;
    v4 = errno();
    v3 = 34;
    goto LABEL_6;
  }
  return v3;
}

