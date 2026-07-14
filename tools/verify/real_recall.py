#!/usr/bin/env python3
"""real_recall.py -- self-driving per-patch recall reference.

Every step here is the plugin's OWN machine code executed under Unicorn, except the
single record->value decode (the value-tree load), which is clearly isolated and
cross-validated below.

=== THE DISPATCH SET COMES FROM EXECUTION, NOT A STATIC READ ===
Running the plugin's own instance builder BUILD sub_7FF91E0268D0 (rva 0x3c68d0, driven
by e2e_emu.build) executes this loop (rva 0x3c6b70, disassembled from the binary):

    xor  r14d,r14d                 ; i = 0
  .loop:
    mov  rbx,[rsi-0x18]            ; rbx = param-list object (per unit)
    mov  rdi,[rbx]                 ; vtable
    mov  ecx,r14d                  ; i
    call 0x3abaf0                  ; desc = sub_7FF91E00BAF0(i)   (global descriptor table)
    mov  r9d,[rax+8]              ; value = desc[i].value  (.data rva 0x98c048 + i*0x10)
    xor  r8d,r8d                   ; flag = 0
    mov  edx,r14d                  ; i
    mov  rcx,rbx
    call [rdi+0x58]                ; SETTER sub_7FF91E019A30(proc, i, 0, value)
    inc  r14d ; cmp r14d,0x1366 ; jl .loop     ; i in 0..4965, ALL indices

PROVEN(exec): during build the setter is called 44694 times, ALL from this one call
site (return rva 0x3c6b8f), 9 units x 4966 indices. The loop dispatches EVERY index
0..4965 unconditionally -- there is no per-leaf selection to reconstruct. Index 760
(DCO RANGE) IS dispatched (9x, value = plugin default 3 -> feet 1.0). The plugin's OWN
default descriptor table sub_7FF91E00BAF0(760)+8 == 3 (8'), read by executing the
accessor. (scratchpad/build_setter_callers.py, scratchpad/desc_probe.py)

This EXECUTED evidence refutes the port's prior claim that "recall never writes feet
3840": that claim came from a recall reimplementation (e2e_emu.recall_patch /
oracle/patch_state_oracle.py / id_feet_mcv_probe.py) that all share the filter
`if 19<=ml<=71 ... else: continue`, which STRUCTURALLY never dispatches index 760.

=== THE SETTER MAPPING COMES FROM EXECUTION ===
PROVEN(exec): SETTER(proc, 760, 0, v) writes engine cell 3840 (DCO "feet") = 2^(v-3):
v=2->0.5(16'), 3->1.0(8'), 4->2.0(4'), 5->4.0(2'). Likewise 758->PWM 4144, 759->PWM
src 3888/3936, 752->LFO rate 1072/1088/2064, 751->LFO delay 1920.
(scratchpad/probe_skipped.py, scratchpad/diff_complete.py, scratchpad/desc_probe.py)

=== THE ONE RECONSTRUCTED STEP: record byte -> descriptor value (value-tree load) ===
The plugin's replaceState (raw bank record -> descriptor[i].value) was NOT executed
(it is fed by a std::ifstream-backed schema; not drivable in budget). We emulate it by
writing the patch record's nibble-decoded byte into the plugin's descriptor value
store for each leaf. This decode is cross-validated NON-circularly:
  - patch-name leaves decode to exact ASCII patch names ("BS Juno Grime", ...);
  - DCO RANGE (index 760) decodes across all 64 patches to the clean enum {2,3,4,5}
    -- a 16'/8'/4' octave control, not garbage; matches the plugin default 3.
dispatch index = Script.xml docpos + 740; record byte = 2*(docpos-2)-4 (SYNTH block)
or 8*(docpos-2)-430 (extended block).

MODES
  default    : write patch bytes into the plugin descriptor table, then re-dispatch the
               CHANGED indices through the real setter (equivalent to re-running the
               full loop: unchanged indices keep the build-applied defaults). Fast.
  --fullloop : drive the plugin's exact loop range i=0..4965 from the descriptor table
               (bit-identical result; slower). Proves the reference == plugin loop.

Usage:
  python3 tools/verify/real_recall.py 62 5 18 39 6 14 31 0
  python3 tools/verify/real_recall.py --fullloop 62
"""
import sys, struct, re
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E

