#!/usr/bin/env python3
"""jx_lanes.py -- make verify-jx3p in lanes, each section's inputs traced; a section whose inputs have not changed
since its GREEN run is carried, not run again (the user, 2026-10-15: "speed this up without compromising
bit-exactness"; playbook 264).

  python3 jx3p/tools/jx_lanes.py run [--lanes N] [--sections "S 0 1 ..."] [--changed] [--tag T]
  python3 jx3p/tools/jx_lanes.py check [--sections ...]     carried or owed, each section, against the working tree
  python3 jx3p/tools/jx_lanes.py --self-test                the trace reader on a planted trace: must see each case

THE RUN. One BASE snapshot of the working tree (tools/snap_tree.sh: HEAD + every modified and untracked file), then
for each section a LANE of its own: a fresh worktree of the base's content (its content tree id must equal the
base's), a scratchpad of its own (a plain snapshot shares the main one, where the program, its references and the
tooth builds go: two runs at once must not share them, playbook 263) with the user's input folders linked in, its
work folder (JX_VERIFY_WORK) and TMPDIR inside that scratchpad; node_modules in it and the emsdk beside it, where
the main tree finds them. A lane runs one section,
JX_VERIFY_ONLY=<section> sh jx3p/tools/jx_verify.sh, under strace -f (seccomp: the file and process calls, and bind), and is
removed after it; up to N lanes run at once.

THE INPUTS of a section: every path whose FIRST access was a read -- a file opened to read or a program started
(its content), a folder listed (its names), a path asked about (present: its type and size; absent) -- by whatever
process (Python, the compilers, Wine, the C harnesses). A path the section made first is its product, not an input.
A GREEN section's stamp (bench/verify_stamps/jx/<section>.json) holds every input's state, the environment the
sections read (JX_*, PATH, locale, ...), the CPU model and flags (the C libraries pick code paths by them) and the
kernel. `check` takes them again in the working tree and the system: all equal, the section's verdict on these
inputs is the GREEN one -- its gates are seeded, the oracle (Unicorn) and the builds deterministic.

WHAT IS NEVER CARRIED: a section that read a file under build/ or scratchpad/ it did not make (in a fresh lane that
cannot happen: it is named as an ANOMALY), that changed a tracked file, that left a relative path unresolved, or
whose absent probe is a path an EARLIER section of the sequential order writes -- in one sequential run that path
would be there, in a lane it is not: the lane run is not the sequential run's equal until the producer becomes the
section's PRELUDE (built inside its traced run; section 4's library is one). Not followed: the clock (no verdict
reads it), file metadata past type and size, an interpreter the kernel starts from a script's #! line (its
libraries are followed).
"""
import concurrent.futures
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import threading
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
STAMPS = os.path.join(REPO, 'bench', 'verify_stamps', 'jx')
LANE_ROOT = os.environ.get('JX_LANES_ROOT', '/home/user')
INPUT_DIRS = ('scratchpad/userbanks', 'scratchpad/jxbanks')        # the user's input folders, linked into a lane
DERIVED = ('build/', 'scratchpad/')                                 # what sections make
SCAFFOLD = ('scratchpad', 'scratchpad/work', 'scratchpad/tmp')      # made by the lane: the same in every lane
SNAP_LINKS = ('scratchpad', 'bench/jobs', 'node_modules')           # a snapshot's links to the main tree
# the system's volatile places (Wine's server sockets live in /tmp/.wine-<uid>); /tmp itself is followed
EXCLUDE = ('/proc/', '/sys/', '/dev/', '/run/', '/tmp/.wine-', '/tmp/.X11-unix', '/var/tmp/')
VOLATILE = tuple(e.rstrip('/') for e in EXCLUDE if e.endswith('/'))   # those folders themselves: a listing of /proc
                                                                    # names its pids (section 5 never carried)
ENV_FIXED = ('WINE', 'PATH', 'LD_LIBRARY_PATH', 'LD_PRELOAD', 'PYTHONPATH', 'PYTHONHASHSEED', 'NODE_PATH', 'LANG', 'LC_ALL',
             'LC_NUMERIC', 'LC_COLLATE', 'TZ', 'HOME', 'WINEPREFIX', 'WINEDEBUG', 'WINEARCH', 'CC', 'CFLAGS', 'EMSDK')
ENV_SKIP = ('JX_VERIFY_ONLY', 'JX_VERIFY_WORK', 'JX_LANES_ROOT', 'JX_LANES_MIN_FREE_GIB', 'JX_LANES_MIN_DISK_GIB')
# minutes a section took in a sequential run (jobs jxverify_144e .. f48_45): the queue starts the longest; a stamp's
# own minutes replace these once a lane has run the section
COST = {'3d': 240, '3e': 180, '5c': 180, '3b': 90, '1': 90, '3': 90, '3h': 90, '3i': 60, '3g': 60, '3f': 60, '2': 60,
        '3c': 30, '5b': 30, '0': 20, '4': 15, '5': 10, 'S': 5, '6': 5}
