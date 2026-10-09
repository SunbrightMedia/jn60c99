"""patch_manager_gate.py -- the patch manager (the patch window's librarian), plugin vs port
(CLAIMS A39, docs/PATCH_MANAGER.md).

The same seeded script of commands runs on
  * the PLUGIN (a worker process, Unicorn only: tools/verify/patch_manager_emu.py): its own key
    handler, mouse handler, button functions, save, timer tick, on its own list control, the
    dialogs answered by the script;
  * the PORT (a worker process, libjuno only: gui/juno_pm.c through ctypes), the same files, the
    same answers;
and after EVERY command the two are compared: every bank's every history state (name, view flag,
edit image, the 64 records), the history cursors, the current bank, the selection, the clipboard,
the number format, the autosave counter, the view's record image and its bank / patch values, the
window's values (panelPatch, patchManager, patchListMain, patchListSub), the dialogs asked (text
offered, menu items and checks, message codes, file dialogs), the file operations made (writes,
deletes, moves), every file of every folder, and the MODEL CALLS the command made, in order: each
record load (its hash), each set (the value's id, the value, the flag), each notify and commit --
the tails, the closes, the loads' bank and patch values. Before each command the window is open:
when a command closed it, the user's PATCH button opens it again (both sides). REACH: each command
kind runs and changes something on the plugin side; the calls reach every tail and the close.

usage: patch_manager_gate.py [--seed N] [--steps N] [--tooth NAME] [--keep LOG]
  worker modes: --plugin OUT.pkl / --port IN.pkl (internal)
"""
import os, sys, struct, random, pickle, hashlib, subprocess, re, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import truth                                                    # noqa: E402
from pm_common import pick, ntfs_key                            # noqa: E402

DATA = 'C:\\ProgramData\\Roland Cloud\\JUNO-60'
PATCH = 'C:\\Program Files\\Common Files\\VST3\\JUNO-60.vst3\\Contents\\x86_64-win\\Patch'
OLD = 'C:\\ProgramData\\Roland\\JUNO-60'
SCRIPT = 'C:\\Program Files\\Common Files\\VST3\\JUNO-60.vst3\\Contents\\x86_64-win\\Script'
DESK = 'C:\\Users\\u\\Desktop'
WATCH = [DATA, PATCH, OLD, DESK]
NAMES = [b'Lead', b'pad  ', b'  Bass One', b'Strings 2', b'Factory', b'factory', b'Initial', b'Initial 1',
         b'A/B', b'.hidden', b'Odd*Name', b'x' * 20, b'Brass|Horn', b'Seq 1', b'\xe9t\xe9', b'']
KEYS = [(0x57, 2), (0x42, 2), (0x52, 2), (0x54, 2), (0x49, 2), (0x45, 2), (0x4E, 2), (0x10B, 0),
        (0x4F, 2), (0x53, 2), (0x20, 0), (0x43, 2), (0x58, 2), (0x56, 2), (0x59, 2), (0x5A, 2),
        (0x5A, 3), (0x4A, 2), (0x100, 0), (0x101, 0), (0x102, 0), (0x103, 0), (0x108, 0), (0x109, 0),
        (0x53, 0), (0x5A, 0), (0x44, 3), (0x44, 2)]
FUNCS = [('ManagePatch', 'load'), ('ManagePatch', 'save'), ('ManagePatch', 'saveLast'), ('ManagePatch', 'rename'),
         ('ManagePatch', 'inc'), ('ManagePatch', 'dec'), ('ManagePatchBank', 'new'), ('ManagePatchBank', 'delete'),
         ('ManagePatchBank', 'inc'), ('ManagePatchBank', 'dec'), ('ManagePatchBank', 'select'),
         ('ManagePatchBank', 'incSub'), ('ManagePatchBank', 'decSub')]
LIST = (338, 57, 1628, 603)                    # the list control's rectangle (Script.xml patch)
BANKNAME = (61, 57, 332, 94)                   # the bank name control's (patchBankName: 61,57 size 271,37)
BANKBTN = (64, 60, 78, 94)                     # its button: buttonPosition 3,3, a 14x34 frame (EXECUTED)
FULL_EVERY = 10                                # every history state's records: every 10th command and the last
REF_FORMAT = 2                                 # the reference pickle's form (2: model calls and window values)
WIN_IDS = (0x0FFFC002, 0x0FFFC004, 0x0FFFC005, 0x0FFFC006)   # panelPatch, patchManager, patchListMain, -Sub


