
///////////////////////
// blink-barebones.c //
///////////////////////

#include <stdint.h>

// Segment stert/end addresses (calculated by linker).

extern uint32_t _sfixed;
extern uint32_t _efixed;
extern uint32_t _etext;
extern uint32_t _srelocate;
extern uint32_t _erelocate;
extern uint32_t _szero;
extern uint32_t _ezero;
extern uint32_t _sstack;
extern uint32_t _estack;

void Reset_Handler(void); // Forward declaration for exception_table.

// Exception Table

__attribute__ ((section(".vectors")))
const void * exception_table[80] = {
    (void*) (&_estack),
    (void*) Reset_Handler,
    (void*) (0UL)
};

void Reset_Handler(void)
{
    // Hard-coded peripheral addresses

    volatile uint32_t *PIOC_PER  = (uint32_t *)0x400e1200;
    volatile uint32_t *PIOC_OER  = (uint32_t *)0x400e1210;
    volatile uint32_t *PIOC_ODSR = (uint32_t *)0x400e1238;
    volatile uint32_t *PIOC_OWER = (uint32_t *)0x400e12a0;
    volatile uint32_t *PIOC_OWDR = (uint32_t *)0x400e12a4;
    volatile uint32_t *WDT_MR    = (uint32_t *)0x400e1854;

    *WDT_MR = 0x000080000; // Disable watchdog timer.

    *PIOC_PER = 0x100;
    *PIOC_OER = 0x100;
    *PIOC_OWDR = ~0;
    *PIOC_OWER = 0x100;

    // Loop indefinitely.

    for (;;)
    {
        // Blink the LED.

        *PIOC_ODSR  ^= 0x100;

        for (volatile uint32_t wait = 0; wait < 1000000; ++wait);
    }
}
