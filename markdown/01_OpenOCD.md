# 1. OpenOCD

OpenOCD is the *Open On-Chip Debugger*, an open source  command-line tool to interact with microcontrollers from a desktop machine.

The product is maintained at the [OpenOCD website](http://openocd.org/).

## 1.1. Introduction

OpenOCD provides direct (read/write) access to a microcontroller's memory, its registers, and its debugging facilities. On top of this, facilities such as flash programming, a bridge to GDB, and facilities to reset the microcontroller are implemented.

OpenOCD has a built-in TCL interpreter to control its functionality. The OpenOCD distribution provides TCL scripts that implement support for a variety of interfaces, development boards, and microcontroller chips.

In addition to the TCL scripts provided with OpenOCD, it is possible to extend its functionality by writing custom TCL scripts.

## 1.2. OpenOCD and the SAME70 XPlained board

The CMSIS-DAP interface as defined by ARM is the preferred way of communicating with a Cortex-M microcontroller, and it is fully supported by OpenOCD. We will use this interface to talk to the SAME70 microcontroller.

Recent versions of OpenOCD also provide TCL configuration scripts for the SAME70 chip and the SAME70 XPlained development board.

The SAME70 XPlained development board features a so-called *embedded debugger*, which is a simple microcontroller that acts as a bridge between the CMSIS-DAP port of the SAME70 and its own USB port. The embedded debugger's USB port is marked *Debug USB* on the development board; do not confuse it with the *Target USB* port that connects directly to the main SAME70 microcontroller.

The job of the embedded debugger is to implement bidirectional communication between the Debug USB port (hooked up to a desktop machine) and the SAME70 microcontroller.

Since the embedded debugger is a simple microcontroller itself, it has its own firmware. Its firmware can only be updated in using the latest version of Atmel Studio, so if you want to do that, you will need to install it. Note that Atmel Studio is Windows-only.

## 1.3. Building OpenOCD

OpenOCD is available as a Debian package. However, support for the SAME70 microcontroller and the SAME70 XPlained development board are not yet available in the packaged version. Therefore, we will build our own OpenOCD.

OpenOCD is hosted as a Git repository on *SourceForge*. You can clone it as follows:

```
git clone git://git.code.sf.net/p/openocd/code openocd-code
```

The build procedure and prerequisites for OpenOCD are documented in the README file of the OpenOCD repository.

In particular, for CMSIS-DAP support, you will need to make sure that the `libusb` and `libhidapi` libraries are installed; on Debian-based systems, install the `libusb-dev` and `libhidapi-dev` packages to make sure they are available.

Assuming all prerequisites are met, the steps shown below will build the software and install the OpenOCD executable, man/info pages, and support files in the `/usr/local/` directory. Use the `--prefix` option in the *configure* step to override the installation location, if desired.

```
cd openocd-code
./bootstrap
./configure
make
sudo make install
```

Note: it is recommended to inspect the last 20 or so output lines of the *configure* step, to ensure that CMSIS-DAP support will be included. If it says *no* there, something is missing from the prerequisites. Fix that first and re-run the configure step, otherwise you will end up with a version of OpenOCD that cannot be used to communicate with the SAME70 XPlained board.

## 1.4. Installing UDEV rules

The OpenOCD distribution provides an UDEV configuration file that makes sure that appropriate ownership and permissions are set up for USB-based adapters that OpenOCD knows about when they are plugged in.

It is recommended that this configuration file be used; it ensures that OpenOCD can access attached hardware as a regular user, provided they are member of the `plugdev` group.

Assuming OpenOCD is installed in `/usr/local`, this can be accomplished by executing:

```
sudo ln -s /usr/local/share/openocd/contrib/??-openocd.rules /etc/udev/rules.d/
```

## 1.5. Testing OpenOCD with the SAME70 XPlained board

With the version of OpenOCD just made, you should now be able to contact a SAME70 XPlained development board that is connected to a USB port of your desktop machine.

Make sure that the USB cable connects to the Debug port of the SAME70 XPlained board. If it is connected to the Target port, the following will not work.

Next, try the following command:

```
openocd -f board/atmel_same70_xplained.cfg
```

This should show about 20 lines of debugging messages. If the message `CMSIS-DAP: Interface ready` is among them, we know that everything works: OpenOCD has connected to the SAME70 microcontroller on the board and can talk to it.

OpenOCD will normally keep running after making a connection. It will open several local TCP server ports that can be used to contact the remote SAME70 microcontroller, e.g. via GDB, or via telnet for interactive use.

We will use this to contact the microcontroller and set registers that will turn the green LED on the development board on and off.

Pin 8 of the PIOC peripheral of the SAME70 controls the green LED on the development board. If we put a '0' there, the led will go on; if we put a '1' there, the led will go off. (The LED pin is *active-low*.)

Assuming OpenOCD is still running after the previously given command, open a second terminal. Start a telnet session to local port 4444 (`telnet localhost 4444`); you should see an OpenOCD prompt.

To control the LED, enter the following four OpenOCD commands (omit the comment starting at '#'). These commands write 32-bit values in registers of the memory-mapped PIOC peripheral:

```
# Put PIOC pin 8 under control of the PIOC peripheral.
mww 0x400e1200 0x100

# Configure PIOC pin 8 as an output pin.
mww 0x400e1210 0x100

# Set PIOC pin 8 as 0 (turns LED on).
mww 0x400e1234 0x100

# Set PIOC pin 8 to 1 (turns LED off).
mww 0x400e1230 0x100
```

You can repeat either of the last two lines to play with the LED.

## 1.6 Some useful OpenOCD commands

You can halt the SAME70 core by executing the 'halt' command.

You can reset the SAME70 core by executing the 'reset' command.

The SAME70 can be programmed to boot either from its built-in ROM (which runs the SAM-BA monitor program on UART0) or from its Flash memory. If the device is in ROM boot mode, it will not run code that is uploaded to its Flash memory.

To force the SAME70 to boot from Flash on the next reset or powerup:

```
# Set GPNVM bit #1 to boot from Flash.
mww 0x400e0c04 0x5a00010b
```

To force the SAME70 to boot from ROM (SAM-BA mode) on the next reset or powerup:

```
# Clear GPNVM bit #1 to boot from SAM-BA ROM.
mww 0x400e0c04 0x5a00010c
```

## 1.7 Using OpenOCD to upload executable images

## 1.8 Using OpenOCD for debugging with GDB

(To be written)


## 1.9 References

1. OpenOCD website: [http://openocd.org/](http://openocd.org/)
2. OpenOCD documentation: [http://openocd.org/documentation/](http://openocd.org/documentation/)
3. OpenOCD GIT repository and README: [https://sourceforge.net/p/openocd/code/ci/master/tree/](https://sourceforge.net/p/openocd/code/ci/master/tree/)