# what a section needs that another section makes: built first, inside its traced run (its sources are inputs)
PRELUDE = {
    '4': 'mkdir -p build/jx_full_ab && cc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing -shared -fPIC '
         '-o build/jx_full_ab/libjx3p.so jx3p/gui/jx_bridge.c jx3p/src/jx_voice_render.c jx3p/src/jx_voice_helpers.c '
         'jx3p/src/jx_master_render.c jx3p/src/jx_ftz.c -lm -lz',
    '5c': 'python3 jx3p/tools/make_native_jx.py > /dev/null',     # JX-3P.exe, which 5b builds in the sequential run
}
MIN_FREE_GIB = float(os.environ.get('JX_LANES_MIN_FREE_GIB', '4'))
MIN_DISK_GIB = float(os.environ.get('JX_LANES_MIN_DISK_GIB', '2'))


def sections_in_order():
    """the sections as jx_verify.sh lists them (the sequential order)"""
    out = []
    for ln in open(os.path.join(HERE, 'jx_verify.sh')):
        m = re.match(r'^if sec (\S+); then', ln)
        if m and m.group(1) not in out:
            out.append(m.group(1))
    return out


def system_record():
    """what the sections' code paths may read besides files: the environment, the CPU, the kernel"""
    env = {k: v for k, v in os.environ.items()
           if (k in ENV_FIXED or k.startswith(('JX_', 'JUNO_', 'EB_'))) and k not in ENV_SKIP}
    cpu = {}
    try:
        for ln in open('/proc/cpuinfo'):
            k, _, v = ln.partition(':')
            k = k.strip()
            if k in ('vendor_id', 'model name', 'flags', 'cpu family', 'model', 'stepping') and k not in cpu:
                cpu[k] = v.strip()
    except OSError:
        pass
    return dict(env=env, cpu=cpu, kernel=os.uname().release)


# ------------------------------------------------------------------------------------------------ the trace reader
LINE_RE = re.compile(r'^(\d+)\s+(.*)$')
CALL_RE = re.compile(r'^([a-z0-9_]+)\((.*)\)\s+=\s+(.*)$')
STR_RE = re.compile(r'"((?:[^"\\]|\\.)*)"')
DIRFD_RE = re.compile(r'^(AT_FDCWD|\d+)<([^>]*)>')
RET_PATH_RE = re.compile(r'^\d+<(.*)>$')
WRITE_FLAGS = ('O_WRONLY', 'O_RDWR', 'O_CREAT', 'O_TRUNC')
AT_CALLS = {'openat', 'openat2', 'newfstatat', 'fstatat64', 'statx', 'faccessat', 'faccessat2', 'readlinkat',
            'execveat', 'mkdirat', 'unlinkat', 'renameat', 'renameat2', 'linkat', 'symlinkat', 'fchmodat', 'utimensat',
            'fchownat', 'mknodat', 'futimesat'}
QUERY = {'stat', 'lstat', 'stat64', 'lstat64', 'newfstatat', 'fstatat64', 'statx', 'access', 'faccessat',
         'faccessat2', 'readlink', 'readlinkat', 'statfs', 'getxattr', 'lgetxattr', 'listxattr', 'llistxattr'}
WRITES = {'creat', 'mkdir', 'mkdirat', 'unlink', 'unlinkat', 'rmdir', 'rename', 'renameat', 'renameat2', 'link',
          'linkat', 'symlink', 'symlinkat', 'truncate', 'chmod', 'fchmodat', 'chown', 'lchown', 'fchownat', 'utimes',
          'utime', 'utimensat', 'futimesat', 'mknod', 'mknodat', 'setxattr', 'lsetxattr', 'removexattr'}
TWO_PATH = {'rename', 'renameat', 'renameat2', 'link', 'linkat', 'symlink', 'symlinkat'}


def unescape(s):
    return bytes(s, 'latin1').decode('unicode_escape').encode('latin1').decode('utf-8', 'surrogateescape')


