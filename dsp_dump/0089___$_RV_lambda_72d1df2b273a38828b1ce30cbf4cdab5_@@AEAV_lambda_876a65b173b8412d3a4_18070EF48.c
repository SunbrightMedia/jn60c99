// ??$?RV_lambda_72d1df2b273a38828b1ce30cbf4cdab5_@@AEAV_lambda_876a65b173b8412d3a47c70a915b0cf4_@@V_lambda_41932305e351933ebe8f8be3ed8bb5dc_@@@?$__crt_seh_guarded_call@X@@QEAAX$$QEAV_lambda_72d1df2b273a38828b1ce30cbf4cdab5_@@AEAV_lambda_876a65b173b8412d3a47c70a915b0cf4_@@$$QEAV_lambda_41932305e351933ebe8f8be3ed8bb5dc_@@@Z  @ 0x18070EF48  (RVA 0x70EF48)
// prototype: 
// callees: 0x18070ABE8, 0x18070AC3C

void __fastcall __crt_seh_guarded_call<void>::operator()<_lambda_72d1df2b273a38828b1ce30cbf4cdab5_,_lambda_876a65b173b8412d3a47c70a915b0cf4_ &,_lambda_41932305e351933ebe8f8be3ed8bb5dc_>(
        __int64 a1,
        int *a2,
        __int64 a3,
        int *a4)
{
  _vcrt_lock_0(*a2);
  _InterlockedIncrement(*(volatile signed __int32 **)(**(_QWORD **)a3 + 136LL));
  _vcrt_unlock_0(*a4);
}

