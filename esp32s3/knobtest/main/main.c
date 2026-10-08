/* KNOB TEST (bare): intro animation + startup sound, then the screen shows the
 * five knobs and the button; each press toggles the button LED. Log: one KT
 * line every 500 ms. Pins = the minisynth's final build (README "Pins"). */
#include <stdio.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/i2s_std.h"
#include "driver/gpio.h"
#include "esp_timer.h"
#include "esp_adc/adc_oneshot.h"
#include "gfx.h"
#include "oled.h"
#include "ui.h"
#include "outstage.h"

#define SR 48000
#define CHUNK 240
static const int KNOB[5] = { 1, 4, 6, 8, 9 };            /* knob 1 (VOL), knobs 2-5 */
static const char *NM[5] = { "VOL", "K2", "K3", "K4", "K5" };
#define PIN_BTN 48                                        /* NC to 3V3: pressed = LOW */
#define PIN_LED 38

extern const int16_t clip_a[] asm("_binary_startup_48k_s16le_raw_start");
extern const int16_t clip_b[] asm("_binary_startup_48k_s16le_raw_end");
static i2s_chan_handle_t TX;
static volatile int snd_pos = 1 << 30;                    /* frame index; starts at -7200 = 150 ms */
static float kv[5];
static int btn, led;

static void audio_task(void *a)
{
    static int16_t z[2 * CHUNK], cb[2 * CHUNK], out[2 * CHUNK];
    outstage_t o; outstage_init(&o, SR);
    int n = (int)((clip_b - clip_a) / 2);
    for (;;) {
        int sp = snd_pos;
        for (int i = 0; i < CHUNK; ++i, ++sp) {
            int in = sp >= 0 && sp < n;
            cb[2 * i] = in ? clip_a[2 * sp] : 0; cb[2 * i + 1] = in ? clip_a[2 * sp + 1] : 0;
        }
        snd_pos = sp;
        outstage_block(&o, z, cb, CHUNK, 1.0f, out, &(outstage_stats){ 0, 1.0f, 0 });
        size_t w; i2s_channel_write(TX, out, sizeof out, &w, portMAX_DELAY);
    }
}

void app_main(void)
{
    printf("\n=== KNOB TEST (bare: no synth) -- knobs G1 G9 G4 G6 G8, button G48, LED G38 ===\n");
    i2s_chan_config_t cc = I2S_CHANNEL_DEFAULT_CONFIG(I2S_NUM_AUTO, I2S_ROLE_MASTER);
    cc.dma_desc_num = 4; cc.dma_frame_num = CHUNK; cc.auto_clear = true;
    i2s_std_config_t sc = { .clk_cfg = I2S_STD_CLK_DEFAULT_CONFIG(SR),
        .slot_cfg = I2S_STD_PHILIPS_SLOT_DEFAULT_CONFIG(I2S_DATA_BIT_WIDTH_16BIT, I2S_SLOT_MODE_STEREO),
        .gpio_cfg = { .mclk = I2S_GPIO_UNUSED, .bclk = 42, .ws = 40, .dout = 21, .din = I2S_GPIO_UNUSED } };
    i2s_new_channel(&cc, &TX, NULL); i2s_channel_init_std_mode(TX, &sc); i2s_channel_enable(TX);
    xTaskCreatePinnedToCore(audio_task, "audio", 4096, NULL, 20, NULL, 1);

    adc_oneshot_unit_handle_t adc; adc_channel_t ch[5];
    adc_oneshot_unit_init_cfg_t uc = { .unit_id = ADC_UNIT_1 };
    adc_oneshot_chan_cfg_t ac = { .atten = ADC_ATTEN_DB_12, .bitwidth = ADC_BITWIDTH_12 };
    adc_oneshot_new_unit(&uc, &adc);
    for (int k = 0; k < 5; ++k) { adc_unit_t u; adc_oneshot_io_to_channel(KNOB[k], &u, &ch[k]); adc_oneshot_config_channel(adc, ch[k], &ac); }
    gpio_config_t bi = { .pin_bit_mask = 1ULL << PIN_BTN, .mode = GPIO_MODE_INPUT, .pull_down_en = 1 };
    gpio_config(&bi);
    gpio_config_t lo = { .pin_bit_mask = 1ULL << PIN_LED, .mode = GPIO_MODE_OUTPUT };
    gpio_config(&lo); gpio_set_level(PIN_LED, 0);

    int oled = oled_init(15, 13);
    printf("OLED: %s\n", oled ? "found" : "NOT FOUND (SDA 15, SCL 13)");
    static gfx_fb fb;
    uint32_t t0 = (uint32_t)(esp_timer_get_time() / 1000), last_log = 0, btn_ms = 0;
    int raw_prev = 1;
    snd_pos = -(SR / 1000) * 150;                          /* the sound 150 ms after frame 0 */
    TickType_t wake = xTaskGetTickCount();
    for (;;) {
        uint32_t now = (uint32_t)(esp_timer_get_time() / 1000);
        for (int k = 0; k < 5; ++k) {                        /* 8x oversample, light smoothing */
            int r, acc = 0; for (int i = 0; i < 8; ++i) { adc_oneshot_read(adc, ch[k], &r); acc += r; }
            kv[k] += (acc / (8 * 4095.0f) - kv[k]) * 0.3f;
        }
        int raw = gpio_get_level(PIN_BTN);                   /* 20 ms debounce; press = HIGH -> LOW */
        if (raw != raw_prev) { raw_prev = raw; btn_ms = now; }
        else if (now - btn_ms >= 20 && (raw == 0) != btn) {
            btn = (raw == 0);
            if (btn) { led = !led; gpio_set_level(PIN_LED, led); }
            printf("KT BUTTON %s, LED %s\n", btn ? "PRESSED" : "released", led ? "ON" : "OFF");
        }
        if (now - t0 < UI_INTRO_MS) ui_intro(&fb, now - t0);
        else {
            char t[32];
            gfx_clear(&fb);
            snprintf(t, sizeof t, "BTN %s  LED %s", btn ? "DOWN" : "UP", led ? "ON" : "OFF");
            gfx_text(&fb, 0, 0, t, 1);
            for (int k = 0; k < 5; ++k) {
                int x = k * 26;
                snprintf(t, sizeof t, "%d", (int)(kv[k] * 100.0f + 0.5f)); gfx_text(&fb, x, 9, t, 1);
                gfx_rect(&fb, x, 18, 24, 5, 1);
                gfx_fill(&fb, x + 1, 19, (int)(kv[k] * 22.0f + 0.5f), 3, 1);
                gfx_text(&fb, x, 24, NM[k], 1);
            }
        }
        oled_flush(&fb);
        if (now - last_log >= 500) {
            last_log = now;
            printf("KT VOL(G1)=%.2f K2(G4)=%.2f K3(G6)=%.2f K4(G8)=%.2f K5(G9)=%.2f | BTN G48 raw=%d %s | LED %s\n",
                   kv[0], kv[1], kv[2], kv[3], kv[4], raw, btn ? "PRESSED" : "released", led ? "ON" : "OFF");
        }
        xTaskDelayUntil(&wake, pdMS_TO_TICKS(33));
    }
}
