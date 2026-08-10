# EB_FPDIV — the S3's hardware divide, inline and BIT-EXACT (2026-08-10)

## THE CLAIM THAT WAS WRONG FOR MONTHS
`eb_vcf_ladder.c`'s header said: *"the ESP32-S3 has no FP divide, so this
division is a soft-float call."* MEASURED, both halves are false.
`__XCHAL_HAVE_FP_DIV` is 1; `div0.s divn.s recip0.s nexp01.s maddn.s
mkdadj.s addexpm.s sqrt0.s` all assemble for this target; and **libgcc's own
`__divsf3` for esp32s3 IS the hardware sequence** — 30 instructions, 14 of
them `div0.s`/`nexp01.s`/`maddn.s`/`divn.s`. The FPU was doing the work all
along.

## SO WHAT WAS BEING PAID IS TRANSPORT, IN THE WORST CURRENCY
The caller holds its operands in FLOAT registers. The windowed ABI passes
them in INTEGER registers. So every division paid a `wfr` pair going in and
an `rfr` coming out purely for the calling convention, plus `entry`/`retw`,
the literal load, the argument moves and the `callx8`. None of that is
arithmetic.

`engine_b/eb_fpdiv.h` inlines libgcc's body VERBATIM — same opcodes, same
order, only register names replaced by compiler-assigned operands.

## VERIFICATION, TWO INDEPENDENT KINDS
**1. MECHANICAL, opcode identity.** Disassemble an `EB_FPDIV=1` build, strip
the ABI transport (`entry retw wfr rfr mov l32r callx8`), and 25 instructions
remain that are OPCODE-FOR-OPCODE IDENTICAL to libgcc's, in the same order.
Bit-exactness by construction, checkable by a script rather than an argument.

**2. NUMERIC, ON REAL XTENSA UNDER QEMU** — the only place it can be tested,
since the host cannot execute `div0.s` and a host pass would be vacuous:

    **1,500,256 comparisons, 0 MISMATCHES**
      256 pairs of {+-0, +-inf, quiet NaN, signalling NaN, FLT_MIN,
          denormals, +-FLT_MAX, +-1, 2, 0.1, 10}   -> 0
      1,200,000 random bit-pattern pairs           -> 0
      300,000 draws from the exact 1/(G^4 k + 1) range the sites see -> 0
    Compared as RESULT BITS, not `==`.

## ★ PROVING THE GATE COULD FAIL TOOK FOUR PLANTS, AND THE FIRST THREE
## TAUGHT SOMETHING REAL
Plants 1-3 — transposing two `maddn.s` operands, `neg.s` -> `mov.s`, changing
a `const.s` seed, re-pointing a `maddn.s` operand — ALL reported zero
mismatches. My first reading was that the gate was blind. **It is not**, and
two facts explain them:

  * `maddn.s r,s,t` computes `r -= s*t`, and multiplication is EXACTLY
    commutative in IEEE, so transposing those operands is a NO-OP.
  * The sequence is Newton-Raphson closed by a correctly-rounded `divn.s`,
    so perturbing an INTERMEDIATE RESIDUAL is genuinely self-corrected.

Plant 4 — doubling the final quotient, which CANNOT be inert — produced
**67,075 mismatches of 80,256** against the clean build's 0.

**AN INERT MUTATION AND A BLIND GATE LOOK IDENTICAL IN A LOG.** The only way
to tell them apart is to plant something that MUST change the answer. This
repo has been caught conflating them three times; this is the fourth, caught
before it became a false claim rather than after.

Also caught on the way, in my own work: a disassembly diff that reported
"identical" because its extraction regex produced two EMPTY files while the
two ELFs had different md5 sums. A comparison of nothing with nothing always
agrees.

## MEASURED EFFECT, four modules, shipping flags
    __divsf3 relocations   12 -> 6
    stack stores           26 -> 16      <- DOWN, not up
The 16-register wall was the stated risk (the sequence needs nine of sixteen
float registers, and a CALL confines that pressure while INLINING exposes it
— exactly what cost EB_FUSE_VCA +168 cycles). The rule was to count stores
before counting cycles. **The stores fell.**

## GATES
    trunk null, -DEB_NOLIBM=1 -DEB_FPDIV=1, all 36 scenarios  PASS EXACTLY 0
Stated honestly: on the host `EB_DIV` is literally `(a)/(b)`, so the trunk
null proves the REFACTOR is inert. The QEMU run above is what proves the
ASSEMBLY. Neither alone is sufficient and both were run.

## WHAT IS NOT CLAIMED
No cycle number. Instructions are not cycles on this chip (c/i ~1.35) — but a
windowed call OCCUPIES issue slots rather than waiting in them, so its removal
should convert better than the control-rate holds did. **The board decides.**
