// capture_runtime_coeffs.js — Frida runtime capture of the 349 parameter-applied
// coefficient values the static dumps don't give us (107 voice-patch + 242
// chorus/master). These are READ by voice_render / the master but written by no
// init: the plugin's parameter system applies them at runtime from default/
// preset values (sub_180388170 registers ~1121 params, each lea [rdi+slot] +
// default -> sub_1803ABA00), several through a param->curve map. So the exact,
// faithful values live only in the running engine -- MEASUREMENTS of the shipped
// plugin, not fitted (the runtime-only case the handoff sanctions Frida for).
//
// Capturing them for one default patch makes the port PLAYABLE: a note produces
// sound and the chorus is live. Output is a C table to paste into
// src/runtime_coeffs_data.c.
//
// HOW TO RUN (Windows, plugin loaded in a host e.g. Ableton):
//   1. Load Cloud 60 on a track. Pick the PATCH + CHORUS MODE you want captured
//      (the values are patch-specific; capture the patch you want to reproduce).
//      Let audio run ~1s so smoothing settles.
//   2. frida -n <host.exe> -l capture_runtime_coeffs.js   (or -p <pid>)
//   3. It hooks the master, grabs the engine-state base on a later block, reads
//      the 349 offsets, prints the C table, detaches. Paste the block into
//      src/runtime_coeffs_data.c (over the placeholder k[]).
//
// Adjust MODULE if the plugin binary isn't auto-found (it lists modules then).

'use strict';
var MODULE = 'Cloud 60.vst3';          // <-- adjust to the actual plugin binary
var RVA_MASTER = 0x363380;             // sub_180363380 (engine state in rcx/arg0)
var SETTLE_BLOCKS = 200;               // capture after this many process calls
var OFFSETS = [272,304,368,384,592,608,624,1040,1056,1072,1088,1856,1872,1888,1904,1920,1936,1952,1968,1984,2000,2016,2032,2048,2064,2080,2096,2112,2560,2784,2800,2816,2832,2848,3040,3264,3280,3296,3312,3328,3840,3856,3872,3888,3904,3920,3936,3952,3968,3984,4000,4016,4032,4048,4064,4080,4096,4112,4128,4144,4192,4208,4224,5520,6448,6512,6528,6720,6736,6832,6864,7008,7024,7296,7312,7328,7344,7360,7376,7392,7408,7424,7440,7456,7472,7600,7616,7632,9056,9072,9088,9104,9584,9600,9616,9680,9824,10176,10192,10208,10224,10240,10256,10272,10288,10304,10320,84304,84448,84464,84480,84496,84544,84560,85136,85152,85168,85184,85984,86288,86304,86320,87056,91120,91136,91152,91168,91184,91200,91216,91232,91248,91264,91280,96336,96352,96368,96384,96400,96416,101072,101136,101152,101744,102352,102368,102384,102400,102416,102432,102448,102464,102480,102496,102512,102528,102560,102576,102592,102608,102624,102640,102656,102672,102688,4297584,4297600,4297616,4297632,4297648,4297664,4297680,4297696,4297712,4297728,4297744,4297760,4297792,4297808,4297824,4297840,4297856,4297872,4297888,4297904,4297920,4297936,4297952,4297968,4297984,6395312,6395328,6396128,6396144,6396160,6396176,6396192,6396208,6396224,6396240,6396256,6396272,6396288,6396304,6396320,6396336,6396352,6396368,6396384,6396400,6396416,6396432,6396448,6396464,6396480,6396496,6396512,6429472,6429488,6430464,6430480,6430496,6430512,6430528,6430544,6430560,6430576,6430592,6430608,6430624,6430640,6430656,6430672,6430688,6430704,6430720,6430736,6430752,6430768,6430784,6430800,6430816,6497168,6497184,6497200,6497216,6497232,6497248,6497264,6497280,6497296,6497312,6497328,6497344,6497376,6497392,6497408,6497424,6497440,6497456,6497472,6497488,6497504,10692016,10692032,10693008,10693024,10693040,10693056,10693072,10693088,10693104,10693120,10693136,10693152,10693168,10693184,10693200,10693216,10693232,10693248,10693264,10693280,10693296,10693312,10693328,10693344,10693360,10759376,10759392,10759408,10759424,10759440,10759488,10759504,10759520,10759536,10759552,10759568,10759584,10759600,10759616,10759632,10759648,10759664,10759680,10759696,10759712,10759728,10759744,10759760,10759776,10759792,10759808,10759824,11022208,11022212,11022216,11022220,11022224,11022228,11022232,11022236,11022240,11022244,11022248,11022252,11022256,11022260,11022264,11022268,11022272,11022276,11022280,11022284,11022288,11022292,11022296,11022300,11022304,11022308,11022312,11022316,11022320,11022324,11022328,11022332,11022336,11022340];

