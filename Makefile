############
#  KERNEL  #
############
KERNELDIR = src
include src/make.config

##################
#  ARCHITECTURE  #
##################
ARCH = i686
ARCHDIR = src/arch/$(ARCH)
include $(ARCHDIR)/make.config

###############
#  TOOLCHAIN  #
###############
CROSS = toolchain/i686-elf/bin/i686-elf-
CC = $(CROSS)gcc
CX = $(CROSS)g++
AS = nasm
LD = $(CROSS)ld

###########
#  FILES  #
###########
OBJECTS = $(ARCHDIR)/crti.s.o   \
		  $(ARCHDIR)/crtbegin.o \
		  $(KERNEL_ARCH_OBJS)   \
		  $(KERNEL_OBJECTS)     \
		  $(ARCHDIR)/crtend.o   \
		  $(ARCHDIR)/crtn.s.o

###########
#  FLAGS  #
###########
INCS = -Isrc/ -Ilibs/pdclib/include -Ilibs/pdclib/platform/nucleOS/include \
	   -L./toolchain/i686-elf/lib/gcc/i686-elf/8.2.0
CFLAGS = -ggdb -O3 -nostdlib -nostartfiles -nodefaultlibs -fstack-protector -Wall -Wextra -Werror -c $(INCS)
ASFLAGS = -f elf32
LDFLAGS = -T $(ARCHDIR)/link.ld -nostdlib -lgcc $(INCS)

###########
#  RULES  #
###########
OUT = iso/boot/kernel.elf

all: $(OUT)

$(CC):
	./toolchain/build_toolchain.sh

$(ARCHDIR)/crtbegin.o $(ARCHDIR)/crtend.o:
	TOBJ=`$(CC) $(CFLAGS) $(LDFLAGS) -print-file-name=$(@F)` && cp "$$TOBJ" $@

$(OUT): $(CC) $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $(OUT)

os.iso: $(OUT)
	xorrisofs -R                                \
				-b boot/grub/stage2_eltorito    \
				-no-emul-boot                   \
				-boot-load-size 4               \
				-A os                           \
				-input-charset utf8             \
				-quiet                          \
				-boot-info-table                \
				-o os.iso                       \
				iso

run: os.iso
	bochs -f bochsrc.txt -q

qemu: os.iso
	qemu-system-i386 -cdrom os.iso -serial mon:stdio -m 4G -soundhw ac97,pcspk \
	-enable-kvm -rtc base=localtime -gdb tcp::1234,ipv4

%.o: %.c
	$(CC) $(CFLAGS)  $< -o $@

%.cpp.o: %.cpp
	$(CX) $(CFLAGS)  $< -o $@

%.s.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -rf $(OUT) os.iso $(OBJECTS)
