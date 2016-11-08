# 5. Startup sequence of the SAME70 microcontroller

In this section, we describe in detail the startup sequence of a SAME70 microcontroller.

## 5.1 The reset handler

The boot process of the SAME70 microcontroller starts at the *reset handler*, which is the second entry of the exception vector table. (The first entry is the initial stack pointer.)

At cold start, the exception vector table is assumed to be at memory location 0 (zero). However, a register is available to move the vector table to a different memory location.

In the SAME70, address 0x00000000 to 0x???????? can either be mapped to the embedded Flash memory or to an embedded ROM containing the SAM-BA monitor program.
If the embedded ROM is selected, the microcontroller will boot into the SAM-BA monitor program, that allows low-level interaction with the microcontroller using a simple serial
protocol on UART0. This is the factory default.

To boot from the embedded Flash memory, it is necessary to write a persistent the appropriate GPNVM (*general-purpose non-volatile memory*) bit. Consult the datasheet for details.

When compiling a SAME70 program, an ELF file is generated that contains a memory image. This memory image can be written to the SAME70's embedded Flash memory using a programming
tool such as OpenOCD. Apart from the user code (which starts from `main()`), the image will usually contain some code provided by the ASF that includes a default implementation of
a reset handler.

The following two files are important to understand the cold-start process of the SAME70:

```
$(ASFDIR)/sam/utils/cmsis/same70/include/same70q21.h
$(ASFDIR)/sam/utils/cmsis/same70/source/templates/gcc/startup_same70.c
```

The first file contains basic definitions and a memory map for the SAME70 processor and its peripherals. For example, it defines the memory layout of the exception vector table (struct `DeviceVectors`). It contains no code.

The second file contains the startup data and code. Specifically, it defines the `exception_table` variable (residing in the `.vector` link section), the `Reset_Handler` function, and the `Dummy_Handler` function.

The `exception_table` contains the initial stack pointer value; 15 system-level exception handlers; and 64 peripheral interrupt handlers. In the `exception_table`, most entries are initialized to either 0 (zero) in case they are *reserved*, or implemented as weak symbols that alias to the `Dummy_Handler`. The latter is simply a routine that enters an infinite loop; in case the SAME70 would ever enter such a routine, the processor will appear to hang. **It is therefore important that all exception and interrupt handler routines that can be expected to happen during operation are actually implemented.**

To implement an exception or interrupt handler, simply implement a function with the appropriate name and signature, such as `void SysTick_Handler(void)` or `void DACC_Handler(void)`. An actual implementation will *override* the default `Dummy_Handler` alias, because it is defined as a so-called *weak symbol* for the linker.

The only exception handler that has a functional default implementation is the `Reset_Handler`. Fortunately, it is short, at about 35 lines of easy-to-follow C code. The code does some initialization (described below), runs `main()`, and then enters an infinite loop. To ensure proper functionality, it is therefore important that the `main()` is written in such a way that it never returns; if it returns, the processor will simply appear to hang.

It is noted that the SAME70 has advanced clock management features that make it possible to switch between an internally generated low-quality clock (default) or higher-quality external crystal clock. At cold start, the SAM4E runs from its internally generated clock, at approximately 4 MHz. The reset handler runs from this 'preliminary' clock source; it is quite customary to switch to the desired runtime clock as the first step of `main()`. See the section about `sysclk_init()` described below.

The following steps are performed in the `Reset_Handler()`:

1. The `.text` segment is copied to the `.relocate` segment, unless they are identical.
2. The `.zero` segment is written with zero words.
3. The processor's vector pointer is re-assigned to point to the start of the `.fixed` segment.
4. If an FPU is used (preprocessor symbol __FPU_USED is defined), the `fpu_enable()` function is executed.
5. The `__libc_init_array()` function is executed, which is provided by Newlib.
6. The `main()` function is called without parameters. The result value, if any, is discarded.
7. An infinite loop (`while (1);`) is entered.

