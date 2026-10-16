/* JUNO LITE firmware -- see ../README.md.
 * I2S: GPIO 5/6/7 (BCK/WS/SD), MIDI IN: UART1 RX GPIO 17 (31250) -- the
 * ESP32-S3_Motherboard v1.0 fab netlist (H1A1 pads 5/6/7 and 10).
 * VOL_POT (H1A1 pad 4 = GPIO 4, ADC1) selects the factory patch: fully down = 1, fully up = 64.
 * Boot: a 6-voice benchmark (BENCH lines), then the demo chords on the pot's patch until the
 * first MIDI note. Log once a second: JL line (load, underruns, voices, peak, MIDI)
 * and the SILENCE PROBE (no voice sounding -> the output must be 0, else STUCK). */
#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/i2s_std.h"
#include "driver/uart.h"
#include "esp_timer.h"
#include "esp_adc/adc_oneshot.h"
#include "jl_synth.h"
#include "jl_demo.h"
#include "jl_bank.h"

#define PIN_BCK 5
#define PIN_WS  6
#define PIN_SD  7
#define PIN_MIDI_RX 17
#define PIN_POT 4
#define BLOCK_US (1e6 * JL_BLOCK / JL_SR)          /* 1451 us */

static i2s_chan_handle_t TX;
static int patch = -1;                      /* factory patch 0..63 now playing */
static volatile int pot_patch = -1, pc_patch = -1;

#ifdef JL_QEMU
static void pot_start(void) { pot_patch = 0; }
#else
/* VOL_POT: 8 reads averaged every 20 ms; 64 equal bins, a new bin only when the reading is
 * 24 counts (of 4095) inside it -- no flicker at a bin edge. */
static adc_oneshot_unit_handle_t ADC;
static adc_channel_t POTCH;
static void pot_task(void *a)
{
    int cur = -1;
    for (;;) {
        int sum = 0, r;
        for (int i = 0; i < 8; ++i) { adc_oneshot_read(ADC, POTCH, &r); sum += r; }
        int raw = sum / 8, idx = raw * 64 / 4096;
        if (idx > 63) idx = 63;
        int lo = idx * 4096 / 64, hi = (idx + 1) * 4096 / 64;
        if (cur < 0 || (idx != cur && raw > lo + 24 && raw < hi - 24) || (idx != cur && (idx == 0 || idx == 63)))
            { cur = idx; pot_patch = idx; }
        vTaskDelay(pdMS_TO_TICKS(20));
    }
}
static void pot_start(void)
{
    adc_unit_t u;
    adc_oneshot_unit_init_cfg_t uc = { .unit_id = ADC_UNIT_1 };
    adc_oneshot_chan_cfg_t cc = { .atten = ADC_ATTEN_DB_12, .bitwidth = ADC_BITWIDTH_12 };
    if (adc_oneshot_io_to_channel(PIN_POT, &u, &POTCH) != ESP_OK || adc_oneshot_new_unit(&uc, &ADC) != ESP_OK
        || adc_oneshot_config_channel(ADC, POTCH, &cc) != ESP_OK) { printf("JL pot: ADC FAIL, patch 1\n"); pot_patch = 0; return; }
    xTaskCreatePinnedToCore(pot_task, "jl_pot", 3072, NULL, 5, NULL, 0);
}
#endif

#ifdef JL_QEMU   /* QEMU has no I2S or MIDI: pace blocks in real time. Built only by test/qemu.sh. */
static int64_t q0; static long qn;
static void out_block(const int16_t *b) { (void)b; if (!q0) q0 = esp_timer_get_time(); ++qn;
    while (esp_timer_get_time() < q0 + (int64_t)(qn * BLOCK_US)) vTaskDelay(1); }
