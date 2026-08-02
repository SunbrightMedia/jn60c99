#!/usr/bin/env python3
"""ledger.py -- THE ENGINE B EQUIVALENCE LEDGER, and the only thing allowed to
write it.

docs/trackb/EQUIVALENCE.tsv answers one question per module: *what was actually
proven, at what cost, by which run.* This project's recurring failure mode is a
gate that is green and wrong, so the ledger is built on one rule:

    A ROW IS NEVER TYPED. A ROW IS EMITTED BY THE PROOF THAT EARNED IT.

Concretely:

  * There is no `--accuracy` argument, no `--cycles` argument, no free-text
    evidence field a human can fill in. Every measured column is parsed out of a
    gate's own stdout or out of `cost.py --json`, in this process, from a run
    that happened seconds earlier.
  * A row records the SHA-256 of every artefact it depends on -- the module
    source, the proof source, the gate script, the cost rig, this file, and the
    scenario set. `ledger.py check` re-hashes them. Edit the module and the row
    goes STALE; the ledger says so and exits non-zero.
  * A row records `row_digest`, the SHA-256 of its own data columns. Hand-edit a
    number and `check` reports FORGED.

WHAT THE DIGEST DOES AND DOES NOT DO. It is a tamper-EVIDENT seal, not a
tamper-PROOF one: the algorithm is in this file, so anyone who wants to forge a
row can recompute the digest. What it removes is the realistic failure -- a
number quietly edited, or a stale claim (`26/26`) copied forward into a ledger
after the scenario set grew to 30. It makes lying deliberate rather than
accidental, and accidental is how every wrong number in this project got here.

WHAT A GREEN ROW IS STILL NOT. `null_b.py` compares engine B against `src/`, the
FROZEN transcription. `src/` is not the authority; the plugin binary is. A row
here is a fast proxy result. docs/trackb/THREE_WAY_GATE.md is what retires a
claim. The `authority` column says so on every row.

USAGE
    ledger.py emit <module> [<module> ...]     run the proofs, append the rows
    ledger.py emit --all                       every module in PROOFS
    ledger.py check                            re-hash; STALE/FORGED -> exit 1
    ledger.py check --rerun                    also re-run every gate
    ledger.py show                             human-readable summary
"""
import argparse
import datetime
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
TSV = os.path.join(REPO, "docs", "trackb", "EQUIVALENCE.tsv")

S3_BUDGET = 3500.0          # docs/engineb/SCOPE.md -- ESP32-S3, 240 MHz, 48 kHz
S3_HARD = 5000.0
XTENSA_BIN = ("/root/.espressif/tools/xtensa-esp-elf/esp-16.1.0_20260609/"
              "xtensa-esp-elf/bin")

COLUMNS = [
    "row_id", "module", "file", "replaces", "status",
    "accuracy_kind", "accuracy_evidence", "accuracy_margin", "scenarios",
    "scen_fingerprint",
    "inv_per_sample", "inv_label", "inv_source",
    "cyc_host", "cyc_m7", "cyc_s3", "s3_pct_budget", "cost_label", "cost_caveat",
    "gate", "gate_exit", "gate_stdout_sha",
    "file_sha", "proof_sha", "gate_sha", "tool_sha", "scen_sha",
    "date", "commit", "toolchain", "authority", "notes", "row_digest",
]
DIGEST_COLS = [c for c in COLUMNS if c != "row_digest"]

