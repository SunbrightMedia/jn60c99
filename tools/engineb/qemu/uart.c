/* uart.c -- minimal ESP32-S3 UART0 output for the QEMU harness.
 * The UART0 register block is at 0x60000000 (QEMU `info mtree`: esp_soc.uart).
 * FIFO at +0x0, STATUS at +0x1C with txfifo_cnt in bits [25:16].
 * Under QEMU the FIFO drains essentially instantly; the busy-wait is kept so
 * the same code would behave on silicon. No stdio, no newlib syscalls.
 */
#include <stdint.h>
#include "uart.h"

#define UART_FIFO   (*(volatile uint32_t *)0x60000000u)
#define UART_STATUS (*(volatile uint32_t *)0x6000001Cu)

void uart_putc(char ch)
{
    while (((UART_STATUS >> 16) & 0x3FFu) > 100u) { }
    UART_FIFO = (uint32_t)(uint8_t)ch;
}

void uart_puts(const char *s)
{
    while (*s) uart_putc(*s++);
}

void uart_u64(uint64_t v)
{
    char buf[21];
    int i = 20;
    buf[i] = 0;
    if (v == 0) { uart_putc('0'); return; }
    while (v) { buf[--i] = (char)('0' + (v % 10u)); v /= 10u; }
    uart_puts(&buf[i]);
}

void uart_hex32(uint32_t v)
{
    static const char h[] = "0123456789abcdef";
    int i;
    uart_puts("0x");
    for (i = 28; i >= 0; i -= 4) uart_putc(h[(v >> i) & 0xF]);
}
