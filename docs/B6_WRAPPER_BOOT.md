# B6 -- the plugin booted as a host boots it (2026-10-06)

LIVING. Answers: what does the plugin's OWN preset load hand the engine, and how
is it executed? Tool: `probes/b6/wrapper_emu.py` (plumbing over `e2e_emu`),
census `probes/b6/state_load_census.py`.

## The wall that fell (P112 section 7)

The 2026-07 wall ("CRT abort in a magic-static string parse, then a fault at
rva 0x284c04") had one root cause: the emulator gave the plugin no TEB/TLS.
Every MSVC magic static checks `guard > *(TLS[TlsIndex] + 24)`; with gs base 0
the epoch read 0 and every static looked constructed, so empty objects were
used. A real TEB with the PE's TLS template (epoch INT_MIN at +24) fixes it.
The host boot then needs only operating-system plumbing, each item MEASURED:

| step | what the plugin needed |
|---|---|
| DllMain (CRT + 844 C++ initializers) | OS version (ConcRT throws `unsupported_os` otherwise), system info, `InitOnceExecuteOnce` that runs its callback, `GetProcAddress` -> named stubs |
| InitDll (module init) | `InitCommonControlsEx`, folder paths, `GetFullPathName`, string conversions, Shell folder listing (IShellFolder / IEnumIDList / IMalloc with well-formed pidls), `Script.xml` in `<module dir>\Script\` (truth/Script.xml), `TextCodeTable.dat` (GUI strings, not supplied: served empty) |
| IComponent::initialize | GDI+ and DIB sections for the GUI skin (blank images, each state as large as its control, slider knobs smaller: Script.xml geometry) |
| controller + connection | IHostApplication::createInstance for IMessage / IAttributeList, IConnectionPoint both ways, an IComponentHandler |

None of it is plugin logic; the skin images and the text table never reach the
engine. initialize returns kResultOk; getState / setState run the plugin's code.

## What a state load does (EXECUTED)

* `IComponent::setState` (rva 0x34AAA0) -> deserializer (rva 0x321F20) sets the
  model value of every entry of the payload, inside a begin/end marker (126/127)
  that raises the core's "loading" flag (core+584, rva 0x321B30).
* The core's model listener (rva 0x347050) queues, for EVERY entry, a kind-2
  engine event (parameter id, raw model value) -- 95 events, in the payload
  order, which is the plugin's parameter-list order (getState writes the list in
  order; the list is the static name table at rva 0x3DD990, READ). Measured: all
  95 are queued even when no value changed.
* For the 79 host-exported parameters it also calls the edit controller's
  performEdit (no beginEdit while loading), which reaches the host's
  IComponentHandler: 79 performEdit calls per load.
* The render driver (rva 0x320B20) applies queued events in queue order at their
  sample offsets (all 0 here) through the engine's host entry (rva 0x3C7AE0,
  flag 0). The "sort" the P112 notes mention is a vector insert of the previous
  block's carry-over (rva 0x31E7E0), not a reorder.
* initialize itself queues the 95 defaults the same way; the first process()
  applies them.

## The voice count (NEW, READ + EXECUTED)

The 95 include `vm.vs.voiceCount` (id 0x0FFFC00E, default 6). The host entry's
special case stores it at engine+0x38; the engine render (rva 0x3C7400) then, per
voice unit u = 0..7, sets assigner[u]'s voice count to it when it differs (vt[16],
rva 0x355940) and renders only units u < count (the others' outputs are zeroed,
their workers not signalled). So the plugin as shipped plays SIX voices. The
`e2e_emu` harness builds on a zero HOST (engine+0x38 = 0, assigners at 8) and
renders all eight units: it omits this preamble. Tracked as CLAIMS B10.

## Census (probes/b6/state_load_census.py, EXECUTED 2026-10-06)

| payload | engine events | order | values | handler calls |
|---|---|---|---|---|
| the plugin's own getState | 95 kind 2, offset 0 | = payload (list) order | = payload | 79 performEdit |
| every value + 1 | 95 | = payload | = payload & storage width (256 -> 0 for 8-bit leaves: VCF CUTOFF, ENV1/ENV2 SUSTAIN, DELAY/REVERB DIRECT LEVEL) | 79 |
| one value changed | 95 (all, not only the changed one) | = payload | = payload | 79 |
| the 95 entries reversed | 95 | REVERSED (follows the payload) | = payload | 79 |

So the engine order is the payload order. A DAW saves the payload with getState,
which writes the list order; so a DAW preset recall reaches the engine as 95 host
edits in list order at one sample (plus whatever the host does with the 79
performEdits: VST3 hosts forward them as parameter changes, host-dependent).
performEdit values are normalized (LFO RATE 145 -> 145/255).