HEADER_DOC = """\
# EQUIVALENCE.tsv -- THE ENGINE B EQUIVALENCE LEDGER.
#
# EVERY ROW IN THIS FILE WAS EMITTED BY tools/engineb/ledger.py FROM A RUN OF THE
# PROOF IT DESCRIBES. Do not hand-write a row and do not hand-edit a number:
# `python3 tools/engineb/ledger.py check` re-hashes every artefact a row depends
# on and recomputes each row's own digest, and reports STALE (an artefact moved
# under the row) or FORGED (the row's numbers no longer match its digest).
#
# Rows are APPEND-ONLY. A module that changes gets a NEW row; the old row stays
# and goes STALE, which is the audit trail.
#
# WHAT A GREEN ROW MEANS: engine B's module nulls against src/, the frozen
# transcription, in the scenarios named by scen_fingerprint. src/ is NOT the
# ground truth -- the plugin binary is (docs/trackb/THREE_WAY_GATE.md). The
# `authority` column carries that caveat per row and it is not decoration.
#
# COST COLUMNS are `lo..hi (nom)` cycles per SAMPLE, from tools/engineb/cost.py.
# Every S3 figure is MODELED against NO SILICON. Read cost_caveat before quoting
# one. The budget is %d cyc/sample (hard limit %d).
#
# Legacy M0-HARNESS rows (2026-07-31, the Track B harness, a different and
# hand-written schema) are preserved verbatim in EQUIVALENCE_M0_LEGACY.tsv.
""" % (int(S3_BUDGET), int(S3_HARD))


# ==========================================================================
# helpers
# ==========================================================================
def sha(path):
    if not os.path.exists(path):
        return "MISSING"
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()[:16]


def sha_text(s):
    return hashlib.sha256(s.encode()).hexdigest()[:16]


def sha_many(paths):
    return sha_text("|".join(sha(p) for p in paths))


def env_path():
    e = dict(os.environ)
    if os.path.isdir(XTENSA_BIN):
        e["PATH"] = XTENSA_BIN + os.pathsep + e.get("PATH", "")
    return e


