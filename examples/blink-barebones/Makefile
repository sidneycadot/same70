
CC = arm-none-eabi-gcc
LD = arm-none-eabi-g++

CFLAGS  = -W -Wall -O3 -mcpu=cortex-m7 -mthumb -mfloat-abi=softfp -mfpu=fpv5-sp-d16 -g3 -std=gnu99

LDFLAGS = -mcpu=cortex-m7 -mthumb -Wl,--entry=Reset_Handler -Wl,--gc-sections -Wl,-T flash.ld

.PHONY : clean upload

blink-barebones.elf : blink-barebones.o
	$(LD) $(LDFLAGS) $(LDLIBS) $^ -o $@

blink-barebones.o : blink-barebones.c

upload : blink-barebones.elf
	openocd -f board/atmel_same70_xplained.cfg -c "program $< verify reset exit"

clean :
	$(RM) -r blink-barebones.o blink-barebones.elf
