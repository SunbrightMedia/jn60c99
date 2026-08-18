/* juno_event_port.h -- the ESP32-S3's settings for event/juno_event.h.
 *
 * The boundary is portable; the LOCK is not. This file is the whole of what
 * the S3 has to say about it, and it is deliberately tiny -- if a port needs
 * more than a lock and a size, the boundary has grown something it should not
 * have.
 *
 * WHY A portMUX AND NOT A MUTEX. The critical section is a handful of
 * instructions -- four byte stores and an index increment -- so a blocking
 * primitive would cost far more than the work it guards, and a mutex may
 * block, which nothing near the audio path may do. portENTER_CRITICAL_SAFE
 * spins on the mux and disables interrupts on THIS core only; it is valid from
 * a task or an ISR, which matters because a future panel or link source may
 * submit from an interrupt.
 *
 * ⚠ THE CONSUMER NEVER TAKES THIS. juno_event_drain() runs on core 0 inside
 * the audio block and takes no lock at all -- THE INVARIANT rule 1 forbids one
 * there. A producer holding the mux while drain runs costs the audio nothing:
 * drain reads the write index as it stands and takes the rest next block,
 * which is rule 3, late rather than lost. If anyone ever adds a lock to the
 * drain side, that is the defect, not this file.
 */
#ifndef JUNO_EVENT_PORT_H
#define JUNO_EVENT_PORT_H

#include "freertos/FreeRTOS.h"

extern portMUX_TYPE juno_evq_mux;

#define JUNO_EVQ_LOCK()   portENTER_CRITICAL_SAFE(&juno_evq_mux)
#define JUNO_EVQ_UNLOCK() portEXIT_CRITICAL_SAFE(&juno_evq_mux)

/* 64 events x 4 bytes = 256 bytes of internal RAM. Sized against the fastest
 * stream the inputs can produce: a DIN cable at 31,250 baud carries about six
 * note messages per 5.8 ms block, so 63 usable slots is ten blocks of the
 * worst case a wire can deliver. Free internal RAM at boot is ~74 KB, so this
 * is 0.3 % of it -- the argument for a bigger queue would have to be a
 * measured refusal count, and the counter that would show it exists. */
#define JUNO_EVQ_N 64

#endif /* JUNO_EVENT_PORT_H */