def read_trace(path, cwd0=None):
    """(first, writes, unresolved): first maps an absolute path to its FIRST access -- 'file' (opened to read, or a
    program started), 'dir' (listed), 'present' / 'absent' (asked about, or an open or a start that found nothing),
    'write' (made, changed or removed) -- writes is every path a call wrote, unresolved the relative paths whose
    folder the trace never showed. cwd0: the first process's folder."""
    pending, cwd, held = {}, {}, {}
    first, writes, unresolved = {}, set(), []
    first_pid = [None]

    def see(p, kind):
        p = os.path.normpath(p)
        if kind == 'write':
            writes.add(p)
        first.setdefault(p, kind)

    def learn(pid, d):
        cwd[pid] = d
        for rel, kind in held.pop(pid, ()):
            see(os.path.join(d, rel), kind)

    def at(pid, rel, kind, base=None):
        if rel.startswith('/'):
            see(rel, kind)
        elif base is not None:
            see(os.path.join(base, rel), kind)
        elif pid in cwd:
            see(os.path.join(cwd[pid], rel), kind)
        else:
            held.setdefault(pid, []).append((rel, kind))   # its folder comes with its next call that shows one

    for raw in open(path, errors='replace'):
        m = LINE_RE.match(raw.rstrip('\n'))
        if not m:
            continue
        pid, body = m.group(1), m.group(2)
        if first_pid[0] is None:
            first_pid[0] = pid
            if cwd0:
                learn(pid, cwd0)
        if body.endswith('<unfinished ...>'):
            pending[pid] = body[:-len('<unfinished ...>')].rstrip()
            continue
        r = re.match(r'^<\.\.\. ([a-z0-9_]+) resumed>(.*)$', body)
        if r:
            body = pending.pop(pid, r.group(1) + '(') + r.group(2)
        c = CALL_RE.match(body)
        if not c:
            continue
        name, args, ret = c.group(1), c.group(2), c.group(3)
        ok = not ret.startswith('-1')
        missing = 'ENOENT' in ret or 'ENOTDIR' in ret
        if name in ('clone', 'clone3', 'fork', 'vfork'):
            child = ret.split()[0]
            if ok and child.isdigit() and pid in cwd and child not in cwd:
                learn(child, cwd[pid])
            continue
        d = DIRFD_RE.match(args)
        base = None
        if d:
            base = d.group(2)
            if d.group(1) == 'AT_FDCWD' and (pid not in cwd or cwd[pid] != base):
                learn(pid, base)
            if d.group(1) != 'AT_FDCWD' and name not in AT_CALLS and name != 'fchdir':
                base = None
        if name == 'fchdir':
            if ok and d:
                learn(pid, d.group(2))
            continue
        sm = list(STR_RE.finditer(args))
        if not sm:
            continue
        p = unescape(sm[0].group(1))
        if name == 'bind':                     # a Unix socket's file is made by its bind (Chromium's SingletonSocket);
            if ok and 'sa_family=AF_UNIX' in args and 'sun_path=@' not in args:   # an abstract or internet one: none
                at(pid, p, 'write')
            continue
        if name in ('chdir',):
            if ok:
                if p.startswith('/'):
                    learn(pid, os.path.normpath(p))
                elif pid in cwd:
                    learn(pid, os.path.normpath(os.path.join(cwd[pid], p)))
                else:
                    unresolved.append(p)
            continue
        if name in TWO_PATH:
            if not ok:
                continue
            dirs = re.findall(r'(?:AT_FDCWD|\d+)<([^>]*)>', args)
            if name.startswith('symlink'):          # symlink(target, linkpath): only the link is made
                q = unescape(sm[1].group(1)) if len(sm) > 1 else None
                if q is not None:
                    at(pid, q, 'write', dirs[-1] if dirs else None)
                continue
            at(pid, p, 'write', dirs[0] if dirs else None)
            if len(sm) > 1:
                at(pid, unescape(sm[1].group(1)), 'write', dirs[-1] if dirs else None)
            continue
        b = base if name in AT_CALLS else None
        if name in WRITES:
            if ok:
                at(pid, p, 'write', b)
            elif 'EEXIST' in ret or 'ENOTEMPTY' in ret:
                at(pid, p, 'present', b)               # a mkdir that found it there: its being there was read
            elif missing:
                at(pid, p, 'absent', b)
            continue
        if name in ('open', 'openat', 'openat2', 'creat'):
            rest = args[sm[0].end():]
            flags = rest.split(',')[1] if rest.count(',') >= 1 else ''
            rp = RET_PATH_RE.match(ret)
            if any(f in flags for f in WRITE_FLAGS) or name == 'creat':
                if ok:
                    at(pid, p, 'write', b)
                    if rp:
                        see(rp.group(1), 'write')
                elif 'EEXIST' in ret:
                    at(pid, p, 'present', b)
                elif missing:
                    at(pid, p, 'absent', b)
            elif ok:
                real = rp.group(1) if rp else None
                kind = 'dir' if 'O_DIRECTORY' in flags else 'file'
                if real:
                    see(real, kind)
                else:
                    at(pid, p, kind, b)
            elif missing:
                at(pid, p, 'absent', b)
        elif name in ('execve', 'execveat'):
            if ok:
                at(pid, p, 'file', b)
            elif missing:
                at(pid, p, 'absent', b)
        elif name in QUERY:
            if ok:
                at(pid, p, 'present', b)
            elif missing:
                at(pid, p, 'absent', b)
    for pid, rels in held.items():
        unresolved.extend(r for r, _ in rels)
    return first, writes, unresolved


