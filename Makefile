# allow bashisms in Makefile recipes
SHELL := /bin/bash
all: extlinux.nopinsertedat*.boot.dsm fd13live.bochs
%.fd0: %.dat
	# tried using bximage but it always prompts for input even with -q
	# NOTE: floppies made this way won't boot. DO NOT USE.
	# just leaving here for reference.
	dd if=/dev/zero of=$@ bs=1024 count=1440
	dd if=$< of=$@ conv=notrunc
%.bochs: %.bxrc %.dat
	bochs -f $< -q
%.bochs: %.bxrc %.iso
	bochs -f $< -q
%.bochs: iso.bxrc %.iso
	PREFIX=$* bochs -f $< -q
%.bochs: %.bxrc %.fd0
	bochs -f $< -q
buster64.dat: /dev/sda3
	ln -sf $< $@
eisa.dat: /dev/sda1
	ln -sf $< $@
%.qemu: %.fd0
	qemu-system-x86_64 -snapshot -fda $<
%.fd0.qemu: %.dat
	qemu-system-x86_64 -snapshot -fda $<
%.qemu: %.dat
	qemu-system-x86_64 -snapshot -hda $<
%.qemu: %.iso
	qemu-system-x86_64 -cdrom $<
%.dat:	%.s Makefile
	as -o $*.o $<
	objcopy --output-target binary $*.o $@
%.dsm: %.dat
	objdump --disassemble-all \
	 --target=binary \
	 --architecture=i386 \
	 --disassembler-options=addr16,data16 \
	 $< > $@
%.nopinsertedat*.boot.dat: %.boot.dsm
	offset=$$(sed -n 's/^\s*0:.*\<jmp\>\s\+\(\S\+\)$$/\1/p' $<) && \
	 cp $*.boot.dat $*.nopinsertedat$$offset.boot.dat && \
	 ./insert_nop_at.sh $$offset $*.nopinsertedat$$offset.boot.dat
