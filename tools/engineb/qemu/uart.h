#ifndef EBQ_UART_H
#define EBQ_UART_H
#include <stdint.h>
void uart_putc(char ch);
void uart_puts(const char *s);
void uart_u64(uint64_t v);
void uart_hex32(uint32_t v);
#endif