# --------------------------------------------------------------------------------------------- the stamps
def file_hash(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for blk in iter(lambda: f.read(1 << 20), b''):
            h.update(blk)
    return h.hexdigest()


def state(path, kind):
    """what a section saw of a path, now: a file's sha256, a folder's sorted names, a present path's type and size,
    or absent"""
    try:
        st = os.stat(path)
    except OSError:
        return 'absent'
    import stat as S
    isdir = S.S_ISDIR(st.st_mode)
    if kind == 'absent':
        return 'present'
    if kind == 'dir' or (kind == 'file' and isdir):
        try:
            return 'dir:' + hashlib.sha256('\0'.join(sorted(os.listdir(path))).encode('utf-8', 'surrogateescape')).hexdigest()
        except OSError:
            return 'unreadable'
    if kind == 'file':
        if not S.S_ISREG(st.st_mode):
            return 'special'
        try:
            return 'file:' + file_hash(path)
        except OSError:
            return 'unreadable'
    return 'present:%s:%d' % ('dir' if isdir else 'file', st.st_size if S.S_ISREG(st.st_mode) else 0)


VERIFY_SH = 'jx3p/tools/jx_verify.sh'


def verify_slice(text, sec):
    """the part of jx_verify.sh a run of one section executes: the prelude, every section's opening line (another
    section's body is skipped: `sec` returns 1), its own block, the lines after the last block -- comment lines and
    blank lines dropped (they execute nothing). A section's stamp holds this slice's hash, not the file's: a comment
    or another section's block changes no verdict of it (that block's own section is owed then)"""
    lines = text.split('\n')
    starts = [i for i, ln in enumerate(lines) if re.match(r'^if sec \S+; then', ln)]
    last_fi = max(i for i, ln in enumerate(lines) if ln == 'fi')
    out = lines[:starts[0]]
    for j, i in enumerate(starts):
        end = starts[j + 1] if j + 1 < len(starts) else last_fi + 1
        if re.match(r'^if sec %s; then' % re.escape(sec), lines[i]):
            out += lines[i:end]
        else:
            out.append(lines[i])
    out += lines[last_fi + 1:]
    return '\n'.join(ln for ln in out if ln.strip() and not ln.lstrip().startswith('#'))


def slice_state(path, sec):
    try:
        return 'slice:' + hashlib.sha256(verify_slice(open(path, encoding='utf-8').read(), sec).encode()).hexdigest()
    except OSError:
        return 'absent'


class View:
    """a tree as a fresh lane sees it: the files git lists there, tracked or untracked and not ignored (a lane is made
    of them), and the user's input folders on disk; every other path -- ignored, or not there -- is absent. The base's
    view takes the stamp, the working tree's the check: the same rule on both sides."""
    def __init__(self, root):
        self.root = root
        out = subprocess.run(['git', '-C', root, 'ls-files', '-z', '--cached', '--others', '--exclude-standard'],
                             capture_output=True, check=True).stdout
        self.files, self.kids = set(), {}
        for raw in out.split(b'\0'):
            f = raw.decode('utf-8', 'surrogateescape')
            if not f or f in SNAP_LINKS or f.startswith(tuple(x + '/' for x in SNAP_LINKS)) or f == '.snapshot_tree':
                continue
            if not os.path.lexists(os.path.join(root, f)):
                continue                                   # deleted, not yet staged: not in a lane
            self.files.add(f)
            parts = f.split('/')
            for i in range(len(parts)):
                self.kids.setdefault('/'.join(parts[:i]) or '.', set()).add(parts[i])

    def state(self, rel, kind):
        if rel in INPUT_DIRS or rel.startswith(tuple(d + '/' for d in INPUT_DIRS)):
            return state(os.path.join(self.root, rel), kind)
        rel = rel or '.'
        if rel in self.kids:
            if kind == 'absent':
                return 'present'
            if kind in ('dir', 'file'):
                return 'dir:' + hashlib.sha256('\0'.join(sorted(self.kids[rel])).encode('utf-8', 'surrogateescape')).hexdigest()
            return 'present:dir:0'
        if rel in self.files:
            return state(os.path.join(self.root, rel), kind)
        return 'absent'


def key_of(path, roots):
    """the stamp's name for a path: R:<repo path> inside a lane, the base or the main tree, A:<path> elsewhere; None:
    not an input (the system's volatile places, git's own files, Python's caches)"""
    if path.startswith(EXCLUDE) or path in VOLATILE or '/__pycache__/' in path or path.endswith(('.pyc', '/__pycache__')):
        return None
    for r in roots:
        if path == r:
            return 'R:.'
        if path.startswith(r + '/'):
            rel = path[len(r) + 1:]
            if rel == '.git' or rel.startswith(('.git/', 'bench/jobs/', 'bench/verify_stamps/')) or rel == '.snapshot_tree':
                return None
            return 'R:' + rel
    if path.startswith(os.path.join(REPO, '.git')):
        return None
    return 'A:' + path


def derived(key):
    rel = key[2:]
    return key.startswith('R:') and (rel.startswith(DERIVED) or rel in ('build', 'scratchpad')) \
        and not rel.startswith(INPUT_DIRS)


def make_stamp(sec, trace, lane, base, verdict, minutes, log, sysrec, base_view):
    first, writes, unresolved = read_trace(trace, cwd0=lane)
    # every path by its real name (the lane is still there): Wine reaches files through its z: drive's links inside
    # the prefix (build/), a lane through its input folders' links
    real = {}

    def rp(p):
        if p not in real:
            real[p] = os.path.realpath(p)
        return real[p]
    f2 = {}
    for p, kind in first.items():
        f2.setdefault(rp(p), kind)
    first, writes = f2, {rp(w) for w in writes}
    roots = [lane, base, REPO]
    above = set()                                      # the folders the lane sits in: there by construction, and
    d = os.path.dirname(lane)                          # JX_LANES_ROOT moves between runs (a stamp named lanes4 was
    while d not in above:                              # never carried in a lanes6 run)
        above.add(d)
        d = os.path.dirname(d)
    inputs, absent_keys, write_keys, anomalies, main_reads, changed_tree = {}, set(), set(), [], [], []
    for w in writes:
        k = key_of(w, roots)
        if k is not None:
            write_keys.add(k)
    for p, kind in first.items():
        if kind == 'write':
            continue
        k = key_of(p, roots)
        if k is None or k in inputs:
            continue
        if p in writes and kind == 'absent':
            continue                                   # asked about, then made: its own product
        if p in above and kind == 'present':
            continue
        if derived(k):
            rel = k[2:]
            if kind == 'absent':
                absent_keys.add(k)
            elif kind == 'dir' or rel in SCAFFOLD:
                pass                                   # a listing of the lane's own folders: its scaffold + its products
            else:
                anomalies.append('read %s (%s) it did not make' % (k, kind))
            continue
        if k.startswith('R:') and p.startswith(REPO + '/') and not k[2:].startswith(INPUT_DIRS):
            main_reads.append(k)                       # read the main tree, not the lane: named
        if p in writes and k.startswith('R:'):
            bp = os.path.join(base, k[2:])
            same = os.path.isfile(p) and os.path.isfile(bp) and file_hash(p) == file_hash(bp)
            if not same:
                changed_tree.append(k[2:])
                continue
        if kind == 'absent':
            absent_keys.add(k)
        if k == 'R:' + VERIFY_SH and kind == 'file':
            inputs[k] = [kind, slice_state(os.path.join(base, VERIFY_SH), sec)]
        else:
            inputs[k] = [kind, base_view.state(k[2:], kind) if k.startswith('R:') else state(p, kind)]
    # a tracked file the section made or changed without reading it first
    for k in sorted(write_keys):
        if not k.startswith('R:') or derived(k) or k[2:] in changed_tree:
            continue
        lp, bp = os.path.join(lane, k[2:]), os.path.join(base, k[2:])
        if os.path.lexists(bp) or os.path.lexists(lp):
            same = os.path.isfile(lp) and os.path.isfile(bp) and file_hash(lp) == file_hash(bp)
            if not same and not (not os.path.lexists(lp) and not os.path.lexists(bp)):
                if not os.path.isdir(lp):
                    changed_tree.append(k[2:])
    tree = open(os.path.join(lane, '.snapshot_tree')).read().strip()
    rec = dict(section=sec, verdict=verdict, minutes=round(minutes, 1), log=log, tree=tree,
               made=time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()), system=sysrec,
               anomalies=anomalies[:50], n_anomalies=len(anomalies), changed_tree=sorted(set(changed_tree))[:50],
               unresolved=unresolved[:50], n_unresolved=len(unresolved), main_reads=sorted(main_reads)[:50],
               absent=sorted(absent_keys), writes=sorted(write_keys), inputs=inputs)
    os.makedirs(STAMPS, exist_ok=True)
    tmp = os.path.join(STAMPS, sec + '.json.partial')
    with open(tmp, 'w') as f:
        json.dump(rec, f, sort_keys=True)
    os.replace(tmp, os.path.join(STAMPS, sec + '.json'))
    return rec


