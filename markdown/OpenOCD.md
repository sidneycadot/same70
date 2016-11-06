# 1. OpenOCD

OpenOCD is the *Open On-Chip Debugger*, a command-line tool to interact with microcontrollers
from a desktop machine.

# 1.1. Introduction

OpenOCD provides direct (read/write) access to a microcontroller's memory, its registers, and
its debugging facilities. On top of this, facilities such as flash programming, a bridge to GDB,
and facilities to reset the microcontroller are implemented.

OpenOCD provides a TCL interpreter to control its functionality. The OpenOCD distribution provides
TCL scripts that implement support for a variety of interfaces, boards, and microcontroller chips.

In addition to the TCL scripts provided with OpenOCD, it is possible to extend its functionality
by writing custom TCL scripts.

# 1.2. OpenOCD and the SAME70 XPlained board

The CMSIS-DAP interface that is the preferred means of communication with Cortex-M processors
is fully supported. We will use this interface to talk to the SAME70 microcontroller.

In recent versions of OpenOCD, the SAME70 microcontroller is supported, as well as the SAME70
XPlained development board.

The SAME70 XPlained development board features a so-called *embedded debugger*, which is a simple
microcontroller that acts as a bridge between the CMSIS-DAP port of the SAME70 and its own USB.
port. The embedded debugger's USB port is marked "Debug USB" on the development board; do not
confuse it with the "Target USB" port which connects directly to the main SAME70 microcontroller.

The job of the embedded debugger is to implement the bi-directional communication between the
Debug USB port (hooked up to a desktop machine) and the SAME70 microcontroller.

Since the `embedded debugger' is a simple microcontroller itself, it has its own firmware. The
firmware can be upgraded to the latest version using the latest version of Atmel Studio.

### 1.3. Building OpenOCD

OpenOCD is available as a Debian package. However, support for the SAME70 microcontroller and
the SAME70 XPlained development board are not yet available in the packaged version. Therefore,
we will build our own OpenOCD.

The build procedure and prerequisites for OpenOCD are documented in the README file of the
OpenOCD repository.

In particular, for CMSIS-DAP support, you will need to make sure that the `libusb` and
`libhidapi` libraries are installed; on Debian-based systems, install the `libusb-dev`
and `libhidapi-dev` packages to make sure they are available.

Next, we need to bring in the OpenOCD repository.  OpenOCD is hosted as a Git repository on
*SourceForge*. You can clone it as follows:

```
git clone git://git.code.sf.net/p/openocd/code openocd-code
```

Assuming all prerequisites are met, the steps shown below will build the sofware and install
the OpenOCD executable, man/info packes, and support files in the `/usr/local/` directory.
Use the `--prefix` option to the *configure* step to override the installation location, if desired.

Note: it is recommended to inspect the last 20 or so output lines of the *configure* step,
to ensure that CMSIS-DAP support will be built. If it says *no* there, something is missing
from the prerequisites. Fix that first and re-run the configure step, otherwise you will end
up with a version of OpenOCD that cannot be used to communicate with the SAME70 XPlained board.

```
cd openocd-code
./bootstrap
./configure
make
make install
cd ..
```

### 1.4. Installing UDEV rules

The OpenOCD distribution provides an UDEV configuration file that makes sure that appropriate
ownership and permissions are set up for USB-based adapters that OpenOCD knows about when they
are plugged in.

It is recommended that this configuration file be used; it ensures that OpenOCD can access
attached hardware as a regular user, provided they are member of the `plugdev` group.

This can be accomplished by executing:

```
sudo ln -s /usr/local/share/openocd/contrib/99-openocd.rules /etc/udev/rules.d/
```

### 1.5. Testing OpenOCD with the SAME70 XPlained board

With the version of OpenOCD just made, you should now be able to contact a SAME70 board that
is connected to a USB port. Try the following command:

```
openocd -f board/atmel_same70_xplained.cfg
```

This should show about 20 lines of debugging messages. If the message `CMSIS-DAP: Interface ready` is
among them, we know that everything works: OpenOCD has connected to the SAME70 microcontroller on the
board and can talk to it.

OpenOCD will normally keep running after making a connection. It will open several local TCP server
ports that can be used to contact the remote SAME70 microcontroller, e.g. via GDB, or via telnet
for interactive use.

We will use this to contact the microcontroller and set registers that will turn the green LED
on the development board on and off.

Pin 8 of the PIOC peripheral of the SAME70 controls the green LED on the development board. If
we put a '0' there, the led will go on; if we put a '1' there, the led will go off. (The LED pin
is *active-low*).

Assuming OpenOCD is still running after the previously given command, open a second terminal. Start
a telnet sessing to local port 4444 (`telnet localhost 4444`); you should see an OpenOCD prompt.

To control the LED, enter the following four OpenOCD commands:

```
mww 0x400e1200 0x100     # put PIOC pin 8 under control of the PIOC peripheral.
mww 0x400e1210 0x100     # configure PIOC pin 8 as output pin.
mww 0x400e1234 0x100     # set PIOC pin 8 as 0 (turns LED on).
mww 0x400e1230 0x100     # set PIOC pin 8 to 1 (turns LED off).
```

You can repeat either of the last two lines to play with the LED.

### 1.6 Some useful OpenOCD commands

(To Be Written)

### 1.7 Using GDB

(To Be Written)

### 1.8 References

1. OpenOCD website: [http://openocd.org/](http://openocd.org/)
2. OpenOCD documentation: [http://openocd.org/documentation/](http://openocd.org/documentation/)
3. OpenOCD GIT repository and README: [https://sourceforge.net/p/openocd/code/ci/master/tree/](https://sourceforge.net/p/openocd/code/ci/master/tree/)
