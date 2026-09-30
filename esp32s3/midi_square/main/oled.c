#include "oled.h"
#include <string.h>
#include "driver/i2c_master.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_timer.h"
#include "esp_log.h"

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

/* THE DISPLAY SOMETIMES STAYED DARK AT POWER-ON (user, v6). At a cold plug
 * the S3 boots in ~300 ms and the SSD1306 module's own reset and charge pump
 * may not be ready; one failed probe left the screen dark for the whole
 * session. Now: wait until 150 ms after boot, then up to 10 tries over ~1.5 s,
 * with a bus reset (9 SCL pulses, frees an SDA held low) before each retry.
 * The init sequence is also re-sent every 2 s by oled_heal(), so a display
 * that browned out or reset later comes back on its own. */
static const uint8_t INIT[] = {
    0xAE, 0xD5, 0x80, 0xA8, 0x1F, 0xD3, 0x00, 0x40, 0x8D, 0x14, 0x20, 0x00,
    0xA1, 0xC8, 0xDA, 0x02, 0x81, 0x8F, 0xD9, 0xF1, 0xDB, 0x40, 0x2E, 0xA4, 0xA6, 0xAF,
};
static int bus_ok, addr_found, tries;
static uint8_t contrast = OLED_CONTRAST_FULL, precharge = 0xF1, vcomh = 0x40;

static int try_attach(void)
{
    int addr = 0;
    if (i2c_master_probe(bus, 0x3C, 20) == ESP_OK) addr = 0x3C;
    else if (i2c_master_probe(bus, 0x3D, 20) == ESP_OK) addr = 0x3D;
    if (!addr) return 0;
    i2c_device_config_t dc = { .dev_addr_length = I2C_ADDR_BIT_LEN_7, .device_address = addr, .scl_speed_hz = 400000 };
    if (i2c_master_bus_add_device(bus, &dc, &dev) != ESP_OK) { dev = NULL; return 0; }
    if (!cmds(INIT, sizeof INIT)) { i2c_master_bus_rm_device(dev); dev = NULL; return 0; }
    uint8_t c[6] = { 0x81, contrast, 0xD9, precharge, 0xDB, vcomh };
    cmds(c, 6);
    addr_found = addr;
    return addr;
}

int oled_init(int sda, int scl)
{
    i2c_master_bus_config_t bc = {
        .i2c_port = -1, .sda_io_num = sda, .scl_io_num = scl,
        .clk_source = I2C_CLK_SRC_DEFAULT, .glitch_ignore_cnt = 7,
        .flags.enable_internal_pullup = true,     /* modules carry their own; this is backup */
    };
    if (i2c_new_master_bus(&bc, &bus) != ESP_OK) return 0;
    bus_ok = 1;
    int64_t t = esp_timer_get_time();
    if (t < 150000) vTaskDelay(pdMS_TO_TICKS((150000 - t) / 1000 + 1));
    esp_log_level_set("i2c.master", ESP_LOG_NONE);   /* a missed probe is expected here, and counted */
    for (tries = 1; tries <= 10; ++tries) {
        if (try_attach()) return addr_found;
        i2c_master_bus_reset(bus);
        vTaskDelay(pdMS_TO_TICKS(100));
    }
    tries = 10;
    return 0;
}

int oled_tries(void) { return tries; }

int oled_heal(void)
{
    if (!bus_ok) return 0;
    if (!dev) {                                    /* not found at boot: keep looking */
        if (try_attach()) return 2;
        i2c_master_bus_reset(bus);
        return 0;
    }
    /* all but DISPLAY OFF, and the CURRENT dim registers in place of the full
     * ones: no flicker, no flash while dimmed. Command bytes only (the scan
     * steps over each command's argument). */
    uint8_t seq[sizeof INIT - 1];
    memcpy(seq, INIT + 1, sizeof seq);
    for (unsigned i = 0; i + 1 < sizeof seq; ++i) {
        if (seq[i] == 0x81) seq[i + 1] = contrast;
        else if (seq[i] == 0xD9) seq[i + 1] = precharge;
        else if (seq[i] == 0xDB) seq[i + 1] = vcomh;
        else continue;
        ++i;
    }
    if (!cmds(seq, sizeof seq)) {
        i2c_master_bus_reset(bus);
        return 0;
    }
    return 1;
}

void oled_dim_regs(uint8_t c, uint8_t pre, uint8_t vc)
{
    uint8_t b[6]; int n = 0;
    if (c != contrast)  { b[n++] = 0x81; b[n++] = c; }
    if (pre != precharge) { b[n++] = 0xD9; b[n++] = pre; }
    if (vc != vcomh)    { b[n++] = 0xDB; b[n++] = vc; }
    contrast = c; precharge = pre; vcomh = vc;
    if (n && dev) cmds(b, n);
}

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
