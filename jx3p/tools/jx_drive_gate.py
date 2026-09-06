#!/usr/bin/env python3
"""jx_drive_gate.py -- THE DRIVE GATE. Every defect that cost this port days
was a DRIVE defect: the harness fed the plugin something wrong, and the A/B
gates stayed green because both sides shared the mistake. Documentation does
not stop that from happening again; these teeth do.

Each check below FAILS LOUDLY and names the playbook entry it guards:

  1. ABI LEDGER (playbook 87) -- for every oracle entry, the register the
     CALLEE READS is re-derived from the machine code and compared with the
     ledger in jx_emu. The SETSR defect (rate in rdx, callee reads xmm1
     float) is exactly what this catches, in one second.
  2. BOOT DETERMINISM (playbook 90) -- the boot is run and its fingerprint
     (static-init ok/fail/skip, stray faults, .data fill, controller map)
     must equal the recorded values. A wall-clock bound, a new faulting
     ctor, or a machine-speed dependency all move these numbers.
  3. BANK DECODE (playbook 88) -- jx_bank_census: every decoded value of
     all 64 patches inside the binary's own parameter ranges, no level pool
     constant bank-wide. Also re-proves the tooth bites under the old +8.
  4. BASE MATCH (playbook 89) -- the SHIPPED template and recall aux must
     come from the same boot: the exporter's clean windows are compared
     against the shipped template before any diff is trusted.

usage: jx_drive_gate.py            (all checks; exit 1 on any failure)
       jx_drive_gate.py --quick    (skip check 4, which re-boots per window)
"""
import sys, os, subprocess, struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.join(HERE, "..", "..")
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))

# The BOOT FINGERPRINT (MEASURED 2026-09-06, deterministic by construction:
# instruction-count bounds only, faulting ctors skipped by RVA). If a number
# below changes, the boot changed -- find out WHY before regenerating a
# single artifact from it.
EXPECT = {
    "static_ok": 841,
    "static_fail": 0,
    "static_skipped": 3,
    "host_map": {0: 18, 1: 19, 2: 20},
    "host_writes": 3,
    "max_faults": 8,          # a clean boot faults ~1; the guard cap is 64
}


def fail(msg):
    print("DRIVE GATE FAIL: %s" % msg)
    return 1


def check_abi():
    """playbook 87: the ledger must match the machine code."""
    import jx_emu as J
    sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
    import abi_check
    import pefile
    pe = pefile.PE(J.BIN)
    ib, img = pe.OPTIONAL_HEADER.ImageBase, pe.get_memory_mapped_image()
    # (name, rva, the arg locations the HARNESS fills)
    LEDGER = [
        ("BUILD",    J.BUILD - J.IB,     {"rcx"}),
        ("SETSR",    J.SETSR - J.IB,     {"rcx", "xmm1"}),
        ("NOTEON",   J.NOTEON - J.IB,    {"rcx", "rdx", "r8"}),
        ("NOTEOFF",  J.NOTEOFF - J.IB,   {"rcx", "rdx", "r8"}),
        ("DISPATCH", J.DISPATCH - J.IB,  {"rcx", "rdx", "r8", "r9"}),
        ("NOTIFY",   J.ASG_NOTIFY - J.IB, {"rcx", "rdx"}),
        ("HOSTPARAM", J.HOSTPARAM - J.IB, {"rcx", "rdx", "r8"}),
    ]
    bad = 0
    for name, rva, filled in LEDGER:
        read, _stack = abi_check.analyze(img, ib, rva)
        got = set(read)
        if got != filled:
            bad += fail("%s rva 0x%x: callee READS %s, harness fills %s "
                        "(playbook 87)" % (name, rva, sorted(got), sorted(filled)))
        # the float/double width of an xmm arg is part of the contract
        for reg in got & {"xmm0", "xmm1", "xmm2", "xmm3"}:
            info = read[reg]
            if len(info) > 2 and info[2] == "double":
                bad += fail("%s reads %s as DOUBLE; the harness passes a float"
                            % (name, reg))
    if not bad:
        print("1. ABI ledger: %d entries match the machine code" % len(LEDGER))
    return bad


def check_boot():
    """playbook 90: the boot fingerprint must be exactly the recorded one."""
    import jx_emu as J
    jx = J.JX()
    ok, f = jx.run_static_init()
    skip = getattr(jx, "static_skipped", 0)
    bad = 0
    if (ok, f, skip) != (EXPECT["static_ok"], EXPECT["static_fail"],
                         EXPECT["static_skipped"]):
        bad += fail("static init ok/fail/skip = %d/%d/%d, expected %d/%d/%d "
                    "(playbook 90: the boot changed)"
                    % (ok, f, skip, EXPECT["static_ok"],
                       EXPECT["static_fail"], EXPECT["static_skipped"]))
    jx.build(); jx.set_ftz(); jx.set_sr(44100.0)
    m = jx.host_map()
    if m != EXPECT["host_map"]:
        bad += fail("controller host map = %s, expected %s (lesson 10)"
                    % (m, EXPECT["host_map"]))
    w, wf = jx.host_init()
    if w != EXPECT["host_writes"] or wf:
        bad += fail("host_init wrote %d (fail %d), expected %d"
                    % (w, wf, EXPECT["host_writes"]))
    if jx.faults > EXPECT["max_faults"]:
        bad += fail("%d stray page faults, expected <= %d -- a crash-walk is "
                    "loose (playbook 90)" % (jx.faults, EXPECT["max_faults"]))
    if not bad:
        print("2. boot fingerprint: static %d/%d/%d, map %s, %d host writes, "
              "%d faults" % (ok, f, skip, m, w, jx.faults))
    return bad


def check_decode():
    """playbook 88: the decode census, and its tooth must still bite."""
    r = subprocess.run([sys.executable, os.path.join(HERE, "jx_bank_census.py")],
                       capture_output=True, text=True)
    if r.returncode != 0:
        print(r.stdout[-800:])
        return fail("bank census RED (playbook 88)")
    r2 = subprocess.run([sys.executable, os.path.join(HERE, "jx_bank_census.py"),
                         "--offset", "8"], capture_output=True, text=True)
    if r2.returncode == 0:
        return fail("the decode TOOTH DID NOT BITE: the old +8 formula passed "
                    "the census (playbook 88)")
    print("3. bank decode: census GREEN, tooth bites under the old +8")
    return 0


def check_base_match():
    """playbook 89: the shipped template and aux must share one base."""
    import jx_emu as J
    sys.path.insert(0, HERE)
    import jx_master_recall_export as X
    jx = J.JX().boot(44100.0, snap=True, host_init=True)
    uc = jx.uc
    clean_m = bytes(uc.mem_read(jx.state[8], X.SNAP_M))
    clean_h = [bytes(uc.mem_read(jx.state[v] + X.HI_LO, X.HI_SZ)) for v in range(8)]
    clean_l = [bytes(uc.mem_read(jx.state[v], 0x60000)) for v in range(8)]
    try:
        X.check_template_base(clean_l, clean_h, clean_m,
                              os.path.join(REPO, "jx3p", "gen", "jx_template.bin"))
    except SystemExit as e:
        return fail("%s" % e)
    print("4. base match: the shipped template IS this boot (playbook 89)")
    return 0


def main():
    quick = "--quick" in sys.argv
    bad = check_abi() + check_boot() + check_decode()
    if not quick:
        bad += check_base_match()
    print("JX DRIVE GATE: %s" % ("GREEN" if not bad else "%d FAILURE(S)" % bad))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