def load_stamps():
    out = {}
    if os.path.isdir(STAMPS):
        for n in os.listdir(STAMPS):
            if n.endswith('.json'):
                try:
                    out[n[:-5]] = json.load(open(os.path.join(STAMPS, n)))
                except (OSError, ValueError):
                    pass
    return out


def broken_deps(sec, stamps, order):
    """the section's absent probes that an earlier section (the sequential order) writes"""
    if sec not in stamps or sec not in order:
        return []
    absent = set(stamps[sec].get('absent', ()))
    out = []
    for s in order[:order.index(sec)]:
        if s in stamps:
            hit = absent.intersection(stamps[s].get('writes', ()))
            out.extend('%s (made by %s)' % (k, s) for k in sorted(hit))
    return out


def check_one(sec, stamps, order, view, sysrec):
    """('carried', why) when the section's GREEN stamp's every input is unchanged in the view's tree and the system;
    else ('owed', why)"""
    rec = stamps.get(sec)
    if rec is None:
        return 'owed', 'no stamp'
    if rec.get('verdict') != 'GREEN':
        return 'owed', 'its last run: %s' % rec.get('verdict')
    for f, why in (('n_anomalies', 'read a product it did not make'), ('changed_tree', 'changed a tree file'),
                   ('n_unresolved', 'relative paths left unresolved')):
        if rec.get(f):
            return 'owed', '%s (%s)' % (why, rec.get(f) if not isinstance(rec.get(f), list) else rec[f][0])
    bd = broken_deps(sec, stamps, order)
    if bd:
        return 'owed', 'needs a prelude: %s' % bd[0]
    for part in ('env', 'cpu', 'kernel'):
        if rec['system'].get(part) != sysrec.get(part):
            return 'owed', 'the system changed: %s' % part
    diff = []
    for k, (kind, was) in rec['inputs'].items():
        if k.startswith('A:') and key_of(k[2:], []) is None:
            continue                                   # a place an older stamp took and today's rule does not
        if k == 'R:' + VERIFY_SH and kind == 'file':
            now = slice_state(os.path.join(view.root, VERIFY_SH), sec)
        else:
            now = view.state(k[2:], kind) if k.startswith('R:') else state(k[2:], kind)
        if now != was:
            diff.append(k)
            if len(diff) >= 3:
                break
    if diff:
        return 'owed', 'changed: ' + ', '.join(diff)
    return 'carried', 'GREEN %s, tree %s (%d inputs unchanged; %s)' % (rec['made'], rec['tree'][:10], len(rec['inputs']),
                                                                       os.path.relpath(rec['log'], REPO))


