#!/usr/bin/env python3
"""shadow_sync_gate.py -- the SHADOW WRITER-SET invariant.

    Every writer of JUNO_PROG_EFX must also put the same EFFECT TYPE into
    JUNO_PREV_EFX, and every writer of JUNO_PROG_DLY must also put the same
    DELAY TYPE into JUNO_PREV_DLY -- or be explicitly, checkably exempt.

WHY A SEPARATE FILE. tools/verify/shadow_bounds_gate.py answers a different
question: "can the port-owned shadow cells false-fail a port-vs-plugin
comparison?" -- a bounds/gate-integrity claim about the COMPARED SET. This file
answers "is the shadow TRUE?" -- a claim about the WRITER SET. Neither subsumes
the other and mixing them would make one verdict cover two unrelated risks.

WHY IT EXISTS. The shadow's contract was first written as "these are written at
EXACTLY ONE SITE, the end of juno_bank_apply ... Any FUTURE live EFFECT TYPE /
DELAY TYPE setter added outside juno_bank_apply MUST update them too." THE
SETTER WAS NOT FUTURE. gui/juno_bridge.c juno_gui_set_chorus_mode already wrote
JUNO_PROG_EFX and already left JUNO_PREV_EFX alone -- a shipped WASM export
(gui/web/build.sh), wrapped by gui/juno_gui.py and gui/juno_web.py, driven in a
loop by tools/verify/cov_replay.py. src/chorus_recall.c reads JUNO_PREV_EFX to
decide whether the chorus WET cell is WRITTEN or CARRIED, so the desync made the
same EFFECT TYPE in force produce two different engines. It fired at every mode
but 2 (2 is the power-on seed, so it re-synced by coincidence), mode 0 included
-- the value the shipping web app passes at startup. Repaired 2026-08-16: that
setter and juno_gui_recall_factory now write the pair themselves, and
src/juno_engine.h names the complete writer set instead of a rule about the
future. A rule about the future cannot be checked; THIS FILE checks the present,
every run, so the same class cannot come back unseen.

An invariant that only lives in a comment is not an invariant. This gate makes
the desync impossible to ship unnoticed, TWO ways, because each alone is weak:

  CHECK B (behavioural, the strong one) -- ctypes, the real exported API. Drive
      every entry point that can move either routing cell and assert, after
      each call, that the routing cell equals CLAMP(shadow). The setter sweep
      covers EVERY mode 0..clamp_max -- mode 0 (the Pan arm the shipping web app
      passes at startup) as much as mode 5 -- and then OUT-OF-RANGE values,
      where the plugin's proven clamp means the routing cell and the shadow must
      DIFFER. A sweep that stopped at clamp_max would miss half the rule. Then
      four PATH-INDEPENDENCE cases: two histories that put the SAME EFFECT TYPE
      in force before the SAME recall must make the SAME WRITE/CARRY DECISION on
      the gated cell(s), and store the same value where they write. Judging the
      raw value instead FALSE-FAILS a legitimate carry -- a carried cell holds
      history by design, so two histories may honestly differ there; the
      decision may not, because it reads the type in force and nothing else.
      Nothing is compared to a fitted number -- only port-to-port, so no oracle
      is needed and the ONE RULE is untouched.
  CHECK S (static) -- parse src/ gui/ engine_b/ esp32s3/, find every statement
      that ASSIGNS a routing cell (by macro name or by raw offset literal), and
      clear it only if the matching shadow is maintained AT OR AFTER that
      statement, by the same function, by a callee it calls afterwards, or by
      every one of its callers. Anything else is RED. A grep alone would flag
      the legitimate sites; the ordering + delegation rules are what make it
      usable, and the teeth below prove it still bites.

NO MAGIC OFFSETS. All four cell offsets and the clamp bound are PARSED from the
headers/sources, so a moved #define moves the gate with it -- and so this file
contains no integer literal inside the shadow window, which would otherwise
turn shadow_bounds_gate.py check 3 red.

TWO-PROCESS RULE (CLAUDE.md): this gate is ctypes-only. It never imports
e2e_emu / unicorn, so it is safe to run beside an oracle process.

SEEN TO FAIL. Teeth (env JUNO_SYNC_TOOTH, or --tooth NAME) inject VIRTUAL
source files into check S -- nothing on disk is touched:
    plant-macro    a writer using the macro name, no shadow write   -> must CATCH
    plant-literal  the same by raw offset literal                   -> must CATCH
    plant-order    shadow written BEFORE the routing cell           -> must CATCH
    plant-clean    shadow written AFTER  the routing cell           -> must PASS
The tooth run prints CAUGHT/MISSED for the planted site specifically, so the
demonstration does not depend on the overall verdict.

USAGE
    python3 tools/verify/shadow_sync_gate.py             # both checks
    python3 tools/verify/shadow_sync_gate.py --static    # no libjuno.so needed
    python3 tools/verify/shadow_sync_gate.py --behav
    python3 tools/verify/shadow_sync_gate.py --tooth plant-macro
    --cells N[,N...]   cells judged by the path-independence cases
                       (default 91232, the chorus WET cell chorus_recall.c gates)
    $JUNO_RENDER_SR    host rate, default 44100

EXIT 0 = GREEN, 1 = RED, 2 = usage//setup.
"""
import os
import re
import sys
import struct
import hashlib

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
ROOT = os.path.dirname(os.path.dirname(HERE))

