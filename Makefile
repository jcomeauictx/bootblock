# allow bashisms in Makefile recipes
SHELL := /bin/bash
all: extlinux.nopinsertedat*.boot.dsm zero.dat.bootable #fd13live.bochs
%.fd0: %.dat
	# tried using bximage but it always prompts for input even with -q
	# NOTE: floppies made this way won't boot, unless all needed code
	# is in the bootblock's 512 bytes. DO NOT USE.
	# just leaving here for reference.
	dd if=/dev/zero of=$@ bs=1024 count=1440
	dd if=$< of=$@ conv=notrunc
%.bochs: %.bxrc %.dat
	bochs -f $< -q
%.bochs: %.bxrc %.iso
	bochs -f $< -q
%.bochs: iso.bxrc %.iso
	PREFIX=$* bochs -f $< -q
%.bochs: hda.bxrc %
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
	@echo Disassembling $< >&2
	# problem is, if this recipe is called before the .dat file is created,
	# the wildcard will not be interpolated and we'll end up with a .dsm
	# file with an asterisk in it. so we fix that right now, since the
	# .dat file must already be there.
	sourcefile=$$(echo $<) && \
	 objdump --disassemble-all \
	 --target=binary \
	 --architecture=i386 \
	 --disassembler-options=addr16,data16 \
	 $< > $${sourcefile%.*}.dsm
%.nopinsertedat*.boot.dat: %.boot.dsm
	offset=$$(sed -n 's/^\s*0:.*\<jmp\>\s\+\(\S\+\)$$/\1/p' $<) && \
	 if ! grep '^\s*$$offset:' $<; then \
	  offset=$$((offset - 1)) && \
	  cp $*.boot.dat $*.nopinsertedat$$offset.boot.dat && \
	  ./insert_nop_at.sh $$offset $*.nopinsertedat$$offset.boot.dat; \
	 else \
	  echo No NOP needed at offset $$offset >&2; \
	 fi
bootsig.dat: sda1.boot.dat
	dd if=$< bs=1 count=2 skip=510 of=$@
%.bootable: % bootsig.dat mbr.bin
	dd if=mbr.bin of=$< conv=notrunc
	dd if=bootsig.dat bs=1 of=$< seek=510 conv=notrunc
zero.dat:
	dd if=/dev/zero of=$@ bs=$$((1024 * 1024)) count=30
cf:	cf2019.dat  # boot colorforth 2019
	qemu-system-i386 -fda $<
.PRECIOUS: *.dat *.dsm