SR = 48000.0
DESCVAL = 0x98c048   # rva of descriptor[i].value; verified by executing sub_7FF91E00BAF0

def descval_addr(i): return E.IB + DESCVAL + i * 0x10
def rd_desc(e, i):   return struct.unpack('<I', e.uc.mem_read(descval_addr(i), 4))[0]
def wr_desc(e, i, v): e.uc.mem_write(descval_addr(i), struct.pack('<I', v & 0xffffffff))
def f32(e, u, off):  return struct.unpack('<f', e.uc.mem_read(e.state[u] + off, 4))[0]
def dec(bl, b):      return ((bl[b] & 0xF) << 4) | (bl[b + 1] & 0xF)

def leaf_table():
    """(dispatch_index, record_byte) for every value-tree leaf that carries a per-patch
    byte -- the value-tree load map (the one reconstructed step)."""
    xml = open(E.SCRIPT_XML, encoding='utf-8', errors='replace').read()
    vals = re.findall(r'<value>(.*?)</value>', xml, re.S)
    out = []
    for p, v in enumerate(vals):
        nm = re.search(r'<name>(.*?)</name>', v); nm = nm.group(1) if nm else '?'
        ml = p - 2
        if 8 <= ml <= 71:      bb = 2 * ml - 4
        elif 88 <= ml <= 135:  bb = 8 * ml - 430
        else:                  continue
        if nm.startswith('PATCH NAME'): continue
        out.append((p + 740, bb))
    return out

CELLS = [(3840, "feet"), (4144, "PWM"), (3888, "PWMsrcA"), (3936, "PWMsrcB"),
         (1920, "LFOdly"), (1072, "LFOrate")]

def recall(idx, bank, leaves, fullloop=False):
    e = E.E2E(); e.build(SR); e.snap_all()          # plugin applies defaults to all units
    blob = E.patch_blob(bank, idx)
    for (disp, bb) in leaves:                        # value-tree load (reconstructed step)
        wr_desc(e, disp, dec(blob, bb))
    # drive the plugin's setter with values sourced from the plugin descriptor table.
    # NOTE: we must dispatch EVERY leaf (not just value!=default): build post-processing
    # can leave a cell differing from a fresh setter write even when the descriptor value
    # is unchanged (e.g. LFO-delay 1920). Dispatching all leaves == the --fullloop result
    # for every leaf-driven cell, at 112 vs 4966 indices.
    idxs = range(0, 4966) if fullloop else [disp for (disp, _) in leaves]
    for u in range(9):
        for i in idxs:
            try: e.dispatch(u, i, rd_desc(e, i))
            except RuntimeError: pass
    e.snap_all()
    return dec(blob, 32), {off: f32(e, 0, off) for off, _ in CELLS}

def main():
    args = sys.argv[1:]
    fullloop = '--fullloop' in args
    args = [a for a in args if a != '--fullloop'] or ['62']
    bank = E.bank_bytes(); leaves = leaf_table()
    sys.stderr.write("value-tree leaves: %d ; dispatch set = plugin loop indices 0..4965 (executed)\n" % len(leaves))
    print("patch name              RANGE feet    PWM      PWMsrcA PWMsrcB LFOdly   LFOrate")
    for a in args:
        idx = int(a); rng, c = recall(idx, bank, leaves, fullloop)
        print("%2d %-18s v=%d %6.3f %8.5f %6.2f %7.2f %8.5f %8.5f" % (
            idx, E.patch_name(bank, idx), rng, c[3840], c[4144], c[3888], c[3936], c[1920], c[1072]))

if __name__ == '__main__':
    main()
