all: fd13live.bochs
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
