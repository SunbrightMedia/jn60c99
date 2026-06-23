// capture_chorus_coeffs.js — Frida runtime capture of the 241 chorus/output
// COEFFICIENT values the static dumps don't give us.
//
// WHY: sub_180388170 registers ~1121 parameters, each pointing at a coefficient
// slot in the audio state (lea [rdi+offset]); the VALUES are applied at runtime
// when default/preset parameters are set, and several pass through a param->curve
// mapping. So the exact, faithful values are only visible in the live engine.
// These are MEASUREMENTS of the shipped plugin (not fitted) — sanctioned by the
// handoff for runtime-only values. This reads state[offset] for the 241 offsets
// the master (sub_180363380) reads but no static init writes, and prints them as
// a C table to paste into src/chorus_coeffs_data.c.
//
// HOW TO RUN (Windows, plugin loaded in a host e.g. Ableton):
//   1. Load Cloud 60 on a track; set the CHORUS to the mode you want captured
//      (default/off is fine for a first pass — capture each mode separately if
//      you want full coverage). Let audio run for a second.
//   2. frida -n <host.exe> -l capture_chorus_coeffs.js     (or attach by PID)
//   3. It hooks the master process, grabs the engine-state base on a later block
//      (after smoothing settles), reads the 241 offsets, prints the C table, and
//      detaches. Copy the printed block into src/chorus_coeffs_data.c.
//
// NOTE: the module name below must match the plugin binary (the VST3/dll that
// contains RVA 0x363380). Adjust MODULE if needed; the script lists modules if
// it can't find it.

'use strict';
var MODULE = 'Cloud 60.vst3';          // <-- adjust to the actual plugin binary
var RVA_MASTER = 0x363380;             // sub_180363380 (engine state in rcx/arg0)
var SETTLE_BLOCKS = 200;               // capture after this many process calls
var OFFSETS = [84448,84464,84480,84496,84544,84560,85136,85152,85168,85184,85984,86288,86304,86320,87056,91120,91136,91152,91168,91184,91200,91216,91232,91248,91264,91280,96336,96352,96368,96384,96400,96416,101072,101136,101152,101744,102352,102368,102384,102400,102416,102432,102448,102464,102480,102496,102512,102528,102560,102576,102592,102608,102624,102640,102656,102672,102688,4297584,4297600,4297616,4297632,4297648,4297664,4297680,4297696,4297712,4297728,4297744,4297760,4297792,4297808,4297824,4297840,4297856,4297872,4297888,4297904,4297920,4297936,4297952,4297968,4297984,6395312,6395328,6396128,6396144,6396160,6396176,6396192,6396208,6396224,6396240,6396256,6396272,6396288,6396304,6396320,6396336,6396352,6396368,6396384,6396400,6396416,6396432,6396448,6396464,6396480,6396496,6396512,6429472,6429488,6430464,6430480,6430496,6430512,6430528,6430544,6430560,6430576,6430592,6430608,6430624,6430640,6430656,6430672,6430688,6430704,6430720,6430736,6430752,6430768,6430784,6430800,6430816,6497168,6497184,6497200,6497216,6497232,6497248,6497264,6497280,6497296,6497312,6497328,6497344,6497376,6497392,6497408,6497424,6497440,6497456,6497472,6497488,6497504,10692016,10692032,10693008,10693024,10693040,10693056,10693072,10693088,10693104,10693120,10693136,10693152,10693168,10693184,10693200,10693216,10693232,10693248,10693264,10693280,10693296,10693312,10693328,10693344,10693360,10759376,10759392,10759408,10759424,10759440,10759488,10759504,10759520,10759536,10759552,10759568,10759584,10759600,10759616,10759632,10759648,10759664,10759680,10759696,10759712,10759728,10759744,10759760,10759776,10759792,10759808,10759824,11022208,11022212,11022216,11022220,11022224,11022228,11022232,11022236,11022240,11022244,11022248,11022252,11022256,11022260,11022264,11022268,11022272,11022276,11022280,11022284,11022288,11022292,11022296,11022300,11022304,11022308,11022312,11022316,11022320,11022324,11022328,11022332,11022336,11022340];

function findModule() {
    var m = Process.findModuleByName(MODULE);
    if (m) return m;
    // try a few common variants / any module whose name contains "Cloud"
    var mods = Process.enumerateModules();
    for (var i = 0; i < mods.length; i++)
        if (mods[i].name.toLowerCase().indexOf('cloud') >= 0) return mods[i];
    console.log('[!] Could not find plugin module. Loaded modules:');
    for (var j = 0; j < mods.length; j++) console.log('    ' + mods[j].name);
    return null;
}

function dump(a1) {
    var out = [];
    out.push('/* captured from live plugin @ ' + new Date().toISOString() + ' */');
    out.push('static const juno_coeff k[] = {');
    var line = '  ';
    for (var i = 0; i < OFFSETS.length; i++) {
        var off = OFFSETS[i];
        var bits = a1.add(off).readU32();           // raw float bits
        var f = a1.add(off).readFloat();
        line += '{' + off + ',0x' + ('00000000' + bits.toString(16)).slice(-8) + 'u}, ';
        if ((i % 4) === 3) { out.push(line + '/* ..' + f + ' */'); line = '  '; }
    }
    if (line.trim().length) out.push(line);
    out.push('};');
    console.log('\n===== BEGIN chorus_coeffs_data.c table (paste over the placeholder) =====');
    console.log(out.join('\n'));
    console.log('===== END =====\n');
}

(function main() {
    var mod = findModule();
    if (!mod) return;
    var addr = mod.base.add(RVA_MASTER);
    console.log('[*] hooking master sub_180363380 @ ' + addr + ' (base ' + mod.base + ')');
    var n = 0, done = false;
    Interceptor.attach(addr, {
        onEnter: function (args) {
            if (done) return;
            if (++n < SETTLE_BLOCKS) return;
            done = true;
            // x64 __fastcall: arg0 (engine state) in rcx == args[0]
            dump(ptr(args[0]));
        }
    });
    console.log('[*] armed — play a note / let audio run; capture after ' + SETTLE_BLOCKS + ' blocks.');
})();
