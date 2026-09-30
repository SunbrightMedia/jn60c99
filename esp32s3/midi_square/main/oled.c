#include "oled.h"
#include <string.h>
#include "driver/i2c_master.h"

static i2c_master_bus_handle_t bus;
static i2c_master_dev_handle_t dev;
static uint32_t errs;
static uint8_t txbuf[1 + GFX_W * GFX_H / 8];

static int cmds(const uint8_t *c, int n)
{
    uint8_t b[32];
    b[0] = 0x00;                                   /* control byte: commands follow */
    memcpy(b + 1, c, n);
    if (i2c_master_transmit(dev, b, n + 1, 50) != ESP_OK) { errs++; return 0; }
    return 1;
}

int oled_init(int sda, int scl)
{
    i2c_master_bus_config_t bc = {
        .i2c_port = -1, .sda_io_num = sda, .scl_io_num = scl,
        .clk_source = I2C_CLK_SRC_DEFAULT, .glitch_ignore_cnt = 7,
        .flags.enable_internal_pullup = true,     /* modules carry their own; this is backup */
    };
    if (i2c_new_master_bus(&bc, &bus) != ESP_OK) return 0;
    int addr = 0;
    if (i2c_master_probe(bus, 0x3C, 50) == ESP_OK) addr = 0x3C;
    else if (i2c_master_probe(bus, 0x3D, 50) == ESP_OK) addr = 0x3D;
    if (!addr) return 0;
    i2c_device_config_t dc = { .dev_addr_length = I2C_ADDR_BIT_LEN_7, .device_address = addr, .scl_speed_hz = 400000 };
    if (i2c_master_bus_add_device(bus, &dc, &dev) != ESP_OK) return 0;
    static const uint8_t init[] = {
        0xAE, 0xD5, 0x80, 0xA8, 0x1F, 0xD3, 0x00, 0x40, 0x8D, 0x14, 0x20, 0x00,
        0xA1, 0xC8, 0xDA, 0x02, 0x81, 0x8F, 0xD9, 0xF1, 0xDB, 0x40, 0x2E, 0xA4, 0xA6, 0xAF,
    };
    if (!cmds(init, sizeof init)) return 0;
    return addr;
}

void oled_contrast(uint8_t c) { uint8_t b[2] = { 0x81, c }; if (dev) cmds(b, 2); }

int oled_flush(const gfx_fb *f)
{
    if (!dev) return 0;
    static const uint8_t win[] = { 0x21, 0x00, 0x7F, 0x22, 0x00, 0x03 };
    if (!cmds(win, sizeof win)) return 0;
    txbuf[0] = 0x40;                               /* control byte: data follows */
    memcpy(txbuf + 1, f->px, sizeof f->px);
    if (i2c_master_transmit(dev, txbuf, sizeof txbuf, 100) != ESP_OK) { errs++; return 0; }
    return 1;
}

uint32_t oled_errors(void) { return errs; }
