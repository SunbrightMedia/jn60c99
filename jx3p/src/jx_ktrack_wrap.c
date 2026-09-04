/* jx_ktrack_wrap.c -- the key-tracker entry wrappers, transcribed bit-literal.
 *
 *   0x357BC0  ON/OFF wrapper: set or clear the note's bit in the 128-bit
 *             held bitmap at +0x50, then dispatch on the mode at +0x10.
 *   0x357B20  OFF wrapper: clear the bit, then dispatch; mode 2 first asks
 *             the host (get50, param 0x31E) and only acts when it answers
 *             true with a nonzero value... (LITERAL: value presence gates
 *             the 0x355D60 call).
 *
 * The three engines live in jx_ktrack.c (jxk_355a60 / jxk_355ae0 /
 * jxk_355d00 / jxk_355d60). This file only mirrors the wrappers.
 */
#include <stdint.h>
#include "jx_ktrack.h"

/* 0x357BC0: rdx=note, r8b=on-flag; bit set/clear, then mode dispatch */
void jx_ktrack_gate(uint8_t *b, const jx_ktrack_cbs *cb, int note, int on,
                    int vel)
{
    uint32_t n = (uint32_t)(note & 0xFF);
    uint32_t *w = (uint32_t *)(b + 0x50) + (n >> 5);
    uint32_t m = 1u << (n & 0x1F);
    if (on) *w |= m; else *w &= ~m;
    switch (*(int32_t *)(b + 0x10)) {
    case 1:  jxk_355ae0(b, cb, (uint8_t)n, (uint8_t)vel); break;
    case 2:  jxk_355d00(b, cb, (uint8_t)n, (uint8_t)vel); break;
    default: jxk_355a60(b, cb, (uint8_t)n, (uint8_t)vel); break;
    }
}

/* 0x357B20: rdx=note; clear bit, then mode dispatch (vel forced 0) */
void jx_ktrack_ungate(uint8_t *b, const jx_ktrack_cbs *cb, int note)
{
    uint32_t n = (uint32_t)(note & 0xFF);
    uint32_t *w = (uint32_t *)(b + 0x50) + (n >> 5);
    *w &= ~(1u << (n & 0x1F));
    switch (*(int32_t *)(b + 0x10)) {
    case 1:
        jxk_355ae0(b, cb, (uint8_t)n, 0);
        break;
    case 2: {
        int32_t out = 0;
        if (cb->get50(cb->user, 4, 0x31E, &out) && out != 0)
            jxk_355d60(b, cb, (uint8_t)n, 0);
        break;
    }
    default:
        jxk_355a60(b, cb, (uint8_t)n, 0);
        break;
    }
}

/* the tape-friendly gate entries used by the differential harness */
void jx_ktrack_on(uint8_t *b, const jx_ktrack_cbs *cb, int note, int vel)
{ jx_ktrack_gate(b, cb, note, vel != 0, vel); }
void jx_ktrack_off(uint8_t *b, const jx_ktrack_cbs *cb, int note)
{ jx_ktrack_ungate(b, cb, note); }
