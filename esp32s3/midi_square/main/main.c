/* MINISYNTH (grew from the MIDI square test): DIN MIDI -> one mono voice (7-osc
 * unison, sine/tri/saw/square morph, attack/release) -> the JUNO FX stage ONLY
 * (proven engine_b master chain: JUNO CHORUS 2 + HALL 1, recalled tables) ->
 * PCM5102 over I2S. Five knobs (1 = SHIFT bank switch), 128x32 SSD1306 OLED.
 * Pins: BCK 5, LCK/WS 6, DIN 7, MIDI RX 18, knobs 1/2/4/8/9, OLED SDA 11 SCL 12.
 *
 * The log is the detector (CLAUDE.md SHIP LAW), not the ear:
 *   SELFTEST  at boot: starvation tooth, then an internal A4 through the SAME
 *             parser + renderer + I2S path: frequency, peak, and SILENT after
 *             release. PASS/FAIL.
 *   NOTE      one line per MIDI note event.
 *   STAT      once a second when anything moved (and every 10 s regardless):
 *             MIDI byte/event/frame-error counters, audio peak, SIL verdict,
 *             HEALTH latch (never reads OK again after a fault). */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/queue.h"
#include "freertos/semphr.h"
#include "driver/i2s_std.h"
#include "driver/uart.h"
#include "driver/gpio.h"
#include "esp_timer.h"
#include "esp_rom_sys.h"
#include "esp_rom_gpio.h"
#include "esp_cpu.h"
#ifndef MSQ_QEMU
#include "esp_adc/adc_oneshot.h"
#endif
#include "soc/gpio_sig_map.h"   /* U1RXD_IN_IDX: UART1 RX matrix input */
#include "msq_core.h"
#include "fx.h"
#include "panel.h"
#include "ui.h"
#include "oled.h"
#include "gen/msq_fx_check.h"

#define PIN_BCK   GPIO_NUM_5
#define PIN_WS    GPIO_NUM_6
#define PIN_DOUT  GPIO_NUM_7
#define PIN_MIDI  18
#define SR        48000
#define CHUNK     240          /* 5 ms */
#define DMA_N     4
#define MIDI_UART UART_NUM_1
static const int PIN_KNOBS[PANEL_KNOBS] __attribute__((unused)) = { 1, 2, 4, 8, 9 };   /* ADC1 wipers */
#define PIN_SDA   11
#define PIN_SCL   12

static msq_t M;
static i2s_chan_handle_t TX;

/* audio-side counters, written by the audio task / ISR */
static volatile uint32_t a_sent, a_written;
static volatile int      a_peak;          /* max |sample| since last take */
static volatile int      a_rises;         /* rising zero crossings since last take */
static volatile int      a_frames;        /* frames rendered since last take */
static volatile int      a_take;          /* 1 = reset accumulators */
static volatile int      a_stall_ms;      /* tooth: stall the audio task once */
static volatile int      a_opeak;         /* max |output sample| since last take (post-FX) */
static volatile uint32_t a_cyc, a_cyc_max; /* core 1 work per block (voices 0-2 + FX): last, max */
static volatile uint32_t w_cyc, w_cyc_max; /* core 0 worker per block (voices 3-5): last, max */
static volatile int      a_mute;          /* 1: render + FX run, the DAC gets zeros (stress test) */
static volatile int      a_hold;          /* 1: no render, no FX, zeros out (FX re-init)          */

/* health latch */
static const char *health = NULL;
static void fault(const char *why) { if (!health) health = why; }

#ifdef MSQ_QEMU
/* QEMU has no I2S. A 5 ms esp_timer plays the DMA: it "sends" one buffer per
 * period and frees one slot; a starved queue still counts as sent. Only the
 * I2S driver is replaced -- parser, renderer, self-test and detectors are the
 * shipped code. Built only by test/qemu.sh; never shipped. */
#include "freertos/semphr.h"
static SemaphoreHandle_t fake_space;
static void fake_dma(void *u) { a_sent++; xSemaphoreGive(fake_space); }
#endif

static IRAM_ATTR bool on_sent(i2s_chan_handle_t h, i2s_event_data_t *e, void *u)
{
    a_sent++;
    return false;
}

/* THE RENDER IS SPLIT OVER BOTH CORES: voices 3-5 on a core-0 worker, voices
 * 0-2 + the FX stage on core 1. One handshake per 5 ms block. */
static SemaphoreHandle_t w_go, w_done;
static float vbufB[CHUNK];

