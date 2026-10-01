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
#include "esp_adc/adc_cali.h"
#include "esp_adc/adc_cali_scheme.h"
#endif
#include "soc/gpio_sig_map.h"   /* U1RXD_IN_IDX: UART1 RX matrix input */
#include "msq_core.h"
#include "fx.h"
#include "eb_master.h"
#include "panel.h"
#include "ui.h"
#include "oled.h"
#include "gen/msq_fx_check.h"
#include "gen/msq_wave_check.h"
#include "esp_memory_utils.h"

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
#define PIN_BAT   10           /* ADC1: battery via 10k/10k divider from the charger OUT+ */
#define PIN_CHRG  13           /* charger CHRG LED pin via 10k: LOW = charging   */
#define PIN_STDBY 14           /* charger STDBY LED pin via 10k: LOW = full      */

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
static volatile uint32_t f_cyc, f_cyc_max; /* the FX stage alone per block (core 1): last, max */
static volatile int      a_n1, a_nact;    /* last split: active voices on core 1, active in total */
static volatile uint32_t a_blocks_off;    /* blocks where any voice started gated-off-and-silent */
static volatile int      a_allidle;       /* 1 while every block since take began with all voices idle */

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

/* THE RENDER IS SPLIT OVER BOTH CORES, ADAPTIVELY. Core 1 carries the FX
 * stage, so it takes fewer voices: each block the SOUNDING voices are divided
 * so that (FX + core-1 voices) and (core-0 voices) are as equal as the running
 * cost averages say. Idle voices go to the worker (a key pressed mid-block is
 * rendered by whichever core holds its bit; every voice is in exactly one
 * mask). One handshake per 5 ms block. */
static SemaphoreHandle_t w_go, w_done;
static float vbufB[CHUNK];
static volatile uint32_t w_mask;

