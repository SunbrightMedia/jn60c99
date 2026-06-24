// sub_7FF91E0256C0 @ rva 0x3C56C0

void __fastcall __noreturn sub_7FF91E0256C0(__int64 a1)
{
  _BYTE pExceptionObject[152]; // [rsp+20h] [rbp-98h] BYREF

  sub_7FF91E025410(pExceptionObject, a1);
  throw (boost::wrapexcept<boost::lock_error> *)pExceptionObject;
}

