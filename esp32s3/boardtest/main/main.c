/* BOARD TEST -- see ../CMakeLists.txt and ../README.md.
 * I2S pins = the ESP32-S3_Motherboard v1.0 fab netlist: H1A1 pads 5/6/7
 * (DevKitC-1 J1: GPIO 5/6/7) -> AUDIO 4-pin JST -> Headphone_Dac J16 -> PCM5102A.
 * Log: one BT line per stage (frames written, peaks of what was written), one
 * BT-LOOP line per loop (the I2S clock rate the writes measured). */
#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/i2s_std.h"
#include "esp_timer.h"
#include "tone.h"

#define PIN_BCK  5
#define PIN_WS   6
#define PIN_SD   7
#define BLOCK    256

static i2s_chan_handle_t TX;

#ifdef BT_QEMU
/* QEMU has no I2S: a block "plays" in its real time. Built only by test/qemu.sh. */
static int write_block(const int16_t *b, size_t bytes, size_t *w)
{
    static int64_t start; static uint64_t sent;          /* pace to the sample clock on average */
    (void)b;
    if (!start) start = esp_timer_get_time();
    sent += BLOCK;
    while (esp_timer_get_time() < start + (int64_t)(sent * 1000000 / BT_SR)) vTaskDelay(1);
    *w = bytes; return 0;
}
static int i2s_start(void) { return 1; }
#else
static int write_block(const int16_t *b, size_t bytes, size_t *w)
{
    return i2s_channel_write(TX, b, bytes, w, 1000) != ESP_OK;
}
static int i2s_start(void)
{
    i2s_chan_config_t cc = I2S_CHANNEL_DEFAULT_CONFIG(I2S_NUM_AUTO, I2S_ROLE_MASTER);
    cc.dma_desc_num = 8;
    cc.dma_frame_num = 512;
    cc.auto_clear = true;
    i2s_std_config_t sc = {
        .clk_cfg  = I2S_STD_CLK_DEFAULT_CONFIG(BT_SR),
        .slot_cfg = I2S_STD_PHILIPS_SLOT_DEFAULT_CONFIG(I2S_DATA_BIT_WIDTH_16BIT, I2S_SLOT_MODE_STEREO),
        .gpio_cfg = { .mclk = I2S_GPIO_UNUSED, .bclk = PIN_BCK, .ws = PIN_WS,
                      .dout = PIN_SD, .din = I2S_GPIO_UNUSED },
    };
    if (i2s_new_channel(&cc, &TX, NULL) != ESP_OK) return 0;
    if (i2s_channel_init_std_mode(TX, &sc) != ESP_OK) return 0;
    return i2s_channel_enable(TX) == ESP_OK;
}
#endif

static void audio_task(void *arg)
{
    static int16_t buf[2 * BLOCK];
    bt_tone t;
    bt_tone_init(&t);
    int peakL = 0, peakR = 0, loop = 0, errs = 0;
    uint32_t sframes = 0, lframes = 0;
    int64_t t0 = esp_timer_get_time();
    for (;;) {
        int ended = -1, endpos = BLOCK;
        int hit = bt_tone_render(&t, buf, BLOCK, &ended, &endpos);
        for (int i = 0; i < BLOCK; ++i) {
            if (hit && i == endpos) {
                printf("BT stage=%-11s frames=%6lu peakL=%5d peakR=%5d\n", bt_stage_name[ended],
                       (unsigned long)sframes, peakL, peakR);
                peakL = peakR = 0; sframes = 0;
                if (ended == BT_NSTAGE - 1) {
                    int64_t t1 = esp_timer_get_time();
                    ++loop;
                    printf("BT-LOOP %d  frames=%lu  %.3f s  rate=%.0f Hz (want %d)  i2s_errors=%d  %s\n",
                           loop, (unsigned long)lframes, (t1 - t0) / 1e6, lframes * 1e6 / (double)(t1 - t0),
                           BT_SR, errs, loop == 1 ? "(loop 1 includes the DMA fill)" : "");
                    t0 = t1; lframes = 0;
                }
            }
            int l = buf[2 * i] < 0 ? -buf[2 * i] : buf[2 * i];
            int r = buf[2 * i + 1] < 0 ? -buf[2 * i + 1] : buf[2 * i + 1];
            if (l > peakL) peakL = l;
            if (r > peakR) peakR = r;
            ++sframes; ++lframes;
        }
        size_t w = 0;
        if (write_block(buf, sizeof buf, &w) || w != sizeof buf) ++errs;
    }
}

void app_main(void)
{
    printf("\n=== BOARD TEST v1 (no synth) -- I2S BCK=GPIO%d WS=GPIO%d SD=GPIO%d, %d Hz 16-bit, peak %d (-30 dBFS) ===\n",
           PIN_BCK, PIN_WS, PIN_SD, BT_SR, BT_PEAK);
    printf("BT order: silence, LEFT beep 440 Hz, RIGHT beep 880 Hz, melody on both, silence, repeat\n");
    if (!i2s_start()) { printf("BT FAIL: I2S did not start\n"); return; }
    printf("BT I2S started\n");
    xTaskCreatePinnedToCore(audio_task, "bt_audio", 4096, NULL, 10, NULL, 1);
}
