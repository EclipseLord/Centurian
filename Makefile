CC = gcc
AS = nasm 
LD = ld

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

CCFLAGS = -m64 -elf_amd64 -fno-PIC -g
AS_OBJ_FLAGS = -felf64 -F dwarf -g
LDFLAGS = -m elf_x86_64 -n -z max-page-size=0x1000 -Tsrc/kernel/kernel.ld

KERNEL_C = $(call rwildcard,src/kernel,*.c)
KERNEL_ASM = $(call rwildcard,src/kernel,*.S)

KERNEL_OBJ = $(KERNEL_ASM:.S=.o) $(KERNEL_C:.c=.o)
KERNEL_SYMS = $(KERNEL_OBJ:.o=.sym)


all: kernel kernel_symbols image 

%.o: %.c
	$(CC) -o $@ -c $< $(CCFLAGS)
%.o: %.S
	$(AS) -o $@ $(AS_OBJ_FLAGS) $<

%.sym: %.o
	objcopy --only-keep-debug $< $@

clean: 
	rm -f $(KERNEL_OBJ)
	rm -f $(KERNEL_SYMS)
	rm -rf ./out

kernel: $(KERNEL_OBJ)
	$(LD) $(LDFLAGS) -o ./out/iso/boot/kernel.bin $^

kernel_symbols: $(KERNEL_SYMS)
	mkdir -p ./out/syms/kernel
	find ./src/kernel -name "*.sym" -exec cp {} ./out/syms/kernel \;

image:
	mkdir -p ./out/iso/boot/grub
	cp src/kernel/grub.cfg.def out/iso/boot/grub/grub.cfg
	grub-mkrescue -o ./out/kernel.iso ./out/iso/