# --------------------------------------------------------------------------------------------- the lanes
def git(*a, env=None):
    return subprocess.run(['git', *a], capture_output=True, text=True, check=True, env=env).stdout


def tree_id(d):
    fd, idx = tempfile.mkstemp()
    os.close(fd)
    os.unlink(idx)
    env = dict(os.environ, GIT_INDEX_FILE=idx)
    try:
        git('-C', d, 'read-tree', 'HEAD', env=env)
        git('-C', d, 'add', '-A', env=env)
        return git('-C', d, 'write-tree', env=env).strip()
    finally:
        if os.path.exists(idx):
            os.unlink(idx)


def drop_lane(d):
    subprocess.run(['git', '-C', REPO, 'worktree', 'remove', '--force', d], capture_output=True)
    if os.path.lexists(d):
        shutil.rmtree(d, ignore_errors=True)
    subprocess.run(['git', '-C', REPO, 'worktree', 'prune'], capture_output=True)


def make_base(d):
    drop_lane(d)
    subprocess.run(['sh', os.path.join(REPO, 'tools', 'snap_tree.sh'), d], check=True, stdout=subprocess.DEVNULL,
                   stderr=subprocess.DEVNULL)
    return open(os.path.join(d, '.snapshot_tree')).read().strip()


def make_lane(base, d):
    """a fresh worktree with the base's content (snap_tree.sh's rule, from the base: its own links skipped), its tree
    id checked equal; a private scratchpad (the input folders linked), the work folder and TMPDIR in it"""
    drop_lane(d)
    head = git('-C', base, 'rev-parse', 'HEAD').strip()
    git('-C', REPO, 'worktree', 'add', '--detach', d, head)
    names = set(git('-C', base, 'diff', '--name-only', 'HEAD').split('\n'))
    names |= set(git('-C', base, 'ls-files', '--others', '--exclude-standard').split('\n'))
    for f in sorted(n for n in names if n):
        if f in SNAP_LINKS or f.startswith(tuple(s + '/' for s in SNAP_LINKS)) or f == '.snapshot_tree':
            continue
        src, dst = os.path.join(base, f), os.path.join(d, f)
        if os.path.lexists(dst):
            os.unlink(dst)
        if os.path.lexists(src):
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy2(src, dst, follow_symlinks=False)
    want = open(os.path.join(base, '.snapshot_tree')).read().strip()
    got = tree_id(d)
    if got != want:
        raise RuntimeError('lane %s: content tree %s, the base %s' % (d, got, want))
    with open(os.path.join(d, '.snapshot_tree'), 'w') as f:
        f.write(got + '\n')
    for s in SCAFFOLD:
        os.makedirs(os.path.join(d, s), exist_ok=True)
    for rel in INPUT_DIRS:
        src = os.path.join(REPO, rel)
        if os.path.isdir(src):
            os.symlink(src, os.path.join(d, rel))
    p = REPO
    while p != '/':                       # Node's ESM resolver: node_modules from the script's folder up (playbook 178)
        if os.path.isdir(os.path.join(p, 'node_modules')):
            if not os.path.lexists(os.path.join(d, 'node_modules')):
                os.symlink(os.path.join(p, 'node_modules'), os.path.join(d, 'node_modules'))
            break
        p = os.path.dirname(p)
    sdk = os.path.join(os.path.dirname(REPO), 'emsdk')    # the SDK beside the checkout (wasm_fptoint_check.py's last
    if os.path.isdir(sdk):                                # place): beside the lane too -- a lane in another root REFUSED
        try:                                              # section 5 for want of it (playbook 273)
            os.symlink(sdk, os.path.join(os.path.dirname(d), 'emsdk'))
        except FileExistsError:
            pass
    return d


def free_gib():
    for ln in open('/proc/meminfo'):
        if ln.startswith('MemAvailable:'):
            return int(ln.split()[1]) / 2 ** 20
    return 99.0


def disk_gib(p):
    st = os.statvfs(p)
    return st.f_bavail * st.f_frsize / 2 ** 30