static void worker_task(void *arg)
{
    for (;;) {
        xSemaphoreTake(w_go, portMAX_DELAY);
        uint32_t c0 = esp_cpu_get_cycle_count();
        msq_render_voices(&M, MSQ_VOICES / 2, MSQ_VOICES, vbufB, CHUNK);
        uint32_t c = esp_cpu_get_cycle_count() - c0;
        w_cyc = c; if (c > w_cyc_max) w_cyc_max = c;
        xSemaphoreGive(w_done);
    }
}

static void audio_task(void *arg)
{
    static int16_t buf[2 * CHUNK];
    static float vbuf[CHUNK];
    float prev = 0;
    for (;;) {
        if (a_hold) {
            memset(buf, 0, sizeof buf);
        } else {
            xSemaphoreGive(w_go);
            uint32_t c0 = esp_cpu_get_cycle_count();
            msq_render_voices(&M, 0, MSQ_VOICES / 2, vbuf, CHUNK);
            uint32_t c1 = esp_cpu_get_cycle_count() - c0;
            xSemaphoreTake(w_done, portMAX_DELAY);
            for (int i = 0; i < CHUNK; ++i) vbuf[i] += vbufB[i];
            c0 = esp_cpu_get_cycle_count();
            fx_process(vbuf, buf, CHUNK);
            uint32_t cyc = c1 + (esp_cpu_get_cycle_count() - c0);
            a_cyc = cyc; if (cyc > a_cyc_max) a_cyc_max = cyc;
        }
        if (a_take) { a_peak = 0; a_rises = 0; a_frames = 0; a_opeak = 0; a_cyc_max = 0; w_cyc_max = 0; a_take = 0; }
        /* SIL / pitch probes on the VOICE SUM (pre-FX): a stuck note is a voice
         * fault; a reverb tail is not. The output peak feeds the meter. */
        int pk = a_peak, r = a_rises, op = a_opeak;
        for (int i = 0; i < CHUNK && !a_hold; ++i) {
            float v = vbuf[i];
            int av = (int)(v < 0 ? -v : v);
            if (v != 0.0f && av == 0) av = 1;             /* any nonzero voice sample counts */
            if (av > pk) pk = av;
            if (prev <= 0 && v > 0) r++;
            prev = v;
            int o = buf[2 * i] < 0 ? -buf[2 * i] : buf[2 * i];
            int o2 = buf[2 * i + 1] < 0 ? -buf[2 * i + 1] : buf[2 * i + 1];
            if (o2 > o) o = o2;
            if (o > op) op = o;
        }
        a_peak = pk; a_rises = r; a_frames += CHUNK; a_opeak = op;
        if (a_mute) memset(buf, 0, sizeof buf);
        if (a_stall_ms) { vTaskDelay(pdMS_TO_TICKS(a_stall_ms)); a_stall_ms = 0; }
#ifdef MSQ_QEMU
        xSemaphoreTake(fake_space, portMAX_DELAY);
#else
        size_t w;
        i2s_channel_write(TX, buf, sizeof buf, &w, portMAX_DELAY);
#endif
        a_written++;
    }
}

static void render_start(void)
{
    w_go = xSemaphoreCreateBinary();
    w_done = xSemaphoreCreateBinary();
    xTaskCreatePinnedToCore(worker_task, "voices35", 4096, NULL, 22, NULL, 0);
}

static int audio_start(void)
{
    render_start();
#ifdef MSQ_QEMU
    fake_space = xSemaphoreCreateCounting(DMA_N, DMA_N);
    esp_timer_handle_t t;
    esp_timer_create_args_t ta = { .callback = fake_dma, .name = "fakedma" };
    esp_timer_create(&ta, &t);
    esp_timer_start_periodic(t, 1000000 / (SR / CHUNK));
    xTaskCreatePinnedToCore(audio_task, "audio", 6144, NULL, 20, NULL, 1);
    return 1;
#endif
    i2s_chan_config_t cc = I2S_CHANNEL_DEFAULT_CONFIG(I2S_NUM_AUTO, I2S_ROLE_MASTER);
    cc.dma_desc_num  = DMA_N;
    cc.dma_frame_num = CHUNK;
    cc.auto_clear    = true;              /* a starved DMA sends zeros, not old audio */
    i2s_std_config_t sc = {
        .clk_cfg  = I2S_STD_CLK_DEFAULT_CONFIG(SR),
        .slot_cfg = I2S_STD_PHILIPS_SLOT_DEFAULT_CONFIG(I2S_DATA_BIT_WIDTH_16BIT,
                                                        I2S_SLOT_MODE_STEREO),
        .gpio_cfg = { .mclk = I2S_GPIO_UNUSED, .bclk = PIN_BCK, .ws = PIN_WS,
                      .dout = PIN_DOUT, .din = I2S_GPIO_UNUSED,
                      .invert_flags = {0, 0, 0} },
    };
    if (i2s_new_channel(&cc, &TX, NULL) != ESP_OK) return 0;
    if (i2s_channel_init_std_mode(TX, &sc) != ESP_OK) return 0;
    i2s_event_callbacks_t cb = { .on_sent = on_sent };
    if (i2s_channel_register_event_callback(TX, &cb, NULL) != ESP_OK) return 0;
    if (i2s_channel_enable(TX) != ESP_OK) return 0;
    xTaskCreatePinnedToCore(audio_task, "audio", 6144, NULL, 20, NULL, 1);
    return 1;
}

