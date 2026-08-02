# engine_b/shim — how one engine B module is put under the null before the
# engine exists

`tools/engineb/null_b.py --module <name>` builds a HYBRID library:

    src/*.c  minus every file that engine_b/shim/<name>/ shadows by filename
    + engine_b/shim/<name>/*.c
    + engine_b/*.c
    + gui/juno_bridge.c

So a shim file replaces exactly one port translation unit, and everything engine
B has not written yet is the port's own code — not a stub, not a mock, not a
bridge anyone has to maintain. That is what "the rest of engine B calls the
oracle" means here, and it is why a divergence is attributable to one module.

Rules that the harness enforces:

* a shim file MUST be named after the `src/` file it replaces. A name that
  shadows nothing is a build error, because otherwise both files compile and the
  module under test is silently not in the build.
* `--module none` substitutes nothing and MUST null EXACTLY 0. That self-test
  runs at the head of every run; if it is not 0, no other number in the run
  means anything.
* `src/` is never edited. The overlay happens in a temp copy of the tree.

What this cannot see: a module that is only correct inside the port's
surrounding code. `--module all` is the acceptance shape, and B-vs-plugin
(docs/trackb/THREE_WAY_GATE.md) is the only comparison that retires a claim.
`src/` is a fast proxy, never the authority.

No modules exist yet.