function findModule() {
    var m = Process.findModuleByName(MODULE);
    if (m) return m;
    var mods = Process.enumerateModules();
    for (var i = 0; i < mods.length; i++)
        if (mods[i].name.toLowerCase().indexOf('cloud') >= 0) return mods[i];
    console.log('[!] Could not find plugin module. Loaded modules:');
    for (var j = 0; j < mods.length; j++) console.log('    ' + mods[j].name);
    return null;
}

// Known fields written by the STATIC init (juno_chorus_init), used to confirm
// arg0 really is the engine-state base before we trust any value off it.
var KNOWN = [[2199956, 0x80000], [95828, 1024], [101028, 1024]];

function snapshot(a1) {
    var s = {};
    for (var i = 0; i < OFFSETS.length; i++) s[OFFSETS[i]] = a1.add(OFFSETS[i]).readU32();
    return s;
}

function verifyBase(a1) {
    var ok = true;
    for (var i = 0; i < KNOWN.length; i++) {
        var got = a1.add(KNOWN[i][0]).readU32();
        if (got !== KNOWN[i][1]) {
            console.log('[!] base check FAILED: state[' + KNOWN[i][0] + '] = 0x' +
                        got.toString(16) + ' expected 0x' + KNOWN[i][1].toString(16));
            ok = false;
        }
    }
    if (ok) console.log('[*] base check OK — arg0 is the engine state.');
    return ok;
}

function emit(a1, snapA, snapB) {
    // anything that changed between the two snapshots is per-sample STATE, not a
    // coefficient — flag it, and zero it in the table so it is not "applied".
    var drifted = [];
    var out = [];
    out.push('/* captured from live plugin @ ' + new Date().toISOString() +
             ' — base-checked, time-invariance-checked */');
    out.push('static const juno_coeff k[] = {');
    var line = '  ';
    for (var i = 0; i < OFFSETS.length; i++) {
        var off = OFFSETS[i];
        var b = snapB[off];
        var emitBits = b;
        if (snapA[off] !== b) { drifted.push(off); emitBits = 0; }   // state, not coeff
        var f = a1.add(off).readFloat();
        line += '{' + off + ',0x' + ('00000000' + emitBits.toString(16)).slice(-8) + 'u}, ';
        if ((i % 4) === 3) { out.push(line + '/* ~' + (emitBits ? f : 0) + ' */'); line = '  '; }
    }
    if (line.trim().length) out.push(line);
    out.push('};');
    console.log('\n===== BEGIN runtime_coeffs_data.c table (paste over the placeholder) =====');
    console.log(out.join('\n'));
    console.log('===== END =====');
    if (drifted.length)
        console.log('[!] ' + drifted.length + ' offsets changed between snapshots ' +
                    '(treated as STATE, emitted as 0): ' + drifted.join(', '));
    else
        console.log('[*] all ' + OFFSETS.length + ' offsets time-invariant — consistent with coefficients.');
    console.log('[i] next: cross-check values against docs/COEFF_PARAM_MAP.md, then the A/B vs plugin.');
}

(function main() {
    var mod = findModule();
    if (!mod) return;
    var addr = mod.base.add(RVA_MASTER);
    console.log('[*] hooking master sub_180363380 @ ' + addr + ' (base ' + mod.base + ')');
    var n = 0, snapA = null, done = false;
    Interceptor.attach(addr, {
        onEnter: function (args) {
            if (done) return;
            n++;
            if (n === SETTLE_BLOCKS) {                    // first (settled) snapshot
                if (!verifyBase(ptr(args[0]))) { done = true; return; }
                snapA = snapshot(ptr(args[0]));
            } else if (n === SETTLE_BLOCKS * 2 && snapA) { // second, to test invariance
                done = true;
                emit(ptr(args[0]), snapA, snapshot(ptr(args[0])));
            }
        }
    });
    console.log('[*] armed — play a sustained note; captures at blocks ' +
                SETTLE_BLOCKS + ' and ' + (SETTLE_BLOCKS * 2) + '.');
})();