static QueueHandle_t midi_q;
static uint32_t n_frame_err, n_fifo_ovf, n_break;

/* RAW PIN PROBE on the MIDI RX pin, independent of the UART: every edge is
 * counted. edges=0 with rx=H = nothing ever pulls the pin low (no signal
 * reaches GPIO 18); rx=L held = the line idles LOW (inverted or shorted). */
static volatile uint32_t rx_edges;
static void IRAM_ATTR rx_edge_isr(void *u) { rx_edges++; }

static int midi_start(void)
{
    uart_config_t cfg = {
        .baud_rate = 31250, .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE, .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE, .source_clk = UART_SCLK_DEFAULT,
    };
    if (uart_driver_install(MIDI_UART, 1024, 0, 16, &midi_q, 0) != ESP_OK) return 0;
    if (uart_param_config(MIDI_UART, &cfg) != ESP_OK) return 0;
    /* THE PAD STAYS A GPIO. GPIO 18 is UART1's own IO_MUX RX pin
     * (U1RXD_GPIO_NUM 18), so uart_set_pin() would hand the pad to the UART
     * function and the GPIO block could no longer drive it -- that is why the
     * v2 self-pulse tooth read +0 on the board. Here the pad keeps the GPIO
     * function (open-drain, released = high, pull-up on: an unwired port is
     * silent, playbook 94) and its input reaches UART1 through the GPIO
     * matrix. So the edge counter, the loopback sender and the UART all see
     * the same pad. */
    gpio_set_level((gpio_num_t)PIN_MIDI, 1);           /* released before OE: no glitch */
    gpio_config_t io = {
        .pin_bit_mask = 1ULL << PIN_MIDI, .mode = GPIO_MODE_INPUT_OUTPUT_OD,
        .pull_up_en = GPIO_PULLUP_ENABLE, .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_ANYEDGE,
    };
    if (gpio_config(&io) != ESP_OK) return 0;
    esp_rom_gpio_connect_in_signal(PIN_MIDI, U1RXD_IN_IDX, false);
    if (gpio_install_isr_service(0) != ESP_OK) return 0;
    if (gpio_isr_handler_add((gpio_num_t)PIN_MIDI, rx_edge_isr, NULL) != ESP_OK) return 0;
    return 1;
}

/* Send one MIDI byte by pulling the pad low (open-drain) at 31,250 baud.
 * Bit edges are timed against the cycle counter (absolute targets), so an
 * interrupt only adds jitter and never accumulates drift. */
static void bitbang_byte(uint8_t v)
{
    const uint32_t BIT = 240000000u / 31250u;           /* 7680 cycles */
    int bits[10];
    bits[0] = 0;
    for (int i = 0; i < 8; ++i) bits[1 + i] = (v >> i) & 1;
    bits[9] = 1;
    uint32_t t0 = esp_cpu_get_cycle_count();
    for (int i = 0; i < 10; ++i) {
        while ((uint32_t)(esp_cpu_get_cycle_count() - t0) < i * BIT) { }
        gpio_set_level((gpio_num_t)PIN_MIDI, bits[i]);
    }
    while ((uint32_t)(esp_cpu_get_cycle_count() - t0) < 10 * BIT) { }
    gpio_set_level((gpio_num_t)PIN_MIDI, 1);
}

/* ----------------------------------------------------------------- PANEL
 * Five pots on ADC1 (ends to 3.3 V / GND, wiper to the pin). Read every 10 ms,
 * smoothed, and handed to panel.c only on a real move (0.4 % deadband), which
 * owns SHIFT (knob 1 as a two-position switch), the two banks and pick-up.
 * Started AFTER the self-test and loopback, which need the fixed defaults. */
