"""refio.py -- a reference pickle is written whole or not at all (playbook 142).

A gate that dies while it writes its reference (a container restart, a kill) must not
leave a truncated file that `make verify`'s freshness test then takes as a good one:
dump() writes PATH.partial and renames it over PATH when the whole object is out.
"""
import os
import pickle


def dump(obj, path, protocol=None):
    """pickle obj to path through path + '.partial' (os.replace is atomic on one filesystem)"""
    tmp = path + '.partial'
    with open(tmp, 'wb') as f:
        pickle.dump(obj, f, protocol)
    os.replace(tmp, path)
