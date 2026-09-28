import re, uuid
src=open('orig.kicad_sch').read()
lines=src.split('\n')
assert lines[0]=='(kicad_sch'
# split into top-level blocks (depth-1 items start with exactly one tab)
blocks=[];cur=None
for l in lines[1:]:
    if l.startswith('\t(') and not l.startswith('\t\t'):
        if cur: blocks.append(cur)
        cur=[l]
        if l.rstrip().endswith(')') and l.count('(')==l.count(')'): blocks.append(cur); cur=None
    elif l=='\t)' :
        cur.append(l); blocks.append(cur); cur=None
    elif l==')' or l=='':
        pass
    else:
        if cur is None: raise SystemExit('orphan line: %r'%l)
        cur.append(l)
blocks=['\n'.join(b) for b in blocks]
def at(b):
    m=re.search(r'\n\t\t\(at ([\d.\-]+) ([\d.\-]+)',b) or re.search(r'^\t\((?:no_connect|junction)\s*\n?\s*\(at ([\d.\-]+) ([\d.\-]+)',b)
    return (float(m.group(1)),float(m.group(2))) if m else None
def near(p,q): return p and abs(p[0]-q[0])<0.01 and abs(p[1]-q[1])<0.01
removed=[]
out=[]
drop_gnd=[(58.42,168.91),(58.42,179.07),(58.42,189.23)]
drop_nc=[(171.45,96.52),(171.45,99.06),(171.45,101.6)]
drop_lbl=[('A1',(123.19,167.64)),('A2',(123.19,173.99))]
for b in blocks:
    h=b.split('\n')[0]
    p=at(b)
    if h.startswith('\t(global_label "GND"') and any(near(p,q) for q in drop_gnd): removed.append(('GND',p)); continue
    if h.startswith('\t(no_connect') and any(near(p,q) for q in drop_nc): removed.append(('NC',p)); continue
    if any(h.startswith('\t(global_label "%s"'%n) and near(p,q) for n,q in drop_lbl): removed.append((h.strip(),p)); continue
    if h.startswith('\t(symbol') and '(lib_id "Jumper:SolderJumper_3_Open")' in b:
        b=b.replace('(lib_id "Jumper:SolderJumper_3_Open")','(lib_id "Jumper:SolderJumper_2_Open")')
        b=b.replace('(property "Value" "SolderJumper_3_Open"','(property "Value" "SolderJumper_2_Open"')
        b=b.replace('"Jumper:SolderJumper-3_P2.0mm_Open_TrianglePad1.0x1.5mm"','"Jumper:SolderJumper-2_P1.3mm_Open_TrianglePad1.0x1.5mm"')
        b=b.replace('"Solder Jumper, 3-pole, open"','"Solder Jumper, 2-pole, open"')
        b=re.sub(r'\n\t\t\(pin "3"\n\t\t\t\(uuid "[^"]+"\)\n\t\t\)','',b)
        assert '(pin "3"' not in b
    out.append(b)