def norm(p):
    return p.replace('/', '\\').lower()


def factory():
    return open(truth.BANK, 'rb').read()


def variant(bank, rnd, name=None):
    """a bank file: the factory's records shuffled and one record's name changed (a file's name)"""
    hdr, n = bank[:23], 20223
    recs = [bank[23 + k * n: 23 + (k + 1) * n] for k in range(64)]
    rnd.shuffle(recs)
    k = rnd.randrange(64)
    nm = (name or b'Var %d' % rnd.randrange(100)).ljust(16)[:16]
    recs[k] = nm + recs[k][16:]
    return hdr + b''.join(recs)


def setup(seed):
    """the folders the plugin reads at its boot"""
    rnd = random.Random(seed)
    bank = factory()
    files = [(DATA + '\\Factory.bin', bank)]
    if seed % 2:
        files.append((DATA + '\\User One.bin', variant(bank, rnd)))
    if seed % 3 == 0:
        files.append((PATCH + '\\Preset A.bin', variant(bank, rnd)))
        files.append((OLD + '\\Old B.bin', variant(bank, rnd)))
    files.append((DATA + '\\Bad.bin', b'KoaBankFile00003PG-JU60' + b'\0' * 100))
    files.append((DESK + '\\Imp One.bin', variant(bank, rnd)))
    files.append((DESK + '\\Imp Two.bin', variant(bank, rnd, b'NamedInFile')))
    files.append((DESK + '\\Broken.bin', b'not a bank'))
    return files


def script(seed, steps):
    """the commands and their answers. Answers: ('text', bytes|None), ('menu', i|None), ('box', 1|2),
    ('file', path|[paths]|None)"""
    rnd = random.Random(seed * 7919 + 1)
    ops = []
    if seed == 100:                         # the history's depth: 70 writes, 70 undos, 70 redos
        ans = [('box', 1)]
        return ([('key', 0x101, 0, ans)] + [('set', k, k % 256, ans) if k % 2 else ('key', 0x53, 2, ans) for k in range(140)]
                + [('key', 0x5A, 2, ans)] * 70 + [('key', 0x5A, 3, ans)] * 70)
    ids = None
    for _ in range(steps):
        r = rnd.random()
        ans = []
        for _k in range(3):
            ans.append(('text', rnd.choice(NAMES + [None])))
        ans.append(('menu', rnd.choice([0, 1, 2, -1, None])))
        ans.append(('box', rnd.choice([1, 1, 2])))
        ans.append(('box', 1))
        ans.append(('file', rnd.choice([DESK + '\\Imp One.bin', [DESK + '\\Imp One.bin', DESK + '\\Imp Two.bin'],
                                        DESK + '\\Broken.bin', DESK + '\\Out %d.bin' % rnd.randrange(3), None])))
        if r < 0.55:
            code, fl = rnd.choice(KEYS)
            ops.append(('key', code, fl, ans))
        elif r < 0.68:
            fn, a = rnd.choice(FUNCS)
            ops.append(('func', fn, a, ans))
        elif r < 0.71:                                # the bank name control: a click or a double click
            x0, y0, x1, y1 = BANKNAME
            a = (rnd.randrange(x0 - 10, x1 + 10), rnd.randrange(y0 - 5, y1 + 5))
            kind = rnd.choice(['click', 'click', 'dbl'])
            ev = {'click': [(0, a), (1, a)], 'dbl': [(0, a), (1, a), (2, a), (1, a)]}[kind]
            ops.append(('bank', kind, ev, ans))
        elif r < 0.82:
            x0, y0, x1, y1 = LIST
            def pt(inside):
                if inside:
                    return (rnd.randrange(x0, x1), rnd.randrange(y0, y1))
                return (rnd.randrange(x0 - 30, x1 + 30), rnd.randrange(y0 - 30, y1 + 30))
            a, m, b = pt(True), pt(rnd.random() < 0.8), pt(rnd.random() < 0.8)
            kind = rnd.choice(['click', 'click', 'dbl', 'drag', 'drag'])
            ev = {'click': [(0, a), (1, a)], 'dbl': [(0, a), (1, a), (2, a), (1, a)],
                  'drag': [(0, a), (3, m), (3, b), (1, b)]}[kind]
            ops.append(('mouse', kind, ev, ans))
        elif r < 0.94:
            ops.append(('set', rnd.randrange(1000), rnd.choice([0, 1, 64, 127, 128, 255, rnd.randrange(256)]), ans))
        elif r < 0.97:
            ops.append(('save', ans))
        else:
            ops.append(('tick', rnd.choice([1, 100, 6001]), ans))
    return ops


