# How to run `extract_dsp.py` (beginner guide)


> **Provenance note (2026-07):** the extraction folders cited below
> (`dsp_dump/`, `init_dump/`, `host_layer/`, `audio_search/`, `master_deps/`,
> `chorus_coeffs/`, `everything_static/`, `param_setter/`) were pruned from the
> repo and its history. The decompile they came from is archived per-RVA in
> `refs/allcode_decomp.tgz`, and everything is regenerable from
> `truth/JUNO60.vst3` (see `docs/RUN_GUIDE.md`). Citations below are kept as
> historical provenance coordinates.

This produces the `dsp_dump/` folder I need to start the C99 port. You run it
once, in **IDA Pro on Windows**, on the Cloud 60 plugin binary.

You only need the **`.vst3` file** — that *is* the binary (a `.vst3` is just a
renamed Windows DLL). IDA opens it directly and builds the analyzed database
(`.i64`) for you. You do **not** need a pre-made `.i64`.

---

## Step A — Open the .vst3 in IDA and let it analyze (one-time, ~5–30 min)

1. A `.vst3` on Windows is sometimes a **single file** and sometimes a
   **folder** (a "bundle"). Look at what you have:
   - **Single file** `Cloud 60.vst3` → that's the binary. Use it directly.
   - **Folder** `Cloud 60.vst3` → open it and dig to
     `Contents\x86_64-win\Cloud 60.vst3` (a `.vst3` or `.dll` file inside).
     That inner file is the binary.
2. Launch **IDA** (the 64-bit one). Menu **File → Open…**, select that binary.
3. IDA shows a load dialog — it should say something like *"Portable executable
   for AMD64 (PE)"*. Just click **OK** (defaults are correct).
4. IDA now **auto-analyzes**. Wait until the bottom status bar reads
   **`AU: idle`**. This can take a while for a big plugin — that's normal.
5. IDA has now created the database. (When you later close IDA, say **Yes** to
   "Save database" so you don't have to re-analyze.)

Now continue to Step 0.

---

## Step 0 — Check you have the x86-64 decompiler (1 minute)

The script needs the **Hex-Rays x86-64 decompiler**. Easiest way to check:

1. With the database open (from Step A) and analysis idle,
2. Click on any function in the left-hand list.
3. Press **F5**.

- If a **C-like pseudocode window opens** → you have it. ✅ Proceed.
- If you get **"the decompiler is not available"** or there's no F5 action →
  the x86-64 decompiler isn't in your license. Tell me and we'll sort licensing
  before you waste a run.

(Alternatively: menu **Help → About**, the license/add-ons line lists
"Hex-Rays Decompiler (x64)" if present.)

---

## Step 1 — Run the script (GUI, recommended for beginners)

1. With the database open and the bottom status bar at **AU: idle**,
2. Menu: **File → Script file…**
3. Pick `tools/extract_dsp.py` from this repo.
4. Watch the **Output window** at the bottom. You'll see lines like:
   ```
   [extract_dsp] output folder: ...\dsp_dump
   [extract_dsp] root: 0x... <name>          <- the audio roots it found
   [extract_dsp] decompiling N functions...
   [extract_dsp]   ...100/N decompiled
   [extract_dsp] DONE. Wrote N functions ...
   ```
   It can take a few minutes. The `root:` lines tell us whether it found the
   master-mix and chorus — copy those lines back to me.

## Step 2 — Send me the result

The output is a folder called `dsp_dump/` sitting **next to your database
file** (the exact path is printed as `output folder:` in the log).

- Zip or tar the whole `dsp_dump/` folder.
- Upload it here.

That folder + the handoff is everything I need to start transcribing.

---

## If F5 worked but you want to be extra safe

Before the full run, you can confirm the seed decompiles: press **G**, type
`0x180369070`, Enter, then **F5**. If readable C appears, the full extraction
will work too.

## Notes

- **You do not need the IDA SDK.** IDAPython ships with IDA.
- Default settings in the script are fine (`SCOPE = "subtree"`). Don't change
  anything unless I ask.
- If the run finishes with **0 roots besides the seed**, the caller-climb didn't
  reach the master-mix/chorus — tell me and I'll bump `CALLER_LEVELS` or we'll
  add their addresses to `SEED_EAS`.
