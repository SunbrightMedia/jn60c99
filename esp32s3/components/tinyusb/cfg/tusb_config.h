/* tusb_config.h -- TinyUSB configuration for the JUNO S3 instrument.
 *
 * ONE class: MIDI. No CDC, no MSC, no HID, no host. The console stays on the
 * OTHER USB-C socket (the UART bridge), so nothing here competes with it.
 *
 * ⚠ THE RISK THIS CARRIES, stated because it is a timing risk and this
 * firmware is a real-time audio engine: USB interrupts run on a core that also
 * renders audio. They are short, but they are not free. The board reports
 * `un=` and `gap=`; if either moves when USB is plugged in, that is this file's
 * doing and not the DSP's.
 */
#ifndef _TUSB_CONFIG_H_
#define _TUSB_CONFIG_H_

#define CFG_TUSB_RHPORT0_MODE   OPT_MODE_DEVICE
#define CFG_TUD_ENABLED         1
#define CFG_TUH_ENABLED         0

/* Full speed. The S3's internal PHY is full speed only. */
#define CFG_TUD_MAX_SPEED       OPT_MODE_FULL_SPEED

#ifndef CFG_TUSB_MEM_SECTION
#define CFG_TUSB_MEM_SECTION
#endif
#ifndef CFG_TUSB_MEM_ALIGN
#define CFG_TUSB_MEM_ALIGN      __attribute__ ((aligned(4)))
#endif

#define CFG_TUD_ENDPOINT0_SIZE  64

/* The classes. MIDI only -- every other one is off on purpose. */
#define CFG_TUD_CDC             0
#define CFG_TUD_MSC             0
#define CFG_TUD_HID             0
#define CFG_TUD_MIDI            1
#define CFG_TUD_VENDOR          0

/* 64-byte buffers: one full-speed bulk packet each way. A DAW sends a few
 * bytes per note; this is not a bandwidth problem and a larger buffer would
 * only add latency. */
#define CFG_TUD_MIDI_RX_BUFSIZE 64
#define CFG_TUD_MIDI_TX_BUFSIZE 64

#endif
