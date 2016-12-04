# Building a toolchain with GCC and Newlib

The *toolchain* consists of tools for compiling and linking source code into executable code that can run on the microcontroller. The toolchain itself runs on a desktop (Linux) computer, but creates programs which run on the microcontroller and is therefore said to be a *cross-compilation toolchain*.

The cross-compilation tools are highly similar to the typical development tools on Linux computers, but the names of all tools begin with `arm-none-eabi-` to distinguish them from the normal tools, for example `arm-none-eabi-gcc`.

This tutorial is far from unique. Many authors have documented this process, and this tutorial closely follows the steps outlined in ["Building the GNU ARM Toolchain"](https://blog.tan-ce.com/gcc-bare-metal/) by Tan Chee Eng. However this tutorial uses newer software versions, builds for a different ARM target and performs slightly different steps.

## x.1 Host system

This tutorial assumes a Linux x86_64 host computer running Debian 8 (jessie).
Other flavours of Linux will probably also work, but have not been tested.

Basic development tools and libraries for the host system are assumed to be installed.
On Debian, this can be achieved by installing the packages `build-essential`, `libgmp-dev`, `libmpfr-dev`, `libmpc-dev`.

## x.2 Preparation

Create a new directory where the toolchain will be installed. Set the environment variable `${TOOLCHAIN}` to point to this directory, for easy reference in the rest of this tutorial.

Also add the `bin` subdirectory of the toolchain to the system path. The later stages of toolchain construction depend on parts that were built earlier and expect to find these parts in the system search path.

```
mkdir /somewhere/arm-toolchain
TOOLCHAIN=/somewhere/arm-toolchain
PATH="/somewhere/arm-toolchain/bin:$PATH"
```

## x.2 Binutils

Binutils consists of the assembler, linker and utilities to manipulate object files.

Download binutils 2.27 from [http://ftp.gnu.org/gnu/binutils/binutils-2.27.tar.gz](http://ftp.gnu.org/gnu/binutils/binutils-2.27.tar.gz) .

```
tar xzvf binutils-2.27.tar.gz
mkdir b-binutils
cd b-binutils
../binutils-2.27/configure --prefix=${TOOLCHAIN} --target=arm-none-eabi --disable-nls --disable-multilib
make
make install
```

The target name `arm-none-eabi` has two purposes: it determines the prefix of the names of the cross-compilation tools (i.e. `arm-none-eabi-gcc`) *and* it specifies the target platform for which the tools will work. You can **not** arbitrarily change this name into something you like better, i.e. `--target=pretty-name` will not work.

When this process is complete, the assembler `arm-none-eabi-as`, linker `arm-none-eabi-ld` and some other tools should be available.

## x.3 GCC

GCC, the GNU Compiler Collection, provides the C and C++ compilers, a small runtime library and the C++ standard library.

To build GCC, the source code of Newlib must be available (**TODO: not sure, confirm this**).

Download GCC 6.2 from [ftp://ftp.nluug.nl/mirror/languages/gcc/releases/gcc-6.2.0/gcc-6.2.0.tar.bz2](ftp://ftp.nluug.nl/mirror/languages/gcc/releases/gcc-6.2.0/gcc-6.2.0.tar.bz2)

Download Newlib 2.4 from [ftp://sourceware.org/pub/newlib/newlib-2.4.0.tar.gz](ftp://sourceware.org/pub/newlib/newlib-2.4.0.tar.gz)

```
tar xzvf newlib-2.4.0.tar.gz
tar xjvf gcc-6.2.0.tar.bz2
mkdir b-gcc
cd b-gcc
../gcc-6.2.0/configure --prefix=${TOOLCHAIN} --target=arm-none-eabi --with-cpu=cortex-m7 --with-mode=thumb --with-float=softfp --with-fpu=fpv5-d16 --disable-multilib --enable-languages="c,c++" --with-newlib --with-headers=../newlib-2.4.0/newlib/libc/include
make
make install
```

Note: The option ```--with-float=softfp``` configures the compiler to work in ```softfp``` mode by default. It also determines the compiler mode used to build GCC and Newlib. In ```softfp``` mode, the compiler will use hardware floating point instructions but will never pass arguments or return values to subroutines via floating point registers. As a result, ```softfp``` code is binary compatible between FPU and non-FPU targets. Alternatives are ```--with-float=hard``` meaning the compiler will pass parameters via floating point registers, and ```--with-float=soft``` meaning the compiler will not use FPU instructions at all.

Note: The option ```--with-fpu=fpv5-d16``` configures the compiler to assume a double-precision FPU by default. It also determines the compiler mode used to build GCC and Newlib. An alternative is ```--with-fpu=fpv5-sp-d16``` for single-precision FPUs.

When this process is complete, the compilers `arm-none-eabi-gcc` and `arm-none-eabi-g++` should be available.

## x.4 Newlib

Newlib is a light-weight C library for embedded systems.

```
mkdir b-newlib
cd b-newlib
../newlib-2.4.0/configure --prefix=${TOOLCHAIN} --target=arm-none-eabi --disable-multilib --disable-newlib-supplied-syscalls
make
make install
```

When this process is complete, the C library `libc.a` should be available.

## x.5 GDB

GDB, the GNU Debugger, enables source level debugging of programs running on the microcontroller.
GDB can be used in combination with OpenOCD to inspect running programs, set breakpoints and step through code.

Download GDB 7.12 from [http://ftp.gnu.org/gnu/gdb/gdb-7.12.tar.xz](http://ftp.gnu.org/gnu/gdb/gdb-7.12.tar.xz)

```
tar xJvf gdb-7.12.tar.xz
mkdir b-gdb
cd b-gdb
../gdb-7.12/configure --prefix=${TOOLCHAIN} --target=arm-none-eabi
make
make install
```

## x.7 References

1. Tan Chee Eng, ["Building the GNU ARM Toolchain"](https://blog.tan-ce.com/gcc-bare-metal/), August 2012.