The `fpu_enable()` function is defined in $(ASFDIR)/sam/utils/fpu/fpu.h.

The `__libc_init_array()` function is defined in `$(NEWLIBDIR)/newlib/libc/misc/init.c`. The intention of this function is to call a number of functions, each with signature void(*)(void), prior to entering `main()`. These are used to implement e.g. constructor calls to global object instances in C++.

## 5.2 The `main()` function

In the examples provided by the ASF, the `main()` function always start by first calling the `sysclk_init()` function, followed by the `board_init()` function. Once both `sysclk_init()` and `board_init()` have completed, the system is properly initialized and the actual user code follows that implements the intended microcontroller functionality.

We will now discuss the implementation of these two functions for the SAME70 microcontroller and the SAME70 XPlained development board.

### 5.2.1 The `sysclk_init()` function

The `sysclk_init()` function is defined in `$(ASFDIR)/common/services/clock/same70/sysclk.c`.

This function is usually called as the very first step in the `main()` function.

The C or C++ file containing `main()` will usually include the file `$(ASFDIR)/common/services/clock/sysclk.h`, which is set up to include a file `conf_clock.h`, followed by the microprocessor-specific version of the header `sysclk.h` header file.

The file `conf_clock.h` is an ASF configuration header file, i.e., a header file that a program that uses the ASF needs to have to communicate configuration information to `deeper' layers of header- and source-files. ASF header- and source files assume that such files are available. The `conf' header files communicate configuration information to the ASF header- and source-files via preprocessor values.

In case of `conf_clock.h`, the configuration information to be provided consists of clock sources and (optionally) settings for the clock multipliers and divisors.

On the SAME70 XPlained board, a 12 MHz external crystal oscillator is present that serves as a source for a PLL. In this configuration, the `sysclk_init()` function performs the following steps:

1. system_init_flash(CHIP_FREQ_CPU_MAX)
2. pll_enable_source(CONFIG_PLL0_SOURCE);
3. pll_config_defaults(&pllcfg, 0);
4. pll_enable(&pllcfg, 0);
5. pll_wait_for_lock(0);
6. pmc_mck_set_division(CONFIG_SYSCLK_DIV);
7. pmc_switch_mck_to_pllack(CONFIG_SYSCLK_PRES);
8. SystemCoreClockUpdate();
9. system_init_flash(sysclk_get_cpu_hz());

### 5.2.2 The `board_init()` function

The `board_init()` function is defined in `$(ASFDIR)/sam/boards/same70_xplained/init.c`.

The intention of the ASF `board_init()` function is to initialize the SAME70 and its external peripherals (residing outside of the SAME70, but on the same PCB).

The following steps are implemented. Note that the behavior of these steps is configurable at compile time; most of these steps can be skipped.
Unfortunately, there is no externally documented specification, it is necessary to inspect the source code to see which configuration options are present.

1. The SAME70 watchdog timer (WDT) peripheral is disabled. If the watchdog timer is not disabled, the SANE70 will be reset 8 seconds after starting.
2. TCM memory will be enabled or disabled. In the former case, data from the `.itcm_lma` segment may be copied to the `.itcm` segment.
3. I/O ports (PIOx peripherals) are initialized.
4. The USART1 peripheral pins are configured.
5. The high-speed TWI (TWIHS0 peripheral)  pins are configured.
6. The CAN0 peripheral pins are configured.
7. The CAN1 peripheral pins are configured.
8. The SPI0 peripheral pins are configured.
9. The LED pins are configured as outputs.
10. The USART0 pins are configured for peripheral control (RXD, TXD, SCK, CTS, RTS).
11. The HSMCI peripheral pins are configured for peripheral control.
12. The EBI peripheral pins are configured for peripheral control (to control an ILI9488 LCD device, if present).
12. The USB peripheral pins are configured for peripheral control.
13. The SDRAMC peripheral pins are configured for peripheral control.
14. The SPI0 peripheral pins are configured for peripheral control (to control an ILI9488 LCD device, if present).
