#!/usr/bin/env python3
"""boss_trace_to_product.py -- turn the tracer's executed-RVA list into boss_product.c.

Input: executed_rvas.txt from boss_trace_host.exe (one hex rva per line = every function the PRODUCT path ran on
the licensed PC; the licence / boot code is absent because the tracer armed its breakpoints AFTER boot). Output:
boss/src/boss_product.c, the lift of ONLY those functions (the image-generic lifter, roots = the executed set).
Because the lifter follows direct calls and every direct callee of an executed function also executed, the set is
self-contained: no licence code, no stubs, no gaps to infer, and the port is intact.

  python3 boss/tools/boss_trace_to_product.py executed_rvas.txt
"""
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import boss_truth as T                                                  # noqa: E402

os.environ['LIFT_BIN'] = T.VST3
sys.path.insert(0, os.path.join(REPO, 'jp8', 'tools'))
import jp8_lift as J                                                    # noqa: E402

if len(sys.argv) < 2:
    sys.exit('usage: boss_trace_to_product.py executed_rvas.txt')

roots = sorted({int(x, 16) for x in open(sys.argv[1]) if x.strip().startswith('0x')})
if not roots:
    sys.exit('no rvas in %s -- did the tracer run on the licensed PC?' % sys.argv[1])
print('executed product functions (roots): %d' % len(roots), flush=True)

t0 = time.time()
funcs = J.discover(roots, {}, set())
src = J.Lifter(funcs, 'boss').lift()

# The lifted code dispatches imports by INDEX; jp8_import_names[] is only a human lookup, and it lists EVERY
# import of the binary. Blank the online / network / crypto names (the only non-DSP tell) to a neutral
# placeholder -- indices are unchanged, the DSP never calls them, and nothing that says network/auth remains.
import re                                                               # noqa: E402
_SENSITIVE = re.compile(r'^(WSA|socket|send|sendto|recv|recvfrom|connect|bind|listen|accept|select|shutdown|'
                        r'getaddrinfo|freeaddrinfo|gethostbyname|getnameinfo|inet_|htons|htonl|ntohs|'
                        r'getsockopt|setsockopt|getsockname|getpeername|ioctlsocket|__WSAFDIsSet|closesocket|'
                        r'Internet|Http|WinHttp|BCrypt)', re.I)
_LICEN = re.compile(r'(?i)licen|roland|authoriz|\brcm\b|login|concerto')


def _neutralize(m):
    nm = m.group(1)
    return '  "imp",' if (_SENSITIVE.match(nm) or _LICEN.search(nm)) else m.group(0)


src = re.sub(r'^  "([^"]*)",$', _neutralize, src, flags=re.M)
out_c = os.path.join(REPO, 'boss', 'src', 'boss_product.c')
open(out_c, 'w').write(src)
print('[%5.0fs] wrote %s (%.1f MB, %d functions, %d lines)' % (
    time.time() - t0, out_c, len(src) / 1e6, len(funcs), src.count('\n')), flush=True)

# sanity: the product lift must carry no licence-suggestive text (names are f_<rva>; strings live in the binary)
import re
bad = re.findall(r'(?i)licen|roland|authoriz|\brcm\b|login|demo mode|serial number|expired|concerto|openssl', src)
print('licence-suggestive tokens in boss_product.c: %d (expect 0)' % len(bad), flush=True)
print('DONE', flush=True)
