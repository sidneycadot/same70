
//////////////////////////////
// getting-started : main.c //
//////////////////////////////

#include "asf.h"

#include <math.h>

static void configure_console(void)
{
    const usart_serial_options_t uart_serial_options =
    {
        .baudrate   = CONF_UART_BAUDRATE,
        .charlength = CONF_UART_CHAR_LENGTH,
        .paritytype = CONF_UART_PARITY,
        .stopbits   = CONF_UART_STOP_BITS
    };

    // Configure console UART.

    sysclk_enable_peripheral_clock(CONSOLE_UART_ID);
    stdio_serial_init(CONF_UART, &uart_serial_options);
}

int main(void)
{
    sysclk_init();
    board_init();

    configure_console();

    // Configure pin 8 of PIOC as output. It drives the green LED on the XPlained Pro board (active-low).

    PIOC->PIO_PER = PIO_PER_P8;
    PIOC->PIO_OER = PIO_OER_P8;

    // Loop indefinitely.

    for (unsigned i = 0;; ++i)
    {
        // Demonstrate serial I/O and floating point.

        printf("%10u --> %10f\r\n", i, sin(i));

        // Blink the LED.

        if ((i & 0x40) != 0)
        {
            PIOC->PIO_SODR = PIO_SODR_P8;
        }
        else
        {
            PIOC->PIO_CODR = PIO_CODR_P8;
        }
    }
}
