// __free_lconv_num  @ 0x1807196B4  (RVA 0x7196B4)
// prototype: 
// callees: 0x18070FB50, 0x1807196B4
// constants/globals referenced:
//   0x180C95160 [.data] off_180C95160  u32=2160677376  f32=-1.848835078511934e-38  f64=3.189512254e-314
//   0x180C95168 [.data] off_180C95168  u32=2160815356  f32=-1.8681701947226878e-38  f64=3.1895804254e-314
//   0x180C95170 [.data] off_180C95170  u32=2160815356  f32=-1.8681701947226878e-38  f64=3.1895804254e-314
//   0x180C951B8 [.data] off_180C951B8  u32=2160677380  f32=-1.8488356390313197e-38  f64=3.189512256e-314
//   0x180C951C0 [.data] off_180C951C0  u32=2160815360  f32=-1.8681707552420736e-38  f64=3.1895804273e-314

void __fastcall _free_lconv_num(__int64 a1)
{
  void *v2; // rcx
  void *v3; // rcx
  void *v4; // rcx
  void *v5; // rcx
  void *v6; // rcx

  if ( a1 )
  {
    v2 = *(void **)a1;
    if ( v2 != off_180C95160 )
      free_base(v2);
    v3 = *(void **)(a1 + 8);
    if ( v3 != off_180C95168 )
      free_base(v3);
    v4 = *(void **)(a1 + 16);
    if ( v4 != off_180C95170 )
      free_base(v4);
    v5 = *(void **)(a1 + 88);
    if ( v5 != off_180C951B8 )
      free_base(v5);
    v6 = *(void **)(a1 + 96);
    if ( v6 != off_180C951C0 )
      free_base(v6);
  }
}