static panel_t PANEL;
static volatile int panel_ready;

static void apply_param(int p, float v)
{
    switch (p) {
    case P_WAVE:    msq_set_wave(&M, v * 3.0f); break;
    case P_ATTACK:  msq_set_attack(&M, msq_knob_to_attack(v)); break;
    case P_CHORUS:  fx_set_chorus((int)(v * 255.0f + 0.5f)); break;
    case P_UNISON:  msq_set_unison(&M, v); break;
    case P_RELEASE: msq_set_release(&M, msq_knob_to_release(v)); break;
    case P_REVERB:  fx_set_reverb((int)(v * 255.0f + 0.5f)); break;
    }
}

#ifndef MSQ_QEMU
static adc_oneshot_unit_handle_t knob_adc;
static adc_channel_t knob_ch[PANEL_KNOBS];
static int knob_ok;
static float knob_avg[PANEL_KNOBS], knob_sent[PANEL_KNOBS];

static int knob_read(int k, float *x)
{
    int raw;
    if (adc_oneshot_read(knob_adc, knob_ch[k], &raw) != ESP_OK) return 0;
    *x = raw / 4095.0f;
    return 1;
}

static void knob_start(void)
{
    adc_oneshot_unit_init_cfg_t uc = { .unit_id = ADC_UNIT_1 };
    adc_oneshot_chan_cfg_t cc = { .atten = ADC_ATTEN_DB_12, .bitwidth = ADC_BITWIDTH_12 };
    if (adc_oneshot_new_unit(&uc, &knob_adc) != ESP_OK) { printf("KNOBS: ADC init failed\n"); return; }
    float pos[PANEL_KNOBS] = {0};
    for (int k = 0; k < PANEL_KNOBS; ++k) {
        adc_unit_t unit;
        if (adc_oneshot_io_to_channel(PIN_KNOBS[k], &unit, &knob_ch[k]) != ESP_OK || unit != ADC_UNIT_1 ||
            adc_oneshot_config_channel(knob_adc, knob_ch[k], &cc) != ESP_OK) {
            printf("KNOBS: GPIO %d is not usable on ADC1\n", PIN_KNOBS[k]); return;
        }
        float x = 0, acc = 0;
        for (int i = 0; i < 8; ++i) { knob_read(k, &x); acc += x; }
        pos[k] = knob_avg[k] = knob_sent[k] = acc / 8;
    }
    knob_ok = 1;
    panel_init(&PANEL, pos, (uint32_t)(esp_timer_get_time() / 1000));
    for (int p = 0; p < P_NPARAM; ++p) apply_param(p, PANEL.val[p]);
    PANEL.changed = 0;
    panel_ready = 1;
    printf("KNOBS: 1..5 on GPIO %d %d %d %d %d = %.2f %.2f %.2f %.2f %.2f, bank %c\n",
           PIN_KNOBS[0], PIN_KNOBS[1], PIN_KNOBS[2], PIN_KNOBS[3], PIN_KNOBS[4],
           pos[0], pos[1], pos[2], pos[3], pos[4], PANEL.bank ? 'B' : 'A');
}

static void knob_poll(void)
{
    if (!knob_ok) return;
    uint32_t now = (uint32_t)(esp_timer_get_time() / 1000);
    for (int k = 0; k < PANEL_KNOBS; ++k) {
        float x;
        if (!knob_read(k, &x)) continue;
        knob_avg[k] += (x - knob_avg[k]) * 0.15f;
        float d = knob_avg[k] - knob_sent[k];
        if (d > 0.006f || d < -0.006f || (knob_avg[k] < 0.002f && knob_sent[k] != 0.0f) ||
            (knob_avg[k] > 0.998f && knob_sent[k] != 1.0f)) {
            float v = knob_avg[k] < 0.002f ? 0.0f : (knob_avg[k] > 0.998f ? 1.0f : knob_avg[k]);
            knob_sent[k] = v;
            int bank0 = PANEL.bank;
            panel_knob(&PANEL, k, v, now);
            if (PANEL.bank != bank0) printf("BANK %c (%s)\n", PANEL.bank ? 'B' : 'A', PANEL.bank ? "SHIFT" : "MAIN");
        }
    }
    static uint32_t last_print;
    uint32_t ch = PANEL.changed;
    if (ch) {
        for (int p = 0; p < P_NPARAM; ++p) if (ch & (1u << p)) apply_param(p, PANEL.val[p]);
        PANEL.changed = 0;
        static uint32_t pending;
        pending |= ch;
        if (now - last_print > 120) {                  /* the log follows, rate-limited */
            for (int p = 0; p < P_NPARAM; ++p) if (pending & (1u << p)) {
                char v[16]; ui_value_text(p, PANEL.val[p], v, sizeof v);
                printf("PARAM %-7s %.3f  %s\n", panel_name(p), PANEL.val[p], v);
            }
            pending = 0; last_print = now;
        }
    }
}
#else
static void knob_start(void) { printf("KNOBS: not in the QEMU build\n"); }
static void knob_poll(void) { }
#endif

