#!/usr/bin/env python3
"""completeness_scan.py -- the ledger completeness net (A1).

THE GAP THIS CLOSES: provenance_check.py validates the rows that are LISTED in
PROVENANCE.tsv; nothing checked that every constant in the shipped engine is
covered by SOME row. The delay-feedback capture (delay_recall.c, 0.4235 "captured
at 48 kHz") survived precisely because it was a MISSING row, not a wrong one.

WHAT IT DOES (mechanical, no judgement):
  1. Scans every shipped source file (src/*.c, src/*.h, gui/juno_bridge.c) for
     MAGIC CONSTANTS -- the vectors by which captured/guessed values enter:
       a. hex float-bit literals   0x????????u  (7-8 hex digits, in CODE not comments)
       b. high-precision float literals  (>= 4 significant decimal digits, or exponent)
       c. big integer stores  J I(...) = <int with >= 6 digits>  (float bits as int)
  2. Loads PROVENANCE.tsv and its `sources` column (6th column, ';'-separated
     repo-relative files) mapping each subsystem row to the files it vouches for.
  3. FAILS (exit 1) if any file containing magic constants is not claimed by at
     least one ledger row, or if a row's `sources` names a nonexistent file.
  4. WARNS on every "captur..." keyword in source comments that is not inside a
     file mapped to a CAPTURED row -- the exact wording that flagged 102560.

So: a new hardcoded value can only ship inside a file that some ledger row --
with an honest status and a runnable gate -- explicitly claims. Adding a new
file of constants without ledgering it turns `make verify` RED.

This is a NET, not a proof: it guarantees attribution, not correctness (the
row's gate + status carry that). Comment-stripping is a pragmatic C lexer
(handles /* */, //, strings); constants in comments are ignored except for the
capture-keyword warning.

NEVER reads user_patch5_ableton.json or captured_coeffs.json.
"""
import os, re, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
LEDGER = os.path.join(ROOT, 'PROVENANCE.tsv')

SCAN_GLOBS = ['src', 'gui']          # every shipped C source
SCAN_EXT = ('.c', '.h')
SKIP_FILES = set()                    # none: the whole shipped engine is in scope

# masks/sentinels that are structure, not data
HEX_ALLOW = {'0xffffffff', '0x7fffffff', '0x80000000', '0xcbf29ce484222325', '0x100000001b3'}

RE_HEX = re.compile(r'0x[0-9a-fA-F]{7,8}u?\b')
RE_FLOAT = re.compile(r'\b\d*\.\d+(?:[eE][+-]?\d+)?f?\b|\b\d+[eE][+-]?\d+f?\b')
RE_JI_BIGINT = re.compile(r'JI\([^)]*\)\s*=\s*-?(\d{6,})\b')
RE_CAPTURE = re.compile(r'captur', re.I)


def strip_comments(src):
    """Return (code, comments) -- a pragmatic C comment/string splitter."""
    code, comments = [], []
    i, n = 0, len(src)
    while i < n:
        two = src[i:i+2]
        if two == '/*':
            j = src.find('*/', i + 2)
            j = n if j < 0 else j + 2
            comments.append(src[i:j]); code.append(' ' * (j - i)); i = j
        elif two == '//':
            j = src.find('\n', i)
            j = n if j < 0 else j
            comments.append(src[i:j]); code.append(' ' * (j - i)); i = j
        elif src[i] == '"':
            j = i + 1
            while j < n and src[j] != '"':
                j += 2 if src[j] == '\\' else 1
            j = min(j + 1, n)
            code.append(' ' * (j - i)); i = j
        else:
            code.append(src[i]); i += 1
    return ''.join(code), '\n'.join(comments)


def sig_digits(tok):
    m = re.sub(r'[fF]$', '', tok)
    digits = re.sub(r'[^0-9]', '', re.sub(r'[eE][+-]?\d+$', '', m)).lstrip('0')
    return len(digits)


RE_NEGATION = re.compile(r'(?i)\b(no|not|never|without|non)\b[^.;]*captur')


def scan_file(path):
    src = open(path, encoding='utf-8', errors='replace').read()
    code, comments = strip_comments(src)
    hexes = [h for h in RE_HEX.findall(code) if h.lower().rstrip('u') not in HEX_ALLOW]
    floats = [f for f in RE_FLOAT.findall(code)
              if sig_digits(f) >= 4 or 'e' in f.lower()]
    bigints = RE_JI_BIGINT.findall(code)
    # capture-keyword audit trail: count positive mentions only (negations like
    # "no captures" are the mandate being honored, not a lead to chase)
    ncap = sum(1 for ln in comments.split('\n')
               if RE_CAPTURE.search(ln) and not RE_NEGATION.search(ln))
    return len(hexes) + len(floats) + len(bigints), ncap


def load_ledger():
    rows = []
    with open(LEDGER) as f:
        for line in f:
            line = line.rstrip('\n')
            if not line.strip() or line.lstrip().startswith('#'):
                continue
            cols = line.split('\t')
            if cols[0] == 'subsystem':
                continue
            subsystem, status = cols[0], cols[2] if len(cols) > 2 else '?'
            sources = cols[5].split(';') if len(cols) > 5 and cols[5].strip() not in ('', '-') else []
            rows.append((subsystem, status, [s.strip() for s in sources if s.strip()]))
    return rows


def main():
    # 1. scan
    findings = {}   # relpath -> (n_magic, n_capture_mentions)
    for d in SCAN_GLOBS:
        base = os.path.join(ROOT, d)
        for dirpath, _, files in os.walk(base):
            if 'web' in os.path.relpath(dirpath, ROOT).split(os.sep):
                continue                                  # gui/web JS app: not the engine
            for fn in sorted(files):
                if not fn.endswith(SCAN_EXT) or fn in SKIP_FILES:
                    continue
                rel = os.path.relpath(os.path.join(dirpath, fn), ROOT)
                findings[rel] = scan_file(os.path.join(dirpath, fn))

    # 2. ledger mapping
    rows = load_ledger()
    claimed, errs, warns = {}, [], []
    for subsystem, status, sources in rows:
        for s in sources:
            if not os.path.exists(os.path.join(ROOT, s)):
                errs.append("row '%s': sources names missing file %s" % (subsystem, s))
            claimed.setdefault(s, []).append((subsystem, status))

    # 3. every constant-bearing file must be claimed
    print("=== completeness scan: magic constants -> ledger attribution ===")
    unmapped = []
    for rel in sorted(findings):
        n, ncap = findings[rel]
        if n == 0:
            continue
        owners = claimed.get(rel, [])
        tag = ', '.join("%s[%s]" % (s, st) for s, st in owners) if owners else '*** UNLEDGERED ***'
        print("  %-28s %5d constants  <- %s" % (rel, n, tag))
        if not owners:
            unmapped.append(rel)
        if ncap and not any(st == 'CAPTURED' for _, st in owners):
            warns.append("%s: %d 'captur*' comment mention(s) but no CAPTURED row claims it" % (rel, ncap))

    if unmapped:
        errs.append("UNLEDGERED constant-bearing files: " + ", ".join(unmapped))
    print()
    for w in warns:
        print("  WARN: " + w)
    if errs:
        print("\n*** COMPLETENESS ERRORS ***")
        for e in errs:
            print("  " + e)
        print("\nSCAN: FAIL -- every constant-bearing file must be claimed by a ledger row")
        return 1
    print("SCAN: OK -- every constant-bearing source file is claimed by a ledger row"
          + ("" if not warns else " (with warnings)"))
    return 0


if __name__ == '__main__':
    sys.exit(main())
