import sys
sys.path.insert(0, "/tmp")
from jx_parts import JS, BT, BA, BB

HTML = """<title>JX-3P Playable Port</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Michroma&family=IBM+Plex+Sans:wght@400;600&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
  :root{
    --panel:#2E3033; --well:#232528; --edge:#1B1C1E; --ink:#D9D6CF;
    --dim:#8F8D88; --coral:#E8626F; --led:#7ADF9A; --blue:#5A7FBF;
    --ivory:#EDE9DF; --key-edge:#4a4c50;
  }
  body{ background:var(--edge); color:var(--ink); margin:0;
        font:15px/1.5 "IBM Plex Sans",system-ui,sans-serif; }
  .panel{ max-width:920px; margin:28px auto; background:var(--panel);
          border:1px solid #101112; border-radius:10px;
          box-shadow:0 14px 40px rgba(0,0,0,.5); overflow:hidden; }
  .rail{ display:flex; align-items:center; gap:16px; padding:18px 24px;
         border-bottom:2px solid var(--edge); }
  .logo{ font:20px "Michroma",sans-serif; letter-spacing:.06em; }
  .logo em{ font-style:normal; color:var(--coral); }
  .badge{ font:11px "IBM Plex Mono",monospace; letter-spacing:.14em;
          color:var(--dim); text-transform:uppercase; border:1px solid #45474b;
          border-radius:3px; padding:3px 8px; }
  .led{ width:10px; height:10px; border-radius:50%; background:#3a3c3f;
        margin-left:auto; box-shadow:inset 0 1px 2px rgba(0,0,0,.6); }
  .led.on{ background:var(--led); box-shadow:0 0 8px var(--led); }
  .controls{ display:flex; gap:14px; align-items:center; flex-wrap:wrap;
             padding:18px 24px; }
  button,select{ font:13px "IBM Plex Mono",monospace; letter-spacing:.08em;
    color:var(--ink); background:var(--well); border:1px solid #101112;
    border-top-color:#4a4c50; border-radius:5px; padding:10px 16px;
    cursor:pointer; }
  button:focus-visible,select:focus-visible{ outline:2px solid var(--coral); }
  #power{ color:#1c1d1f; background:var(--coral); border-top-color:#f-2a3ad;
          font-weight:500; }
  #power[disabled]{ background:#5b5d60; color:#2b2d30; cursor:default; }
  .lcd{ margin-left:auto; background:#151a14; color:var(--led);
        font:12px "IBM Plex Mono",monospace; padding:9px 14px;
        border-radius:4px; border:1px solid #0c0d0c; min-width:250px; }
  .kbd-wrap{ padding:8px 24px 22px; }
  #kbd{ display:flex; height:170px; user-select:none; touch-action:none; }
  .wk{ flex:1; background:var(--ivory); border:1px solid var(--key-edge);
       border-radius:0 0 5px 5px; position:relative; cursor:pointer; }
  .wk.on{ background:#f7c8cd; }
  .bk{ position:absolute; width:58%; height:60%; left:71%; z-index:2;
       background:#141517; border-radius:0 0 4px 4px; cursor:pointer; }
  .bk.on{ background:var(--coral); }
  .strip{ display:flex; gap:6px; padding:0 24px 14px; }
  .patchbtn{ width:22px; height:10px; border-radius:2px; background:#3a3c3f;
             border:1px solid #191a1c; cursor:pointer; }
  .patchbtn.sel{ background:var(--blue); box-shadow:0 0 6px rgba(90,127,191,.7); }
  .patchbtn:nth-child(8n+1){ margin-left:10px; }
  .foot{ padding:14px 24px 18px; border-top:2px solid var(--edge);
         color:var(--dim); font-size:12.5px; display:flex; gap:18px;
         flex-wrap:wrap; }
  .foot b{ color:var(--ink); font-weight:600; }
  .mono{ font-family:"IBM Plex Mono",monospace; }
  kbd{ font:11px "IBM Plex Mono",monospace; background:var(--well);
       border:1px solid #101112; border-radius:3px; padding:1px 5px; }
</style>
<div class="panel">
  <div class="rail">
    <div class="logo">JX-3P <em>·</em> bit-exact port</div>
    <div class="badge">voice engine proven · 64/64 exactly 0</div>
    <div class="led" id="led"></div>
  </div>
  <div class="controls">
    <button id="power" disabled>START AUDIO</button>
    <select id="patch" aria-label="patch"></select>
    <div class="lcd" id="lcd">BOOTING ENGINE…</div>
  </div>
  <div class="strip" id="strip"></div>
  <div class="kbd-wrap"><div id="kbd"></div></div>
  <div class="foot">
    <div><b>Play:</b> <kbd>A</kbd>–<kbd>K</kbd> white · <kbd>W E T Y U</kbd> black · <kbd>Z</kbd>/<kbd>X</kbd> octave</div>
    <div class="mono">clean boot · 8 voices · 44100&nbsp;Hz</div>
    <div>Master FX (chorus/echo) bypassed in this preview — the effect manager's host-parameter init is the logged next arc.</div>
  </div>
</div>
<script>__ENGINE__</script>
<script>
const B64 = { tmpl:"__BT__", aux:"__BA__", bank:"__BB__" };
function b64bytes(s){ const bin=atob(s); const u=new Uint8Array(bin.length);
  for(let i=0;i<bin.length;i++) u[i]=bin.charCodeAt(i); return u; }
async function gunzip(u8){
  const ds=new DecompressionStream('gzip');
  const buf=await new Response(new Blob([u8]).stream().pipeThrough(ds)).arrayBuffer();
  return new Uint8Array(buf);
}
const lcd=t=>document.getElementById('lcd').textContent=t;
(async()=>{
  const mod=await Jx3pModule();
  const [t,a,b]=await Promise.all([gunzip(b64bytes(B64.tmpl)),
    gunzip(b64bytes(B64.aux)), gunzip(b64bytes(B64.bank))]);
  mod.FS.writeFile('/t.bin',t); mod.FS.writeFile('/a.bin',a);
  mod.FS.writeFile('/b.bin',b);
  if(!mod.ccall('jx3p_init','number',['string','string','string'],
                ['/t.bin','/b.bin','/a.bin'])){ lcd('ENGINE INIT FAILED'); return; }
  const recall=i=>{ mod.ccall('jx3p_recall',null,['number'],[i]);
    lcd('PATCH '+String(i+1).padStart(2,'0')+'  ·  READY');
    document.querySelectorAll('.patchbtn').forEach((el,k)=>
      el.classList.toggle('sel',k===i));
    document.getElementById('patch').value=i; };
  const sel=document.getElementById('patch');
  for(let i=0;i<64;i++){ const o=document.createElement('option');
    o.value=i; o.textContent='PATCH '+String(i+1).padStart(2,'0');
    sel.appendChild(o); }
  sel.onchange=()=>recall(sel.value|0);
  const strip=document.getElementById('strip');
  for(let i=0;i<64;i++){ const d=document.createElement('div');
    d.className='patchbtn'; d.title='Patch '+(i+1);
    d.onclick=()=>recall(i); strip.appendChild(d); }
  recall(0);
  const N=256, pL=mod._malloc(N*4), pR=mod._malloc(N*4);
  let ctx=null;
  const power=document.getElementById('power');
  power.disabled=false;
  power.onclick=()=>{ if(ctx) return;
    ctx=new AudioContext({sampleRate:44100});
    const node=ctx.createScriptProcessor(N,0,2);
    node.onaudioprocess=e=>{
      mod.ccall('jx3p_render_dry',null,['number','number','number'],[pL,pR,N]);
      const g=8.0, l=mod.HEAPF32.subarray(pL>>2,(pL>>2)+N),
            r=mod.HEAPF32.subarray(pR>>2,(pR>>2)+N),
            ol=e.outputBuffer.getChannelData(0),
            or2=e.outputBuffer.getChannelData(1);
      for(let i=0;i<N;i++){ ol[i]=g*l[i]; or2[i]=g*r[i]; } };
    node.connect(ctx.destination);
    document.getElementById('led').classList.add('on');
    power.textContent='AUDIO RUNNING';
    lcd('PATCH '+String((sel.value|0)+1).padStart(2,'0')+'  ·  PLAY'); };
  let octave=4; const held=new Set(), els={};
  const on=n=>mod.ccall('jx3p_note_on',null,['number','number'],[n,100]);
  const off=n=>mod.ccall('jx3p_note_off',null,['number'],[n]);
  const paint=()=>{ for(const[n,el] of Object.entries(els))
    el.classList.toggle('on',held.has(+n)); };
  const KM={a:0,w:1,s:2,e:3,d:4,f:5,t:6,g:7,y:8,h:9,u:10,j:11,k:12};
  addEventListener('keydown',e=>{ if(e.repeat) return;
    const k=e.key.toLowerCase();
    if(k==='z'){octave=Math.max(1,octave-1);return;}
    if(k==='x'){octave=Math.min(7,octave+1);return;}
    if(k in KM){ const n=12*octave+KM[k];
      if(!held.has(n)){held.add(n);on(n);paint();} } });
  addEventListener('keyup',e=>{ const k=e.key.toLowerCase();
    if(k in KM){ const n=12*octave+KM[k];
      if(held.has(n)){held.delete(n);off(n);paint();} } });
  const kbd=document.getElementById('kbd');
  const W=[0,2,4,5,7,9,11], BA2={0:1,2:3,5:6,7:8,9:10};
  for(let o=3;o<=5;o++) for(const w of W){
    const n=12*o+w, el=document.createElement('div');
    el.className='wk'; kbd.appendChild(el); els[n]=el;
    el.onpointerdown=()=>{held.add(n);on(n);paint();};
    el.onpointerup=el.onpointerleave=()=>{ if(held.has(n)){held.delete(n);off(n);paint();} };
    if(w in BA2){ const bn=12*o+BA2[w], b2=document.createElement('div');
      b2.className='bk'; el.appendChild(b2); els[bn]=b2;
      b2.onpointerdown=ev=>{ev.stopPropagation();held.add(bn);on(bn);paint();};
      b2.onpointerup=b2.onpointerleave=ev=>{ev.stopPropagation();
        if(held.has(bn)){held.delete(bn);off(bn);paint();} }; } }
})();
</script>
"""
out = HTML.replace("__ENGINE__", JS).replace("__BT__", BT).replace("__BA__", BA).replace("__BB__", BB)
dst = "/tmp/claude-0/-home-user-jn60c99/851980e2-931d-52da-bb74-16fb8562b242/scratchpad/jx3p_port.html"
open(dst, "w").write(out)
print(dst, len(out))