/* ------------------------------------------------------------------ OLED
 * Its own task on core 0 (the audio owns core 1). ~30 fps; the intro runs
 * first, then the live screens. A missing display is logged, never fatal. */
static int oled_addr;
static volatile uint32_t ui_frames;

static void ui_task(void *arg)
{
    static gfx_fb fb;
    static ui_anim an;
    uint32_t t0 = (uint32_t)(esp_timer_get_time() / 1000);
    for (;;) {
        uint32_t now = (uint32_t)(esp_timer_get_time() / 1000);
        if (now - t0 < UI_INTRO_MS || !panel_ready) {
            ui_intro(&fb, now - t0 < UI_INTRO_MS ? now - t0 : UI_INTRO_MS);
            if (panel_ready) ui_anim_init(&an, &PANEL);
        } else {
            ui_live lv = { M.gate ? M.last_note : -1, a_opeak / 16384.0f, {0} };
            for (int k = 0; k < MSQ_VOICES && k < 6; ++k)
                lv.vstate[k] = M.v[k].gate ? 2 : (M.v[k].level > 0.0f ? 1 : 0);
            ui_render(&fb, &PANEL, &lv, &an, now);
        }
        if (oled_flush(&fb)) ui_frames++;
        vTaskDelay(pdMS_TO_TICKS(30));
    }
}

static void oled_start(void)
{
    oled_addr = oled_init(PIN_SDA, PIN_SCL);
    if (!oled_addr) { printf("OLED: no SSD1306 at 0x3C/0x3D on SDA %d SCL %d\n", PIN_SDA, PIN_SCL); return; }
    printf("OLED: SSD1306 128x32 at 0x%02X (SDA %d, SCL %d)\n", oled_addr, PIN_SDA, PIN_SCL);
    xTaskCreatePinnedToCore(ui_task, "ui", 6144, NULL, 2, NULL, 0);
}

static const char *NAMES[12] = {"C","C#","D","D#","E","F","F#","G","G#","A","A#","B"};

static void print_event(void)
{
    int n = M.last_note;
    if (M.last_event == 1)
        printf("NOTE ON  %3d %-2s%d vel %3d  %8.2f Hz\n", n, NAMES[n % 12], n / 12 - 1,
               M.last_vel, msq_note_hz(n));
    else if (M.last_event == 2)
        printf("NOTE OFF %3d %-2s%d  held=%d\n", n, NAMES[n % 12], n / 12 - 1, M.nheld);
    else if (M.last_event == 3)
        printf("ALL NOTES OFF (CC 120/123)\n");
}

static int64_t last_off_us;

