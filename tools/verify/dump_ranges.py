#!/usr/bin/env python3
"""dump_ranges.py -- dump plugin disassembly to TEXT, once, in ONE process.

WHY THIS EXISTS (2026-08-26, playbook 82b): an audit Workflow gave every agent
`disasm.py`, and each call maps the 11 MB image into a fresh Unicorn instance.
Nineteen agents doing that, next to two running gate jobs, killed both jobs by
memory pressure. The analysis those agents do is pure READING -- it never
needed an emulator. So the emulator runs ONCE, here, and the agents read text.

Faster too: an agent waits ~20 s per disasm.py call and none for a file read.

usage: dump_ranges.py <outdir>
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import e2e_emu as E
import capstone
import disasm as D

# (name, rva, nbytes). Wide ranges on purpose: a compare's jump can sit several
# instructions away, and the caller's context is usually what settles a claim.
RANGES = [
    # --- the seven UNVERIFIED candidates (docs/CONTROL_AUDIT_CANDIDATES.md) ---
    ("cand1_bend_dco_35C630", 0x35C630, 0x140),
    ("cand1_bend_vcf_359BE0", 0x359BE0, 0x140),
    ("cand2_mod_dco_35C710", 0x35C710, 0x140),
    ("cand2_mod_vcf_359D10", 0x359D10, 0x140),
    ("cand3_noteon_leaf_3AEC60", 0x3AEC60, 0x140),
    ("cand3_gate_setter_35CC30", 0x35CC30, 0xC0),
    ("cand4_voicecmn_ctor_35C900", 0x35C900, 0x140),
    ("cand5_setsr_3C7A00", 0x3C7A00, 0x200),
    ("cand5_round_helper_3F2050", 0x3F2050, 0xC0),
    ("cand6_ratelaw_356D00", 0x356D00, 0x120),
    ("cand6_ratelaw_362D40", 0x362D40, 0x120),
    ("cand6_ratelaw_35D060", 0x35D060, 0x120),
    # --- context for the six files the audit never reached ---
    ("effect_dispatch_3B9A30", 0x3B9A30, 0x200),
    ("setsr_container_3BC980", 0x3BC980, 0x180),
]


def main():
    outdir = sys.argv[1]
    os.makedirs(outdir, exist_ok=True)
    e = E.E2E()
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    index = []
    for name, rva, n in RANGES:
        code = bytes(e.uc.mem_read(E.IB + rva, n))
        ins = list(md.disasm(code, E.IB + rva))
        path = os.path.join(outdir, "%s.asm" % name)
        with open(path, "w") as f:
            f.write("; %s  rva 0x%X  %d bytes  (from the checksummed binary)\n"
                    % (name, rva, n))
            for i in ins:
                f.write("%06X  %-20s %s %s\n" % (i.address - E.IB,
                                                 i.bytes.hex(), i.mnemonic,
                                                 i.op_str))
            # the playbook-81 view, appended so an agent never has to compute it
            f.write("\n; ---- COMPARE / JUMP PAIRS (unordered behaviour) ----\n")
            for idx, a in enumerate(ins):
                if not a.mnemonic.startswith(("comis", "ucomis")):
                    continue
                b = None
                for k in range(idx + 1, min(idx + 6, len(ins))):
                    m = ins[k].mnemonic
                    if m.startswith("j") or m.startswith("set"):
                        b = ins[k]; break
                    if not m.startswith(D.__dict__.get("FLAG_SAFE_TUPLE", (
                            "mov", "movss", "movsd", "movaps", "movapd",
                            "movd", "movq", "lea", "nop", "movzx", "movsx",
                            "movsxd", "xorps", "xorpd", "cvtdq2ps",
                            "cvtsi2ss", "push", "pop"))):
                        break
                if b is None:
                    f.write("; %06X  %s %s -> no branch within 5 insns\n"
                            % (a.address - E.IB, a.mnemonic, a.op_str))
                    continue
                beh = D.UNORDERED.get(b.mnemonic)
                if beh is None:
                    f.write("; %06X  %s %s -> %s [unclassified jump]\n"
                            % (a.address - E.IB, a.mnemonic, a.op_str,
                               b.mnemonic))
                    continue
                f.write("; %06X  %s %s ; %s   unordered: %s  %s%s\n"
                        % (a.address - E.IB, a.mnemonic, a.op_str, b.mnemonic,
                           beh[0], beh[1],
                           "   <== RISK" if beh[0] == "NOT taken" else ""))
        index.append((name, rva, n, len(ins), path))
        print("wrote %s (%d insns)" % (path, len(ins)))

    with open(os.path.join(outdir, "INDEX.txt"), "w") as f:
        for name, rva, n, ni, path in index:
            f.write("%-34s rva 0x%06X  %4d bytes  %3d insns  %s\n"
                    % (name, rva, n, ni, os.path.basename(path)))
    print("INDEX written; %d ranges" % len(index))


if __name__ == "__main__":
    main()
