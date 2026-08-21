/* s3_link_uart.h -- O6/D2: the CONTROL LINK on silicon, and the bring-up that
 * makes the first two-board flash diagnose itself.
 *
 * ⚑ THE ONE RULE THIS FILE OBEYS ABOVE ALL: A BOARD WITH NO JUMPER AND NO
 * WIRES MUST BEHAVE EXACTLY AS IT DOES TODAY.
 *
 * The user has a working single board. Every line below is arranged so that
 * an unstrapped board with nothing attached reads role A, finds no peer, says
 * so once, and plays all its voices exactly as this firmware already does. A
 * link that breaks the instrument you already have is not progress.
 *
 * That is why "no peer" is NOT a fault here. It is SINGLE-BOARD MODE. The
 * handshake's rejections only bite once a peer has actually answered -- at
 * which point a wrong answer really is a fault and really must mute.
 *
 * ==========================================================================
 * WHY THE UART AND NOT THE I2S LINK FIRST
 * ==========================================================================
 * The audio link (D1) and the control link (D2) share the same six wires and
 * the same ground. If both are brought up at once and the pair stays silent,
 * nothing says which wire is wrong. The UART is the cheap half: it needs two
 * wires, it is testable the moment they are soldered, and it PROVES THE
 * GROUND AND THE PAIRING before any audio depends on them.
 *
 * So this is deliberately staged, and the staging is the point:
 *   step 1 (here)  UART handshake -- proves ground, pins, roles, coefficients
 *   step 2 (next)  I2S audio link -- only after step 1 reports OK on a bench
 *
 * ⚠ UART2, NOT UART1. UART1 is MIDI IN on GPIO 18 and is already installed.
 * Taking UART1 would have silently stolen the MIDI port -- and MIDI is the
 * only proven external input this instrument has.
 */
#ifndef JUNO_S3_LINK_UART_H
#define JUNO_S3_LINK_UART_H

#include "s3_link.h"
#include "driver/uart.h"
#include "driver/gpio.h"
#include "esp_timer.h"
#include <string.h>
#include <stdio.h>

#define LINK_UART   UART_NUM_2
#define LINK_BAUD   115200

/* ---- state --------------------------------------------------------------- */
typedef struct {
    int            started;
    int            role;
    s3_role_cfg    cfg;
    s3_peer        peer;
    int            hs;            /* last s3_handshake_check result          */
    uint32_t       peer_acrc;     /* B's advertised audio-chunk CRC          */
    uint32_t       peer_ablk;
    int            acrc_fresh;    /* set per received frame, consumed by the
                                   * audio injection -- one compare per frame */
    int            said;          /* the verdict has been printed once       */
    unsigned long  sent, got, bad;
    int64_t        last_tx_us;
    unsigned char  rx[sizeof(s3_link_frame) * 4];
    int            rxn;
} s3_link;

static s3_link LINK;

/* ---- THE STRAP, read once, with the pull-up that defines the sense ------- */
static int s3_link_read_strap(void)
{
    gpio_config_t io = {
        .pin_bit_mask = 1ULL << S3_ROLE_PIN,
        .mode         = GPIO_MODE_INPUT,
        .pull_up_en   = GPIO_PULLUP_ENABLE,     /* unconnected reads HIGH = A */
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type    = GPIO_INTR_DISABLE,
    };
    if (gpio_config(&io) != ESP_OK) return 0;   /* fail SAFE: fail to chip A  */
    /* let the pull-up settle before believing the level: a floating pin read
     * immediately after configuration can return the previous bus state, and
     * a misread here silently turns the master into a slave. */
    esp_rom_delay_us(1000);
    return gpio_get_level((gpio_num_t)S3_ROLE_PIN) == 0;   /* low = strapped */
}

/* ⚑ O6/D3: THE STRAP MUST BE READ BEFORE THE BOOT RECALL, not at link start.
 *
 * The boot recall deals the CONDITION/UNISON scatter, and it deals it from
 * EB_DEVSEQ_VOICE_BASE. Link start happens AFTER boot recall (it needs the
 * console up), so reading the strap only there would leave chip B playing
 * chip A's scatter until its first patch change -- four seconds of the exact
 * defect D3 exists to prevent, invisible to every CRC because the base-0 key
 * would match the base-0 recall. s3_link_early() is called before the boot
 * burst; s3_link_start() reuses its answer rather than re-reading. */
static int s3_link_early_role = -1;

static int s3_link_early(void)
{
    s3_link_early_role = s3_role_of(s3_link_read_strap());
    return s3_link_early_role;
}

static int s3_link_start(void)
{
    uart_config_t cfg = {
        .baud_rate  = LINK_BAUD,
        .data_bits  = UART_DATA_8_BITS,
        .parity     = UART_PARITY_DISABLE,
        .stop_bits  = UART_STOP_BITS_1,
        .flow_ctrl  = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_DEFAULT,
    };
    memset(&LINK, 0, sizeof LINK);
    LINK.role = (s3_link_early_role >= 0) ? s3_link_early_role
                                          : s3_role_of(s3_link_read_strap());
    LINK.cfg  = s3_role_config(LINK.role);
    LINK.hs   = S3_HS_NO_PEER;

    if (uart_driver_install(LINK_UART, 512, 512, 0, NULL, 0) != ESP_OK) return 0;
    if (uart_param_config(LINK_UART, &cfg) != ESP_OK) return 0;
    if (uart_set_pin(LINK_UART, S3_LINK_UART_TX, S3_LINK_UART_RX,
                     UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE) != ESP_OK) return 0;
    LINK.started = 1;
    return 1;
}

