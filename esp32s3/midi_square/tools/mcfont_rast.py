from fontTools.ttLib import TTFont
from fontTools.pens.recordingPen import RecordingPen
f=TTFont('Minecraft.otf'); gs=f.getGlyphSet(); cmap=f.getBestCmap()
def polys(ch):
    p=RecordingPen(); gs[cmap[ord(ch)]].draw(p)
    out=[]; cur=[]
    for op,args in p.value:
        if op=='moveTo': cur=[args[0]]
        elif op=='lineTo': cur.append(args[0])
        elif op in('closePath','endPath'): out.append(cur); cur=[]
        else: raise Exception(op)
    return out
def inside(pt,polys):
    x,y=pt; c=False
    for poly in polys:
        n=len(poly)
        for i in range(n):
            (x1,y1),(x2,y2)=poly[i],poly[(i+1)%n]
            if (y1>y)!=(y2>y) and x < x1+(y-y1)*(x2-x1)/(y2-y1): c=not c
    return c
def glyph(ch):
    P=polys(ch); xs=[x for p in P for x,_ in p]
    if not xs: return [], gs[cmap[ord(ch)]].width
    cols=[]
    for i in range(0,8):
        col=0
        for j in range(8):          # row 0 = top (y 13), row 7 = y -1 (descender)
            y=13-2*j
            if inside((2*i+1,y),P): col|=1<<j
        cols.append(col)
    while cols and cols[-1]==0: cols.pop()
    return cols, gs[cmap[ord(ch)]].width
if __name__=='__main__':
    for ch in "AHgyi.|MW@t":
        c,w=glyph(ch); print(ch,w,[hex(x) for x in c])
        for j in range(8): print(''.join('#' if (x>>j)&1 else '.' for x in c))