static void sil_and_stat(int force)
{
    static uint32_t p_bytes, p_on, p_off, p_fe, p_edges;
    static int64_t p_print;
    int64_t now = esp_timer_get_time();
    int pk = a_peak, op = a_opeak;
    uint32_t cyc = a_cyc, cycx = a_cyc_max, wcx = w_cyc_max;
    a_take = 1;
    if (fx_overrun()) fault("REVERB TAP OVERRUN");
    if (cycx > 240000000u / (SR / CHUNK) || wcx > 240000000u / (SR / CHUNK)) fault("AUDIO BLOCK OVER BUDGET (render > 5 ms)");
    const char *sil;
    if (M.gate)                               sil = pk > 0 ? "SOUNDING" : "MUTE?";
    else if (now - last_off_us < (int64_t)(M.release_s * 1e6f) + 100000) sil = "RELEASING";
    else                                      sil = pk == 0 ? "SILENT" : "STUCK";
    if (!strcmp(sil, "STUCK")) fault("STUCK (no key held, output not silent)");
    if (!strcmp(sil, "MUTE?")) fault("MUTE (key held, output exactly 0)");
    int32_t deficit = (int32_t)(a_sent - a_written);
    static int32_t base = 0x7fffffff;
    if (base == 0x7fffffff) base = deficit;
    if (deficit > base + 1) fault("AUDIO STARVED (DMA sent a buffer nobody filled)");
    static uint32_t p_written;
    if (a_written == p_written) fault("AUDIO TASK STALLED (no block written in 1 s)");
    p_written = a_written;
    int moved = M.n_bytes != p_bytes || M.n_on != p_on || M.n_off != p_off || n_frame_err != p_fe || rx_edges != p_edges;
    if (force || moved || now - p_print > 10000000) {
        printf("PIN rx%d=%c edges=%lu brk=%lu | ", PIN_MIDI,
               gpio_get_level((gpio_num_t)PIN_MIDI) ? 'H' : 'L',
               (unsigned long)rx_edges, (unsigned long)n_break);
        printf("STAT midi bytes=%lu on=%lu off=%lu cc=%lu rt=%lu ferr=%lu ovf=%lu held=%d | "
               "peak=%d out=%d deficit=%ld cpu1=%lu%%/%lu%% cpu0=%lu%% voices=%d oled=%lu/%lu | SIL: %s | HEALTH: %s\n",
               (unsigned long)M.n_bytes, (unsigned long)M.n_on, (unsigned long)M.n_off,
               (unsigned long)M.n_cc, (unsigned long)M.n_rt, (unsigned long)n_frame_err,
               (unsigned long)n_fifo_ovf, M.nheld, pk, op, (long)(deficit - base),
               (unsigned long)(cyc * 100u / (240000000u / (SR / CHUNK))),
               (unsigned long)(cycx * 100u / (240000000u / (SR / CHUNK))),
               (unsigned long)(wcx * 100u / (240000000u / (SR / CHUNK))), msq_voices_sounding(&M),
               (unsigned long)ui_frames, (unsigned long)oled_errors(), sil,
               health ? health : "OK");
        p_print = now;
    }
    p_bytes = M.n_bytes; p_on = M.n_on; p_off = M.n_off; p_fe = n_frame_err; p_edges = rx_edges;
}

/* measure over `ms`: returns Hz, peak via *pk */
static float window(int ms, int *pk)
{
    a_take = 1;
    vTaskDelay(pdMS_TO_TICKS(20));
    a_take = 1;
    vTaskDelay(pdMS_TO_TICKS(ms));
    *pk = a_peak;
    int f = a_frames;
    return f ? a_rises * (float)SR / f : 0.0f;  /* crossings per rendered second */
}

static int selftest(void)
{
    int ok = 1, pk;
    /* 1. starvation tooth: stall the audio task 100 ms (5x the 20 ms queue);
     *    the counter MUST move by far more than its +1 threshold */
    vTaskDelay(pdMS_TO_TICKS(300));
    int32_t d0 = (int32_t)(a_sent - a_written);
    a_stall_ms = 100;
    vTaskDelay(pdMS_TO_TICKS(200));
    int32_t d1 = (int32_t)(a_sent - a_written);
    printf("SELFTEST starvation tooth: deficit %ld -> %ld  %s\n", (long)d0, (long)d1,
           d1 > d0 + 1 ? "FIRES (detector live)" : "DID NOT FIRE -- detector dead");
    if (!(d1 > d0 + 1)) ok = 0;

    /* 2. internal A4 through the same parser: 0x90 69 100 ... 0x80 69 0 */
    msq_byte(&M, 0x90); msq_byte(&M, 69); msq_byte(&M, 100);
    float hz = window(500, &pk);
    int pk_on = pk, op_on = a_opeak;
    msq_byte(&M, 0x80); msq_byte(&M, 69); msq_byte(&M, 0);
    vTaskDelay(pdMS_TO_TICKS(60));
    window(200, &pk);
    int pk_off = pk, op_off = a_opeak;
    int f_ok = hz > 437.0f && hz < 443.0f, on_ok = pk_on > 0.97f * M.amp, off_ok = pk_off == 0;
    printf("SELFTEST A4: %.1f Hz (want 440 +-3) %s, peak %d (want ~4096) %s, "
           "after release peak %d %s\n", hz, f_ok ? "ok" : "BAD", pk_on, on_ok ? "ok" : "BAD",
           pk_off, off_ok ? "SILENT" : "NOT SILENT");
    ok &= f_ok && on_ok && off_ok;
    /* 3. the JUNO FX stage (chorus 0, reverb 0: its dry path) carried the A4:
     *    MEASURED (QEMU v6): a +-4096 square came out at 3005 at FX_IN_GAIN
     *    1/196608; at 1/294912 that is ~2000 */
    int fx_on = op_on > 1000 && op_on < 4000, fx_off = op_off <= 1;
    printf("SELFTEST FX: out peak %d with the note (want ~2000) %s, %d after release %s, overrun %d\n",
           op_on, fx_on ? "ok" : "BAD", op_off, fx_off ? "ok" : "BAD", fx_overrun());
    ok &= fx_on && fx_off && !fx_overrun();
    /* the self-test's own events must not count as played notes */
    M.n_bytes = M.n_on = M.n_off = 0; M.last_event = 0;
    return ok;
}