SR = float(os.environ.get('JUNO_RENDER_SR', '44100'))
TOOTH = os.environ.get('JUNO_SYNC_TOOTH', '')
SCAN_TREES = ('src', 'gui', 'engine_b', 'esp32s3')
SCAN_EXT = ('.c', '.h')

RED = []          # collected failure lines, printed again at the end


def fail(msg):
    RED.append(msg)
    print('    RED: %s' % msg)


def hdr(tag, s):
    print('\n--- %s: %s' % (tag, s))


# ===================================================================== offsets
def parse_define(relpath, name):
    """The offset this gate protects comes from the source, never from a number
    typed here."""
    txt = open(os.path.join(ROOT, relpath)).read()
    m = re.search(r'^\s*#define\s+%s\s+(0x[0-9a-fA-F]+|\d+)u?\b' % name, txt, re.M)
    return int(m.group(1), 0) if m else None


def parse_clamp(relpath, var):
    """`if (etype > 5) etype = 5;` -- the routing cell is CLAMPED, the shadow is
    the RAW leaf, so the relation between them is CLAMP, not equality."""
    txt = open(os.path.join(ROOT, relpath)).read()
    m = re.search(r'if\s*\(\s*%s\s*>\s*(\d+)\s*\)\s*%s\s*=\s*(\d+)\s*;'
                  % (var, var), txt)
    return (int(m.group(1)), int(m.group(2))) if m else None


class Cells(object):
    pass


def load_cells():
    hdr('check 0', 'the offsets and the clamp still say what this gate assumes')
    c = Cells()
    c.prog_efx = parse_define('src/delay_recall.h', 'JUNO_PROG_EFX')
    c.prog_dly = parse_define('src/delay_recall.h', 'JUNO_PROG_DLY')
    c.prev_efx = parse_define('src/juno_engine.h', 'JUNO_PREV_EFX')
    c.prev_dly = parse_define('src/juno_engine.h', 'JUNO_PREV_DLY')
    alt_efx = parse_define('src/effect_modes.h', 'JUNO_PROG_EFX')
    for nm, v in (('JUNO_PROG_EFX', c.prog_efx), ('JUNO_PROG_DLY', c.prog_dly),
                  ('JUNO_PREV_EFX', c.prev_efx), ('JUNO_PREV_DLY', c.prev_dly)):
        print('    %-14s %s' % (nm, v))
        if v is None:
            fail('%s not found -- this gate cannot locate the cell it protects'
                 % nm)
    if alt_efx is not None and alt_efx != c.prog_efx:
        fail('src/effect_modes.h JUNO_PROG_EFX=%s != src/delay_recall.h %s'
             % (alt_efx, c.prog_efx))
    ce = parse_clamp('src/effect_modes.c', 'etype')
    cd = parse_clamp('src/delay_recall.c', 'dtype')
    print('    clamp EFFECT TYPE  src/effect_modes.c  %s' % (ce,))
    print('    clamp DELAY  TYPE  src/delay_recall.c  %s' % (cd,))
    if ce is None or cd is None:
        fail('the routing-cell clamp could not be read; the PROG<->PREV '
             'relation is unknown and this gate must not guess it')
        c.clamp_max = None
    elif ce != cd or ce[0] != ce[1]:
        fail('the two clamps disagree (%s vs %s); relation unknown' % (ce, cd))
        c.clamp_max = None
    else:
        c.clamp_max = ce[0]
    # the two PAIRS this gate enforces
    c.pairs = [('EFX', c.prog_efx, c.prev_efx, 'JUNO_PROG_EFX', 'JUNO_PREV_EFX'),
               ('DLY', c.prog_dly, c.prev_dly, 'JUNO_PROG_DLY', 'JUNO_PREV_DLY')]
    return c


def clamp(cells, v):
    return cells.clamp_max if (cells.clamp_max is not None
                               and v > cells.clamp_max) else v


