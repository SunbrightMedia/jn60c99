// ?construct_ptd_array@@YAXQEAU__acrt_ptd@@@Z  @ 0x18070F344  (RVA 0x70F344)
// prototype: void __fastcall(struct __acrt_ptd *const)
// callees: 0x18070EF48, 0x18070EFC8
// constants/globals referenced:
//   0x180CB79C8 [.data] qword_180CB79C8  u32=4294967295  f32=nan  f64=nan
//   0x180A91E80 [.rdata] unk_180A91E80  u32=3221225477  f32=-2.0000011920928955  f64=2.49334505463e-313
//   0x180C958F0 [.data] unk_180C958F0  u32=0  f32=0.0  f64=0.0

void __fastcall construct_ptd_array(struct __acrt_ptd *const a1)
{
  int v1; // [rsp+20h] [rbp-30h] BYREF
  int v2; // [rsp+24h] [rbp-2Ch] BYREF
  struct __acrt_ptd *v3; // [rsp+28h] [rbp-28h] BYREF
  __int64 *v4; // [rsp+30h] [rbp-20h] BYREF
  struct __acrt_ptd **v5; // [rsp+38h] [rbp-18h] BYREF
  _QWORD v6[2]; // [rsp+40h] [rbp-10h] BYREF
  char v7; // [rsp+68h] [rbp+18h] BYREF
  int v8; // [rsp+70h] [rbp+20h] BYREF
  int v9; // [rsp+78h] [rbp+28h] BYREF

  v3 = a1;
  v5 = &v3;
  v8 = 5;
  v9 = 5;
  v6[0] = &v3;
  v6[1] = &v4;
  v1 = 4;
  v2 = 4;
  v4 = &qword_180CB79C8;
  *((_DWORD *)a1 + 10) = 1;
  *(_QWORD *)v3 = &unk_180A91E80;
  *((_DWORD *)v3 + 234) = 1;
  *((_QWORD *)v3 + 17) = &unk_180C958F0;
  *((_WORD *)v3 + 94) = 67;
  *((_WORD *)v3 + 225) = 67;
  *((_QWORD *)v3 + 116) = 0;
  __crt_seh_guarded_call<void>::operator()<_lambda_72d1df2b273a38828b1ce30cbf4cdab5_,_lambda_876a65b173b8412d3a47c70a915b0cf4_ &,_lambda_41932305e351933ebe8f8be3ed8bb5dc_>(
    (__int64)&v7,
    &v9,
    (__int64)&v5,
    &v8);
  __crt_seh_guarded_call<void>::operator()<_lambda_5e887d1dcbef67a5eb4283622ba103bf_,_lambda_4466841279450cc726390878d4a41900_ &,_lambda_341c25c0346d94847f1f3c463c57e077_>(
    (__int64)&v7,
    &v2,
    (__int64)v6,
    &v1);
}