# ------------------------------------------------------------------ the plugin (worker)
def run_plugin(seed, steps, out):
    import patch_manager_emu as M
    P = M.PlugPM(files=setup(seed))
    h = P.h
    pids = sorted(P.recobj)
    res = []
    def files():
        out_ = {}
        for k, v in h.files.items():
            if any(k.startswith(norm(d) + '\\') for d in WATCH):
                out_[k] = hashlib.sha1(v).hexdigest()[:16]
        return out_
    res.append(('boot', [], M.digest(P.snapshot()), files(), [], P.window()))
    ops = script(seed, steps)
    for op in ops:
        P.open_window()                       # the window open for each command (the PATCH button)
        h.answers = list(op[-1])
        n0, c0 = len(h.wlog), len(P.calls)
        kind = op[0]
        if kind == 'key':
            P.key(op[1], op[2])
        elif kind == 'func':
            P.func(op[1], op[2])
        elif kind == 'mouse':
            for t, (x, y) in op[2]:
                P.mouse(t, x, y)
        elif kind == 'bank':
            for t, (x, y) in op[2]:
                P.bank_mouse(t, x, y)
        elif kind == 'set':
            pid = pids[op[1] % len(pids)]
            P.model_set(pid, op[2])
        elif kind == 'save':
            P.save_all()
        elif kind == 'tick':
            for _ in range(op[1]):
                P.tick()
        full = (len(res) % FULL_EVERY == 0) or len(res) == len(ops)
        res.append((op[:-1], h.wlog[n0:], M.digest(P.snapshot(full)), files(), P.calls[c0:], P.window()))
    pickle.dump(dict(fmt=REF_FORMAT, seed=seed, steps=steps, pids=pids, res=res, ops=ops), open(out, 'wb'))