/* LOOPBACK TOOTH: the pad sends itself a real note (0x90 60 100 ... 0x80 60 0)
 * through the same pin, UART, parser and synth the keybed uses. It must give
 * 6 bytes, a NOTE ON and a NOTE OFF, edges > 0 and a C4 (261.6 Hz) tone.
 * Idle level first: L = something outside holds the line low. */
static int midi_loopback(void)
{
    static const uint8_t on[3] = {0x90, 60, 100}, off[3] = {0x80, 60, 0};
    uint8_t rx[16];
    int lvl0 = gpio_get_level((gpio_num_t)PIN_MIDI), pk, n_on, n_off;
    uint32_t e0 = rx_edges, on0 = M.n_on, off0 = M.n_off;
    int got = 0;
    uart_flush_input(MIDI_UART);
    for (int i = 0; i < 3; ++i) bitbang_byte(on[i]);
    int n = uart_read_bytes(MIDI_UART, rx, sizeof rx, pdMS_TO_TICKS(30));
    for (int i = 0; i < n; ++i) msq_byte(&M, rx[i]);
    got += n;
    float hz = window(300, &pk);
    for (int i = 0; i < 3; ++i) bitbang_byte(off[i]);
    n = uart_read_bytes(MIDI_UART, rx, sizeof rx, pdMS_TO_TICKS(30));
    for (int i = 0; i < n; ++i) msq_byte(&M, rx[i]);
    got += n;
    n_on = M.n_on - on0; n_off = M.n_off - off0;
    uint32_t de = rx_edges - e0;
    int ok = lvl0 && got == 6 && n_on == 1 && n_off == 1 && de > 0 && !M.gate &&
             hz > 258.0f && hz < 265.0f && pk > 0.97f * M.amp;
    printf("LOOPBACK rx%d idle=%c: sent 6 bytes, UART got %d, NOTE ON %d, NOTE OFF %d, edges +%lu, "
           "tone %.1f Hz (want 261.6) peak %d  %s\n", PIN_MIDI, lvl0 ? 'H' : 'L', got, n_on, n_off,
           (unsigned long)de, hz, pk, ok ? "PASS (pin->UART->parser->synth live)" :
           !lvl0 ? "FAIL -- line held LOW from outside" : "FAIL");
    if (!ok) fault(lvl0 ? "MIDI LOOPBACK FAIL" : "MIDI RX HELD LOW");
    vTaskDelay(pdMS_TO_TICKS(50));
    uart_flush_input(MIDI_UART);
    xQueueReset(midi_q);
    M.n_bytes = M.n_on = M.n_off = 0; M.last_event = 0;
    rx_edges = 0;
    last_off_us = esp_timer_get_time();
    return ok;
}

/* WORST-CASE STRESS (the INVARIANT: bounded worst case, not a good average).
 * Output MUTED. 6 voices x 7 unison oscillators, a waveform morph (two shapes
 * per oscillator), full chorus and reverb, 400 ms. Budget per 5 ms block =
 * 1,200,000 cycles per core. FAIL (latched) above 90 %. Then the FX state is
 * re-initialised so no stress tail is ever heard. */
