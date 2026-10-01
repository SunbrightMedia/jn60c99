#include "gfx.h"
#include <string.h>
#include <stdlib.h>

void gfx_clear(gfx_fb *f) { memset(f->px, 0, sizeof f->px); }

void gfx_pixel(gfx_fb *f, int x, int y, int on)
{
    if ((unsigned)x >= GFX_W || (unsigned)y >= GFX_H) return;
    uint8_t *b = &f->px[(y >> 3) * GFX_W + x], m = (uint8_t)(1u << (y & 7));
    if (on == 2) *b ^= m; else if (on) *b |= m; else *b &= (uint8_t)~m;
}

int gfx_get(const gfx_fb *f, int x, int y)
{
    if ((unsigned)x >= GFX_W || (unsigned)y >= GFX_H) return 0;
    return (f->px[(y >> 3) * GFX_W + x] >> (y & 7)) & 1;
}

void gfx_hline(gfx_fb *f, int x0, int x1, int y, int on)
{ if (x0 > x1) { int t = x0; x0 = x1; x1 = t; } for (int x = x0; x <= x1; ++x) gfx_pixel(f, x, y, on); }
void gfx_vline(gfx_fb *f, int x, int y0, int y1, int on)
{ if (y0 > y1) { int t = y0; y0 = y1; y1 = t; } for (int y = y0; y <= y1; ++y) gfx_pixel(f, x, y, on); }

void gfx_line(gfx_fb *f, int x0, int y0, int x1, int y1, int on)
{
    int dx = abs(x1 - x0), sx = x0 < x1 ? 1 : -1, dy = -abs(y1 - y0), sy = y0 < y1 ? 1 : -1, e = dx + dy;
    for (;;) {
        gfx_pixel(f, x0, y0, on);
        if (x0 == x1 && y0 == y1) break;
        int e2 = 2 * e;
        if (e2 >= dy) { e += dy; x0 += sx; }
        if (e2 <= dx) { e += dx; y0 += sy; }
    }
}

void gfx_rect(gfx_fb *f, int x, int y, int w, int h, int on)
{
    if (w <= 0 || h <= 0) return;
    gfx_hline(f, x, x + w - 1, y, on); gfx_hline(f, x, x + w - 1, y + h - 1, on);
    gfx_vline(f, x, y, y + h - 1, on); gfx_vline(f, x + w - 1, y, y + h - 1, on);
}

void gfx_fill(gfx_fb *f, int x, int y, int w, int h, int on)
{ for (int j = 0; j < h; ++j) for (int i = 0; i < w; ++i) gfx_pixel(f, x + i, y + j, on); }

void gfx_rfill(gfx_fb *f, int x, int y, int w, int h, int on)
{
    gfx_fill(f, x, y, w, h, on);
    if (w > 2 && h > 2) {                       /* knock the four corners back */
        int off = on == 2 ? 2 : !on;
        gfx_pixel(f, x, y, off); gfx_pixel(f, x + w - 1, y, off);
        gfx_pixel(f, x, y + h - 1, off); gfx_pixel(f, x + w - 1, y + h - 1, off);
    }
}