# ============================================================ C source parsing
def strip_code(text):
    """Comments and string/char literals -> spaces, newlines preserved, so line
    numbers survive and a cell named only in a COMMENT is never a write."""
    out = []
    i, n, st = 0, len(text), 0        # 0 code 1 // 2 /* 3 " 4 '
    while i < n:
        ch = text[i]
        nx = text[i + 1] if i + 1 < n else ''
        if st == 0:
            if ch == '/' and nx == '/':
                st = 1; out.append('  '); i += 2; continue
            if ch == '/' and nx == '*':
                st = 2; out.append('  '); i += 2; continue
            if ch == '"':
                st = 3; out.append(' '); i += 1; continue
            if ch == "'":
                st = 4; out.append(' '); i += 1; continue
            out.append(ch); i += 1; continue
        if st == 1:
            if ch == '\n':
                st = 0; out.append('\n')
            else:
                out.append(' ')
            i += 1; continue
        if st == 2:
            if ch == '*' and nx == '/':
                st = 0; out.append('  '); i += 2; continue
            out.append('\n' if ch == '\n' else ' '); i += 1; continue
        q = '"' if st == 3 else "'"
        if ch == '\\':
            out.append('  '); i += 2; continue
        if ch == q:
            st = 0; out.append(' '); i += 1; continue
        out.append('\n' if ch == '\n' else ' '); i += 1
    return ''.join(out)


def functions(code):
    """[(name, first_body_line, last_body_line)] from brace depth at file scope."""
    funcs, depth, cur, header = [], 0, None, ''
    line = 1
    seg = []
    for ch in code:
        if ch == '{':
            if depth == 0:
                head = header + ' ' + ''.join(seg)
                m = re.findall(r'([A-Za-z_][A-Za-z0-9_]*)\s*\(', head)
                cur = [m[-1] if m else '<anon>', line]
            depth += 1
            seg = []
        elif ch == '}':
            depth -= 1
            if depth <= 0:
                depth = 0
                if cur:
                    funcs.append((cur[0], cur[1], line))
                    cur = None
                header = ''
            seg = []
        elif ch == ';' and depth == 0:
            header = ''
            seg = []
        else:
            seg.append(ch)
            if ch == '\n' and depth == 0:
                header += ' ' + ''.join(seg)
                seg = []
        if ch == '\n':
            line += 1
    return funcs


def statements(code):
    """[(text, first_line, last_line)] -- statement-based, so a write split over
    several lines is still one unit and cannot slip past the assignment test."""
    out, buf, start, line = [], [], None, 1
    for ch in code:
        if ch in ';{}':
            t = ''.join(buf).strip()
            if t and start is not None:
                out.append((t, start, line))
            buf, start = [], None
        else:
            if not ch.isspace() and start is None:
                start = line
            buf.append(ch)
        if ch == '\n':
            line += 1
    t = ''.join(buf).strip()
    if t and start is not None:
        out.append((t, start, line))
    return out


ASSIGN = re.compile(r'(?<![=!<>])=(?!=)')


def lhs_of(stmt):
    """Text left of the first real assignment, or None if the statement assigns
    nothing. `p39 = (int32_t *)JCELL(st, JUNO_PROG_DLY)` is a READ: the cell is
    on the RIGHT."""
    m = ASSIGN.search(stmt)
    if not m:
        return None
    return stmt[:m.start()]


def writes_cell(stmt, tokens):
    l = lhs_of(stmt)
    if l is None:
        return False
    return any(re.search(r'(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])' % re.escape(t), l)
               for t in tokens)


def scan_sources(extra):
    """[(relpath, stripped_code)] over the four trees, plus any virtual tooth
    files. Nothing on disk is read for a tooth and nothing is written."""
    files = []
    for tree in SCAN_TREES:
        base = os.path.join(ROOT, tree)
        for dirpath, dirnames, filenames in os.walk(base):
            dirnames[:] = [d for d in dirnames if d not in ('.git', 'build')]
            for fn in sorted(filenames):
                if fn.endswith(SCAN_EXT):
                    p = os.path.join(dirpath, fn)
                    rel = os.path.relpath(p, ROOT)
                    files.append((rel, strip_code(open(p, errors='replace').read())))
    files.sort()
    for rel, text in extra:
        files.append((rel, strip_code(text)))
    return files


# ==================================================================== TEETH (S)
def tooth_files(cells):
    """Virtual sources injected into check S. `%(EFX)s` is the macro name and
    `%(LIT)s` the raw offset, both taken from the parsed defines so this file
    holds no offset literal of its own."""
    E, PE = 'JUNO_PROG_EFX', 'JUNO_PREV_EFX'
    lit = str(cells.prog_efx)
    T = {
        'plant-macro': ('<tooth>/plant_macro.c', '''
void tooth_live_effect_type(unsigned char *st, int t)
{
    *(int32_t *)JCELL(st, %s) = (int32_t)t;
}
''' % E),
        'plant-literal': ('<tooth>/plant_literal.c', '''
void tooth_live_effect_type_lit(unsigned char *st, int t)
{
    *(int32_t *)JCELL(st, %s) = (int32_t)t;
}
''' % lit),
        'plant-order': ('<tooth>/plant_order.c', '''
void tooth_order(unsigned char *st, int t)
{
    JI(st, %s) = t;
    *(int32_t *)JCELL(st, %s) = (int32_t)t;
}
''' % (PE, E)),
        'plant-clean': ('<tooth>/plant_clean.c', '''
void tooth_clean(unsigned char *st, int t)
{
    *(int32_t *)JCELL(st, %s) = (int32_t)t;
    JI(st, %s) = t;
}
''' % (E, PE)),
    }
    if not TOOTH:
        return [], None
    if TOOTH not in T:
        print('unknown tooth %r; known: %s' % (TOOTH, ', '.join(sorted(T))))
        raise SystemExit(2)
    rel, src = T[TOOTH]
    return [(rel, src)], rel


