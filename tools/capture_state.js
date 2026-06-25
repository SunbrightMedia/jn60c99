// capture_state.js — one-shot capture of the JUNO-60 (Cloud 60 / System-8 PLUG-OUT)
// engine's RUNTIME COEFFICIENT STATE. This is the single load-bearing capture: the
// plugin computes its coefficient values at runtime (parameter DB -> engine, via a
// binding that exists only in live memory and is NOT statically recoverable), so this
// reads the plugin's OWN ground-truth state. Done once per patch, it gives a complete,
// consistent base that Script.xml preset-overrides + the faithful DSP build on.
//
// HOW IT WORKS
//   Hooks master_render (sub_180363380, rva 0x363380). Its first argument a1 IS the
//   engine state base pointer. We wait a few audio blocks (so the patch is fully
//   applied + the engine warmed), then dump the coefficient region to a binary file.
//   Coefficients are set at patch-load and are stable per-sample, so an early-but-not-
//   cold dump is exact for them.
//
// USAGE (Windows, with the plugin loaded in any VST3 host and a note sounding):
//   1. pip/npm install frida-tools  (frida)
//   2. Load the plugin in your host, select the patch you want (e.g. the INIT patch
//      first — that's the most reusable base — then SQ Dynamic ARPG), play/hold a note.
//   3. Find the host process name (e.g. your DAW, or a VST3 host like Carla/validator).
//   4. frida -n <HostProcess.exe> -l capture_state.js
//      (or:  frida -f "C:\\path\\to\\host.exe" -l capture_state.js  to spawn)
//   5. It writes  juno_state_<modulebase>.bin  next to the host CWD. Send me that file.
//
// Adjust MODULE_NAME below to the plugin's binary file name (the .vst3/.dll). If you
// don't know it, run `Process.enumerateModules()` in the frida REPL and look for the
// Cloud 60 / System-8 / Roland module.

'use strict';

var MODULE_NAME = null;          // e.g. "Cloud 60.vst3" or "System-8.dll"; null = auto-detect by export scan
var RVA_MASTER_RENDER = 0x363380; // sub_180363380, image base 0x180000000
var DUMP_BYTES = 11 * 1024 * 1024; // 11 MB: covers the full CJu60Sim workspace (voice + aux + chorus state @ ~10.7MB)
var WARM_BLOCKS = 200;            // dump after this many master_render calls (patch applied + warm)

function findModule() {
  if (MODULE_NAME) {
    var m = Process.findModuleByName(MODULE_NAME);
    if (m) return m;
  }
  // Heuristic: pick the largest non-system module whose name hints at the plugin.
  var best = null;
  Process.enumerateModules().forEach(function (m) {
    var n = m.name.toLowerCase();
    if (n.indexOf('cloud') >= 0 || n.indexOf('system-8') >= 0 || n.indexOf('system8') >= 0 ||
        n.indexOf('ju') === 0 || n.indexOf('roland') >= 0) {
      if (!best || m.size > best.size) best = m;
    }
  });
  return best;
}

var mod = findModule();
if (!mod) {
  console.error('[capture] Could not auto-detect the plugin module. Set MODULE_NAME at the top ' +
                'of this script (run Process.enumerateModules() to list them).');
} else {
  var addr = mod.base.add(RVA_MASTER_RENDER);
  console.log('[capture] module ' + mod.name + ' base=' + mod.base + '  hook=' + addr);
  var calls = 0, done = false;
  Interceptor.attach(addr, {
    onEnter: function (args) {
      if (done) return;
      if (++calls < WARM_BLOCKS) return;
      done = true;
      try {
        var state = args[0];                       // a1 = engine state base
        console.log('[capture] state base = ' + state + '  dumping ' + DUMP_BYTES + ' bytes...');
        var buf = Memory.readByteArray(state, DUMP_BYTES);
        var fname = 'juno_state_' + mod.base + '.bin';
        var f = new File(fname, 'wb');
        f.write(buf);
        f.flush();
        f.close();
        console.log('[capture] WROTE ' + fname + '  (' + DUMP_BYTES + ' bytes). Send this file back.');
        console.log('[capture] Tip: re-run per patch (INIT patch, then SQ Dynamic ARPG) for a full set.');
      } catch (e) {
        console.error('[capture] dump failed: ' + e + '  (try a smaller DUMP_BYTES, e.g. 200000, ' +
                      'if the region is not fully mapped).');
      }
    }
  });
  console.log('[capture] armed. Play/hold a note in the host; dump fires after ' + WARM_BLOCKS + ' audio blocks.');
}
