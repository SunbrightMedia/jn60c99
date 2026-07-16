# truth/ — the ground truth

**The original Roland Cloud JUNO-60 (JU-06A) VST3 is the ONLY truth for this port.**
Every bit-exactness claim is measured against these files by running the plugin's own
machine code under Unicorn emulation. Nothing in `src/` is authoritative; these are.

| file | what it is |
|------|------------|
| `JUNO60.vst3` | the plugin binary (PE/DLL). Its DSP is what the C99 port reproduces. Run under emulation — never patched, never "captured". |
| `Script.xml` | the plugin's own "Koa Script" schema (user-supplied). Defines the bank-blob → parameter layout the recall reads. Reading it is allowed plugin data. |
| `presetbankog1.bin` | the `KoaBankFile00003` / `PG-JU60` factory bank (64 patches) the recall is proven against. |
| `SHA256SUMS` | pins the exact bytes. `tools/verify/truth.py verify` asserts them before trusting any run. |

## How the gates find these

Never hardcode a path. Python resolves through `tools/verify/truth.py`
(`truth.VST3 / SCRIPT_XML / BANK`), which reads this folder — or `$JUNO_TRUTH` if you
keep the binaries outside git. Check integrity with:

```
python3 tools/verify/truth.py
```

## Provenance rule (self-proving mandate)

Ground truth is ONLY the plugin binary executed under emulation. Audio renders,
Frida dumps, and hand-typed coefficient tables are **captures** and are never ground
truth — they must not appear here and must not feed `src/`. If a value in the port
cannot be traced to this folder via an executed gate, it is `UNVERIFIED` in
`verify/PROVENANCE.tsv`, not proven.