# ================================================================== CHECK S
def check_static(cells):
    extra, tooth_rel = tooth_files(cells)
    hdr('check S', 'every routing-cell writer maintains its shadow')
    if TOOTH:
        print('    TOOTH ACTIVE: %s  (virtual file %s, nothing on disk touched)'
              % (TOOTH, tooth_rel))
    files = scan_sources(extra)
    print('    scanned %d file(s) under %s' % (len(files), ', '.join(SCAN_TREES)))

    # index: per file, its functions and statements
    idx = {}
    for rel, code in files:
        idx[rel] = (functions(code), statements(code))

    def enclosing(rel, line):
        for name, lo, hi in idx[rel][0]:
            if lo <= line <= hi:
                return name, lo, hi
        return None

    def writers(tokens):
        """{(rel, func): [lines]} for every statement assigning one of tokens."""
        out = {}
        for rel, _ in files:
            for stmt, lo, hi in idx[rel][1]:
                if writes_cell(stmt, tokens):
                    f = enclosing(rel, lo)
                    key = (rel, f[0] if f else '<file scope>')
                    out.setdefault(key, []).append(lo)
        return out

    def calls_in(rel, func_lo, func_hi, name):
        """Lines inside [func_lo, func_hi] that call `name` (not a declaration --
        declarations live at file scope, outside every body)."""
        pat = re.compile(r'(?<![A-Za-z0-9_])%s\s*\(' % re.escape(name))
        return [lo for stmt, lo, hi in idx[rel][1]
                if func_lo <= lo <= func_hi and pat.search(stmt)]

    # A brace block at file scope that is NOT a function -- `extern "C" { }`,
    # a struct/enum body, an array initializer -- comes back named <anon>.
    # It may not act as a CALLER (src/effect_modes.h's extern "C" block wraps the
    # juno_apply_effect_modes PROTOTYPE, and a prototype is not a call), but it
    # must still be able to hold a WRITE, or a write hidden in one would be
    # silently unattributed. So: anonymous blocks are excluded from the caller
    # set, and a routing/shadow write inside one is RED on the spot.
    def named_funcs(rel):
        return [f for f in idx[rel][0] if f[0] != '<anon>']

    ok = True
    tooth_verdict = None
    for tag, prog_off, prev_off, prog_name, prev_name in cells.pairs:
        prog_tok = {prog_name, str(prog_off)}
        prev_tok = {prev_name, str(prev_off)}
        pw = writers(prog_tok)
        sw = writers(prev_tok)
        print('\n    [%s] %s writers: %d   %s writers: %d'
              % (tag, prog_name, sum(len(v) for v in pw.values()),
                 prev_name, sum(len(v) for v in sw.values())))

        # functions that maintain the shadow, and the earliest line at which they do
        def self_maint(rel, func):
            return sorted(sw.get((rel, func), []))

        maint_funcs = set(k[1] for k in sw)

        for (rel, func) in sorted(list(pw) + list(sw)):
            if func in ('<anon>', '<file scope>'):
                ok = False
                fail('%s: a %s/%s write sits outside any named function (%s) -- '
                     'this gate cannot attribute it, so it cannot clear it'
                     % (rel, prog_name, prev_name, func))

        for (rel, func) in sorted(pw):
            if func in ('<anon>', '<file scope>'):
                continue
            for L in sorted(pw[(rel, func)]):
                f = enclosing(rel, L)
                lo, hi = (f[1], f[2]) if f else (L, L)
                why = None

                sm = [x for x in self_maint(rel, func) if x >= L]
                if sm:
                    why = 'SELF   %s writes %s at :%d' % (func, prev_name, sm[0])

                if why is None:                       # delegate DOWN
                    for g in sorted(maint_funcs):
                        if g == func:
                            continue
                        cl = [x for x in calls_in(rel, lo, hi, g) if x >= L]
                        if cl:
                            why = ('CALLEE %s calls %s at :%d, which writes %s'
                                   % (func, g, cl[0], prev_name))
                            break

                if why is None:                       # delegate UP
                    callers = []
                    for rel2, _ in files:
                        for name2, lo2, hi2 in named_funcs(rel2):
                            if name2 == func and rel2 == rel:
                                continue
                            for cline in calls_in(rel2, lo2, hi2, func):
                                callers.append((rel2, name2, lo2, hi2, cline))
                    if callers:
                        good = []
                        bad = []
                        for rel2, name2, lo2, hi2, cline in callers:
                            m = [x for x in self_maint(rel2, name2) if x >= cline]
                            (good if m else bad).append(
                                '%s %s:%d' % (rel2, name2, cline))
                        if not bad:
                            why = ('CALLERS all %d caller(s) write %s after the '
                                   'call: %s' % (len(good), prev_name,
                                                 '; '.join(good)))
                        else:
                            why = None
                            unclean = bad

                if why:
                    print('      OK   %s:%d %s  -- %s' % (rel, L, func, why))
                    if tooth_rel and rel == tooth_rel:
                        tooth_verdict = ('MISSED', rel, L)
                else:
                    ok = False
                    detail = ('no %s write at or after :%d in %s, no callee that '
                              'writes it, and no clean caller set'
                              % (prev_name, L, func))
                    fail('%s:%d %s writes %s and %s'
                         % (rel, L, func, prog_name, detail))
                    if tooth_rel and rel == tooth_rel:
                        tooth_verdict = ('CAUGHT', rel, L)

    if tooth_rel:
        want = 'PASS' if TOOTH == 'plant-clean' else 'CATCH'
        got = tooth_verdict[0] if tooth_verdict else 'NOT-SEEN'
        good = ((want == 'CATCH' and got == 'CAUGHT') or
                (want == 'PASS' and got == 'MISSED'))
        print('\n    TOOTH %s: planted site was %s (wanted %s)  -> %s'
              % (TOOTH, got, want, 'tooth OK' if good else 'TOOTH FAILED'))
    return ok