static int hw_start(void) { return 1; }
static int midi_read(uint8_t *b, int n) { (void)b; (void)n; return 0; }
#else
static void out_block(const int16_t *b) { size_t w; i2s_channel_write(TX, b, JL_BLOCK * 4, &w, 1000); }
static int midi_read(uint8_t *b, int n) { return uart_read_bytes(UART_NUM_1, b, n, 0); }
static int hw_start(void)
{
    i2s_chan_config_t cc = I2S_CHANNEL_DEFAULT_CONFIG(I2S_NUM_AUTO, I2S_ROLE_MASTER);
    cc.dma_desc_num = 4; cc.dma_frame_num = 256; cc.auto_clear = true;
    i2s_std_config_t sc = {
        .clk_cfg = I2S_STD_CLK_DEFAULT_CONFIG(JL_SR),
        .slot_cfg = I2S_STD_PHILIPS_SLOT_DEFAULT_CONFIG(I2S_DATA_BIT_WIDTH_16BIT, I2S_SLOT_MODE_STEREO),
        .gpio_cfg = { .mclk = I2S_GPIO_UNUSED, .bclk = PIN_BCK, .ws = PIN_WS, .dout = PIN_SD, .din = I2S_GPIO_UNUSED },
    };
    if (i2s_new_channel(&cc, &TX, NULL) != ESP_OK || i2s_channel_init_std_mode(TX, &sc) != ESP_OK
        || i2s_channel_enable(TX) != ESP_OK) return 0;
    uart_config_t u = { .baud_rate = 31250, .data_bits = UART_DATA_8_BITS, .parity = UART_PARITY_DISABLE,
                        .stop_bits = UART_STOP_BITS_1, .flow_ctrl = UART_HW_FLOWCTRL_DISABLE, .source_clk = UART_SCLK_DEFAULT };
    if (uart_driver_install(UART_NUM_1, 1024, 0, 0, NULL, 0) != ESP_OK || uart_param_config(UART_NUM_1, &u) != ESP_OK
        || uart_set_pin(UART_NUM_1, UART_PIN_NO_CHANGE, PIN_MIDI_RX, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE) != ESP_OK) return 0;
    return 1;
}
#endif

/* MIDI: omni, running status. Notes, bend (+-2), CC 1 mod, 7 volume, 71 res,
 * 74 cutoff, 120/123 all off, program change = factory patch (1..64). */
static int midi_notes;
static void midi_byte(uint8_t c)
{
    static uint8_t st, d[2]; static int n;
    if (c >= 0xF8) return;
    if (c & 0x80) { st = c; n = 0; return; }
    if (!st) return;
    d[n++] = c;
    int t = st & 0xF0, need = (t == 0xC0 || t == 0xD0) ? 1 : 2;
    if (n < need) return;
    n = 0;
    if (t == 0x90 && d[1]) { jl_note_on(d[0], d[1]); ++midi_notes; }
    else if (t == 0x80 || t == 0x90) jl_note_off(d[0]);
    else if (t == 0xE0) jl_bend(((d[1] << 7 | d[0]) - 8192) / 4096.0f);
    else if (t == 0xC0) pc_patch = d[0] & 63;
    else if (t == 0xB0) {
        float v = d[1] / 127.0f;
        if (d[0] == 1) jl_mod(v); else if (d[0] == 7) jl_volume(v * 0.5f);
        else if (d[0] == 74) jl_cc_cutoff(v); else if (d[0] == 71) jl_cc_res(v);
        else if (d[0] == 120 || d[0] == 123) jl_all_off();
    }
}

static void bench(void)
{
    static int16_t b[2 * JL_BLOCK];
    for (int p = 0; p < jl_npresets; ++p) {
        jl_set_patch(&jl_presets[p]);
        for (int i = 0; i < 6; ++i) jl_note_on(jl_chordA[i], 100);
        for (int i = 0; i < 20; ++i) jl_render(b);
        int64_t t0 = esp_timer_get_time();
        for (int i = 0; i < 200; ++i) jl_render(b);
        double us = (esp_timer_get_time() - t0) / 200.0;
        printf("BENCH %-8s 6 voices: %6.1f us/block = %4.1f %% of one core (budget 100 %%)\n",
               jl_presets[p].name, us, 100 * us / BLOCK_US);
        jl_panic();
    }
    double worst = 0; int wi = 0;                         /* the 64 factory patches, 6 voices each */
    for (int p = 0; p < JL_BANK_COUNT; ++p) {
        jl_patch q; jl_bank_patch(p, &q); jl_set_patch(&q);
        for (int i = 0; i < 6; ++i) jl_note_on(jl_chordA[i], 100);
        for (int i = 0; i < 5; ++i) jl_render(b);
        int64_t t0 = esp_timer_get_time();
        for (int i = 0; i < 40; ++i) jl_render(b);
        double us = (esp_timer_get_time() - t0) / 40.0;
        if (us > worst) { worst = us; wi = p; }
        jl_panic();
    }
    printf("BENCH factory bank, worst of 64: patch %d %s %6.1f us/block = %4.1f %% of one core\n",
           wi + 1, jl_bank[wi].name, worst, 100 * worst / BLOCK_US);
}

