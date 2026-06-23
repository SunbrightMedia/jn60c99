// ??$?RV_lambda_5e887d1dcbef67a5eb4283622ba103bf_@@AEAV_lambda_4466841279450cc726390878d4a41900_@@V_lambda_341c25c0346d94847f1f3c463c57e077_@@@?$__crt_seh_guarded_call@X@@QEAAX$$QEAV_lambda_5e887d1dcbef67a5eb4283622ba103bf_@@AEAV_lambda_4466841279450cc726390878d4a41900_@@$$QEAV_lambda_341c25c0346d94847f1f3c463c57e077_@@@Z  @ 0x18070EFC8  (RVA 0x70EFC8)
// prototype: 
// callees: 0x18070ABE8, 0x18070AC3C, 0x18070F7C4

void __fastcall __crt_seh_guarded_call<void>::operator()<_lambda_5e887d1dcbef67a5eb4283622ba103bf_,_lambda_4466841279450cc726390878d4a41900_ &,_lambda_341c25c0346d94847f1f3c463c57e077_>(
        __int64 a1,
        int *a2,
        __int64 a3,
        int *a4)
{
  _vcrt_lock_0(*a2);
  replace_current_thread_locale_nolock(
    **(struct __acrt_ptd *const **)a3,
    ***(struct __crt_locale_data *const ***)(a3 + 8));
  _vcrt_unlock_0(*a4);
}