def run(cmd, cwd=REPO, timeout=7200):
    p = subprocess.run(cmd, cwd=cwd, env=env_path(), timeout=timeout,
                       capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr


def git_commit():
    rc, out = run(["git", "rev-parse", "--short", "HEAD"])
    return out.strip() if rc == 0 else "UNKNOWN"


def toolchain_id():
    ids = []
    for cc, tag in (("cc", "host"), ("xtensa-esp32s3-elf-gcc", "s3"),
                    ("arm-none-eabi-gcc", "m7")):
        rc, out = run([cc, "-dumpversion"])
        ids.append("%s=%s" % (tag, out.strip() if rc == 0 else "ABSENT"))
    return " ".join(ids)


def scenario_fingerprint():
    """The scenario set is part of the claim. `26/26 EXACTLY 0` was true when
    there were 26 scenarios and is a lie now that there are 30, so the count and
    the tags are hashed into every row that depends on them."""
    sys.path.insert(0, os.path.join(REPO, "tools", "trackb"))
    sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
    import null_ab
    tags = [t for _, _, t in null_ab.SCEN]
    return len(tags), sha_text("\n".join(sorted(tags))), tags


# ==========================================================================
# COST: run the rig, parse its JSON, and correct the one place where its
# STATIC libm charge is known to over-report.
# ==========================================================================
LIBM_CALL = (80.0, 150.0, 300.0)        # must track cost.py LIBM_CALL


def cost(sources, func, per_sample, includes=(), strip_libm=False):
    """-> dict target -> (lo, nom, hi) cycles per SAMPLE, plus the raw JSON.

    `strip_libm` subtracts the rig's STATIC libm charge. It is only ever passed
    when a MEASURED dynamic count says the libm path does not execute, and the
    reason is recorded in the row's cost_caveat. It is not a knob for making a
    number look better.
    """
    jf = tempfile.NamedTemporaryFile(suffix=".json", delete=False)
    jf.close()
    cmd = [sys.executable, os.path.join(HERE, "cost.py"), "measure"]
    cmd += list(sources)
    for i in includes:
        cmd += ["-I", i]
    cmd += ["--func", func, "--per-sample", str(per_sample),
            "--tier", "s3_iram", "--json", jf.name]
    rc, out = run(cmd)
    if rc != 0 or not os.path.getsize(jf.name):
        raise SystemExit("cost.py failed for %s:\n%s" % (func, out[-3000:]))
    data = json.load(open(jf.name))
    os.unlink(jf.name)

    res = {}
    for tgt in ("host", "m7", "s3"):
        d = data.get(tgt)
        if not d or "per_sample" not in d:
            res[tgt] = None
            continue
        rho = d["rho"]
        per_inv = list(d["cyc_per_invocation"])
        if strip_libm:
            n = d["static"]["libm"]
            per_inv = [max(0.0, per_inv[i] - n * LIBM_CALL[i] * rho[i])
                       for i in range(3)]
        res[tgt] = tuple(v * per_sample for v in per_inv)
    res["_raw"] = data
    return res


def band(b):
    if b is None:
        return "TOOLCHAIN ABSENT"
    return "%s..%s (%s)" % tuple(format(int(round(v)), ",d") for v in
                                 (b[0], b[2], b[1]))


def pct(b):
    if b is None:
        return "n/a"
    return "%.1f%%..%.1f%% (%.1f%%)" % (100 * b[0] / S3_BUDGET,
                                        100 * b[2] / S3_BUDGET,
                                        100 * b[1] / S3_BUDGET)


# ==========================================================================
# THE PROOFS. Each entry says how to RUN the proof and how to READ its result.
# There is no path by which a number reaches a row without passing through one
# of these parsers.
# ==========================================================================
def _cc_run(src, extra=()):
    """Compile a standalone engine B unit test and run it. Returns (rc, stdout)."""
    exe = tempfile.NamedTemporaryFile(delete=False)
    exe.close()
    cmd = ["cc", "-std=c99", "-O2", "-ffp-contract=off",
           "-I" + os.path.join(REPO, "engine_b"), "-o", exe.name,
           os.path.join(REPO, "engine_b", src)] + list(extra)
    rc, out = run(cmd)
    if rc:
        raise SystemExit("compile failed: %s\n%s" % (src, out[-2000:]))
    rc, out = run([exe.name], cwd=REPO)
    os.unlink(exe.name)
    return rc, out


def proof_noise():
    rc, out = _cc_run("test_noise_lfsr.c")
    m = re.search(r"bit-identical to the oracle over (\d+) samples", out)
    if rc != 0 or not m:
        return dict(ok=False, out=out)
    n = int(m.group(1))
    return dict(ok=True, out=out, kind="BIT_IDENTICAL",
                evidence="bit-identical over %s consecutive oracle samples "
                         "(docs/engineb/data/noise_core_200k.npy, float32 bit "
                         "compare)" % format(n, ",d"),
                margin="EXACTLY 0 (-inf dB)",
                scenarios="n/a (exhaustive over the captured sequence)")


def proof_triangle():
    rc, out = _cc_run("test_triangle.c", extra=["-lm"])
    m = re.search(r"2\^32 patterns, (\d+) NaN skipped, (\d+) mismatches", out)
    if rc != 0 or not m:
        return dict(ok=False, out=out)
    nan, bad = int(m.group(1)), int(m.group(2))
    tested = (1 << 32) - nan
    if bad:
        return dict(ok=False, out=out)
    return dict(ok=True, out=out, kind="BIT_IDENTICAL",
                evidence="bit-identical to src/juno_dsp.c juno_triangle over %s "
                         "of 2^32 float32 bit patterns (%s NaN skipped), 0 "
                         "mismatches" % (format(tested, ",d"), format(nan, ",d")),
                margin="EXACTLY 0 (-inf dB)",
                scenarios="n/a (exhaustive over the whole input domain)")


def proof_null(module):
    """The sample-domain null. Parses null_b.py's own per-scenario lines; the
    self-test at the head of that run (substitute nothing -> must be EXACTLY 0)
    is what makes the module block mean anything, so it is re-parsed here and a
    module row is refused if it did not pass."""
    def go():
        rc, out = run([sys.executable, os.path.join(HERE, "null_b.py"),
                       "--module", module])
        blocks = out.split("--- engine B [")
        if rc != 0 or len(blocks) < 2:
            return dict(ok=False, out=out)
        if "SELF-TEST: no module substituted (must be EXACTLY 0): PASS" not in out:
            return dict(ok=False, out=out, why="self-test did not pass")
        body = blocks[-1]
        rows = re.findall(
            r"residual (EXACTLY 0|-?[\d.]+ dB).*?-> (PASS|FAIL)", body)
        if not rows:
            return dict(ok=False, out=out, why="no scenario lines parsed")
        npass = sum(1 for _, v in rows if v == "PASS")
        exact = sum(1 for r, _ in rows if r == "EXACTLY 0")
        worst = "EXACTLY 0" if exact == len(rows) else max(
            (r for r, _ in rows if r != "EXACTLY 0"),
            key=lambda s: float(s.split()[0]))
        n, fp, _ = scenario_fingerprint()
        if len(rows) != n:
            return dict(ok=False, out=out,
                        why="parsed %d scenario lines but null_ab.SCEN has %d"
                            % (len(rows), n))
        return dict(ok=(npass == len(rows)), out=out, kind="NULL_SAMPLE_DOMAIN",
                    evidence="%d/%d scenarios PASS, %d of them residual EXACTLY 0"
                             % (npass, len(rows), exact),
                    margin=worst,
                    scenarios="%d/%d" % (npass, len(rows)),
                    fp=fp)
    return go


PROOFS = {
    "noise_lfsr": dict(
        file="engine_b/noise_lfsr.h",
        replaces="src/voice_render.c analog-noise LFSR (per-voice block "
                 "84272..84436, byte-identical across units -- PROVEN "
                 "autonomous, docs/RENDER_LOOP_LOG.md)",
        proof=proof_noise,
        proof_src=["engine_b/test_noise_lfsr.c",
                   "docs/engineb/data/noise_core_200k.npy"],
        gate="python3 tools/engineb/ledger.py emit noise_lfsr "
             "-> cc engine_b/test_noise_lfsr.c && run",
        cost_src="cost_noise.c",
        cost_body='#include "noise_lfsr.h"\n'
                  'float eb_noise_step_cost(eb_noise *n)'
                  ' { return eb_noise_step(n); }\n',
        cost_func="eb_noise_step_cost",
        inv=1,
        inv_label="STATIC",
        inv_source="engine_b/eb_engine.c steps the SHARED generator exactly once "
                   "per rendered sample (one instance for the whole engine, not "
                   "per voice); the port computes it inside every voice",
        strip_libm=False,
        cost_caveat="wrapper is a non-inlined call, so entry/ret is charged that "
                    "an inlined use would not pay",
        notes="No approximation: the same 25-bit LFSR recurrence and the same "
              "float bits after scaling. The ACCURACY_STANDARD claim that "
              "'analog' noise can only be matched spectrally is refuted here by "
              "execution.",
    ),
    "triangle": dict(
        file="engine_b/triangle.h",
        replaces="src/juno_dsp.c:54 juno_triangle",
        proof=proof_triangle,
        proof_src=["engine_b/test_triangle.c"],
        gate="python3 tools/engineb/ledger.py emit triangle "
             "-> cc engine_b/test_triangle.c && run (2^32 sweep, ~85 s)",
        cost_src="cost_tri.c",
        cost_body='#include "triangle.h"\n'
                  'float eb_triangle_cost(float p) { return eb_triangle(p); }\n',
        cost_func="eb_triangle_cost",
        inv=104,
        inv_label="MEASURED-ON-ORACLE",
        inv_source="callgrind on tools/engineb/cost_harness.c, delta of 1400 and "
                   "400 sample runs, 8 voices, patch 0, 48 kHz: 104,000 "
                   "juno_triangle calls / 1000 samples = 104.0 = 8 voices x 13 "
                   "voice_render sites; the 3 master_render sites executed 0 "
                   "times. ENGINE B'S DCO IS NOT WRITTEN, so 104 is the ORACLE'S "
                   "rate -- the number to BEAT, not engine B's own",
        strip_libm=True,
        cost_caveat="THE RIG'S STATIC COUNT CHARGES 2 fmodf CALLS THAT DO NOT "
                    "EXECUTE: callgrind measured 0 fmodf calls and 19.0 dynamic "
                    "x86 instr per juno_triangle call over 104,000 invocations, "
                    "i.e. the far-out-of-range wrap branch is never taken in the "
                    "rendered scenarios. The libm term is therefore subtracted "
                    "here. The un-subtracted worst case is in notes",
        notes="",
    ),
    "env": dict(
        file="engine_b/eb_envgen.c",
        replaces="src/voice_render.c:965-1075 (ENV1 971-1021, ENV2 1026-1075)",
        proof=proof_null("env"),
        proof_src=["engine_b/shim/env/voice_render.c", "engine_b/eb_envgen.h"],
        gate="python3 tools/engineb/null_b.py --module env",
        cost_src=None,
        cost_sources=["engine_b/eb_envgen.c"],
        cost_func="eb_env_tick",
        inv=16,
        inv_label="STATIC",
        inv_source="engine_b/shim/env/voice_render.c:1059 -- one eb_env_tick per "
                   "(voice, envelope) = 8 voices x 2 envelopes = 16/sample, and "
                   "the port runs both envelopes of all 8 voices every sample "
                   "whatever the polyphony (the 91% idle floor)",
        strip_libm=False,
        cost_caveat="eb_env_tick makes no libm call (the port's fminf is replaced "
                    "by a comparison); the band is CPI and rho spread only",
        notes="The two algebraic simplifications that would have been wrong are "
              "refused by construction and documented in eb_envgen.c: the slew "
              "constant loses the step's low mantissa bits through exponent 2^3, "
              "and the release rate keeps its rel/r cancellation terms.",
    ),
}


# ==========================================================================
# emit
# ==========================================================================
def digest(row):
    return sha_text("\x1f".join(row[c] for c in DIGEST_COLS))


def read_tsv():
    rows, doc = [], []
    if not os.path.exists(TSV):
        return doc, rows
    hdr = None
    for line in open(TSV):
        line = line.rstrip("\n")
        if line.startswith("#"):
            doc.append(line)
            continue
        if not line.strip():
            continue
        parts = line.split("\t")
        if hdr is None:
            hdr = parts
            continue
        rows.append(dict(zip(hdr, parts)))
    return doc, rows


def write_tsv(rows):
    # No two rows may share a row_id (module@commit); the later one wins. See
    # the note in emit(). Applied here as well so a file that already contains
    # historical twins is cleaned by the next legitimate emission rather than by
    # a hand edit, which is the one thing this file forbids.
    seen = {}
    for r in rows:
        seen[r.get("row_id")] = r
    rows = list(seen.values())
    with open(TSV, "w") as f:
        f.write(HEADER_DOC)
        f.write("\t".join(COLUMNS) + "\n")
        for r in rows:
            f.write("\t".join(str(r.get(c, "")).replace("\t", " ")
                              for c in COLUMNS) + "\n")


def emit(names):
    _, rows = read_tsv()
    n_scen, fp_scen, _ = scenario_fingerprint()
    commit, tc, today = git_commit(), toolchain_id(), \
        datetime.date.today().isoformat()
    tool_sha = sha_many([os.path.join(HERE, "cost.py"),
                         os.path.join(HERE, "ledger.py")])
    bad = 0

    for name in names:
        spec = PROOFS[name]
        print("=== %s: running the proof ===" % name)
        res = spec["proof"]()
        if not res.get("ok"):
            print("*** PROOF FAILED for %s (%s). NO ROW EMITTED. ***"
                  % (name, res.get("why", "see output")))
            print(res.get("out", "")[-2500:])
            bad += 1
            continue
        print("    %s" % res["evidence"])

        # ---- cost
        print("    costing on host / m7 / s3 ...")
        if spec.get("cost_src"):
            d = tempfile.mkdtemp(prefix="ebledger_")
            p = os.path.join(d, spec["cost_src"])
            open(p, "w").write(spec["cost_body"])
            srcs, extra_sha = [p], sha_text(spec["cost_body"])
        else:
            srcs = [os.path.join(REPO, s) for s in spec["cost_sources"]]
            extra_sha = ""
        c = cost(srcs, spec["cost_func"], spec["inv"],
                 includes=[os.path.join(REPO, "engine_b")],
                 strip_libm=spec["strip_libm"])

        notes = spec["notes"]
        if spec["strip_libm"]:
            raw = cost(srcs, spec["cost_func"], spec["inv"],
                       includes=[os.path.join(REPO, "engine_b")],
                       strip_libm=False)
            notes = ("Un-subtracted worst case, if the fmodf branch WERE taken "
                     "every call: s3 %s cyc/sample. " % band(raw["s3"])) + notes

        row = {c_: "" for c_ in COLUMNS}
        row.update(
            row_id="%s@%s" % (name, commit),
            module=name,
            file=spec["file"],
            replaces=spec["replaces"],
            status="GREEN",
            accuracy_kind=res["kind"],
            accuracy_evidence=res["evidence"],
            accuracy_margin=res["margin"],
            scenarios=res["scenarios"] if res["kind"] != "NULL_SAMPLE_DOMAIN"
            else "%s (fingerprint %s)" % (res["scenarios"], res["fp"]),
            scen_fingerprint=(res.get("fp") or "n/a (not scenario-based)"),
            inv_per_sample=str(spec["inv"]),
            inv_label=spec["inv_label"],
            inv_source=spec["inv_source"],
            cyc_host=band(c["host"]),
            cyc_m7=band(c["m7"]),
            cyc_s3=band(c["s3"]),
            s3_pct_budget=pct(c["s3"]),
            cost_label="MODELED (no S3 silicon exists; rho MEASURED-TRANSFERRED "
                       "from juno_voice_render; tier s3_iram MODELED)",
            cost_caveat=spec["cost_caveat"],
            gate=spec["gate"],
            gate_exit="0",
            gate_stdout_sha=sha_text(res["out"]),
            file_sha=sha(os.path.join(REPO, spec["file"])),
            proof_sha=sha_many([os.path.join(REPO, s)
                                for s in spec["proof_src"]] +
                               ([] if not extra_sha else [])),
            gate_sha=sha_many([os.path.join(HERE, "null_b.py"),
                               os.path.join(REPO, "tools", "trackb",
                                            "null_ab.py")]),
            tool_sha=tool_sha,
            scen_sha="%d:%s" % (n_scen, fp_scen),
            date=today,
            commit=commit,
            toolchain=tc,
            authority="PROXY vs src/ (FROZEN transcription). src/ is not ground "
                      "truth; the plugin binary is. Retire via "
                      "docs/trackb/THREE_WAY_GATE.md",
            notes=notes,
        )
        row["row_digest"] = digest(row)
        # row_id is module@commit. Re-emitting the SAME module at the SAME
        # commit replaces its row instead of appending a twin: two rows with an
        # identical id are distinguishable only by file position, which is not a
        # property anyone should have to know. Rows from OTHER commits are kept
        # as history and marked SUPERSEDED by `check`.
        rows = [r for r in rows if r.get("row_id") != row["row_id"]]
        rows.append(row)
        print("    s3 %s cyc/sample = %s of the %d budget"
              % (row["cyc_s3"], row["s3_pct_budget"], int(S3_BUDGET)))

    write_tsv(rows)
    print("\nwrote %s (%d rows)" % (os.path.relpath(TSV, REPO), len(rows)))
    return 1 if bad else 0


# ==========================================================================
# check
# ==========================================================================
def check(rerun=False):
    _, rows = read_tsv()
    if not rows:
        print("EMPTY LEDGER")
        return 1
    n_scen, fp_scen, _ = scenario_fingerprint()
    tool_sha = sha_many([os.path.join(HERE, "cost.py"),
                         os.path.join(HERE, "ledger.py")])
    bad = 0
    # SUPERSESSION. row_id carries the commit, so re-emitting a module APPENDS a
    # new row and keeps the old one as history. History rows are stale BY
    # DEFINITION -- that is what supersession means -- so counting their
    # staleness as a problem makes `check` permanently red after the first
    # re-emission and trains everyone to ignore it. Only the LAST row per module
    # is CURRENT and must re-hash clean. History rows are still checked for
    # FORGED and MALFORMED, which are never excusable, and are printed as
    # SUPERSEDED so they cannot be mistaken for live claims.
    current = {}
    for i, r in enumerate(rows):
        current[r.get("module")] = i
    for i, r in enumerate(rows):
        live = current.get(r.get("module")) == i
        missing = [c for c in COLUMNS if c not in r]
        if missing:
            bad += 1
            print("[%-12s] MALFORMED: %d column(s) missing (%s...). A row with "
                  "the wrong shape was appended by something other than this "
                  "tool." % (r.get("row_id", r.get("module", "?")),
                             len(missing), missing[0]))
            continue
        name = r["module"]
        problems = []
        if digest(r) != r["row_digest"]:
            problems.append("FORGED (row_digest does not match its own columns "
                            "-- a number was edited by hand)")
        spec = PROOFS.get(name)
        if spec is None:
            problems.append("UNKNOWN MODULE (no proof is registered for it, so "
                            "nothing can re-derive this row)")
        else:
            if sha(os.path.join(REPO, spec["file"])) != r["file_sha"]:
                problems.append("STALE: %s changed since the row was emitted"
                                % spec["file"])
            ps = sha_many([os.path.join(REPO, s) for s in spec["proof_src"]])
            if ps != r["proof_sha"]:
                problems.append("STALE: the proof source changed")
            gs = sha_many([os.path.join(HERE, "null_b.py"),
                           os.path.join(REPO, "tools", "trackb", "null_ab.py")])
            if gs != r["gate_sha"]:
                problems.append("STALE: the gate harness changed")
        if tool_sha != r["tool_sha"]:
            problems.append("STALE: cost.py/ledger.py changed")
        if r["scen_sha"] != "%d:%s" % (n_scen, fp_scen):
            problems.append("STALE: the scenario set changed (now %d scenarios, "
                            "fingerprint %s) -- an 'N/N scenarios' claim is "
                            "about a set that no longer exists"
                            % (n_scen, fp_scen))
        if rerun and spec is not None:
            res = spec["proof"]()
            if not res.get("ok"):
                problems.append("RE-RUN FAILED")
            elif sha_text(res["out"]) != r["gate_stdout_sha"]:
                problems.append("RE-RUN DIFFERS: the gate no longer prints what "
                                "this row recorded")
        forged = [p for p in problems if p.startswith(("FORGED", "UNKNOWN"))]
        if not live:
            # history: only dishonesty counts, not age.
            if forged:
                bad += 1
                print("[%-12s] SUPERSEDED but %s" % (r["row_id"], forged[0]))
            else:
                print("[%-12s] SUPERSEDED (history; not a live claim)"
                      % r["row_id"])
        elif problems:
            bad += 1
            print("[%-12s] %s" % (r["row_id"], problems[0]))
            for p in problems[1:]:
                print("               %s" % p)
        else:
            print("[%-12s] OK (current)" % r["row_id"])
    print("\n%d row(s), %d problem(s)" % (len(rows), bad))
    return 1 if bad else 0


def teeth():
    """The checker is tested before it is trusted. Each case damages a COPY of
    the ledger (or an artefact) in a way a careless or dishonest edit really
    would, and `check` must catch every one. A checker whose teeth were never
    demonstrated is exactly the green-and-wrong gate this project keeps
    producing."""
    import shutil
    orig = open(TSV).read()
    backup = {}
    cases = []

    def restore():
        open(TSV, "w").write(orig)
        for p, s in backup.items():
            open(p, "wb").write(s)
        backup.clear()

    def edit_tsv(fn):
        open(TSV, "w").write(fn(orig))

    def touch(rel):
        p = os.path.join(REPO, rel)
        backup[p] = open(p, "rb").read()
        open(p, "ab").write(b"\n/* ledger.py teeth */\n")

    # (name, damage, must check() report a problem?)
    cases = [
        ("CLEAN CONTROL", lambda: None, False),
        ("edited cycle number",
         lambda: edit_tsv(lambda s: s.replace("(34.0%)", "(3.0%)", 1)), True),
        ("edited accuracy evidence",
         lambda: edit_tsv(lambda s: s.replace("0 mismatches",
                                              "0 mismatches (approx)", 1)), True),
        ("appended a hand-written row",
         lambda: edit_tsv(lambda s: s + "M9_VCF\tengine_b/eb_vcf.c\tGREEN\n"),
         True),
        ("module source changed under the row",
         lambda: touch("engine_b/noise_lfsr.h"), True),
        ("proof source changed under the row",
         lambda: touch("engine_b/test_triangle.c"), True),
        ("scenario set changed under the row",
         lambda: touch("tools/trackb/null_ab.py"), True),
    ]
    print("=== LEDGER CHECKER TEETH ===")
    bad = 0
    for name, damage, want in cases:
        restore()
        damage()
        out = subprocess.run([sys.executable, __file__, "check"],
                             capture_output=True, text=True, cwd=REPO)
        got = out.returncode != 0
        ok = (got == want)
        if not ok:
            bad += 1
        print("  %-40s -> %s%s" % (name, "caught" if got else "NOT caught",
                                   "" if ok else "   *** TEETH FAILURE ***"))
    restore()
    print("TEETH: %s" % ("PASS" if bad == 0 else "FAIL in %d case(s)" % bad))
    return 1 if bad else 0


def show():
    _, allrows = read_tsv()
    # CURRENT ROWS ONLY. The ledger is append-only, so a re-emitted module has
    # more than one row; summing all of them would double-count a module and
    # report a budget figure that is simply wrong.
    keep = {}
    for r in allrows:
        keep[r.get("module")] = r
    rows = list(keep.values())
    if len(rows) != len(allrows):
        print("(%d superseded history row(s) not shown or summed)"
              % (len(allrows) - len(rows)))
    tot = [0.0, 0.0, 0.0]
    print("%-12s %-22s %-30s %s" % ("module", "accuracy", "s3 cyc/sample",
                                    "% of 3,500"))
    for r in rows:
        print("%-12s %-22s %-30s %s" % (r["module"], r["accuracy_margin"],
                                        r["cyc_s3"], r["s3_pct_budget"]))
        m = re.match(r"([\d,]+)\.\.([\d,]+) \(([\d,]+)\)", r["cyc_s3"])
        if m:
            v = [float(x.replace(",", "")) for x in m.groups()]
            tot = [tot[0] + v[0], tot[1] + v[1], tot[2] + v[2]]
    print("%-12s %-22s %s..%s (%s)   %.0f%%..%.0f%% (%.0f%%)"
          % ("SUM", "", format(int(tot[0]), ",d"), format(int(tot[1]), ",d"),
             format(int(tot[2]), ",d"),
             100 * tot[0] / S3_BUDGET, 100 * tot[1] / S3_BUDGET,
             100 * tot[2] / S3_BUDGET))
    print("\nThe SUM is over the modules in the ledger only. It is not an engine "
          "total: most of the engine is not written.")
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    e = sub.add_parser("emit")
    e.add_argument("module", nargs="*")
    e.add_argument("--all", action="store_true")
    c = sub.add_parser("check")
    c.add_argument("--rerun", action="store_true")
    sub.add_parser("show")
    sub.add_parser("teeth")
    a = ap.parse_args()
    if a.cmd == "teeth":
        return teeth()
    if a.cmd == "emit":
        names = list(PROOFS) if a.all else a.module
        if not names:
            ap.error("name a module or pass --all; known: %s" % ", ".join(PROOFS))
        for n in names:
            if n not in PROOFS:
                ap.error("no proof registered for %r" % n)
        return emit(names)
    if a.cmd == "check":
        return check(a.rerun)
    return show()


if __name__ == "__main__":
    sys.exit(main())
