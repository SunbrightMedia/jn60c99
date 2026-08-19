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

/* WAS 64, RAISED TO 256 ON THE MEASUREMENT THIS COMMENT ASKED FOR.
 *
 * The original sizing argued from the INPUT rate: a DIN cable at 31,250 baud
 * carries about six note messages per 5.8 ms block, so 63 slots was ten blocks
 * of the worst case a wire can deliver. It ended "the argument for a bigger
 * queue would have to be a measured refusal count, and the counter that would
 * show it exists". The counter now shows it: **ref=542, hi=63 of 63** on the
 * b10 robot run.
 *
 * ⚠ THE SIZING ARGUMENT WAS AGAINST THE WRONG RATE. What fills this queue is
 * not how fast events ARRIVE, it is how long the consumer cannot DRAIN. Events
 * are taken only when no build owns the shadow, so a 15-step patch build or an
 * 11-block note build blocks the drain for that whole time -- and the budget
 * added in b10 makes those intervals LONGER by design, so 64 would have got
 * worse, not better. A queue must be sized against its worst DRAIN OUTAGE.
 *
 * 256 events x 4 bytes = 1 KB of internal RAM, 1.4 % of the ~74 KB free at
 * boot. 255 usable slots covers a 255-block outage -- 1.5 s -- against a
 * storm rate of one event per block, which is already far beyond a player.
 *
 * ⚠ IT IS STILL BOUNDED, AND THAT IS THE POINT, NOT THE SIZE. A queue that
 * cannot refuse is a queue that can grow without limit on the audio path,
 * which is rule 1. Refusals remain counted and latch HEALTH; this makes them
 * rare rather than impossible. The residual worst case is a permanently
 * over-budget patch, where a build takes up to starve_max blocks per step and
 * the outage can exceed 255 blocks -- and that is O4's steady-state overrun
 * showing up here, which is why `forced=` is the number to read beside it. */
#define JUNO_EVQ_N 256

#endif /* JUNO_EVENT_PORT_H */
