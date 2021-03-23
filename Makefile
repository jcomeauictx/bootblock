all: extlinux.mbr.boot
%.fd0: %.dat
	# tried using bximage but it always prompts for input even with -q
	dd if=/dev/zero of=$@ bs=1024 count=1440
	dd if=$< of=$@ conv=notrunc
%.boot: bochsrc.bxrc %.fd0
	bochs -f $< -q
