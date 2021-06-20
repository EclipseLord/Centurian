#!/bin/bash

make -j16 -l16 all
qemu-system-x86_64 -cdrom out/kernel.iso -s -S & disown
gdb -ex 'target remote 192.168.1.64:1234' \
    -ex 'set disassembly-flavor intel' \
    -ex 'set step-mode on' \
    -ex 'layout reg' \
    -ex 'directory out/' \
    -ex 'break *0x100000' \
    -ex 'continue'