static void worker_task(void *arg)
{
    for (;;) {
        xSemaphoreTake(w_go, portMAX_DELAY);
        uint32_t c0 = esp_cpu_get_cycle_count();
        msq_render_mask(&M, w_mask, vbufB, CHUNK);
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
    float fx_avg = 0, v_avg = 0;                         /* cycles: FX per block, one voice per block */
    uint32_t on_at_start = 0;
    for (;;) {
        int allidle = 1;
        if (a_hold) {
            memset(buf, 0, sizeof buf);
        } else {
            on_at_start = M.n_on;
            uint32_t act = 0; int nact = 0;
            for (int k = 0; k < MSQ_VOICES; ++k)
                if (M.v[k].gate || M.v[k].level > 0.0f) { act |= 1u << k; nact++; }
            allidle = nact == 0;
            int n1 = nact / 2;
            if (v_avg > 0.0f) {
                float x = (nact * v_avg - fx_avg) / (2.0f * v_avg);
                n1 = (int)(x + 0.5f); if (n1 < 0) n1 = 0; if (n1 > nact) n1 = nact;
            }
            uint32_t m1 = 0; int c = 0;
            for (int k = 0; k < MSQ_VOICES && c < n1; ++k) if (act & (1u << k)) { m1 |= 1u << k; c++; }
            w_mask = ((1u << MSQ_VOICES) - 1) & ~m1;
            a_n1 = n1; a_nact = nact;
            xSemaphoreGive(w_go);
            uint32_t c0 = esp_cpu_get_cycle_count();
            msq_render_mask(&M, m1, vbuf, CHUNK);
            uint32_t c1 = esp_cpu_get_cycle_count() - c0;
            xSemaphoreTake(w_done, portMAX_DELAY);
            for (int i = 0; i < CHUNK; ++i) vbuf[i] += vbufB[i];
            c0 = esp_cpu_get_cycle_count();
            fx_process(vbuf, buf, CHUNK);
            uint32_t cf = esp_cpu_get_cycle_count() - c0;
            uint32_t cyc = c1 + cf;
            a_cyc = cyc; if (cyc > a_cyc_max) a_cyc_max = cyc;
            f_cyc = cf; if (cf > f_cyc_max) f_cyc_max = cf;
            fx_avg += ((float)cf - fx_avg) * 0.1f;
            if (nact) v_avg += ((float)(c1 + w_cyc) / nact - v_avg) * 0.1f;
        }
        if (a_take) { a_peak = 0; a_rises = 0; a_frames = 0; a_opeak = 0; a_cyc_max = 0; w_cyc_max = 0; f_cyc_max = 0; a_allidle = 1; a_take = 0; }
        if (!allidle) a_allidle = 0;
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
        /* STUCK is judged only on blocks that began with every voice idle:
         * such a block must render exactly 0 (unless a key arrived during it). */
        if (allidle && !a_hold && M.n_on == on_at_start) for (int i = 0; i < CHUNK; ++i) if (vbuf[i] != 0.0f) { a_blocks_off++; break; }
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
    /* ONE BYTE IS ONE CRITICAL SECTION (320 us). v6 LOOPBACK FAILED 5 of 6
     * bytes on the board: the core-0 voice worker (priority 22) preempted
     * this task mid-byte, and a stretched bit is a wrong byte. */
    static portMUX_TYPE mux = portMUX_INITIALIZER_UNLOCKED;
    taskENTER_CRITICAL(&mux);
    uint32_t t0 = esp_cpu_get_cycle_count();
    for (int i = 0; i < 10; ++i) {
        while ((uint32_t)(esp_cpu_get_cycle_count() - t0) < i * BIT) { }
        gpio_set_level((gpio_num_t)PIN_MIDI, bits[i]);
    }
    while ((uint32_t)(esp_cpu_get_cycle_count() - t0) < 10 * BIT) { }
    gpio_set_level((gpio_num_t)PIN_MIDI, 1);
    taskEXIT_CRITICAL(&mux);
}

/* ----------------------------------------------------------------- PANEL
 * Five pots on ADC1 (ends to 3.3 V / GND, wiper to the pin). Read every 10 ms,
 * smoothed, and handed to panel.c only on a real move (0.4 % deadband), which
 * owns SHIFT (knob 1 as a two-position switch), the two banks and pick-up.
 * Started AFTER the self-test and loopback, which need the fixed defaults. */
static panel_t PANEL;
static volatile int panel_ready;
static volatile uint32_t touch_ms;        /* last knob move (knobs 1-4) or key: the screen dim clock */

/* No knobs (ADC failed, or the QEMU build): the panel still starts, at its
 * defaults, so the screen leaves the intro and the synth plays. */
static void panel_fallback(void)
{
    float pos[PANEL_KNOBS] = { 0.0f, 0.5f, 0.5f, 0.5f, 0.5f };
    panel_init(&PANEL, pos, (uint32_t)(esp_timer_get_time() / 1000));
    PANEL.changed = 0;
    panel_ready = 1;
}

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

/* 8 conversions averaged per read: the v6 board log showed +-3 % raw jitter
 * on an idle pot (a 100 nF cap from each wiper to GND removes most of it). */
#define KNOB_OVERSAMPLE 8
#define KNOB_IIR        0.10f
#define KNOB_DEADBAND   0.010f
static int knob_read(int k, float *x)
{
    int raw, acc = 0;
    for (int i = 0; i < KNOB_OVERSAMPLE; ++i) {
        if (adc_oneshot_read(knob_adc, knob_ch[k], &raw) != ESP_OK) return 0;
        acc += raw;
    }
    *x = acc / (4095.0f * KNOB_OVERSAMPLE);
    return 1;
}

static void knob_start(void)
{
    adc_oneshot_unit_init_cfg_t uc = { .unit_id = ADC_UNIT_1 };
    adc_oneshot_chan_cfg_t cc = { .atten = ADC_ATTEN_DB_12, .bitwidth = ADC_BITWIDTH_12 };
    if (adc_oneshot_new_unit(&uc, &knob_adc) != ESP_OK) { printf("KNOBS: ADC init failed\n"); panel_fallback(); return; }
    float pos[PANEL_KNOBS] = {0};
    for (int k = 0; k < PANEL_KNOBS; ++k) {
        adc_unit_t unit;
        if (adc_oneshot_io_to_channel(PIN_KNOBS[k], &unit, &knob_ch[k]) != ESP_OK || unit != ADC_UNIT_1 ||
            adc_oneshot_config_channel(knob_adc, knob_ch[k], &cc) != ESP_OK) {
            printf("KNOBS: GPIO %d is not usable on ADC1\n", PIN_KNOBS[k]); panel_fallback(); return;
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
        knob_avg[k] += (x - knob_avg[k]) * KNOB_IIR;
        float d = knob_avg[k] - knob_sent[k];
        if (d > KNOB_DEADBAND || d < -KNOB_DEADBAND || (knob_avg[k] < 0.002f && knob_sent[k] != 0.0f) ||
            (knob_avg[k] > 0.998f && knob_sent[k] != 1.0f)) {
            float v = knob_avg[k] < 0.002f ? 0.0f : (knob_avg[k] > 0.998f ? 1.0f : knob_avg[k]);
            knob_sent[k] = v;
            if (k < 4) touch_ms = now;                 /* knob 5 is unwired: it floats */
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

/* ---------------------------------------------------------------- BATTERY
 * GPIO 10 reads the battery through a 10k/10k divider (half the voltage),
 * calibrated in mV by the chip's own eFuse curve. WIRED OR NOT is measured,
 * not assumed: at boot the pin's pull-down is switched on -- a floating pin
 * falls to ~0 V, a divider holds it at ~1.6-2.1 V. CHRG and STDBY are the
 * charger's LED pins (open drain): LOW = charging / full. Both LOW is not a
 * real state (a clamped pin with the charger unplugged) and reads as "on
 * battery". */
static adc_channel_t bat_ch;
static adc_cali_handle_t bat_cali;
static int bat_ok;
static volatile int bat_state;
static volatile float bat_v;
static volatile int bat_pct;

static float bat_read_v(void)
{
    int raw, mv, acc = 0;
    for (int i = 0; i < 16; ++i) {
        if (adc_oneshot_read(knob_adc, bat_ch, &raw) != ESP_OK) return -1;
        if (adc_cali_raw_to_voltage(bat_cali, raw, &mv) != ESP_OK) return -1;
        acc += mv;
    }
    return acc / 16.0f * 2.0f / 1000.0f;               /* divider: x2 */
}

static void bat_start(void)
{
    adc_unit_t unit;
    gpio_config_t st = { .pin_bit_mask = (1ULL << PIN_CHRG) | (1ULL << PIN_STDBY), .mode = GPIO_MODE_INPUT,
                         .pull_up_en = GPIO_PULLUP_ENABLE };
    gpio_config(&st);
    adc_oneshot_chan_cfg_t cc = { .atten = ADC_ATTEN_DB_12, .bitwidth = ADC_BITWIDTH_12 };
    adc_cali_curve_fitting_config_t cf = { .unit_id = ADC_UNIT_1, .atten = ADC_ATTEN_DB_12, .bitwidth = ADC_BITWIDTH_12 };
    if (!knob_ok || adc_oneshot_io_to_channel(PIN_BAT, &unit, &bat_ch) != ESP_OK || unit != ADC_UNIT_1 ||
        adc_oneshot_config_channel(knob_adc, bat_ch, &cc) != ESP_OK ||
        adc_cali_create_scheme_curve_fitting(&cf, &bat_cali) != ESP_OK) {
        printf("BATT: ADC on GPIO %d unavailable -- no battery gauge\n", PIN_BAT); return;
    }
    gpio_pulldown_en((gpio_num_t)PIN_BAT);             /* the wired-or-not probe */
    vTaskDelay(pdMS_TO_TICKS(5));
    float probe = bat_read_v();
    gpio_pulldown_dis((gpio_num_t)PIN_BAT);
    vTaskDelay(pdMS_TO_TICKS(5));
    float v = bat_read_v();
    bat_ok = probe > 1.0f;
    if (bat_ok) { bat_v = v; bat_pct = ui_bat_pct(v); bat_state = UI_BAT_ON; }
    printf("BATT: GPIO %d %s (probe %.2f V, now %.2f V), CHRG %d STDBY %d\n", PIN_BAT,
           bat_ok ? "divider found" : "nothing wired -- gauge shows USB", probe, v,
           gpio_get_level((gpio_num_t)PIN_CHRG), gpio_get_level((gpio_num_t)PIN_STDBY));
}

/* every 500 ms: smooth the voltage (tau ~5 s); the percent shown moves only on
 * a 2-point change, so a note's load sag does not make it flicker */
static void bat_poll(void)
{
    if (!bat_ok) return;
    float v = bat_read_v();
    if (v < 0) return;
    bat_v += (v - bat_v) * 0.1f;
    int chg = !gpio_get_level((gpio_num_t)PIN_CHRG), full = !gpio_get_level((gpio_num_t)PIN_STDBY);
    int st = (chg && !full) ? UI_BAT_CHG : (full && !chg) ? UI_BAT_FULL : UI_BAT_ON;
    int p = ui_bat_pct(bat_v);
    if (st != bat_state || abs(p - bat_pct) >= 2) bat_pct = p;
    if (st != bat_state) printf("BATT: %s\n", st == UI_BAT_CHG ? "CHARGING" : st == UI_BAT_FULL ? "FULL" : "ON BATTERY");
    bat_state = st;
}
#else
static void knob_start(void) { printf("KNOBS: not in the QEMU build\n"); panel_fallback(); }
static void knob_poll(void) { }
static int bat_ok;
static volatile int bat_state, bat_pct;
static volatile float bat_v;
static void bat_start(void) { printf("BATT: not in the QEMU build\n"); }
static void bat_poll(void) { }
#endif

/* ------------------------------------------------------------------ OLED
 * Its own task on core 0 (the audio owns core 1). ~30 fps. The intro starts
 * AFTER the boot tests: v6's intro stuttered at the same point every boot,
 * which was the muted STRESS test loading core 0 (INFERRED from the timing;
 * the INTRO: line now measures the worst frame gap). The screen dims to 10 %
 * after 10 s without a knob move or a key: contrast, pre-charge and VCOMH in
 * one smooth fade (ui_dim / ui_dim_regs, host-tested). */
static int oled_addr;
static volatile uint32_t ui_frames;

static void ui_task(void *arg)
{
    static gfx_fb fb;
    static ui_anim an;
    uint32_t t0 = (uint32_t)(esp_timer_get_time() / 1000), prev = t0, gap = 0, heal_at = t0 + 2000;
    int intro_frames = 0, intro_done = 0;
    int dim = 0;                                         /* 0 full .. 255 dimmest */
    TickType_t wake = xTaskGetTickCount();
    touch_ms = t0;
    for (;;) {
        uint32_t now = (uint32_t)(esp_timer_get_time() / 1000);
        if (now - t0 < UI_INTRO_MS || !panel_ready) {
            if (now - prev > gap) gap = now - prev;
            intro_frames++;
            ui_intro(&fb, now - t0 < UI_INTRO_MS ? now - t0 : UI_INTRO_MS);
            if (panel_ready) ui_anim_init(&an, &PANEL);
        } else {
            if (!intro_done) {
                intro_done = 1;
                printf("INTRO: %d frames in %lu ms, worst frame gap %lu ms %s\n", intro_frames,
                       (unsigned long)(now - t0), (unsigned long)gap, gap < 60 ? "(smooth)" : "(STUTTER)");
                touch_ms = now;
            }
            ui_live lv = { M.gate ? M.last_note : -1, a_opeak / 16384.0f, {0},
                           bat_ok ? bat_state : UI_BAT_NONE, bat_v, bat_pct };
            for (int k = 0; k < MSQ_VOICES && k < 6; ++k)
                lv.vstate[k] = M.v[k].gate ? 2 : (M.v[k].level > 0.0f ? 1 : 0);
            ui_render(&fb, &PANEL, &lv, &an, now);
        }
        prev = now;
        /* dim: the level follows idle time down smoothly; a touch brings it
         * back to full in ~150 ms */
        int tgt = intro_done ? ui_dim(now - touch_ms) : 0;
        if (tgt < dim) dim = dim - tgt > 50 ? dim - 50 : tgt; else dim = tgt;
        uint8_t rc, rp, rv;
        ui_dim_regs((uint8_t)dim, &rc, &rp, &rv);
        oled_dim_regs(rc, rp, rv);
        if (oled_flush(&fb)) ui_frames++;
        if (intro_done && (int32_t)(now - heal_at) >= 0) {   /* self-heal: re-init every 2 s */
            heal_at = now + 2000;
            if (oled_heal() == 2) printf("OLED: display found late -- now on\n");
        }
        xTaskDelayUntil(&wake, pdMS_TO_TICKS(33));      /* a fixed frame clock, not "30 ms after the flush" */
    }
}

static void oled_start(void)
{
    static gfx_fb blank;
    oled_addr = oled_init(PIN_SDA, PIN_SCL);
    if (!oled_addr) { printf("OLED: no SSD1306 at 0x3C/0x3D on SDA %d SCL %d after %d tries (will keep looking)\n", PIN_SDA, PIN_SCL, oled_tries()); return; }
    gfx_clear(&blank);
    oled_flush(&blank);                                /* power-up RAM is noise: clear it now */
    printf("OLED: SSD1306 128x32 at 0x%02X (SDA %d, SCL %d), try %d\n", oled_addr, PIN_SDA, PIN_SCL, oled_tries());
}

static void ui_begin(void)
{
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
    /* v6 raised false STUCK / MUTE? alarms: the 1 s window mixed audio from
     * before a key change with the state after it. Now STUCK = a block that
     * BEGAN with every voice idle rendered a nonzero sample (counted in the
     * audio task, never a window guess); MUTE? = a key held through the whole
     * window and not one nonzero sample. */
    static uint32_t p_off_bad;
    static int p_gate;
    uint32_t off_bad = a_blocks_off;
    int allidle = a_allidle, gated = M.gate && p_gate;
    p_gate = M.gate;
    const char *sil;
    if (off_bad != p_off_bad)                 sil = "STUCK";
    else if (gated)                           sil = pk > 0 ? "SOUNDING" : "MUTE?";
    else if (M.gate || !allidle)              sil = pk > 0 ? "SOUNDING" : "RELEASING";
    else                                      sil = "SILENT";
    p_off_bad = off_bad;
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
               "peak=%d out=%d deficit=%ld cpu1=%lu%%/%lu%% (fx %lu%%) cpu0=%lu%% voices=%d split=%d/%d oled=%lu/%lu bat=%s%.2fV/%d%% | SIL: %s | HEALTH: %s\n",
               (unsigned long)M.n_bytes, (unsigned long)M.n_on, (unsigned long)M.n_off,
               (unsigned long)M.n_cc, (unsigned long)M.n_rt, (unsigned long)n_frame_err,
               (unsigned long)n_fifo_ovf, M.nheld, pk, op, (long)(deficit - base),
               (unsigned long)(cyc * 100u / (240000000u / (SR / CHUNK))),
               (unsigned long)(cycx * 100u / (240000000u / (SR / CHUNK))),
               (unsigned long)(f_cyc_max * 100u / (240000000u / (SR / CHUNK))),
               (unsigned long)(wcx * 100u / (240000000u / (SR / CHUNK))), msq_voices_sounding(&M),
               a_n1, a_nact - a_n1,
               (unsigned long)ui_frames, (unsigned long)oled_errors(),
               !bat_ok ? "none " : bat_state == UI_BAT_CHG ? "CHG " : bat_state == UI_BAT_FULL ? "FULL " : "",
               bat_ok ? bat_v : 0.0f, bat_ok ? bat_pct : 0, sil,
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
    uint32_t c1 = a_cyc_max, c0 = w_cyc_max, cf = f_cyc_max;
    int s1 = a_n1, s0 = a_nact - a_n1;
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
    printf("STRESS (muted) %d voices x %d osc, morph, chorus 255, reverb 255: core1 %u%% (FX alone %u%%)  core0 %u%% of the 5 ms block, "
           "split %d/%d voices, out peak %d/32767  %s\n", nv, MSQ_UNI, p1, (unsigned)(cf * 100ull / budget), p0,
           s1, s0, opk, ok ? "PASS" : "FAIL");
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
    uint32_t wc = msq_wave_crc();
    printf("WAVES: voice render check crc %08lx vs host %08lx: %s\n", (unsigned long)wc, (unsigned long)MSQ_WAVE_CRC,
           wc == MSQ_WAVE_CRC ? "MATCH (tri/saw/square/morphs == host samples)" : "MISMATCH");
    if (wc != MSQ_WAVE_CRC) fault("WAVE RENDER CRC MISMATCH");
    const void *hot[3] = { (const void *)msq_render_mask, (const void *)eb_master_render, (const void *)fx_process };
    int in_iram = 1;
    for (int i = 0; i < 3; ++i) in_iram &= esp_ptr_in_iram(hot[i]);
    printf("IRAM: msq_render_mask %p, eb_master_render %p, fx_process %p: %s\n", hot[0], hot[1], hot[2],
           in_iram ? "all in IRAM" : "NOT ALL IN IRAM (flash fetch on the audio path)");
    if (!in_iram) fault("AUDIO CODE NOT IN IRAM");
    oled_start();
    if (!audio_start()) { printf("FATAL: I2S start failed\n"); return; }
    int st = selftest();
    printf("SELFTEST: %s\n", st ? "PASS" : "FAIL");
    if (!st) fault("SELFTEST FAIL");
    if (!midi_start()) { printf("FATAL: MIDI UART start failed\n"); return; }
    midi_loopback();
    stress();
    knob_start();
    bat_start();
    ui_begin();
    printf("READY -- play notes. Any MIDI channel. Expect one NOTE line per key.\n");
    sil_and_stat(1);

    uint8_t b[128];
    int64_t next_stat = esp_timer_get_time() + 1000000, next_knob = 0, next_bat = 0;
    for (;;) {
        uart_event_t ev;
        if (xQueueReceive(midi_q, &ev, pdMS_TO_TICKS(10))) {
            if (ev.type == UART_DATA) {
                int n = uart_read_bytes(MIDI_UART, b, sizeof b, 0);
                for (int i = 0; i < n; ++i)
                    if (msq_byte(&M, b[i])) {
                        touch_ms = (uint32_t)(esp_timer_get_time() / 1000);
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
        if (esp_timer_get_time() >= next_bat) {
            bat_poll();
            next_bat = esp_timer_get_time() + 500000;
        }
        if (esp_timer_get_time() >= next_stat) {
            sil_and_stat(0);
            next_stat += 1000000;
        }
    }
}
