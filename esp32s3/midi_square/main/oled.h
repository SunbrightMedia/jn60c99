/* oled -- SSD1306 128x32 over I2C (new i2c_master driver). */
#ifndef MSQ_OLED_H
#define MSQ_OLED_H
#include <stdint.h>
#include "gfx.h"
int  oled_init(int sda, int scl);          /* 0x3C then 0x3D; returns the address, or 0 = not found */
int  oled_flush(const gfx_fb *f);         /* 1 ok */
void oled_contrast(uint8_t c);
uint32_t oled_errors(void);
#endif