def run_section(sec, base, logdir, lock, sysrec, base_view):
    while free_gib() < MIN_FREE_GIB or disk_gib(LANE_ROOT) < MIN_DISK_GIB:
        time.sleep(30)
    lane = os.path.join(LANE_ROOT, 'jxlane_' + sec)
    log = os.path.join(logdir, 'sec_%s.log' % sec)
    t0 = time.time()
    try:
        make_lane(base, lane)
    except Exception as e:                                  # noqa: BLE001 -- a lane that cannot be made is a RED
        with open(log, 'w') as lf:
            lf.write('lane error: %s\n' % e)
        with lock:
            print('  %-3s LANE ERROR %s' % (sec, e), flush=True)
        return sec, 'RED (lane)'
    trace = os.path.join(lane, 'scratchpad', 'trace.txt')
    cmd = 'sh jx3p/tools/jx_verify.sh'
    if sec in PRELUDE:
        cmd = PRELUDE[sec] + ' && ' + cmd
    env = dict(os.environ, JX_VERIFY_ONLY=sec, JX_VERIFY_WORK=os.path.join(lane, 'scratchpad', 'work'),
               TMPDIR=os.path.join(lane, 'scratchpad', 'tmp'))
    with open(log, 'w') as lf:
        rc = subprocess.run(['strace', '-f', '--seccomp-bpf', '-qq', '-y', '-s', '4096',
                             '-e', 'trace=%file,%process,fchdir,bind', '-o', trace, 'sh', '-c', cmd],
                            cwd=lane, env=env, stdout=lf, stderr=subprocess.STDOUT).returncode
    minutes = (time.time() - t0) / 60
    text = open(log, errors='replace').read()
    verdict = 'GREEN' if rc == 0 and '[jx verify] GREEN' in text else 'RED (exit %d)' % rc
    try:
        rec = make_stamp(sec, trace, lane, base, verdict, minutes, log, sysrec, base_view)
        note = ''
        for f, label in (('n_anomalies', 'ANOMALIES'), ('changed_tree', 'CHANGED TREE'), ('n_unresolved', 'UNRESOLVED'),
                         ('main_reads', 'MAIN-TREE READS')):
            if rec.get(f):
                note += '  %s: %s' % (label, rec[f] if not isinstance(rec[f], list) else ', '.join(rec[f][:3]))
        n_in = len(rec['inputs'])
    except Exception as e:                                  # noqa: BLE001 -- the verdict stands; no stamp, so owed
        note, n_in = '  STAMP ERROR: %s' % e, 0
        try:
            os.unlink(os.path.join(STAMPS, sec + '.json'))
        except OSError:
            pass
    if verdict == 'GREEN':
        drop_lane(lane)
    else:
        try:
            os.unlink(trace)                                 # the lane stays for a look; its trace is large
        except OSError:
            pass
    with lock:
        print('  %-3s %-14s %6.1f min  inputs %d%s' % (sec, verdict, minutes, n_in, note), flush=True)
    return sec, verdict


def main():
    a = sys.argv[1:]

    def arg(k, d):
        return a[a.index(k) + 1] if k in a else d
    if '--self-test' in a:
        return self_test()
    order = sections_in_order()
    secs = arg('--sections', None)
    secs = secs.replace(',', ' ').split() if secs else list(order)
    unknown = [s for s in secs if s not in order]
    if unknown:
        print('jx_lanes: no such section(s): %s (jx_verify.sh has %s)' % (' '.join(unknown), ' '.join(order)))
        return 2
    stamps = load_stamps()
    sysrec = system_record()
    view = View(REPO)
    if not a or a[0] == 'check':
        owed = 0
        for s in secs:
            v, why = check_one(s, stamps, order, view, sysrec)
            owed += v != 'carried'
            print('  %-3s %-8s %s' % (s, v, why))
        print('jx_lanes check: %d carried, %d owed' % (len(secs) - owed, owed))
        return 0 if not owed else 1
    if a[0] != 'run':
        print(__doc__)
        return 2
    if '--changed' in a:
        keep = []
        for s in secs:
            v, why = check_one(s, stamps, order, view, sysrec)
            print('  %-3s %-8s %s' % (s, v, why))
            if v != 'carried':
                keep.append(s)
        secs = keep
    if not secs:
        print('jx_lanes: every section carried -- nothing to run')
        return 0
    n = max(1, min(int(arg('--lanes', '3')), len(secs)))
    tag = arg('--tag', time.strftime('jxlanes_%m%d_%H%M'))
    logdir = os.path.join(REPO, 'bench', 'verify_stamps', 'logs', tag)
    os.makedirs(logdir, exist_ok=True)
    base = os.path.join(LANE_ROOT, 'jxlanes_base')
    tree = make_base(base)
    base_view = View(base)
    print('jx_lanes %s: base %s = content tree %s; %d section(s) in %d lane(s): %s' % (
        tag, base, tree, len(secs), n, ' '.join(secs)), flush=True)
    cost = {s: stamps[s]['minutes'] if s in stamps and stamps[s].get('minutes') else COST.get(s, 60) for s in secs}
    queue = sorted(secs, key=lambda s: -cost[s])
    lock, results = threading.Lock(), {}

    def worker(_):
        while True:
            with lock:
                if not queue:
                    return
                s = queue.pop(0)
            sec, v = run_section(s, base, logdir, lock, sysrec, base_view)
            results[sec] = v
    with concurrent.futures.ThreadPoolExecutor(n) as ex:
        list(ex.map(worker, range(n)))
    drop_lane(base)
    stamps = load_stamps()
    bad = [s for s in secs if results.get(s) != 'GREEN']
    print('jx_lanes %s: content tree %s' % (tag, tree))
    for s in order:
        if s in secs:
            bd = broken_deps(s, stamps, order)
            if bd:
                bad.append(s)
                print('  %-3s NEEDS A PRELUDE: %s' % (s, '; '.join(bd[:5])))
    print('jx_lanes %s: %s -- %d of %d GREEN%s; logs %s' % (
        tag, 'GREEN' if not bad else 'RED', len(secs) - len(set(bad)), len(secs),
        (', not GREEN: ' + ' '.join(sorted(set(bad), key=order.index))) if bad else '', logdir))
    return 0 if not bad else 1


