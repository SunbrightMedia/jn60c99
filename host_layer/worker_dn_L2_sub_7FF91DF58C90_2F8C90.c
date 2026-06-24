// sub_7FF91DF58C90 @ rva 0x2F8C90

void __fastcall __noreturn sub_7FF91DF58C90(__int64 a1)
{
  _BYTE pExceptionObject[152]; // [rsp+20h] [rbp-98h] BYREF

  sub_7FF91DF53E00(pExceptionObject, a1);
  throw (boost::wrapexcept<boost::thread_resource_error> *)pExceptionObject;
}

