/* gfx -- 128x32 1-bit framebuffer, SSD1306 page layout (4 pages x 128 bytes,
 * bit 0 = top row of the page). Portable C: firmware and host frame tests. */
#ifndef MSQ_GFX_H
#define MSQ_GFX_H
#include <stdint.h>

#define GFX_W 128
#define GFX_H 32

typedef struct { uint8_t px[GFX_W * GFX_H / 8]; } gfx_fb;

void gfx_clear(gfx_fb *f);
void gfx_pixel(gfx_fb *f, int x, int y, int on);         /* on: 1 set, 0 clear, 2 invert */
int  gfx_get(const gfx_fb *f, int x, int y);
void gfx_hline(gfx_fb *f, int x0, int x1, int y, int on);
void gfx_vline(gfx_fb *f, int x, int y0, int y1, int on);
void gfx_line(gfx_fb *f, int x0, int y0, int x1, int y1, int on);
void gfx_rect(gfx_fb *f, int x, int y, int w, int h, int on);
void gfx_fill(gfx_fb *f, int x, int y, int w, int h, int on);
void gfx_rfill(gfx_fb *f, int x, int y, int w, int h, int on);  /* rounded corners */
/* 5x7 font, 6 px advance. Upper-case, digits, . - % : < > / + # and space. */
int  gfx_text(gfx_fb *f, int x, int y, const char *s, int on);
int  gfx_text_w(const char *s);
/* The same font at 2x, smoothed (EPX), 12 px advance, 14 px tall. */
int  gfx_text2(gfx_fb *f, int x, int y, const char *s, int on);
int  gfx_text2_w(const char *s);
#endif