def self_test():
    """the trace reader on a planted trace, each case a line: a started program, an open to read, a relative stat
    under a known folder, an absent probe, a listed folder, a write then a read of the same file (made, not an input),
    a read then a write (an input), a rename, a chdir, a child's relative open through its parent's folder printed
    before the parent's clone line, an fchdir, a symlink (only the link made), a failed program start (absent), a Unix
    socket's bind then a stat of it (made; an abstract or an internet bind: no path); key_of on the volatile folders
    (none: not inputs), a place outside the tree and one inside it"""
    t = tempfile.NamedTemporaryFile('w', suffix='.txt', delete=False)
    t.write('\n'.join([
        '10  execve("/usr/bin/python3", ["python3"], 0x0 /* 1 vars */) = 0',
        '10  openat(AT_FDCWD</r>, "a.c", O_RDONLY|O_CLOEXEC) = 3</r/a.c>',
        '10  newfstatat(AT_FDCWD</r>, "sub/b.h", {st_mode=S_IFREG|0644, st_size=9, ...}, 0) = 0',
        '10  newfstatat(AT_FDCWD</r>, "nope.h", 0x7ff, 0) = -1 ENOENT (No such file or directory)',
        '10  openat(AT_FDCWD</r>, "/r/dir", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 4</r/dir>',
        '10  openat(AT_FDCWD</r>, "out.pkl", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 5</r/out.pkl>',
        '10  openat(AT_FDCWD</r>, "out.pkl", O_RDONLY) = 5</r/out.pkl>',
        '10  openat(AT_FDCWD</r>, "cfg.txt", O_RDONLY) = 6</r/cfg.txt>',
        '10  openat(AT_FDCWD</r>, "cfg.txt", O_WRONLY|O_TRUNC) = 6</r/cfg.txt>',
        '10  rename("/r/x.partial", "/r/x.pkl") = 0',
        '10  chdir("/r/sub") = 0',
        '11  open("c.txt", O_RDONLY) = 3</r/sub/c.txt>',
        '11  access("rel.txt", R_OK) = -1 ENOENT (No such file or directory)',
        '10  vfork( <unfinished ...>',
        '10  <... vfork resumed>) = 11',
        '10  fchdir(7</r/dir>) = 0',
        '10  access("in_dir.txt", F_OK) = 0',
        '10  symlink("/elsewhere/target", "lnk") = 0',
        '10  execve("/usr/local/bin/cat", ["cat"], 0x0 /* 1 vars */) = -1 ENOENT (No such file or directory)',
        '10  mkdir("/home/user", 0777) = -1 EEXIST (File exists)',
        '10  bind(16<socket:[7]>, {sa_family=AF_UNIX, sun_path="/r/s/Sock"}, 110) = 0',
        '10  newfstatat(15</r/s>, "Sock", {st_mode=S_IFSOCK|0755, st_size=0, ...}, AT_SYMLINK_NOFOLLOW) = 0',
        '10  bind(17<socket:[8]>, {sa_family=AF_UNIX, sun_path=@"abstract"}, 12) = 0',
        '10  bind(18<socket:[9]>, {sa_family=AF_INET, sin_port=htons(1), sin_addr=inet_addr("0.0.0.0")}, 16) = 0',
    ]) + '\n')
    t.close()
    first, wr, unres = read_trace(t.name, cwd0='/r')
    os.unlink(t.name)
    want = {'/usr/bin/python3': 'file', '/r/a.c': 'file', '/r/sub/b.h': 'present', '/r/nope.h': 'absent',
            '/r/dir': 'dir', '/r/out.pkl': 'write', '/r/cfg.txt': 'file', '/r/sub/c.txt': 'file',
            '/r/sub/rel.txt': 'absent', '/r/dir/in_dir.txt': 'present', '/r/dir/lnk': 'write',
            '/usr/local/bin/cat': 'absent', '/home/user': 'present', '/r/s/Sock': 'write'}
    bad = {k: first.get(k) for k, v in want.items() if first.get(k) != v}
    need_w = {'/r/out.pkl', '/r/cfg.txt', '/r/x.partial', '/r/x.pkl', '/r/dir/lnk', '/r/s/Sock'}
    ok = not bad and need_w <= wr and '/elsewhere/target' not in first and not unres and '/home/user' not in wr
    stray = [k for k in first if k.endswith(('abstract', '0.0.0.0'))]
    ok = ok and not stray
    keys = [key_of(x, ['/r']) for x in ('/proc', '/proc/12/stat', '/dev', '/home/user/emsdk', '/r/a.c')]
    if keys != [None, None, None, 'A:/home/user/emsdk', 'R:a.c']:
        print('jx_lanes --self-test: key_of %s' % keys)
        ok = False
    if stray:
        print('jx_lanes --self-test: a bind with no path seen as one: %s' % stray)
    print('jx_lanes --self-test: %s%s%s%s' % ('ok' if ok else 'FAILED', (' wrong: %s' % bad) if bad else '',
          (' writes missing: %s' % sorted(need_w - wr)) if not need_w <= wr else '', (' unresolved: %s' % unres) if unres else ''))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