# ------------------------------------------------------------------ the port (worker)
def run_port(pkl, tooth=None):
    import ctypes as C
    ref = pickle.load(open(pkl, 'rb'))
    if ref.get('fmt') != REF_FORMAT:
        raise SystemExit('%s: an old reference form; delete it to rebuild' % pkl)
    seed, steps, pids = ref['seed'], ref['steps'], ref['pids']
    L = C.CDLL(os.path.join(REPO, 'scratchpad', 'libjuno_pmtooth_%s.so' % tooth) if tooth else os.path.join(REPO, 'libjuno.so'))
    L.juno_gui_create.restype = C.c_void_p
    L.juno_gui_create.argtypes = [C.c_float, C.c_int]
    L.juno_gui_plugin_init.argtypes = [C.c_void_p]
    L.juno_gui_record.argtypes = [C.c_void_p, C.c_void_p, C.c_int]
    L.juno_gui_model_set.argtypes = [C.c_void_p, C.c_uint32, C.c_int32]
    L.juno_gui_model_get.argtypes = [C.c_void_p, C.c_uint32]
    L.juno_gui_queue_record.argtypes = [C.c_void_p, C.c_void_p, C.c_int]
    L.juno_gui_commit.argtypes = [C.c_void_p]
    L.juno_pm_value.argtypes = [C.c_void_p, C.c_uint32]
    L.juno_pm_set_value.argtypes = [C.c_void_p, C.c_uint32, C.c_int]
    L.juno_pm_create.restype = C.c_void_p
    L.juno_pm_create.argtypes = [C.c_void_p, C.c_void_p, C.c_char_p, C.c_char_p, C.c_char_p, C.c_char_p]
    for fn in ('juno_pm_attach', 'juno_pm_save_all', 'juno_pm_initialize'):
        getattr(L, fn).argtypes = [C.c_void_p]
    L.juno_pm_tick.argtypes = [C.c_void_p]
    L.juno_pm_key.argtypes = [C.c_void_p, C.c_int, C.c_int, C.POINTER(C.c_int)]
    L.juno_pm_func.argtypes = [C.c_void_p, C.c_char_p, C.c_char_p]
    L.juno_pm_select.argtypes = [C.c_void_p, C.c_int]
    L.juno_pm_move.argtypes = [C.c_void_p, C.c_int, C.c_int]
    L.juno_pm_mouse.argtypes = [C.c_void_p, C.c_int, C.c_int, C.c_int, C.POINTER(C.c_int)]
    L.juno_pm_bank_mouse.argtypes = [C.c_void_p, C.c_int, C.c_int, C.c_int, C.POINTER(C.c_int), C.POINTER(C.c_int)]
    for fn in ('juno_pm_nbanks', 'juno_pm_cur_bank', 'juno_pm_sel', 'juno_pm_format'):
        getattr(L, fn).argtypes = [C.c_void_p] if fn != 'juno_pm_format' else []
    L.juno_pm_hist.argtypes = [C.c_void_p, C.c_int, C.POINTER(C.c_int)]
    L.juno_pm_cur.argtypes = [C.c_void_p, C.c_int]
    L.juno_pm_state_info.argtypes = [C.c_void_p, C.c_int, C.c_int, C.POINTER(C.c_char_p), C.POINTER(C.c_int), C.POINTER(C.c_void_p)]
    L.juno_pm_state_rec.restype = C.c_void_p
    L.juno_pm_state_rec.argtypes = [C.c_void_p, C.c_int, C.c_int, C.c_int]
    L.juno_pm_clip.restype = C.c_void_p
    L.juno_pm_clip.argtypes = [C.c_void_p]
    L.juno_pm_view_values.argtypes = [C.c_void_p, C.POINTER(C.c_int), C.POINTER(C.c_int), C.POINTER(C.c_int)]

    FS = {}            # norm path -> bytes ; the listing order per folder as the plugin's (insertion)
    DIRS = {}
    def put(path, data):
        k = norm(path); FS[k] = bytes(data)
        d, nm = k.rsplit('\\', 1)
        lst = DIRS.setdefault(d, [])
        real = path.replace('/', '\\').rsplit('\\', 1)[1]
        if not any(x.lower() == nm for x in lst):
            lst.append(real)
            lst.sort(key=ntfs_key)                # the same NTFS order as the plugin's side
    def rm(path):
        k = norm(path); FS.pop(k, None)
        d, nm = k.rsplit('\\', 1)
        if d in DIRS: DIRS[d] = [x for x in DIRS[d] if x.lower() != nm]
    for p, d in setup(seed):
        put(p, d)
    log, answers = [], []
    def answer(kind):
        for i, (k, v) in enumerate(answers):
            if k == kind:
                del answers[i]; return v
        return None
    libc = C.CDLL(None)
    libc.malloc.restype = C.c_void_p
    libc.malloc.argtypes = [C.c_size_t]
    def cbuf(b):
        p = libc.malloc(len(b) + 1); C.memmove(p, b + b'\0', len(b) + 1); return p
    READ = C.CFUNCTYPE(C.c_void_p, C.c_void_p, C.c_char_p, C.POINTER(C.c_long))
    WRITE = C.CFUNCTYPE(C.c_int, C.c_void_p, C.c_char_p, C.c_void_p, C.c_long)
    ONE = C.CFUNCTYPE(C.c_int, C.c_void_p, C.c_char_p)
    TWO = C.CFUNCTYPE(C.c_int, C.c_void_p, C.c_char_p, C.c_char_p)
    LISTF = C.CFUNCTYPE(C.c_void_p, C.c_void_p, C.c_char_p, C.POINTER(C.c_int))
    TEXT = C.CFUNCTYPE(C.c_int, C.c_void_p, C.c_int, C.c_char_p, C.c_void_p, C.c_int)
    MENU = C.CFUNCTYPE(C.c_int, C.c_void_p, C.POINTER(C.c_char_p), C.POINTER(C.c_int), C.c_int)
    CONF = C.CFUNCTYPE(C.c_int, C.c_void_p, C.c_int)
    OPENF = C.CFUNCTYPE(C.c_int, C.c_void_p, C.c_char_p, C.c_char_p, C.POINTER(C.c_void_p), C.POINTER(C.c_int))
    SAVEF = C.CFUNCTYPE(C.c_int, C.c_void_p, C.c_char_p, C.c_char_p, C.c_void_p, C.c_int)
    def f_read(u, path, ln):
        d = FS.get(norm(path.decode('latin1')))
        if d is None: return None
        ln[0] = len(d); p = libc.malloc(len(d) + 1); C.memmove(p, d, len(d)); return p
    def f_write(u, path, data, n):
        p = path.decode('latin1'); log.append(('write', p)); put(p, C.string_at(data, n)); return 1
    def f_remove(u, path):
        p = path.decode('latin1'); log.append(('delete', p))
        if norm(p) not in FS: return 0
        rm(p); return 1
    def f_move(u, a, b):
        a, b = a.decode('latin1'), b.decode('latin1'); log.append(('move', a, b))
        if norm(a) not in FS or norm(b) in FS: return 0
        d = FS[norm(a)]; rm(a); put(b, d); return 1
    def f_exists(u, path):
        k = norm(path.decode('latin1'))
        return 1 if k in FS or k in DIRS else 0
    def f_list(u, d, n):
        names = DIRS.get(norm(d.decode('latin1')), [])
        n[0] = len(names)
        arr = libc.malloc(8 * max(1, len(names)))
        for i, nm in enumerate(names):
            C.c_void_p.from_address(arr + 8 * i).value = cbuf(nm.encode('latin1'))
        return arr
    def f_text(u, what, offered, out, cap):
        t = answer('text'); log.append(('text', offered, t))
        if t is None: return 0
        C.memmove(out, t[:cap - 1] + b'\0', min(len(t), cap - 1) + 1); return 1
    def f_menu(u, items, checked, n):
        ch = pick(answer('menu'), n)
        log.append(('menu', [(items[i], checked[i]) for i in range(n)], ch))
        return -1 if ch is None else ch
    def f_confirm(u, msg):
        if msg != 38: log.append(('message', msg))
        log.append(('box', 0x31 if msg == 38 else 0x30))
        a = answer('box')
        return 1 if (a is None or a == 1) else 0
    def f_open(u, title, ext, paths, n):
        p = answer('file'); log.append(('dialog', 'fdopen', p))
        if p is None: return 0
        ps = p if isinstance(p, list) else [p]
        ps = ps[:1] + [q.replace('/', '\\').rsplit('\\', 1)[-1] for q in ps[1:]]   # the others: their names
        arr = libc.malloc(8 * len(ps))
        for i, q in enumerate(ps):
            C.c_void_p.from_address(arr + 8 * i).value = cbuf(q.encode('latin1'))
        paths[0] = arr; n[0] = len(ps); return 1
    def f_save(u, title, sug, out, cap):
        p = answer('file'); log.append(('dialog', 'fdsave', p))
        if p is None: return 0
        if isinstance(p, list): p = p[0]                # the fake dialog's GetResult: the first pick
        b = p.encode('latin1'); C.memmove(out, b + b'\0', len(b) + 1); return 1
    # the view: the bridge's own calls, each model call the window's code makes logged in order
    RECF = C.CFUNCTYPE(C.c_int, C.c_void_p, C.c_void_p, C.c_int)
    MODELF = C.CFUNCTYPE(C.c_int, C.c_void_p, C.c_int, C.c_uint32, C.c_int, C.c_int)
    calls = []
    H_ = lambda b: hashlib.sha1(b).hexdigest()[:16]
    def f_record(u, out, cap):
        return L.juno_gui_record(ctx, out, cap)
    def f_load(u, body, n):
        calls.append(('load', H_(C.string_at(body, n))))
        return L.juno_gui_queue_record(ctx, body, n)
    def f_model(u, op, vid, v, flag):
        if op == 0:
            return L.juno_gui_model_get(ctx, vid)
        if op == 1:
            calls.append(('set', vid, v, flag)); L.juno_gui_model_set(ctx, vid, v); return 1
        if op == 2:
            calls.append(('notify',)); return 0
        calls.append(('commit',)); L.juno_gui_commit(ctx); return 0
    cbs = [READ(f_read), WRITE(f_write), ONE(f_remove), TWO(f_move), ONE(f_exists), LISTF(f_list),
           TEXT(f_text), MENU(f_menu), CONF(f_confirm), OPENF(f_open), SAVEF(f_save),
           RECF(f_record), RECF(f_load), MODELF(f_model)]

    class IO(C.Structure):                    # gui/juno_pm.h juno_pm_io, field for field
        _fields_ = [('u', C.c_void_p), ('read', READ), ('write', WRITE), ('remove', ONE), ('move', TWO),
                    ('exists', ONE), ('list', LISTF), ('text', TEXT), ('menu', MENU), ('confirm', CONF),
                    ('open_files', OPENF), ('save_file', SAVEF), ('record', RECF), ('load', RECF),
                    ('model', MODELF)]
    io = IO(None, *cbs)
    ctx = L.juno_gui_create(48000.0, 1)
    L.juno_gui_plugin_init(ctx)
    g = lambda s: s.replace('\\', '/').encode('latin1')
    pm = L.juno_pm_create(ctx, C.byref(io), g(DATA), g(PATCH), g(OLD), g(SCRIPT))
    L.juno_pm_attach(pm)
    L.juno_pm_initialize(pm)                  # IComponent::initialize's load (rva 0x320643)
    rec = C.create_string_buffer(20207)
    def window():
        return tuple(L.juno_pm_value(pm, k) for k in WIN_IDS)
    def open_window():                        # the app's PATCH button: the value, the panel's commit
        if L.juno_pm_value(pm, WIN_IDS[0]) == 0:
            L.juno_pm_set_value(pm, WIN_IDS[0], 1); L.juno_gui_commit(ctx)
    def snap(full=True):
        banks = []
        for b in range(L.juno_pm_nbanks(pm)):
            cur = C.c_int()
            n = L.juno_pm_hist(pm, b, C.byref(cur))
            sts = []
            for i in range(n):
                nm, v, e = C.c_char_p(), C.c_int(), C.c_void_p()
                L.juno_pm_state_info(pm, b, i, C.byref(nm), C.byref(v), C.byref(e))
                recs = [H_(C.string_at(L.juno_pm_state_rec(pm, b, i, k), 20207)) for k in range(64)] if (full or i == cur.value) else []
                sts.append((nm.value, v.value, H_(C.string_at(e.value, 20207)), recs))
            banks.append((cur.value, sts))
        L.juno_gui_record(ctx, rec, 20207)
        vb, vp, tk = C.c_int(), C.c_int(), C.c_int()
        L.juno_pm_view_values(pm, C.byref(vb), C.byref(vp), C.byref(tk))
        return dict(cur=L.juno_pm_cur_bank(pm), cur2=L.juno_pm_cur(pm, 1), sel=L.juno_pm_sel(pm), clip=H_(C.string_at(L.juno_pm_clip(pm), 20207)),
                    fmt=L.juno_pm_format(), tick=tk.value, view=H_(rec.raw), values=(vb.value, vp.value), banks=banks)
    def files():
        out_ = {}
        for k, v in FS.items():
            if any(k.startswith(norm(d) + '\\') for d in WATCH):
                out_[k] = hashlib.sha1(v).hexdigest()[:16]
        return out_
    RECT = (C.c_int * 4)(*LIST)
    BRECT, BBTN = (C.c_int * 4)(*BANKNAME), (C.c_int * 4)(*BANKBTN)
    rows = ref['res']
    close = C.c_int()

    def steps():
        yield ('boot', [], snap(), files(), list(calls), window())
        for (op, *_), opfull in zip(rows[1:], ref['ops']):
            open_window()
            answers[:] = list(opfull[-1])
            del log[:]
            del calls[:]
            kind = op[0]
            if kind == 'key':
                L.juno_pm_key(pm, op[1], op[2], C.byref(close))
            elif kind == 'func':
                L.juno_pm_func(pm, op[1].encode(), op[2].encode())
            elif kind == 'mouse':
                for t, (x, y) in op[2]:
                    L.juno_pm_mouse(pm, t, x, y, RECT)
            elif kind == 'bank':
                for t, (x, y) in op[2]:
                    L.juno_pm_bank_mouse(pm, t, x, y, BRECT, BBTN)
            elif kind == 'set':
                L.juno_gui_model_set(ctx, pids[op[1] % len(pids)], op[2])
            elif kind == 'save':
                L.juno_pm_save_all(pm)
            elif kind == 'tick':
                for _ in range(op[1]):
                    L.juno_pm_tick(pm)
            k = len(rows) - 1
            yield (op, list(log), snap(full=full_step(steps.n, k)), files(), list(calls), window())
            steps.n += 1
    steps.n = 1
    return grade(ref, steps())