static int stress(void)
{
    const uint32_t budget = 240000000u / (SR / CHUNK);
    a_mute = 1;
    msq_set_unison(&M, 1.0f); msq_set_wave(&M, 2.5f);
    fx_set_chorus(255); fx_set_reverb(255);
    for (int k = 0; k < MSQ_VOICES; ++k) { msq_byte(&M, 0x90); msq_byte(&M, (uint8_t)(48 + 4 * k)); msq_byte(&M, 100); }
    vTaskDelay(pdMS_TO_TICKS(60));
    a_take = 1;
    vTaskDelay(pdMS_TO_TICKS(400));
    uint32_t c1 = a_cyc_max, c0 = w_cyc_max;
    int nv = msq_voices_sounding(&M), opk = a_opeak;
    for (int k = 0; k < MSQ_VOICES; ++k) { msq_byte(&M, 0x80); msq_byte(&M, (uint8_t)(48 + 4 * k)); msq_byte(&M, 0); }
    vTaskDelay(pdMS_TO_TICKS(60));
    a_hold = 1; vTaskDelay(pdMS_TO_TICKS(20));
    fx_init(NULL);
    msq_set_unison(&M, 0.0f); msq_set_wave(&M, 3.0f);
    a_hold = 0; vTaskDelay(pdMS_TO_TICKS(20));
    a_take = 1; vTaskDelay(pdMS_TO_TICKS(20));        /* the stress peaks must not reach STAT */
    a_mute = 0;
    unsigned p1 = (unsigned)(c1 * 100ull / budget), p0 = (unsigned)(c0 * 100ull / budget);
    int ok = nv == MSQ_VOICES && p1 <= 90 && p0 <= 90 && c1 > 0 && c0 > 0;
    printf("STRESS (muted) %d voices x %d osc, morph, chorus 255, reverb 255: core1 %u%%  core0 %u%% of the 5 ms block, "
           "out peak %d/32767  %s\n", nv, MSQ_UNI, p1, p0, opk, ok ? "PASS" : "FAIL");
    if (!ok) fault("STRESS OVER BUDGET");
    M.n_bytes = M.n_on = M.n_off = 0; M.last_event = 0;
    return ok;
}

void app_main(void)
{
    printf("\n=== MINISYNTH (BCK %d, LCK %d, DIN %d, MIDI RX %d, %d Hz) ===\n",
           PIN_BCK, PIN_WS, PIN_DOUT, PIN_MIDI, SR);
    msq_init(&M, SR);
    fx_init(NULL);
    uint32_t cc, sc;
    int fxok = fx_selfcheck(&cc, &sc);
    printf("FX: JUNO master stage (CHORUS 2 + HALL 1, delay off), coef crc %08lx state crc %08lx vs host: %s\n",
           (unsigned long)cc, (unsigned long)sc, fxok ? "MATCH" : "MISMATCH");
    if (!fxok) fault("FX COEF/STATE CRC MISMATCH");
    uint32_t rc = fx_render_crc();
    printf("FX: render check crc %08lx vs host %08lx: %s\n", (unsigned long)rc,
           (unsigned long)MSQ_FX_RENDER_CRC, rc == MSQ_FX_RENDER_CRC ? "MATCH (S3 arithmetic == host == recall path)" : "MISMATCH");
    if (rc != MSQ_FX_RENDER_CRC) fault("FX RENDER CRC MISMATCH");
    oled_start();
    if (!audio_start()) { printf("FATAL: I2S start failed\n"); return; }
    int st = selftest();
    printf("SELFTEST: %s\n", st ? "PASS" : "FAIL");
    if (!st) fault("SELFTEST FAIL");
    if (!midi_start()) { printf("FATAL: MIDI UART start failed\n"); return; }
    midi_loopback();
    stress();
    knob_start();
    printf("READY -- play notes. Any MIDI channel. Expect one NOTE line per key.\n");
    sil_and_stat(1);

    uint8_t b[128];
    int64_t next_stat = esp_timer_get_time() + 1000000, next_knob = 0;
    for (;;) {
        uart_event_t ev;
        if (xQueueReceive(midi_q, &ev, pdMS_TO_TICKS(10))) {
            if (ev.type == UART_DATA) {
                int n = uart_read_bytes(MIDI_UART, b, sizeof b, 0);
                for (int i = 0; i < n; ++i)
                    if (msq_byte(&M, b[i])) {
                        if (!M.gate) last_off_us = esp_timer_get_time();
                        print_event();
                    }
            } else if (ev.type == UART_BREAK) {
                n_break++;
            } else if (ev.type == UART_FRAME_ERR) {
                n_frame_err++;
            } else if (ev.type == UART_FIFO_OVF || ev.type == UART_BUFFER_FULL) {
                n_fifo_ovf++;
                uart_flush_input(MIDI_UART);
                xQueueReset(midi_q);
            }
        }
        if (esp_timer_get_time() >= next_knob) {
            knob_poll();
            next_knob = esp_timer_get_time() + 10000;
        }
        if (esp_timer_get_time() >= next_stat) {
            sil_and_stat(0);
            next_stat += 1000000;
        }
    }
}