static void audio_task(void *arg)
{
    static int16_t b[2 * JL_BLOCK];
    uint8_t mb[64];
    long t = 0; int demo = 1, under = 0, peak = 0, maxv = 0, stuck = 0, quiet_blocks = 0, idle_run = 0;
    double maxload = 0, sumload = 0; int64_t next = esp_timer_get_time() + 1000000;
    for (;;) {
        int n = midi_read(mb, sizeof mb);
        for (int i = 0; i < n; ++i) midi_byte(mb[i]);
        if (demo && midi_notes) { demo = 0; jl_all_off(); printf("JL MIDI note seen: demo off\n"); }
        int want = -1;
        if (pc_patch >= 0) { want = pc_patch; pc_patch = -1; }
        static int last_pot = -1;
        if (pot_patch != last_pot) { last_pot = pot_patch; want = pot_patch; }
        if (want >= 0 && want != patch) {
            jl_patch q; patch = want; jl_bank_patch(patch, &q); jl_set_patch(&q);
            printf("JL patch %d %s\n", patch + 1, q.name);
        }
        if (demo) jl_demo_notes(t);
        int64_t r0 = esp_timer_get_time();
        jl_render(b);
        double ld = (esp_timer_get_time() - r0) / BLOCK_US;
        if (ld > maxload) maxload = ld;
        sumload += ld; if (ld > 1) ++under;
        int act = jl_active(), pk = 0;
        for (int i = 0; i < 2 * JL_BLOCK; ++i) { int a = b[i] < 0 ? -b[i] : b[i]; if (a > pk) pk = a; }
        if (pk > peak) peak = pk;
        if (act > maxv) maxv = act;
        idle_run = act ? 0 : idle_run + 1;              /* the chorus tail lasts <= 46 ms */
        if (idle_run > 100) { ++quiet_blocks; if (pk) ++stuck; }
        out_block(b); ++t;
        if (esp_timer_get_time() >= next) {
            next += 1000000;
            printf("JL t=%lds patch=%2d %s load avg %4.1f%% max %4.1f%% underruns(total)=%d voices<=%d peak=%5d midi_notes=%d  SIL:%s\n",
                   (long)(t * BLOCK_US / 1e6), patch + 1, demo ? "DEMO" : "MIDI",
                   100 * sumload / 689, 100 * maxload, under, maxv, peak, midi_notes,
                   quiet_blocks ? (stuck ? "STUCK" : "SILENT") : "playing");
            sumload = maxload = 0; peak = maxv = 0; quiet_blocks = stuck = 0;
        }
    }
}

void app_main(void)
{
    printf("\n=== JUNO LITE v1 (NOT bit-exact; 6 voices) -- I2S BCK=%d WS=%d SD=%d, MIDI RX=GPIO%d, %d Hz ===\n",
           PIN_BCK, PIN_WS, PIN_SD, PIN_MIDI_RX, JL_SR);
    int64_t t0 = esp_timer_get_time();
    jl_init();
    printf("JL tables built in %lld ms\n", (esp_timer_get_time() - t0) / 1000);
    bench();
    pot_start();
    if (!hw_start()) { printf("JL FAIL: I2S/UART did not start\n"); return; }
    printf("JL I2S + MIDI started; demo plays until the first MIDI note\n");
    xTaskCreatePinnedToCore(audio_task, "jl_audio", 6144, NULL, 10, NULL, 1);
}
