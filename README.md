# SAME70

This project aims for in-depth exploration of ARM Cortex-M microcontrollers.

We will use an Atmel SAME70 (Cortex-M7) microcontroller development board for this:
the SAME70 XPlained board as manufactured by Atmel.


## OpenOCD

OpenOCD is used to access the Cortex-M processor on the development board using a standardized
CMSIS-DAP access port.

An embedded debugger chip is present on the XPlained Pro development board that takes care of
the bi-directional communication between the Debug USB port and the SAME70 microcontroller.

### Building OpenOCD

Modern versions of OpenOCD support the SAME70 microcontroller and the SAME70 Xplained Board
out of the box. Assuming such a version is not available in your particular OS, it is quite
easy to build OpenOCD.

First make sure you have all standard C build tools available on your system (compiler, autotools,
etc.)

Make sure the library 'libhidapi' is available on your system (both library and header files).
Assuming a Debian distribution, this can be achieved by executing the command:

```
sudo apt-get install libhidapi-dev
```

Next, clone the 'official' github mirror of OpenOCD to your machine:

```
git clone https://github.com/ntfreak/openocd
```

Next, execute the following steps:

```
cd openocd
./bootstrap
./configure
make
cd ..
```

### Using OpenOCD

With the version of OpenOCD just made, you should now be able to contact the SAME70 board.
You may have to execute this as root:

```
sudo openocd/src/openocd -s tcl -f openocd/board/atmel_same70_xplained.cfg
```

The default mode of operation of OpenOCD is to run as a daemon process. It will open several
local TCP ports that can be used to contact the remote SAME70 microcontroller, e.g. via GDB,
or via telnet for interactive use.

We will use this to contact the microcontroller and set registers that will turn the green LED
on the development board on and off.

Assuming OpenOCD is running after the previously given command, open a second terminal and enter
the following commands:

```
mww 0x400e1200 0x100     # put PIOC pin 8 under control of the PIOC peripheral.
mww 0x400e1210 0x100     # configure PIOC pin 8 as output pin.
mww 0x400e1234 0x100     # set  PIOC pin 8 as 0 (turns LED on).
mww 0x400e1230 0x100     # set  PIOC pin 8 to 1 (turns LED off).
```

You can repeat either of the last two lines to play with the LED.
