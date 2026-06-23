# How to run `extract_dsp.py` (beginner guide)

This produces the `dsp_dump/` folder I need to start the C99 port. You run it
once, in **IDA Pro on Windows**, on the already-analyzed Cloud 60 database.

---

## Step 0 — Check you have the x86-64 decompiler (1 minute)

The script needs the **Hex-Rays x86-64 decompiler**. Easiest way to check:

1. Open your Cloud 60 database in IDA (the `.i64` file).
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

1. Open the analyzed Cloud 60 database in IDA and wait until the bottom status
   bar says **AU: idle** (analysis finished).
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
