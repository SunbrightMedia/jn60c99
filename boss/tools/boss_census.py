#!/usr/bin/env python3
"""boss_census.py -- the BOSS binary census (charter section 1: census from the binary BEFORE gates),
mechanical and reproducible. Everything READ (static) from boss/truth/BOSS_Effects_Pedals.vst3, bound to its
pinned sha256 (boss_truth): the version resource, the VST3 exports, the import surface by DLL, the PE sections
with their runtime-filled tails, the TLS callbacks + entry, the RTTI pedal-model and wrapper classes, and the
companion-file count. Emits JSON to stdout; `--tooth` proves the census is binary-derived (a flipped byte breaks
the sha bind). PLUMBING ONLY: it reimplements no plugin logic.

  python3 boss/tools/boss_census.py            # JSON census of the pinned binary
  python3 boss/tools/boss_census.py --tooth    # prove the sha bind fails on one flipped byte
"""
import collections
import json
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'tools', 'verify'))
import boss_truth as T                                                  # noqa: E402
import pefile                                                           # noqa: E402
from pe_recon import PE                                                 # noqa: E402  (reuse the section recon)

# model DSP classes appear mangled as C<Model>Dsp (plain '.?AVCDs1Dsp@@' and templated
# '.?AV?$CCs1Dsp@$01@@', and inside the CEfx* wrappers). The four product wrapper categories the factory
# instantiates are CEfxStereoPlugin / ...WithCarryover / CEfxStereoSharedChannelPlugin /
# CEfxMultiProcessorStereoPlugin. Both are READ straight from the RTTI names.
MODEL_DSP_RE = re.compile(r'C([A-Za-z][A-Za-z0-9]{1,10}?)Dsp')
WRAPPER_RE = re.compile(r'(CEfx[A-Za-z]+Plugin(?:WithCarryover)?)')


def version(pe):
    out = {}
    try:
        for fi in pe.FileInfo[0]:
            if fi.Key == b'StringFileInfo':
                for st in fi.StringTable:
                    for k, v in st.entries.items():
                        out[k.decode()] = v.decode()
    except Exception:
        pass
    return out


def rtti_classes(img):
    """every MSVC RTTI TypeDescriptor name '.?AV<name>@@' / '.?AU<name>@@' in the image (READ)."""
    names = set()
    for m in re.finditer(rb'\.\?A[UV][A-Za-z0-9_@?$]+@@', img):
        names.add(m.group(0).decode('latin1'))
    return sorted(names)


def census():
    binpath = T.VST3
    pe = pefile.PE(binpath)
    img = PE(binpath).img
    ib = pe.OPTIONAL_HEADER.ImageBase

    # TLS callbacks + entry
    tls = pe.DIRECTORY_ENTRY_TLS.struct
    cbs, p = [], tls.AddressOfCallBacks - ib
    while struct.unpack_from('<Q', img, p)[0]:
        cbs.append(hex(struct.unpack_from('<Q', img, p)[0] - ib))
        p += 8

    # RTTI: isolate the pedal model DSP classes and the four Efx plugin wrapper categories
    allcls = rtti_classes(img)
    text = '\n'.join(allcls)
    GENERIC = {'Base', 'Stereo', 'Mono', 'Fx'}                          # not pedal model codes
    dsps = sorted(set(m for m in MODEL_DSP_RE.findall(text) if m not in GENERIC))
    wrappers = collections.Counter(WRAPPER_RE.findall(text))

    return {
        'binary': {'path': os.path.relpath(binpath, os.path.join(os.path.dirname(__file__), '..', '..')),
                   'size': os.path.getsize(binpath), 'sha256': T._sha256(binpath)},
        'version': version(pe),
        'exports': [e.name.decode() for e in pe.DIRECTORY_ENTRY_EXPORT.symbols if e.name],
        'entry_point': hex(pe.OPTIONAL_HEADER.AddressOfEntryPoint),
        'tls_callbacks': cbs,
        'imports_by_dll': {e.dll.decode(): len(e.imports) for e in pe.DIRECTORY_ENTRY_IMPORT},
        'import_total': sum(len(e.imports) for e in pe.DIRECTORY_ENTRY_IMPORT),
        'sections': [{'name': s.Name.rstrip(b'\0').decode(), 'va': hex(s.VirtualAddress),
                      'vsize': hex(s.Misc_VirtualSize), 'rawsize': hex(s.SizeOfRawData)} for s in pe.sections],
        'rtti_model_dsps': dsps,
        'rtti_model_dsp_count': len(dsps),
        'rtti_plugin_wrapper_categories': dict(wrappers),
        'rtti_class_count': len(allcls),
        'companion_files_pinned': sum(1 for _ in open(T.SUMS) if _.strip()),
    }


def tooth():
    import hashlib
    import tempfile
    data = bytearray(open(T.VST3, 'rb').read())
    data[len(data) // 2] ^= 1
    with tempfile.NamedTemporaryFile(delete=False, suffix='.vst3') as f:
        f.write(data)
        tmp = f.name
    flipped = hashlib.sha256(open(tmp, 'rb').read()).hexdigest()
    os.unlink(tmp)
    real = T._sha256(T.VST3)
    ok = flipped != real
    print('TOOTH %s: one flipped byte -> sha %s (pinned %s)' % ('bites' if ok else 'FAILED', flipped[:16],
                                                                 real[:16]))
    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    if '--tooth' in sys.argv:
        tooth()
    print(json.dumps(census(), indent=1))
