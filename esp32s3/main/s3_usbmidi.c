/* s3_usbmidi.c -- USB MIDI IN over the ESP32-S3's NATIVE USB socket.
 *
 * WHY. The DIN-socket path needs an optocoupler, four resistors and a diode.
 * The S3 has a native USB controller, so the instrument can instead BE a
 * class-compliant USB MIDI device: no parts, no driver, and a DAW can drive it
 * directly.
 *
 * ⚠ WHICH SOCKET. The S3 has TWO USB paths and only one of them can do this:
 *
 *   USB-Serial-JTAG   the console and the flashing port. A board that exposes
 *                     this through a bridge chip (CH340, CP210x) CANNOT do USB
 *                     MIDI on that connector, whatever the connector looks
 *                     like.
 *   USB-OTG           GPIO 19 and 20, the native controller. THIS one.
 *
 * This board has two USB-C sockets. The one that is NOT the console is the
 * native one. If the host sees no device, that is the first thing to swap --
 * it is a cable in the wrong hole, not a firmware fault.
 *
 * ⚠ WHAT IT COSTS, and it is a real-time risk rather than a cycle cost. USB
 * interrupts are serviced on a core that also renders audio. tud_task() runs
 * in its own low-priority task, NOT in the audio loop, for the same reason
 * printf was moved out of it (playbook 30, four recurrences). But the
 * interrupt itself cannot be moved. The board prints `un=` and `gap=`: if
 * either moves when the USB cable goes in, this file is the cause.
 *
 * WHAT IT DOES NOT DO. Device only, IN only, one cable port, no MIDI OUT, no
 * SysEx, no USB host. A USB keyboard plugged into the S3 will NOT work -- that
 * needs host mode, which is a different controller mode and is not built here.
 * The DAW, or a keyboard through a computer, is the supported path.
 */
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_private/usb_phy.h"
#include "esp_err.h"
#include "tusb.h"

/* The instrument's own note entry. Defined in juno_s3_listen.c; the UART MIDI
 * parser calls the same function, so the two inputs cannot diverge in their
 * velocity policy or their allocator handling. */
void s3_midi_event(int on, int note, int vel);

/* Counted so the board can say whether the host ever talked to it. A device
 * that enumerates and sends nothing looks identical to a dead cable. */
unsigned long usbmidi_pkts = 0;
static usb_phy_handle_t PHY;

/* ------------------------------------------------------------ descriptors
 * Hand-written rather than generated: the whole device is one MIDI interface
 * with one virtual cable, and a generator would be more code than the table.
 *
 * The VID/PID pair is Espressif's own test pair. It is NOT a registered ID for
 * this project and must not be sold under it. Stated here because an unowned
 * VID shipped in a product is a real problem, not a formality. */
#define USB_VID 0x303A          /* Espressif */
#define USB_PID 0x4001

static const tusb_desc_device_t DESC_DEVICE = {
    .bLength            = sizeof(tusb_desc_device_t),
    .bDescriptorType    = TUSB_DESC_DEVICE,
    .bcdUSB             = 0x0200,
    .bDeviceClass       = 0x00,
    .bDeviceSubClass    = 0x00,
    .bDeviceProtocol    = 0x00,
    .bMaxPacketSize0    = CFG_TUD_ENDPOINT0_SIZE,
    .idVendor           = USB_VID,
    .idProduct          = USB_PID,
    .bcdDevice          = 0x0100,
    .iManufacturer      = 0x01,
    .iProduct           = 0x02,
    .iSerialNumber      = 0x03,
    .bNumConfigurations = 0x01
};

enum { ITF_NUM_MIDI = 0, ITF_NUM_MIDI_STREAMING, ITF_NUM_TOTAL };
#define EPNUM_MIDI_OUT  0x01    /* host -> device: the notes */
#define EPNUM_MIDI_IN   0x81    /* device -> host: unused, required by the class */

#define CONFIG_TOTAL_LEN (TUD_CONFIG_DESC_LEN + TUD_MIDI_DESC_LEN)

static const uint8_t DESC_CFG[] = {
    TUD_CONFIG_DESCRIPTOR(1, ITF_NUM_TOTAL, 0, CONFIG_TOTAL_LEN, 0x00, 100),
    TUD_MIDI_DESCRIPTOR(ITF_NUM_MIDI, 0, EPNUM_MIDI_OUT, EPNUM_MIDI_IN, 64)
};

static const char *const DESC_STR[] = {
    (const char[]){ 0x09, 0x04 },   /* 0: English (US) */
    "project-ssx",                  /* 1: manufacturer */
    "JUNO-60 Engine B",             /* 2: product -- what the DAW shows */
    "000001",                       /* 3: serial */
    "JUNO-60 MIDI IN",              /* 4: the MIDI interface */
};

const uint8_t *tud_descriptor_device_cb(void)
{
    return (const uint8_t *)&DESC_DEVICE;
}

const uint8_t *tud_descriptor_configuration_cb(uint8_t index)
{
    (void)index;
    return DESC_CFG;
}

const uint16_t *tud_descriptor_string_cb(uint8_t index, uint16_t langid)
{
    static uint16_t buf[32];
    uint8_t len, i;
    (void)langid;

    if (index == 0) {
        memcpy(&buf[1], DESC_STR[0], 2);
        len = 1;
    } else {
        if (index >= sizeof DESC_STR / sizeof DESC_STR[0]) return NULL;
        {   const char *s = DESC_STR[index];
            len = (uint8_t)strlen(s);
            if (len > 31) len = 31;
            for (i = 0; i < len; ++i) buf[1 + i] = s[i];
        }
    }
    buf[0] = (uint16_t)((TUSB_DESC_STRING << 8) | (2 * len + 2));
    return buf;
}

/* ------------------------------------------------------------------ the task
 * Priority 2, on core 0, exactly like the reporter: it must never preempt the
 * audio loop, and the audio loop donates a tick once a second, so it gets to
 * run. Notes therefore arrive with up to one tick of latency on top of the
 * block latency. That is stated rather than hidden; if it is too slow to play,
 * the fix is a donated tick per block, not a higher priority. */
static void usbmidi_task(void *arg)
{
    (void)arg;
    for (;;) {
        tud_task();

        /* USB-MIDI carries 4-byte event packets: [cable|CIN, status, d1, d2].
         * The CIN nibble already tells us note-on from note-off, but the
         * STATUS byte is used instead so that this path and the UART path
         * decide the same way. A note-on with velocity 0 is a note-off, and
         * s3_midi_event applies that rule for both. */
        while (tud_midi_available()) {
            uint8_t p[4];
            if (tud_midi_packet_read(p) != true) break;
            ++usbmidi_pkts;
            {   uint8_t st = p[1] & 0xF0u;
                if (st == 0x90u)      s3_midi_event(1, p[2], p[3]);
                else if (st == 0x80u) s3_midi_event(0, p[2], p[3]);
            }
        }
        vTaskDelay(1);
    }
}

int s3_usbmidi_start(void)
{
    usb_phy_config_t pc = {
        .controller  = USB_PHY_CTRL_OTG,
        .target      = USB_PHY_TARGET_INT,
        .otg_mode    = USB_OTG_MODE_DEVICE,
        .otg_speed   = USB_PHY_SPEED_FULL,
    };
    if (usb_new_phy(&pc, &PHY) != ESP_OK) return 0;
    if (!tud_init(0)) return 0;
    if (xTaskCreatePinnedToCore(usbmidi_task, "usbmidi", 4096, NULL, 2, NULL, 0)
        != pdPASS) return 0;
    return 1;
}
