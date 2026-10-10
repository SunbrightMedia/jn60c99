#!/usr/bin/env python3
"""jx_guest.py -- the committed guest images as files, for the PORT's processes (no Unicorn here: the two-process
rule). jx_guest_export.py writes jx3p/gen/jx_guest_44k.bin.gz and jx_guest_96k.bin.gz (the plugin's heap after its
boot at 44100 / 96000, the image's pages, the factory patch records); only the .gz files are committed. path(k)
inflates one into a temporary folder (deleted at the process's exit), once per process, and returns the file's path for jx3p_init. The raw .bin an
export leaves in jx3p/gen/ is never read: a stale one could not then stand in for the committed image.

    import jx_guest; jx_guest.path(44)   -> '/tmp/.../jx_guest_44k.bin'
"""
import atexit
import gzip
import os
import shutil
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
_cache = {}


def path(rate_k, tmp=None):
    """the committed guest image for engine rate rate_k kHz (44 or 96), inflated; tmp: the folder to use"""
    if rate_k in _cache and os.path.exists(_cache[rate_k]):
        return _cache[rate_k]
    gz = os.path.join(REPO, 'jx3p', 'gen', 'jx_guest_%dk.bin.gz' % rate_k)
    if tmp is None:                    # a folder of this process's own, deleted at its exit (44 MB per image: 724
        tmp = tempfile.mkdtemp(prefix='jx_guest_')    # left-behind folders filled the disk, 2026-10-10)
        atexit.register(shutil.rmtree, tmp, True)
    dst = os.path.join(tmp, 'jx_guest_%dk.bin' % rate_k)
    with gzip.open(gz, 'rb') as f:
        data = f.read()
    with open(dst, 'wb') as f:
        f.write(data)
    _cache[rate_k] = dst
    return dst
