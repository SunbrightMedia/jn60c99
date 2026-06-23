// frida_chorus_coeffs.js — capture the real chorus mix + modulation coefficients.
// Reads the chorus DSP object's mix levels, LFO state, and L/R in/out so we can
// match the recorded TestC/TestD stereo image and +57% gain exactly.
//
// RUN: load a patch with CHORUS I on, hold a note:
//   frida -n "Ableton Live 12 Suite.exe" -l frida_chorus_coeffs.js
// Then switch to CHORUS II and note the values change. Copy back the C lines.
'use strict';
const MODULE = 'JUNO-60(VST3 64bit).vst3';
const RVA = 0x369070;   // the per-block render (chorus runs inside master)
function f32(p,o){ try { return p.add(o).readFloat(); } catch(e){ return null; } }
const mod = Process.findModuleByName(MODULE);
if (!mod) {
  console.log('[!] module not found; JUNO modules:');
  Process.enumerateModules().forEach(m=>{ if(m.name.toUpperCase().indexOf('JUNO')>=0) console.log('   '+m.name); });
} else {
  console.log('[*] chorus capture — turn CHORUS I on, hold a note. Then try CHORUS II.');
  let n = 0, lastReport = 0;
  let minDelay=1e9, maxDelay=-1e9;  // track LFO sweep extent
  console.log('CHORUS_START');
  Interceptor.attach(mod.base.add(RVA), {
    onEnter: function(){
      const b = this.context.rcx;
      if (!b || b.isNull()) return;
      // mix coefficients (static once a mode is selected)
      const dry  = f32(b, 0x419410);
      const wet  = f32(b, 0x419420);
      const wmix = f32(b, 0x419460);
      const tap  = f32(b, 0x419440);
      const lfor = f32(b, 0x419560);
      const mdly = f32(b, 0x419370);  // current modulated delay (sweeps with LFO)
      if (dry === null) return;
      if (mdly !== null) { if (mdly<minDelay) minDelay=mdly; if (mdly>maxDelay) maxDelay=mdly; }
      // print the static coeffs once (they don't change within a mode)
      if (n < 1) { n++;
        console.log('C dry='+dry.toFixed(6)+' wet='+wet.toFixed(6)+' wetMix='+wmix.toFixed(6)
                   +' tapRatio='+tap.toFixed(6)+' lfoRate='+lfor.toFixed(9)); }
      // every ~1s report the LFO sweep range (min/max delay) — gives depth + rate
      lastReport++;
      if (lastReport >= 48000) { lastReport = 0;
        const span = maxDelay - minDelay;
        const center = (maxDelay+minDelay)*0.5;
        console.log('   [delay sweep: min='+minDelay.toFixed(5)+' max='+maxDelay.toFixed(5)
                   +' span='+span.toFixed(5)+' center='+center.toFixed(5)+']');
        minDelay=1e9; maxDelay=-1e9; }
    }
  });
}