# ================================================================== CHECK B
def dec_rec(rec, off):
    """nibble pair -> logical byte, exactly src/effect_modes.c efx_rec_byte."""
    return ((rec[off] & 0xF) << 4) | (rec[off + 1] & 0xF)


def check_behav(cells, judged):
    import ctypes
    import truth
    import freshlib

    hdr('check B', 'the real exported API keeps routing cell == CLAMP(shadow)')
    if cells.clamp_max is None:
        fail('clamp unknown (check 0) -- refusing to guess the relation')
        return False

    lib = freshlib.load()
    print('    libjuno.so sha256 %s' % sha256(freshlib.LIB)[:16])
    bp = truth.BANK
    bank = open(bp, 'rb').read()
    print('    bank %s' % bp)
    print('    sha256 %s' % sha256(bp))
    print('    SR %g   judged cells %s' % (SR, judged))

    V, I, F, C = ctypes.c_void_p, ctypes.c_int, ctypes.c_float, ctypes.c_char_p
    lib.juno_gui_create.restype = V
    lib.juno_gui_create.argtypes = [F, I]
    lib.juno_gui_destroy.argtypes = [V]
    lib.juno_gui_apply_bank.argtypes = [V, C, I, I]
    lib.juno_gui_apply_bank.restype = I
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [V, I]
    lib.juno_gui_set_chorus_mode.argtypes = [V, I]
    lib.juno_gui_recall_factory.argtypes = [V]
    lib.juno_gui_set_param.restype = F
    lib.juno_gui_set_param.argtypes = [V, I, I]
    lib.juno_gui_param_count.restype = I
    lib.juno_gui_host_count.restype = I
    lib.juno_gui_host_set.argtypes = [V, I, I]
    lib.juno_gui_note_on.argtypes = [V, I, I]
    lib.juno_gui_note_off.argtypes = [V, I]
    lib.juno_gui_render.restype = I
    lib.juno_gui_render.argtypes = [V, ctypes.POINTER(F), I]
    lib.juno_gui_warmup.argtypes = [V, I]
    lib.juno_gui_arp_config.argtypes = [V, I, I, I, F, F]
    lib.juno_gui_set_tempo.argtypes = [V, F]
    lib.juno_gui_set_kbd_velocity.argtypes = [V, I]
    lib.juno_bank_num_patches.restype = I
    lib.juno_bank_num_patches.argtypes = [C, ctypes.c_ulong]
    lib.juno_bank_record.restype = ctypes.POINTER(ctypes.c_ubyte)
    lib.juno_bank_record.argtypes = [C, I]

    npat = lib.juno_bank_num_patches(bank, len(bank))

    def rec(i):
        p = lib.juno_bank_record(bank, i)
        return bytes(bytearray(p[k] for k in range(3100)))

    # EFFECT TYPE (record 634) / DELAY TYPE (record 650) per patch -- the RAW
    # leaves, decoded exactly as src/effect_modes.c and src/delay_recall.c do.
    et = {i: dec_rec(rec(i), 634) for i in range(npat)}
    dt = {i: dec_rec(rec(i), 650) for i in range(npat)}
    print('    bank %d patches; EFFECT TYPE histogram %s'
          % (npat, dict(sorted(_hist(et.values()).items()))))
    print('    %26s DELAY  TYPE histogram %s'
          % ('', dict(sorted(_hist(dt.values()).items()))))

    def peek(ctx, off):
        return lib.juno_gui_peek(ctx, off)

    def snap(ctx):
        return {'PROG_EFX': _s32(peek(ctx, cells.prog_efx)),
                'PROG_DLY': _s32(peek(ctx, cells.prog_dly)),
                'PREV_EFX': _s32(peek(ctx, cells.prev_efx)),
                'PREV_DLY': _s32(peek(ctx, cells.prev_dly))}

    bad_points = []

    def consistent(ctx, label, quiet=False):
        s = snap(ctx)
        rows = []
        good = True
        for tag, pn, sn in (('EFX', 'PROG_EFX', 'PREV_EFX'),
                            ('DLY', 'PROG_DLY', 'PREV_DLY')):
            want = clamp(cells, s[sn])
            hit = (s[pn] == want)
            good = good and hit
            rows.append('%s prog=%-4d shadow=%-4d %s'
                        % (tag, s[pn], s[sn], 'ok' if hit else '<-- DESYNCED'))
        if not good:
            bad_points.append(label)
            fail('%-46s %s' % (label, '   '.join(rows)))
        elif not quiet:
            print('      ok   %-42s %s' % (label, '   '.join(rows)))
        return good

    # ---------------------------------------------------- entry-point sweep
    print('\n    ENTRY-POINT SWEEP -- after every call that can move either cell')
    ctx = lib.juno_gui_create(ctypes.c_float(SR), 2)
    if not ctx:
        fail('juno_gui_create returned NULL')
        return False
    consistent(ctx, 'juno_gui_create(%g, 2)' % SR)

    # one patch per distinct (EFFECT TYPE, DELAY TYPE) pair -- covers every type
    # the shipping bank can put in force, including the clamped ones if any.
    seen, reps = set(), []
    for i in range(npat):
        k = (et[i], dt[i])
        if k not in seen:
            seen.add(k)
            reps.append(i)
    for i in reps:
        lib.juno_gui_apply_bank(ctx, bank, len(bank), i)
        consistent(ctx, 'juno_gui_apply_bank(p%d)  ET=%d DT=%d'
                   % (i, et[i], dt[i]), quiet=True)
    print('      ok   juno_gui_apply_bank x %d (one per distinct ET/DT pair)'
          % len(reps))

    # Drive the legacy setter from a shadow that is KNOWN to differ, so a mode
    # cannot pass by coincidence (the shadow happening to hold that value from
    # the previous recall). For each mode, recall a patch whose EFFECT TYPE is
    # something else first.
    for m in range(0, cells.clamp_max + 1):
        seed = next((i for i in range(npat) if et[i] != m), None)
        if seed is None:
            continue
        lib.juno_gui_apply_bank(ctx, bank, len(bank), seed)
        lib.juno_gui_set_chorus_mode(ctx, m)
        consistent(ctx, 'apply p%d (ET=%d) then set_chorus_mode(%d)'
                   % (seed, et[seed], m))

    # OUT OF RANGE -- the half of the rule a 0..clamp_max sweep cannot see. The
    # plugin CLAMPS EFFECT TYPE > 5 to 5 for every value 0..255 (PROVEN under
    # Unicorn by the setter spot sweep, src/effect_modes.h JUNO_PROG_EFX), so a
    # live setter must ROUTE the clamped value and SHADOW the raw one -- exactly
    # what prog == CLAMP(shadow) asserts. Both halves were wrong here before the
    # repair: the setter wrote the RAW value into the routing cell, a state the
    # plugin can never hold, and never touched the shadow at all.
    for m in (cells.clamp_max + 1, cells.clamp_max + 4, 255):
        seed = next((i for i in range(npat) if et[i] != m), None)
        if seed is None:
            continue
        lib.juno_gui_apply_bank(ctx, bank, len(bank), seed)
        lib.juno_gui_set_chorus_mode(ctx, m)
        consistent(ctx, 'apply p%d (ET=%d) then set_chorus_mode(%d) OUT OF RANGE'
                   % (seed, et[seed], m))

    lib.juno_gui_recall_factory(ctx)
    consistent(ctx, 'juno_gui_recall_factory()')

    lib.juno_gui_apply_bank(ctx, bank, len(bank), 0)
    n = lib.juno_gui_param_count()
    for i in range(n):
        lib.juno_gui_set_param(ctx, i, (i * 37) & 0xFF)
    if consistent(ctx, 'juno_gui_set_param x %d' % n, quiet=True):
        print('      ok   juno_gui_set_param x %d' % n)

    hn = lib.juno_gui_host_count()
    for i in range(hn):
        lib.juno_gui_host_set(ctx, i, 1)
    if consistent(ctx, 'juno_gui_host_set x %d' % hn, quiet=True):
        print('      ok   juno_gui_host_set x %d' % hn)

    lib.juno_gui_set_tempo(ctx, ctypes.c_float(140.0))
    consistent(ctx, 'juno_gui_set_tempo(140)')
    lib.juno_gui_arp_config(ctx, 1, 0, 2, ctypes.c_float(100.0),
                            ctypes.c_float(0.5))
    consistent(ctx, 'juno_gui_arp_config(on)')
    lib.juno_gui_set_kbd_velocity(ctx, 1)
    consistent(ctx, 'juno_gui_set_kbd_velocity(1)')
    lib.juno_gui_note_on(ctx, 60, 100)
    consistent(ctx, 'juno_gui_note_on(60,100)')
    buf = (ctypes.c_float * 256)()
    lib.juno_gui_render(ctx, buf, 128)
    consistent(ctx, 'juno_gui_render(128)')
    lib.juno_gui_note_off(ctx, 60)
    consistent(ctx, 'juno_gui_note_off(60)')
    lib.juno_gui_warmup(ctx, 64)
    consistent(ctx, 'juno_gui_warmup(64)')
    lib.juno_gui_arp_config(ctx, 0, 0, 1, ctypes.c_float(120.0),
                            ctypes.c_float(0.5))
    consistent(ctx, 'juno_gui_arp_config(off)')
    lib.juno_gui_destroy(ctx)
    print('    EXEMPT by design: juno_gui_set / juno_gui_poke are RAW cell '
          'writers for the harness (they can write ANY cell, so they are not '
          'routing setters); nothing else is exempt.')

    # ------------------------------------------------ path-independence cases
    print('\n    PATH INDEPENDENCE -- same EFFECT TYPE in force, same recall,')
    print('    therefore the same WRITE/CARRY DECISION on the gated cell, and the')
    print('    same value when it is written. Port-to-port only: no oracle, no')
    print('    fitted number. (src/chorus_recall.c gates cell 91232 on the type')
    print('    IN FORCE BEFORE the recall.)')
    print('    THE VERDICT IS THE DECISION, NOT THE VALUE, and that is not a')
    print('    softening -- it is the only sound form. When neither arm of the')
    print('    gate fires the cell is CARRIED, so its value comes from the')
    print('    history by design and two histories may legitimately differ')
    print('    (post-repair: p39->p40 carries p39\'s Wet, set(5)->p40 carries the')
    print('    power-on 0 -- both correct). What may NEVER differ is whether the')
    print('    recall wrote at all: that decision reads the type in force and')
    print('    nothing else, so it cannot depend on HOW the type got there.')
    print('    Judging raw values instead FALSE-FAILS a correct carry, and')
    print('    judging nothing would miss the defect this gate exists for --')
    print('    which was exactly a stale shadow flipping the decision.')

    FINAL = 40
    if FINAL >= npat:
        fail('bank has only %d patches; case set assumes p%d' % (npat, FINAL))
        return False

    def run(hist):
        """Replay a history in a FRESH engine. `pre` is the snapshot taken just
        BEFORE the final recall -- that is where the desync is visible; after
        the final recall both sides have been overwritten by p40's own leaf and
        look identical while the RESULT already differs."""
        c = lib.juno_gui_create(ctypes.c_float(SR), 2)

        def step(kind, arg):
            if kind == 'apply':
                lib.juno_gui_apply_bank(c, bank, len(bank), arg)
            else:
                lib.juno_gui_set_chorus_mode(c, arg)
        for kind, arg in hist[:-1]:
            step(kind, arg)
        pre = snap(c)
        prevals = {off: peek(c, off) for off in judged}
        step(*hist[-1])
        s = snap(c)
        vals = {off: peek(c, off) for off in judged}
        lib.juno_gui_destroy(c)
        return pre, prevals, s, vals

    # in_force = the RAW EFFECT TYPE the last writer put into force, derived:
    # a recall puts the patch's record-634 leaf in force, the legacy setter puts
    # its own argument in force.
    def in_force(hist):
        v = 2                                   # juno_engine_prepare power-on
        for kind, arg in hist:
            v = et[arg] if kind == 'apply' else arg
        return v

    CASES = [
        ('A  p39 -> p40',            [('apply', 39), ('apply', FINAL)]),
        ('B  set(5) -> p40',         [('set', 5), ('apply', FINAL)]),
        ('C  p39, set(2) -> p40',    [('apply', 39), ('set', 2),
                                      ('apply', FINAL)]),
        ('D  p0 -> p40',             [('apply', 0), ('apply', FINAL)]),
    ]
    def act(prevals, vals, o):
        """WRITTEN or CARRIED, decided by the cell itself. A write that happens to
        store the value already there reads as CARRIED -- that can only make this
        check MISS a defect, never invent one, which is the right direction for a
        heuristic inside a gate."""
        return 'WRITTEN' if vals[o] != prevals[o] else 'CARRIED'

    results = []
    for label, hist in CASES:
        presnap, prevals, s, vals = run(hist)
        # the type in force BEFORE the final recall
        pre = in_force(hist[:-1])
        results.append((label, hist, pre, prevals, vals))
        print('      %-26s in force = %-3d | BEFORE the final recall: PROG_EFX=%d '
              'PREV_EFX=%d %s | %s'
              % (label, pre, presnap['PROG_EFX'], presnap['PREV_EFX'],
                 'ok      ' if presnap['PREV_EFX'] == pre else 'SHADOW LIES',
                 '  '.join('%d: 0x%08x -> 0x%08x %s'
                           % (o, prevals[o], vals[o], act(prevals, vals, o))
                           for o in judged)))

    groups = {}
    for label, hist, pre, prevals, vals in results:
        groups.setdefault((pre, hist[-1][1]), []).append((label, prevals, vals))
    ok = True
    for (pre, final), members in sorted(groups.items()):
        if len(members) < 2:
            print('      (group type=%d -> p%d has one member; no claim)'
                  % (pre, final))
            continue
        base_label, base_pre, base = members[0]
        for label, mpre, vals in members[1:]:
            for o in judged:
                a, b = act(base_pre, base, o), act(mpre, vals, o)
                if a != b:
                    ok = False
                    fail('type %d in force -> recall p%d, cell %d: the '
                         'WRITE/CARRY DECISION differs.\n'
                         '           %-26s 0x%08x -> 0x%08x %s\n'
                         '           %-26s 0x%08x -> 0x%08x %s\n'
                         '           That decision reads the type IN FORCE and '
                         'nothing else, so it cannot depend on HOW the type was '
                         'put in force. A stale shadow is what makes it.'
                         % (pre, final, o, base_label, base_pre[o], base[o], a,
                            label, mpre[o], vals[o], b))
                elif a == 'WRITTEN' and vals[o] != base[o]:
                    ok = False
                    fail('type %d in force -> recall p%d, cell %d: WRITTEN by '
                         'both histories but with DIFFERENT values '
                         '(%s 0x%08x vs %s 0x%08x). The written value depends on '
                         'the patch record alone, so the two must agree.'
                         % (pre, final, o, base_label, base[o], label, vals[o]))
                else:
                    print('      ok   type %d -> p%d cell %d: %s and %s both %s%s'
                          % (pre, final, o, base_label, label, a,
                             ', same value 0x%08x' % base[o]
                             if a == 'WRITTEN' else
                             ' (values are the histories\' own priors, by design)'))
    print('\n    NOTE on DELAY TYPE: there is no behavioural case for '
          'JUNO_PREV_DLY because')
    print('    nothing reads it yet, so a desync there is INVISIBLE to any '
          'measurement.')
    print('    That is exactly why check S must carry it. juno_gui_recall_factory '
          'writes')
    print('    JUNO_PROG_DLY, and it used to be correct only because the '
          'juno_engine_prepare')
    print('    three lines above happened to seed the same 0; the DELAY TYPE >= '
          '6 work makes')
    print('    that site live. It now writes the pair itself, and check S holds '
          'it on ORDER,')
    print('    not on luck -- the only kind of proof available for a cell with '
          'no reader.')
    return ok and not bad_points