print('removed',removed); assert len(removed)==8
# new lib symbol
sj2='''		(symbol "Jumper:SolderJumper_2_Open"
			(pin_names
				(offset 0)
				(hide yes)
			)
			(exclude_from_sim yes)
			(in_bom no)
			(on_board yes)
			(in_pos_files yes)
			(duplicate_pin_numbers_are_jumpers no)
			(property "Reference" "JP"
				(at 0 2.032 0)
				(show_name no)
				(do_not_autoplace no)
				(effects
					(font
						(size 1.27 1.27)
					)
				)
			)
			(property "Value" "SolderJumper_2_Open"
				(at 0 -2.54 0)
				(show_name no)
				(do_not_autoplace no)
				(effects
					(font
						(size 1.27 1.27)
					)
				)
			)
			(property "Footprint" ""
				(at 0 0 0)
				(show_name no)
				(do_not_autoplace no)
				(hide yes)
				(effects
					(font
						(size 1.27 1.27)
					)
				)
			)
			(property "Datasheet" ""
				(at 0 0 0)
				(show_name no)
				(do_not_autoplace no)
				(hide yes)
				(effects
					(font
						(size 1.27 1.27)
					)
				)
			)
			(property "Description" "Solder Jumper, 2-pole, open"
				(at 0 0 0)
				(show_name no)
				(do_not_autoplace no)
				(hide yes)
				(effects
					(font
						(size 1.27 1.27)
					)
				)
			)
			(property "ki_keywords" "solder jumper SPST"
				(at 0 0 0)
				(show_name no)
				(do_not_autoplace no)
				(hide yes)
				(effects
					(font
						(size 1.27 1.27)
					)
				)
			)
			(property "ki_fp_filters" "SolderJumper*Open*"
				(at 0 0 0)
				(show_name no)
				(do_not_autoplace no)
				(hide yes)
				(effects
					(font
						(size 1.27 1.27)
					)
				)
			)
			(symbol "SolderJumper_2_Open_0_1"
				(arc
					(start -0.254 1.016)
					(mid -1.2656 0)
					(end -0.254 -1.016)
					(stroke
						(width 0)
						(type default)
					)
					(fill
						(type none)
					)
				)
				(arc
					(start -0.254 1.016)
					(mid -1.2656 0)
					(end -0.254 -1.016)
					(stroke
						(width 0)
						(type default)
					)
					(fill
						(type outline)
					)
				)
				(polyline
					(pts
						(xy -0.254 1.016) (xy -0.254 -1.016)
					)
					(stroke
						(width 0)
						(type default)
					)
					(fill
						(type none)
					)
				)
				(polyline
					(pts
						(xy 0.254 1.016) (xy 0.254 -1.016)
					)
					(stroke
						(width 0)
						(type default)
					)
					(fill
						(type none)
					)
				)
				(arc
					(start 0.254 -1.016)
					(mid 1.2656 0)
					(end 0.254 1.016)
					(stroke
						(width 0)
						(type default)
					)
					(fill
						(type none)
					)
				)
				(arc
					(start 0.254 -1.016)
					(mid 1.2656 0)
					(end 0.254 1.016)
					(stroke
						(width 0)
						(type default)
					)
					(fill
						(type outline)
					)
				)
			)
			(symbol "SolderJumper_2_Open_1_1"
				(pin passive line
					(at -3.81 0 0)
					(length 2.54)
					(name "A"
						(effects
							(font
								(size 1.27 1.27)
							)
						)
					)
					(number "1"
						(effects
							(font
								(size 1.27 1.27)
							)
						)
					)
				)
				(pin passive line
					(at 3.81 0 180)
					(length 2.54)
					(name "B"
						(effects
							(font
								(size 1.27 1.27)
							)
						)
					)
					(number "2"
						(effects
							(font
								(size 1.27 1.27)
							)
						)
					)
				)
			)
			(embedded_fonts no)
		)'''
for i,b in enumerate(out):
    if b.startswith('\t(lib_symbols'):
        assert b.endswith('\n\t)')
        out[i]=b[:-3]+'\n'+sj2+'\n\t)'
        break
def glabel(name,x,y,ang):
    j='left' if ang==0 else 'right'
    w=1.2*len(name)+2.5
    rx=x+w if ang==0 else x-w
    return f'''	(global_label "{name}"
		(shape input)
		(at {x:g} {y:g} {ang})
		(fields_autoplaced yes)
		(effects
			(font
				(size 1.27 1.27)
			)
			(justify {j})
		)
		(uuid "{uuid.uuid4()}")
		(property "Intersheetrefs" "${{INTERSHEET_REFS}}"
			(at {rx:.4f} {y:g} 0)
			(hide yes)
			(show_name no)
			(do_not_autoplace no)
			(effects
				(font
					(size 1.27 1.27)
				)
				(justify {j})
			)
		)
	)'''
new=[]
JP={0:168.91,1:179.07,2:189.23}; D={0:(95.25,177.8),1:(109.22,186.69),2:(125.73,191.77)}; R={0:146.05,1:160.02,2:171.45}
UROW={0:101.6,1:99.06,2:96.52}
for n in range(3):
    A='A%d'%n
    new.append(glabel('SEG_A',63.5-3.81,JP[n],180))          # JP pin1
    new.append(glabel(A+'_J',63.5+3.81,JP[n],0))            # JP pin2
    dx,dy=D[n]
    new.append(glabel(A+'_D',dx-5.08,dy,180))               # D pin1 = K (bar) -> resistor side
    new.append(glabel(A+'_J',dx+5.08,dy,0))                 # D pin2 = A -> jumper side
    new.append(glabel(A+'_D',34.29-5.08,R[n],180))          # R pin1
    new.append(glabel(A,34.29+5.08,R[n],0))                 # R pin2 -> ROW
    new.append(glabel(A,148.59+22.86,UROW[n],0))            # U1 ROW pin
# insert new labels after last global_label
last=max(i for i,b in enumerate(out) if b.startswith('\t(global_label'))
out[last+1:last+1]=new
open('SegmentBackpack.kicad_sch','w').write('(kicad_sch\n'+'\n'.join(out)+'\n)\n')