def full_step(i, n):
    """the gate's rule: every history state's records at every 10th command and the last"""
    return i % FULL_EVERY == 0 or i == n


def grade(ref, steps):
    """the port's (or an app's) rows against the plugin's reference, command by command: the dialogs and
    file changes, the manager's state, the files, the model calls, the window's values; REACH.
    `steps` yields (op, log, digest, files, calls, window), the boot first. Returns (nfail, fails, n)."""
    seed, rows = ref['seed'], ref['res']
    fails, nfail = [], 0
    reach, creach = {}, {}
    prev = rows[0][2]
    it = iter(steps)
    boot = next(it)
    if tuple(boot[5]) != tuple(rows[0][5]):
        nfail += 1
        fails.append('boot window: plugin %s port %s' % (rows[0][5], boot[5]))
    for k_ in ('cur', 'cur2', 'sel', 'clip', 'fmt', 'tick', 'view', 'values', 'banks'):
        if boot[2][k_] != rows[0][2][k_]:
            nfail += 1
            fails.append('boot %s: plugin %s port %s' % (k_, str(rows[0][2][k_])[:200], str(boot[2][k_])[:200]))
    n = 0
    for (op, plog, pdig, pfiles, pcalls, pwin), got in zip(rows[1:], it):
        n += 1
        _, log, d, f, calls, win = got
        errs = []
        if [tuple(x) if not isinstance(x, tuple) else x for x in log] != [tuple(x) for x in plog]:
            errs.append('calls: plugin %s port %s' % (plog, log))
        for k in ('cur', 'cur2', 'sel', 'clip', 'fmt', 'tick', 'view', 'values'):
            if d[k] != pdig[k]:
                errs.append('%s: plugin %s port %s' % (k, pdig[k], d[k]))
        if d['banks'] != pdig['banks']:
            pb, qb = pdig['banks'], d['banks']
            if len(pb) != len(qb):
                errs.append('banks: plugin %d %s port %d %s' % (len(pb), [s[-1][0] for c, s in pb], len(qb), [s[-1][0] for c, s in qb]))
            else:
                for bi, ((pc, ps), (qc, qs)) in enumerate(zip(pb, qb)):
                    if (pc, len(ps)) != (qc, len(qs)):
                        errs.append('bank %d history: plugin %d/%d port %d/%d' % (bi, pc, len(ps), qc, len(qs)))
                    for si, (a_, b_) in enumerate(zip(ps, qs)):
                        if a_ != b_:
                            what = [nm for nm, (u, v) in zip(('name', 'view', 'edit', 'recs'), zip(a_, b_)) if u != v]
                            extra = ''
                            if 'recs' in what and len(a_[3]) == len(b_[3]) == 64:
                                extra = ' records %s' % [k for k in range(64) if a_[3][k] != b_[3][k]][:8]
                            if 'name' in what:
                                extra += ' names %r / %r' % (a_[0], b_[0])
                            errs.append('bank %d state %d: %s differ%s' % (bi, si, what, extra))
                            break
        if f != pfiles:
            errs.append('files: only plugin %s, only port %s, differ %s' % (
                sorted(set(pfiles) - set(f)), sorted(set(f) - set(pfiles)), sorted(k for k in f if k in pfiles and f[k] != pfiles[k])))
        if [tuple(c) for c in pcalls] != [tuple(c) for c in calls]:
            errs.append('model calls: plugin %s port %s' % (pcalls, calls))
        if tuple(pwin) != tuple(win):
            errs.append('window: plugin %s port %s' % (pwin, win))
        for c in pcalls:                      # REACH of the calls: tails, closes, loads
            k = ('call set %08X=%d' % (c[1], c[2])) if c[0] == 'set' and c[1] in WIN_IDS else ('call ' + c[0])
            creach[k] = creach.get(k, 0) + 1
        if errs:
            nfail += 1
            if len(fails) < 12:
                fails.append('step %d %s: %s' % (n, op, '; '.join(errs)[:900]))
        name = op[0] if op[0] not in ('key', 'func', 'mouse', 'bank') else ('%s %s' % (op[0], hex(op[1]) + ('+%d' % op[2] if op[2] else '') if op[0] == 'key' else op[1] + ' ' + op[2] if op[0] == 'func' else op[1]))
        changed = pdig != prev or bool(plog)
        a_, b_ = reach.get(name, (0, 0))
        reach[name] = (a_ + 1, b_ + (1 if changed else 0))
        prev = pdig
    if n != len(rows) - 1:
        nfail += 1
        fails.append('the run stopped after %d of %d commands' % (n, len(rows) - 1))
    print('REACH ' + ' '.join('%s=%d/%d' % (k, v[1], v[0]) for k, v in sorted(reach.items())))
    print('REACH calls ' + ' '.join('%s=%d' % kv for kv in sorted(creach.items())))
    need = ['call load', 'call notify', 'call commit', 'call set 0FFFC002=0', 'call set 0FFFC004=1', 'call set 0FFFC005=1']
    if seed == 100:                           # the history's depth: a history of 64 states, undo and redo
        need = ['call notify', 'call commit']
        deep = max(len(sts) for r in rows[1:] for c, sts in r[2]['banks'])
        if deep != 64:
            nfail += 1
            fails.append('REACH: the deepest history %d states, not 64' % deep)
    miss = [k for k in need if k not in creach]
    if miss:
        nfail += 1
        fails.append('REACH: no command made %s' % miss)
    return nfail, fails, len(rows) - 1