#ifndef MSQ_FONT_MC
/* 5x7 (+1 descender row), column bytes, bit 0 = top. */
static const struct { char c; uint8_t col[5]; } FONT[] = {
    {' ',{0x00,0x00,0x00,0x00,0x00}}, {'.',{0x00,0x60,0x60,0x00,0x00}},
    {'-',{0x08,0x08,0x08,0x08,0x08}}, {'%',{0x23,0x13,0x08,0x64,0x62}},
    {':',{0x00,0x36,0x36,0x00,0x00}}, {'<',{0x08,0x14,0x22,0x41,0x00}},
    {'>',{0x00,0x41,0x22,0x14,0x08}}, {'/',{0x20,0x10,0x08,0x04,0x02}},
    {'+',{0x08,0x08,0x3E,0x08,0x08}}, {'#',{0x14,0x7F,0x14,0x7F,0x14}},
    {'0',{0x3E,0x51,0x49,0x45,0x3E}}, {'1',{0x00,0x42,0x7F,0x40,0x00}},
    {'2',{0x42,0x61,0x51,0x49,0x46}}, {'3',{0x21,0x41,0x45,0x4B,0x31}},
    {'4',{0x18,0x14,0x12,0x7F,0x10}}, {'5',{0x27,0x45,0x45,0x45,0x39}},
    {'6',{0x3C,0x4A,0x49,0x49,0x30}}, {'7',{0x01,0x71,0x09,0x05,0x03}},
    {'8',{0x36,0x49,0x49,0x49,0x36}}, {'9',{0x06,0x49,0x49,0x29,0x1E}},
    {'A',{0x7E,0x11,0x11,0x11,0x7E}}, {'B',{0x7F,0x49,0x49,0x49,0x36}},
    {'C',{0x3E,0x41,0x41,0x41,0x22}}, {'D',{0x7F,0x41,0x41,0x22,0x1C}},
    {'E',{0x7F,0x49,0x49,0x49,0x41}}, {'F',{0x7F,0x09,0x09,0x09,0x01}},
    {'G',{0x3E,0x41,0x49,0x49,0x7A}}, {'H',{0x7F,0x08,0x08,0x08,0x7F}},
    {'I',{0x00,0x41,0x7F,0x41,0x00}}, {'J',{0x20,0x40,0x41,0x3F,0x01}},
    {'K',{0x7F,0x08,0x14,0x22,0x41}}, {'L',{0x7F,0x40,0x40,0x40,0x40}},
    {'M',{0x7F,0x02,0x0C,0x02,0x7F}}, {'N',{0x7F,0x04,0x08,0x10,0x7F}},
    {'O',{0x3E,0x41,0x41,0x41,0x3E}}, {'P',{0x7F,0x09,0x09,0x09,0x06}},
    {'Q',{0x3E,0x41,0x51,0x21,0x5E}}, {'R',{0x7F,0x09,0x19,0x29,0x46}},
    {'S',{0x46,0x49,0x49,0x49,0x31}}, {'T',{0x01,0x01,0x7F,0x01,0x01}},
    {'U',{0x3F,0x40,0x40,0x40,0x3F}}, {'V',{0x1F,0x20,0x40,0x20,0x1F}},
    {'W',{0x3F,0x40,0x38,0x40,0x3F}}, {'X',{0x63,0x14,0x08,0x14,0x63}},
    {'Y',{0x07,0x08,0x70,0x08,0x07}}, {'Z',{0x61,0x51,0x49,0x45,0x43}},
    /* lower case (the classic 5x7 set; g j p q y use an 8th row, the descender) */
    {'a',{0x20,0x54,0x54,0x54,0x78}}, {'b',{0x7F,0x48,0x44,0x44,0x38}},
    {'c',{0x38,0x44,0x44,0x44,0x20}}, {'d',{0x38,0x44,0x44,0x48,0x7F}},
    {'e',{0x38,0x54,0x54,0x54,0x18}}, {'f',{0x08,0x7E,0x09,0x01,0x02}},
    {'g',{0x18,0xA4,0xA4,0xA4,0x7C}}, {'h',{0x7F,0x08,0x04,0x04,0x78}},
    {'i',{0x00,0x44,0x7D,0x40,0x00}}, {'j',{0x40,0x80,0x84,0x7D,0x00}},
    {'k',{0x7F,0x10,0x28,0x44,0x00}}, {'l',{0x00,0x41,0x7F,0x40,0x00}},
    {'m',{0x7C,0x04,0x18,0x04,0x78}}, {'n',{0x7C,0x08,0x04,0x04,0x78}},
    {'o',{0x38,0x44,0x44,0x44,0x38}}, {'p',{0xFC,0x24,0x24,0x24,0x18}},
    {'q',{0x18,0x24,0x24,0x18,0xFC}}, {'r',{0x7C,0x08,0x04,0x04,0x08}},
    {'s',{0x48,0x54,0x54,0x54,0x20}}, {'t',{0x04,0x3F,0x44,0x40,0x20}},
    {'u',{0x3C,0x40,0x40,0x20,0x7C}}, {'v',{0x1C,0x20,0x40,0x20,0x1C}},
    {'w',{0x3C,0x40,0x30,0x40,0x3C}}, {'x',{0x44,0x28,0x10,0x28,0x44}},
    {'y',{0x1C,0xA0,0xA0,0xA0,0x7C}}, {'z',{0x44,0x64,0x54,0x4C,0x44}},
};

#endif

#ifdef MSQ_FONT_MC
/* THE MINECRAFT FONT (PROPOSED, opt-in until the user approves: -DMSQ_FONT_MC): proportional, 7 rows + 1 descender
 * row, generated exactly from the font's outlines (gen/font_mc.h). Big text is
 * plain 2x pixel doubling -- blocky on purpose, which is the look. */