static void s3_link_banner(void)
{
    printf("\n=== TWO-CHIP LINK (O6) ===\n");
    printf("LINK: strap GPIO %d reads %s -> THIS BOARD IS CHIP %s\n",
           S3_ROLE_PIN, (LINK.role == S3_ROLE_B) ? "LOW (jumpered)"
                                                 : "HIGH (unconnected)",
           s3_role_name(LINK.role));
    printf("LINK: this chip owns GLOBAL voices %d..%d of 6\n",
           LINK.cfg.voice_base, LINK.cfg.voice_base + LINK.cfg.voices - 1);
    printf("LINK: control UART%d on TX GPIO %d / RX GPIO %d at %d baud\n",
           LINK_UART, S3_LINK_UART_TX, S3_LINK_UART_RX, LINK_BAUD);
    printf("LINK: audio link pins BCLK %d  LRCK %d  DATA %d "
           "(NOT STARTED YET -- step 2)\n",
           S3_LINK_BCLK, S3_LINK_LRCK, S3_LINK_DATA);
    printf("LINK: wiring -> docs/engineb/TWO_CHIP_WIRING.md\n");
    printf("LINK: with NO peer this board runs SINGLE-BOARD, exactly as before.\n"
           "      That is not a fault and is not reported as one.\n");
}

/* Called once per block from the audio loop's tail. O(1), no allocation. */
static void s3_link_poll(int my_patch, unsigned long my_crc,
                         uint32_t my_acrc, uint32_t my_ablk)
{
    int64_t now;
    int n;
    if (!LINK.started) return;
    now = esp_timer_get_time();

    /* announce ourselves ~10x a second. Both chips do it; neither waits for
     * the other, so there is no start-order dependency and no deadlock if one
     * board is powered up minutes after the other. */
    if (now - LINK.last_tx_us > 100000) {
        s3_link_frame f;
        memset(&f, 0, sizeof f);
        f.m0 = S3_LINK_MAGIC0; f.m1 = S3_LINK_MAGIC1;
        f.role       = (unsigned char)LINK.role;
        f.voice_base = (unsigned char)LINK.cfg.voice_base;
        f.voices     = (unsigned char)LINK.cfg.voices;
        f.patch      = (unsigned short)my_patch;
        f.crc        = (uint32_t)my_crc;
        f.acrc       = my_acrc;
        f.ablk       = my_ablk;
        f.sum        = s3_link_sum(&f);
        uart_write_bytes(LINK_UART, (const char *)&f, sizeof f);
        LINK.last_tx_us = now;
        ++LINK.sent;
    }

    /* drain whatever arrived and resynchronise on the magic rather than
     * assuming frame alignment -- a wire connected mid-run starts anywhere */
    n = uart_read_bytes(LINK_UART, LINK.rx + LINK.rxn,
                        (int)(sizeof LINK.rx - (size_t)LINK.rxn), 0);
    if (n > 0) LINK.rxn += n;
    while (LINK.rxn >= (int)sizeof(s3_link_frame)) {
        s3_link_frame f;
        if (LINK.rx[0] != S3_LINK_MAGIC0 || LINK.rx[1] != S3_LINK_MAGIC1) {
            memmove(LINK.rx, LINK.rx + 1, (size_t)(--LINK.rxn));
            ++LINK.bad;
            continue;
        }
        memcpy(&f, LINK.rx, sizeof f);
        memmove(LINK.rx, LINK.rx + sizeof f,
                (size_t)(LINK.rxn -= (int)sizeof f));
        if (f.sum != s3_link_sum(&f)) { ++LINK.bad; continue; }
        ++LINK.got;
        LINK.peer.present    = 1;
        LINK.peer.role       = f.role;
        LINK.peer.patch      = f.patch;
        LINK.peer.voice_base = f.voice_base;
        LINK.peer.voices     = f.voices;
        LINK.peer.crc        = f.crc;
        if (f.acrc != LINK.peer_acrc || f.ablk != LINK.peer_ablk) {
            /* a NEW advertisement -- stale repeats must not re-verify */
            LINK.peer_acrc  = f.acrc;
            LINK.peer_ablk  = f.ablk;
            LINK.acrc_fresh = 1;
        }
        LINK.hs = s3_handshake_check(&LINK.cfg, my_patch, my_crc, &LINK.peer);
        if (!LINK.said) {
            LINK.said = 1;
            printf("\nLINK: PEER ANSWERED -- it is chip %s\n",
                   s3_role_name(LINK.peer.role));
            printf("LINK: handshake %s\n", s3_handshake_name(LINK.hs));
            if (LINK.hs == S3_HS_CRC_DIFFERS)
                printf("LINK: ⚠ both chips hold patch %d and built DIFFERENT\n"
                       "      coefficients. Same firmware? Same bank? This is\n"
                       "      the silent class of defect -- nothing else would\n"
                       "      have reported it.\n", my_patch);
        }
    }
}

static void s3_link_report(void)
{
    if (!LINK.started) return;
    if (!LINK.peer.present) {
        printf("LINK: role=%c  NO PEER (single-board, normal)  tx=%lu bad=%lu\n",
               'A' + LINK.role, LINK.sent, LINK.bad);
        return;
    }
    printf("LINK: role=%c peer=%c  hs=%s  gv=%d..%d peer=%d..%d  "
           "tx=%lu rx=%lu bad=%lu\n",
           'A' + LINK.role, 'A' + LINK.peer.role, s3_handshake_name(LINK.hs),
           LINK.cfg.voice_base, LINK.cfg.voice_base + LINK.cfg.voices - 1,
           LINK.peer.voice_base, LINK.peer.voice_base + LINK.peer.voices - 1,
           LINK.sent, LINK.got, LINK.bad);
}

#endif /* JUNO_S3_LINK_UART_H */