def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--steps', type=int, default=150)
    ap.add_argument('--plugin')
    ap.add_argument('--port')
    ap.add_argument('--ref', help='reuse this plugin pickle')
    ap.add_argument('--tooth')
    a = ap.parse_args()
    if a.plugin:
        run_plugin(a.seed, a.steps, a.plugin); return 0
    if a.port:
        nfail, fails, n = run_port(a.port, a.tooth)
        for s in fails:
            print('  FAIL ' + s)
        print('PORT %d %d' % (nfail, n))
        return 0
    pkl = a.ref or os.path.join(REPO, 'scratchpad', 'patch_manager_ref%d_%d_%d.pkl' % (REF_FORMAT, a.seed, a.steps))
    if not a.ref and not os.path.exists(pkl):
        os.makedirs(os.path.dirname(pkl), exist_ok=True)
        r = subprocess.run([sys.executable, __file__, '--plugin', pkl + '.partial', '--seed', str(a.seed), '--steps', str(a.steps)])
        if r.returncode:
            raise SystemExit('the plugin side failed')
        os.replace(pkl + '.partial', pkl)
    cmd = [sys.executable, __file__, '--port', pkl]
    if a.tooth:
        lib = os.path.join(REPO, 'scratchpad', 'libjuno_pmtooth_%s.so' % a.tooth)
        srcs = subprocess.run(['make', '-s', '-C', REPO, '--no-print-directory', 'print-libjuno-srcs'],
                              capture_output=True, text=True).stdout.split()
        b = subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC',
                            '-DPM_TOOTH=%s' % a.tooth, '-o', lib] + srcs + ['-lm'], cwd=REPO, capture_output=True, text=True)
        if b.returncode:
            raise SystemExit('tooth build failed: ' + b.stderr[-2000:])
        cmd += ['--tooth', a.tooth]
    r = subprocess.run(cmd, capture_output=True, text=True)
    sys.stdout.write(r.stdout); sys.stderr.write(r.stderr[-3000:])
    m = re.search(r'PORT (\d+) (\d+)', r.stdout)
    ok = bool(m) and m.group(1) == '0'
    if a.tooth:
        bit = bool(m) and m.group(1) != '0'
        print('patch_manager_gate --tooth %s: %s (seed %d)' % (a.tooth, 'BITES' if bit else 'DID NOT BITE', a.seed))
        return 0 if bit else 1
    print('patch_manager_gate: %s (seed %d, %s steps)' % ('GREEN' if ok else 'RED', a.seed, m.group(2) if m else '?'))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
