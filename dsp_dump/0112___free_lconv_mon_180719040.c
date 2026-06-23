// __free_lconv_mon  @ 0x180719040  (RVA 0x719040)
// prototype: 
// callees: 0x18070FB50, 0x180719040
// constants/globals referenced:
//   0x180C95178 [.data] off_180C95178  u32=2160815356  f32=-1.8681701947226878e-38  f64=3.1895804254e-314
//   0x180C95180 [.data] off_180C95180  u32=2160815356  f32=-1.8681701947226878e-38  f64=3.1895804254e-314
//   0x180C95188 [.data] off_180C95188  u32=2160815356  f32=-1.8681701947226878e-38  f64=3.1895804254e-314
//   0x180C95190 [.data] off_180C95190  u32=2160815356  f32=-1.8681701947226878e-38  f64=3.1895804254e-314
//   0x180C95198 [.data] off_180C95198  u32=2160815356  f32=-1.8681701947226878e-38  f64=3.1895804254e-314
//   0x180C951A0 [.data] off_180C951A0  u32=2160815356  f32=-1.8681701947226878e-38  f64=3.1895804254e-314
//   0x180C951A8 [.data] off_180C951A8  u32=2160815356  f32=-1.8681701947226878e-38  f64=3.1895804254e-314
//   0x180C951C8 [.data] off_180C951C8  u32=2160815360  f32=-1.8681707552420736e-38  f64=3.1895804273e-314
//   0x180C951D0 [.data] off_180C951D0  u32=2160815360  f32=-1.8681707552420736e-38  f64=3.1895804273e-314
//   0x180C951D8 [.data] off_180C951D8  u32=2160815360  f32=-1.8681707552420736e-38  f64=3.1895804273e-314
//   0x180C951E0 [.data] off_180C951E0  u32=2160815360  f32=-1.8681707552420736e-38  f64=3.1895804273e-314
//   0x180C951E8 [.data] off_180C951E8  u32=2160815360  f32=-1.8681707552420736e-38  f64=3.1895804273e-314
//   0x180C951F0 [.data] off_180C951F0  u32=2160815360  f32=-1.8681707552420736e-38  f64=3.1895804273e-314

void __fastcall _free_lconv_mon(_QWORD *a1)
{
  void *v2; // rcx
  void *v3; // rcx
  void *v4; // rcx
  void *v5; // rcx
  void *v6; // rcx
  void *v7; // rcx
  void *v8; // rcx
  void *v9; // rcx
  void *v10; // rcx
  void *v11; // rcx
  void *v12; // rcx
  void *v13; // rcx
  void *v14; // rcx

  if ( a1 )
  {
    v2 = (void *)a1[3];
    if ( v2 != off_180C95178 )
      free_base(v2);
    v3 = (void *)a1[4];
    if ( v3 != off_180C95180 )
      free_base(v3);
    v4 = (void *)a1[5];
    if ( v4 != off_180C95188 )
      free_base(v4);
    v5 = (void *)a1[6];
    if ( v5 != off_180C95190 )
      free_base(v5);
    v6 = (void *)a1[7];
    if ( v6 != off_180C95198 )
      free_base(v6);
    v7 = (void *)a1[8];
    if ( v7 != off_180C951A0 )
      free_base(v7);
    v8 = (void *)a1[9];
    if ( v8 != off_180C951A8 )
      free_base(v8);
    v9 = (void *)a1[13];
    if ( v9 != off_180C951C8 )
      free_base(v9);
    v10 = (void *)a1[14];
    if ( v10 != off_180C951D0 )
      free_base(v10);
    v11 = (void *)a1[15];
    if ( v11 != off_180C951D8 )
      free_base(v11);
    v12 = (void *)a1[16];
    if ( v12 != off_180C951E0 )
      free_base(v12);
    v13 = (void *)a1[17];
    if ( v13 != off_180C951E8 )
      free_base(v13);
    v14 = (void *)a1[18];
    if ( v14 != off_180C951F0 )
      free_base(v14);
  }
}