#include "gen/font_mc.h"
static const uint8_t *glyph_w(char c, int *w)
{
    if (c < MC_FONT_FIRST || c > MC_FONT_LAST) c = '?';
    *w = MC_FONT[c - MC_FONT_FIRST].w;
    return MC_FONT[c - MC_FONT_FIRST].col;
}
static int gbit(const uint8_t *g, int w, int x, int y)
{ return (x < 0 || x >= w || y < 0 || y > 7) ? 0 : (g[x] >> y) & 1; }

int gfx_text(gfx_fb *f, int x, int y, const char *s, int on)
{
    for (; *s; ++s) {
        int w; const uint8_t *g = glyph_w(*s, &w);
        for (int i = 0; i < w; ++i) for (int j = 0; j < 8; ++j) if (gbit(g, w, i, j)) gfx_pixel(f, x + i, y + j, on);
        x += w + 1;
    }
    return x;
}
int gfx_text_w(const char *s)
{
    int n = 0, w;
    for (; *s; ++s) { glyph_w(*s, &w); n += w + 1; }
    return n ? n - 1 : 0;
}
int gfx_text2(gfx_fb *f, int x, int y, const char *s, int on)
{
    for (; *s; ++s) {
        int w; const uint8_t *g = glyph_w(*s, &w);
        for (int i = 0; i < w; ++i) for (int j = 0; j < 8; ++j) if (gbit(g, w, i, j)) {
            gfx_pixel(f, x + 2 * i, y + 2 * j, on);     gfx_pixel(f, x + 2 * i + 1, y + 2 * j, on);
            gfx_pixel(f, x + 2 * i, y + 2 * j + 1, on); gfx_pixel(f, x + 2 * i + 1, y + 2 * j + 1, on);
        }
        x += 2 * (w + 1);
    }
    return x;
}
int gfx_text2_w(const char *s) { int n = gfx_text_w(s); return n ? 2 * n : 0; }
#else
static const uint8_t *glyph(char c)
{
    for (unsigned i = 0; i < sizeof FONT / sizeof FONT[0]; ++i) if (FONT[i].c == c) return FONT[i].col;
    if (c >= 'a' && c <= 'z') c = (char)(c - 32);
    for (unsigned i = 0; i < sizeof FONT / sizeof FONT[0]; ++i) if (FONT[i].c == c) return FONT[i].col;
    return FONT[0].col;
}

static int gbit(const uint8_t *g, int x, int y)
{ return (x < 0 || x > 4 || y < 0 || y > 7) ? 0 : (g[x] >> y) & 1; }

int gfx_text(gfx_fb *f, int x, int y, const char *s, int on)
{
    for (; *s; ++s, x += 6) {
        const uint8_t *g = glyph(*s);
        for (int i = 0; i < 5; ++i) for (int j = 0; j < 8; ++j) if (gbit(g, i, j)) gfx_pixel(f, x + i, y + j, on);
    }
    return x;
}
int gfx_text_w(const char *s) { int n = (int)strlen(s); return n ? n * 6 - 1 : 0; }

/* EPX / Scale2x: each source pixel P becomes 2x2; a corner takes the value of
 * its two orthogonal neighbours when they agree and differ from the others. */
int gfx_text2(gfx_fb *f, int x, int y, const char *s, int on)
{
    for (; *s; ++s, x += 12) {
        const uint8_t *g = glyph(*s);
        for (int i = 0; i < 5; ++i) for (int j = 0; j < 8; ++j) {
            int P = gbit(g, i, j), A = gbit(g, i, j - 1), B = gbit(g, i + 1, j),
                C = gbit(g, i - 1, j), D = gbit(g, i, j + 1);
            int e0 = P, e1 = P, e2 = P, e3 = P;
            if (C == A && C != D && A != B) e0 = A;
            if (A == B && A != C && B != D) e1 = B;
            if (D == C && D != B && C != A) e2 = C;
            if (B == D && B != A && D != C) e3 = D;
            int px = x + 2 * i, py = y + 2 * j;
            if (e0) gfx_pixel(f, px, py, on);
            if (e1) gfx_pixel(f, px + 1, py, on);
            if (e2) gfx_pixel(f, px, py + 1, on);
            if (e3) gfx_pixel(f, px + 1, py + 1, on);
        }
    }
    return x;
}
int gfx_text2_w(const char *s) { int n = (int)strlen(s); return n ? n * 12 - 2 : 0; }
#endif
