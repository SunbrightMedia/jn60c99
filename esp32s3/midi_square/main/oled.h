/* oled -- SSD1306 128x32 over I2C (new i2c_master driver). */
#ifndef MSQ_OLED_H
#define MSQ_OLED_H
#include <stdint.h>
#include "gfx.h"
int  oled_init(int sda, int scl);          /* 0x3C then 0x3D; returns the address, or 0 = not found */
int  oled_flush(const gfx_fb *f);         /* 1 ok */
/* Brightness: contrast (0x81), pre-charge (0xD9), VCOMH (0xDB). Sent only on
 * change; re-sent by oled_heal. */
#define OLED_CONTRAST_FULL 0x8F                /* the v1-v6 brightness */
void oled_dim_regs(uint8_t contrast, uint8_t precharge, uint8_t vcomh);
/* Call every ~2 s from the display task: re-sends the init (never DISPLAY OFF,
 * so no flicker) and the contrast; attaches a display that was absent at boot.
 * Returns 2 when a display was newly found. */
int  oled_heal(void);
int  oled_tries(void);                        /* probe attempts used at boot */
uint32_t oled_errors(void);
#endif