def _hist(vals):
    h = {}
    for v in vals:
        h[v] = h.get(v, 0) + 1
    return h


def _s32(u):
    return struct.unpack('<i', struct.pack('<I', u))[0]


def sha256(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


# ======================================================================== main
def main():
    global TOOTH
    argv = sys.argv[1:]
    if '--help' in argv or '-h' in argv:
        print(__doc__)
        return 2
    if '--tooth' in argv:
        TOOTH = argv[argv.index('--tooth') + 1]
    judged = [91232]
    if '--cells' in argv:
        judged = [int(x, 0) for x in
                  argv[argv.index('--cells') + 1].replace(',', ' ').split()]
    do_static = '--behav' not in argv
    do_behav = '--static' not in argv

    print('=== SHADOW SYNC GATE ===')
    print('INVARIANT: every writer of the EFFECT/DELAY TYPE routing cell must')
    print('           also put the same raw type into its port-owned shadow.')
    cells = load_cells()
    res = []
    if do_static:
        res.append(check_static(cells))
    if do_behav:
        res.append(check_behav(cells, judged))
    ok = all(res) and not RED
    print('\n' + '=' * 70)
    if RED:
        print('FAILURES (%d):' % len(RED))
        for r in RED:
            print('  - %s' % r.splitlines()[0])
    print('VERDICT: %s' % ('GREEN' if ok else 'RED'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
